module hashids

import math

const (
	version                 = '0.1.0'
	default_alphabet        = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'
	default_separators      = 'cfhistuCFHISTU'
	default_salt            = 'this is salt'
	default_min_hash_length = 0
	min_alphabet_length     = 16
	ratio_separators        = 3.5
	ratio_guards            = 12.0
)

// HashID is the type holding the alphabet, salt, separators and guards.
struct HashID {
	alphabet   []string
	salt       []string
	separators []string
	guards     []string
	min_length int
}

// new will create a new instance of a HashID type to be used when encoding or
// decoding hashes. This will use default values for alphabet, salt and minimum
// hash length.
pub fn new() HashID {
	return new_with_config(default_alphabet, default_salt, default_min_hash_length)
}

// new_with_salt will create a HashID instance with a desired salt.
pub fn new_with_salt(salt string) HashID {
	return new_with_config(default_alphabet, salt, default_min_hash_length)
}

// new_with_config will create a HashID instance with desired alphabet, salt and
// minimum hash length.
pub fn new_with_config(alphabet_str string, salt_str string, min_length int) HashID {
	mut alphabet := alphabet_str.split('')
	mut separators := default_separators.split('')
	mut guards := []string{}
	salt := salt_str.split('')
	if alphabet.len < min_alphabet_length {
		panic('alphabet to short')
	}
	if ' ' in alphabet {
		panic('alphabet may not contain spaces')
	}
	// Alphabet should only contain unqiue characters
	alphabet = unique_chars(alphabet)
	// Separators should only contain characters in alphabet.
	separators = remove_not_in(separators, alphabet)
	// Alphabet should not contain characters in separators.
	alphabet = remove_in(alphabet, separators)
	separators = consistent_shuffle(separators, salt)
	if separators.len == 0 || f64(alphabet.len / separators.len) > ratio_separators {
		mut separators_length := int(math.ceil(f64(alphabet.len) / ratio_separators))
		if separators_length == 1 {
			separators_length = 2
		}
		if separators_length > separators.len {
			diff := separators_length - separators.len
			separators << alphabet[..diff]
			alphabet = alphabet[diff..]
		} else {
			separators = separators[..separators_length]
		}
	}
	alphabet = consistent_shuffle(alphabet, salt)
	guard_count := int(math.ceil(f64(alphabet.len) / ratio_guards))
	if alphabet.len < 3 {
		guards = separators[..guard_count]
		separators = separators[guard_count..]
	} else {
		guards = alphabet[..guard_count]
		alphabet = alphabet[guard_count..]
	}
	return HashID{
		alphabet: alphabet
		salt: salt
		separators: separators
		guards: guards
		min_length: min_length
	}
}

// encode_one will encode a single integer and return the hash as a string.
pub fn (h HashID) encode_one(digit int) string {
	return h.encode([digit])
}

// encode_hex will encode a hex string (a string representing a hexadecimal
// value) and return the hash as a string.
pub fn (h HashID) encode_hex(hex string) string {
	return h.encode(hex_to_int(hex))
}

// encode will encode a list of integers and return the hash as a string. The
// digits must all be positive and there must be at least one digit.
pub fn (h HashID) encode(digits []int) string {
	if digits.len < 1 {
		panic('cannot encode empty list')
	}
	for n in digits {
		if n < 0 {
			panic('cannot encode negative numbers')
		}
	}
	mut alphabet_copy := copy_slice(h.alphabet)
	mut result := []string{}
	mut number_hash := 0
	for i, num in digits {
		number_hash += (num % (i + 100))
	}
	lottery := h.alphabet[number_hash % alphabet_copy.len]
	result << lottery
	for i, _ in digits {
		mut num := digits[i]
		mut buf := lottery.split('')
		buf << h.salt
		buf << alphabet_copy
		alphabet_copy = consistent_shuffle(alphabet_copy, buf[..alphabet_copy.len])
		last := hash(num, alphabet_copy)
		result << last
		if i + 1 < digits.len {
			num %= last[0][0] + i
			result << h.separators[num % h.separators.len]
		}
	}
	if result.len < h.min_length {
		mut new_result := h.guards[(number_hash + result[0][0]) % h.guards.len].split('')
		new_result << result
		result = new_result
		if result.len < h.min_length {
			result << h.guards[(number_hash + result[2][0]) % h.guards.len]
		}
	}
	half_length := alphabet_copy.len / 2
	for result.len < h.min_length {
		alphabet_copy = consistent_shuffle(alphabet_copy, alphabet_copy)
		mut new_result := copy_slice(alphabet_copy[half_length..])
		new_result << result
		new_result << copy_slice(alphabet_copy[..half_length])
		result = new_result
		excess := result.len - h.min_length
		if excess > 0 {
			result = result[(excess / 2)..(excess / 2) + h.min_length]
		}
	}
	return result.join('')
}

// decode_one will decode a hash to a signle integer. Even if the hash
// represents multiple digits only the first one will be returned without
// yielding any errors.
pub fn (h HashID) decode_one(hash string) int {
	return h.decode(hash)[0]
}

// decode_hex will decode a hash and return the original hexadecimal
// representation as a string.
pub fn (h HashID) decode_hex(hash string) string {
	return int_to_hex(h.decode(hash))
}

