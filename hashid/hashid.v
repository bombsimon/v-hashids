module hashid

import (
	math
)

const (
	version = '1.0.0'
	default_alphabet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'
	default_separators = 'cfhistuCFHISTU'
	default_salt = 'this is salt'
	default_min_hash_length = 0
	min_alphabet_length = 16
	ratio_separators = 3.5
	ratio_guards = 12.0
)

struct HashID {
	alphabet              []string
	salt                  []string
	separators            []string
	guards                []string
	min_length            int
	max_length_per_number int
}

pub fn new() HashID {
	return new_with_config(default_alphabet, default_salt, default_min_hash_length)
}

pub fn new_with_config(alphabet_str, salt_str string, min_length int) HashID {
	mut alphabet := alphabet_str.split('')
	mut separators := default_separators.split('')
	mut guards := []string
	salt := salt_str.split('')
	//
	if alphabet.len < min_alphabet_length {
		panic('alphabet to short')
	}
	//
	if ' ' in alphabet {
		panic('alphabet may not contain spaces')
	}
	// Alphabet should only contain unqiue characters
	alphabet = unique_chars(alphabet)
	// Alphabet should not contain separators, separators should only contain
	// chars in alphabet.
	separators = remove_not_in(separators, alphabet)
	alphabet = remove_in(alphabet, separators)
	separators = consistent_shuffle(separators, salt)
	//
	if separators.len == 0 || f32(alphabet.len / separators.len) > ratio_separators {
		mut separators_length := int(math.ceil(f32(alphabet.len) / ratio_separators))
		if separators_length == 1 {
			separators_length = 2
		}
		//
		if separators_length > separators.len {
			diff := separators_length - separators.len
			separators << alphabet[..diff]
			alphabet << alphabet[diff..]
		}
		else {
			separators = separators[..separators_length]
		}
	}
	//
	alphabet = consistent_shuffle(alphabet, salt)
	guard_count := int(math.ceil(f32(alphabet.len) / ratio_guards))
	//
	if alphabet.len < 3 {
		guards = separators[..guard_count]
		separators = separators[guard_count..]
	}
	else {
		guards = alphabet[..guard_count]
		alphabet = alphabet[guard_count..]
	}
	//
	return HashID{
		alphabet: alphabet
		salt: salt
		separators: separators
		guards: guards
		min_length: min_length
	}
}

pub fn (h HashID) encode(digits []int) string {
	if digits.len < 1 {
		panic('cannot encode empty list')
	}
	//
	for n in digits {
		if n < 0 {
			panic('cannot encode negative numbers')
		}
	}
	//
	mut alphabet_copy := copy_slice(h.alphabet)
	mut result := []string
	mut number_hash := 0
	//
	for i, num in digits {
		number_hash += (num % (i + 100))
	}
	//
	lottery := h.alphabet[number_hash % alphabet_copy.len]
	result << lottery
	//
	for i, _ in digits {
		mut num := digits[i]
		mut buf := lottery.split('')
		//
		buf << h.salt
		buf << alphabet_copy
		alphabet_copy = consistent_shuffle(alphabet_copy, buf[..alphabet_copy.len])
		last := hash(num, alphabet_copy)
		result << last
		//
		if i + 1 < digits.len {
			num %= buf[0][0] + i
			result << h.separators[num % h.separators.len]
		}
	}
	//
	if result.len < h.min_length {
		mut new_result := h.guards[(number_hash + result[0][0]) % h.guards.len].split('')
		new_result << result
		result = new_result
		//
		if result.len < h.min_length {
			result << h.guards[(number_hash + result[2][0]) % h.guards.len]
		}
	}
	//
	half_length := alphabet_copy.len / 2
	//
	for result.len < h.min_length {
		alphabet_copy = consistent_shuffle(alphabet_copy, alphabet_copy)
		mut new_result := alphabet_copy[half_length..]
		new_result << result
		new_result << alphabet_copy[0..half_length]
		result = new_result
		excess := result.len - h.min_length
		//
		if excess > 0 {
			result[(excess / 2)..h.min_length]
		}
	}
	//
	return result.join('')
}

