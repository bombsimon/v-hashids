module hashids

/*
All tests output is generated with the existing Go implementation to ensure
    correctness between different implementations.
*/
fn test_new_with_config() {
	hid := new_with_config(default_alphabet, 'my salt', default_min_hash_length)
	assert hid.alphabet.join('') != default_alphabet
}

fn test_encode() {
	hid := new()
	assert hid.encode([33, 22, 33]) == 'ZqhOCd'
	assert hid.encode([333]) == '5Aj'
	hid_min_len := new_with_config(default_alphabet, 'this is salt', 30)
	assert hid_min_len.encode([33, 22, 33]) == 'KwX6ND91ylAaZqhOCdgQWzRMmLdrYb'
}

fn test_encode_one() {
	hid := new()
	assert hid.encode_one(333) == '5Aj'
}

fn test_encode_hex() {
	hid := new()
	assert hid.encode_hex('5a74d76ac89b05000e977baa') == 'YMTbf0soIycPsDCGfOHzFbi4SMUNTNUEUJUZU2ils5s7SJfP'
	assert hid.encode_hex('DEADbeef') == 'pqcJU1f2c7S4UZUY'
}

fn test_encode_custom_alphabet() {
	hid := new_with_config('abcdefghABCDEFGHxyzXYZ12345', 'salty', 10)
	assert hid.encode_one(33) == '3AZ25zd45G'
	assert hid.encode([101, 404, 500]) == 'BXyHAbDCzae'
}

fn test_decode() {
	hid := new()
	assert i_array_eq(hid.decode('ZqhOCd'), [33, 22, 33])
	assert i_array_eq(hid.decode('5Aj'), [333])
	hid_min_len := new_with_config(default_alphabet, 'this is salt', 30)
	assert i_array_eq(hid_min_len.decode('KwX6ND91ylAaZqhOCdgQWzRMmLdrYb'), [33, 22, 33])
}

fn test_decode_one() {
	hid := new()
	assert hid.decode_one('5Aj') == 333
	assert hid.decode_one('ZqhOCd') == 33
}

fn test_decode_hex() {
	hid := new()
	assert hid.decode_hex('YMTbf0soIycPsDCGfOHzFbi4SMUNTNUEUJUZU2ils5s7SJfP') == '5a74d76ac89b05000e977baa'
	assert hid.decode_hex('pqcJU1f2c7S4UZUY') == 'deadbeef'
}

fn test_decode_custom_alphabet() {
	hid := new_with_config('abcdefghABCDEFGHxyzXYZ12345', 'salty', 10)
	assert hid.decode_one('3AZ25zd45G') == 33
	assert i_array_eq(hid.decode('BXyHAbDCzae'), [101, 404, 500])
}

fn test_consistent_shuffle() {
	assert array_eq(consistent_shuffle(string_to_slice('abc'), string_to_slice('my salt')),
		string_to_slice('bca'))
	assert array_eq(consistent_shuffle(string_to_slice('abcABC123'), string_to_slice('xxx')),
		string_to_slice('2AC1b3cBa'))
	// Ensure shuffle doesn't change the passed value in place.
	do_not_change_me := string_to_slice('abcdefABCDEF')
	do_not_change_me_orig := copy_slice(do_not_change_me)
	consistent_shuffle(do_not_change_me, string_to_slice('some salty salt'))
	assert array_eq(do_not_change_me, do_not_change_me_orig)
	if !array_eq(do_not_change_me, do_not_change_me_orig) {
		println('do not change me was: $do_not_change_me_orig')
		println('do not change me is:  $do_not_change_me')
	} else {
		print("i\'m just printing this due to https://github.com/vlang/v/issues/3420")
	}
}

fn test_custom_alphabets() {
	cases := ['cCsSfFhHuUiItT01', 'abdegjklCFHISTUc', 'abdegjklmnopqrSF', 'abdegjklmnopqrvwxyzABDEGJKLMNOPQRVWXYZ1234567890',
		'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890`~!@#$%^&*()-_=+\\|";:/?.>,<{[}]',
	]
	numbers := [1, 2, 3]
	for _, c in cases {
		hid := new_with_config(c, 'my salt', 0)
		encoded := hid.encode(numbers)
		decoded := hid.decode(encoded)
		assert i_array_eq(decoded, numbers)
	}
}

fn test_min_length() {
	cases := [0, 1, 10, 999, 1000]
	numbers := [1, 2, 3]
	for _, min_length in cases {
		hid := new_with_config(default_alphabet, 'my salt', min_length)
		encoded := hid.encode(numbers)
		decoded := hid.decode(encoded)
		assert i_array_eq(decoded, numbers)
	}
}

fn test_unique_chars() {
	assert array_eq(unique_chars(string_to_slice('abc')), string_to_slice('abc'))
	assert array_eq(unique_chars(string_to_slice('aaabbcc')), string_to_slice('abc'))
	assert array_eq(unique_chars(string_to_slice('aaaaaabbccccaaa')), string_to_slice('abc'))
	assert array_eq(unique_chars(string_to_slice('abc123abc123')), string_to_slice('abc123'))
}

fn test_exchange_in() {
	assert array_eq(exchange_in(string_to_slice('abcdeABCDE'), string_to_slice('bB'),
		'X'), string_to_slice('aXcdeAXCDE'))
	assert array_eq(exchange_in(string_to_slice('abc'), string_to_slice('abc'), 'f'),
		string_to_slice('fff'))
	assert array_eq(exchange_in(string_to_slice('abc'), string_to_slice('def'), 'X'),
		string_to_slice('abc'))
}

fn test_remove_in() {
	assert array_eq(remove_in(string_to_slice('abcde'), string_to_slice('de')), string_to_slice('abc'))
	assert array_eq(remove_in(string_to_slice('abc'), string_to_slice('abc')), [])
	assert array_eq(remove_in(string_to_slice('abc'), string_to_slice('xyz')), string_to_slice('abc'))
}

fn test_remove_not_in() {
	assert array_eq(remove_not_in(string_to_slice('abcde'), string_to_slice('abc')), string_to_slice('abc'))
	assert array_eq(remove_not_in(string_to_slice('abc'), string_to_slice('def')), [])
	assert array_eq(remove_not_in(string_to_slice('aabbcc'), string_to_slice('axy')),
		string_to_slice('aa'))
}

fn test_copy_slice() {
	assert array_eq(copy_slice(string_to_slice('abc')), string_to_slice('abc'))
	assert array_eq(copy_slice(string_to_slice('')), [])
}

fn array_eq(a []string, b []string) bool {
	if a.len != b.len {
		return false
	}
	for i, v in a {
		if v != b[i] {
			return false
		}
	}
	return true
}

fn i_array_eq(a []int, b []int) bool {
	if a.len != b.len {
		return false
	}
	for i, v in a {
		if v != b[i] {
			return false
		}
	}
	return true
}

fn string_to_slice(s string) []string {
	return s.split('')
}