// decode will decode a hash and return a list of integers they were encoded
// from.
pub fn (h HashID) decode(hash string) []int {
	mut result := []int{}
	mut breakdown := exchange_in(hash.split(''), h.guards, ' ')
	mut hashes := breakdown.join('').split(' ')
	mut idx := 0
	if hashes.len == 2 || hashes.len == 3 {
		idx = 1
	}
	hash_brakedown := hashes[idx].split('')
	if hash_brakedown.len > 0 {
		lottery := hash_brakedown[0]
		breakdown = exchange_in(hash_brakedown[1..], h.separators, ' ')
		hashes = breakdown.join('').split(' ')
		mut alphabet_copy := copy_slice(h.alphabet)
		for _, sub_hash in hashes {
			mut buffer := lottery.split('')
			buffer << h.salt
			buffer << alphabet_copy
			alphabet_copy = consistent_shuffle(alphabet_copy, buffer[..alphabet_copy.len])
			result << unhash(sub_hash, alphabet_copy)
		}
	}
	if h.encode(result) != hash {
		println('Could not convert to old hash')
		return []
	}
	return result
}

// unhash will reverse the hashing algoritm to calculate the integer value of a
// (sub) hash and return it's integer representation.
fn unhash(hash string, alphabet []string) int {
	mut result := 0
	for _, c in hash.split('') {
		mut pos := -1
		for i, letter in alphabet {
			if c == letter {
				pos = i
				break
			}
		}
		if pos == -1 {
			panic('could not get index of letter in hash')
		}
		result = result * alphabet.len + pos
	}
	return result
}

// hash will perform the hashing algoritm on the passed digit and return the
// hash as a slice of strings to make it easy to append the result to an
// existing string slice.
fn hash(num int, alphabet []string) []string {
	mut num_copy := num
	mut result := ''
	for num_copy > 0 {
		alphabet_part := alphabet[num_copy % alphabet.len]
		result = '$alphabet_part$result'
		num_copy = num_copy / alphabet.len
	}
	return result.split('')
}

// consistent_shuffle takes a string slice and a salt (as a string slie) and
// moves characters in the string slice in a consistent way toe nsure the same
// result every time.
fn consistent_shuffle(str []string, salt []string) []string {
	if salt.len < 1 {
		return str
	}
	mut index := 0
	mut integer_sum := 0
	mut shuffled := copy_slice(str)
	for i := shuffled.len - 1; i > 0; i-- {
		if salt[index].len > 1 {
			panic('currently not supported with characters larger than one code point')
		}
		integer := salt[index][0]
		integer_sum += integer
		j := (integer + index + integer_sum) % i
		s_i := shuffled[i]
		s_j := shuffled[j]
		shuffled[i] = s_j
		shuffled[j] = s_i
		index = (index + 1) % salt.len
	}
	return shuffled
}

// unique_chars will walk over a slice of strings and remove duplicates. Only
// the first occurrence will persist in the result.
fn unique_chars(chars []string) []string {
	mut m := map[string]bool{}
	mut unique := []string{}
	for c in chars {
		if m[c] {
			continue
		}
		if c == ' ' {
			continue
		}
		unique << c
		m[c] = true
	}
	return unique
}

// exchange_in takes two slices of strings where the first one is the target fo
// replacing and the second one is a list of characters to exchange. For every
// occurrence of charaters to replace they will be replaced with the third
// argument which is what to replace with.
// Example:
// exchange_in(['a', 'b', 'c'], ['b', 'c'], 'X') // ['a', 'X', 'X']
fn exchange_in(str []string, replace []string, replace_with string) []string {
	mut str_copy := copy_slice(str)
	for i, c in str {
		if c in replace {
			str_copy[i] = replace_with
		}
	}
	return str_copy
}

// remove_in takes two slices and removes every occurrence in the first slice if
// if they're present in the second slice.
fn remove_in(a []string, b []string) []string {
	mut final_arr := []string{}
	for x in a {
		if x in b {
			continue
		}
		final_arr << x
	}
	return final_arr
}

// remove_not_in takes two slices and removes every occurrence in the first
// slice if they're not present in the second slice.
fn remove_not_in(a []string, b []string) []string {
	mut final_arr := []string{}
	for x in a {
		if !(x in b) {
			continue
		}
		final_arr << x
	}
	return final_arr
}

// copy_slice creates a copy of a string slice.
fn copy_slice(to_copy []string) []string {
	mut new := [''].repeat(to_copy.len)
	for i, v in to_copy {
		new[i] = v
	}
	return new
}

// hex_to_int takes a string representation of a hexadecimal value and converts
// each position to it's integer representation. The return value is a list of
// integers.
fn hex_to_int(hex string) []int {
	mut numbers := []int{}
	for _, c in hex.split('') {
		mut b := int(c[0])
		if b >= int(`0`) && b <= int(`9`) {
			b -= int(`0`)
		} else if b >= int(`a`) && b <= int(`f`) {
			b -= int(`a`) - int(`A`)
			if b >= int(`A`) && b <= int(`F`) {
				b -= (int(`A`) - 0xA)
			}
		} else if b >= int(`A`) && b <= int(`F`) {
			b -= (int(`A`) - 0xA)
		} else {
			panic('invalid hex')
		}
		numbers << 0x10 + b
	}
	return numbers
}

// int_to_hex takes a list of integers and for each value it's hexadecimal
// equvivalent is added to the returned string.
fn int_to_hex(numbers []int) string {
	hex := '0123456789abcdef'.split('')
	mut result := []string{}
	for n in numbers {
		if n < 0x10 || n > 0x1f {
			panic('invalid number')
		}
		result << hex[n - 0x10]
	}
	return result.join('')
}