pub fn (h HashID) decode(hash string) []int {
	mut result := []int
	mut breakdown := exchange_in(hash.split(''), h.guards, ' ')
	mut array := breakdown.join('').split(' ')
	mut idx := 0
	//
	if array.len == 2 || array.len == 3 {
		idx = 1
	}
	//
	if breakdown.len > 0 {
		lottery := breakdown[0]
		breakdown = exchange_in(breakdown[1..], h.separators, ' ')
		array = breakdown.join('').split(' ')
		alphabet_copy := copy_slice(h.alphabet)
		//
		for i := 0; i < array.len; i++ {
			sub_hash := array[i]
			mut buffer := lottery.split('')
			buffer << h.salt
			buffer << alphabet_copy
			new_alphabet := consistent_shuffle(alphabet_copy, buffer[..alphabet_copy.len])
			result << unhash(sub_hash, new_alphabet)
		}
	}
	// Ensure we can encode our result to the given hash for sanity.
	if h.encode(result) != hash {
		println('Could not convert to old hash')
		return []
	}
	//
	return result
}

fn unhash(hash string, alphabet []string) int {
	mut result := 0
	//
	for _, c in hash.split('') {
		mut pos := -1
		//
		for i, letter in alphabet {
			if c == letter {
				pos = i
				break
			}
		}
		//
		if pos == -1 {
			panic('could not get index of letter in hash')
		}
		//
		result = result * alphabet.len + pos
	}
	//
	return result
}

fn hash(num int, alphabet []string) []string {
	mut num_copy := num
	mut result := ''
	//
	for num_copy > 0 {
		alphabet_part := alphabet[num_copy % alphabet.len]
		result = '$alphabet_part$result'
		num_copy = num_copy / alphabet.len
	}
	//
	return result.split('')
}

fn consistent_shuffle(str, salt []string) []string {
	if salt.len < 1 {
		return str
	}
	//
	mut index := 0
	mut integer_sum := 0
	mut shuffled := str[..]
	//
	for i := shuffled.len - 1; i > 0; i-- {
		if salt[index].len > 1 {
			panic('currently not supported with characters larger than one code point')
		}
		//
		integer := salt[index][0]
		integer_sum += integer
		//
		j := (integer + index + integer_sum) % i
		//
		s_i := shuffled[i]
		s_j := shuffled[j]
		shuffled[i] = s_j
		shuffled[j] = s_i
		//
		index = (index + 1) % salt.len
	}
	//
	return shuffled
}

fn unique_chars(chars []string) []string {
	mut m := map[string]bool
	for c in chars {
		m[c] = true
	}
	//
	mut unique := []string
	for c, _ in m {
		if c in unique {
			panic('duplicate charcater found in alphabet')
		}
		//
		if c == ' ' {
			continue
		}
		//
		unique << c
	}
	//
	return chars
}

fn exchange_in(str, replace []string, replace_with string) []string {
	mut str_copy := copy_slice(str)
	//
	for i, c in str {
		if c in replace {
			str_copy[i] = replace_with
		}
	}
	//
	return str_copy
}

fn remove_in(a, b []string) []string {
	mut final_arr := []string
	//
	for x in a {
		if x in b {
			continue
		}
		//
		final_arr << x
	}
	//
	return final_arr
}

fn remove_not_in(a, b []string) []string {
	mut final_arr := []string
	//
	for x in a {
		if !x in b {
			continue
		}
		//
		final_arr << x
	}
	//
	return final_arr
}

fn copy_slice(to_copy []string) []string {
	mut new := [''].repeat(to_copy.len)
	for i, v in to_copy {
		new[i] = v
	}
	//
	return new
}
