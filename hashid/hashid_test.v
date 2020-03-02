module hashid

fn test_new_with_config() {
	hid := new_with_config(default_alphabet, 'my salt', default_min_hash_length)
	println(hid.alphabet)
	println(hid.salt)
	println(hid.separators)
	println(hid.guards)
	// Set to false to debug
	assert 1 == 1
}

fn test_unique_chars() {
	assert array_eq(unique_chars('abc'.split('')), 'abc'.split(''))
	assert array_eq(unique_chars('aaabbcc'.split('')), 'abc'.split(''))
	assert array_eq(unique_chars('aaaaaabbccccaaa'.split('')), 'abc'.split(''))
	assert array_eq(unique_chars('abc123abc123'.split('')), '123abc'.split(''))
}

fn test_remove_in() {
	assert array_eq(remove_in('abcde'.split(''), 'de'.split('')), 'abc'.split(''))
	assert array_eq(remove_in('abc'.split(''), 'abc'.split('')), [])
	assert array_eq(remove_in('abc'.split(''), 'xyz'.split('')), 'abc'.split(''))
}

fn test_remove_not_in() {
	assert array_eq(remove_not_in('abcd'.split(''), 'abc'.split('')), 'abc'.split(''))
	assert array_eq(remove_not_in('abc'.split(''), 'def'.split('')), [])
	assert array_eq(remove_not_in('aabbcc'.split(''), 'axy'.split('')), 'aa'.split(''))
}

fn test_shuffle() {
	assert array_eq(consistent_shuffle('abc'.split(''), 'my salt'.split('')), 'bca'.split(''))
}

fn array_eq(a, b []string) bool {
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
