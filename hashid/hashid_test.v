module hashid

fn test_new_with_config() {
	hid := new_with_config(default_alphabet, 'my salt', default_min_hash_length)
	assert hid.alphabet.join('') != default_alphabet
}

fn test_encode() {
	hid := new()
	assert hid.encode([33, 22, 33]) == 'ZqhOCd'
	assert hid.encode([333]) == '5Aj'
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

fn test_decode() {
	hid := new()
	assert i_array_eq(hid.decode('ZqhOCd'), [33, 22, 33])
	assert i_array_eq(hid.decode('5Aj'), [333])
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

fn test_consistent_shuffle() {
	assert array_eq(consistent_shuffle(_s('abc'), _s('my salt')), _s('bca'))
	assert array_eq(consistent_shuffle(_s('abcABC123'), _s('xxx')), _s('2AC1b3cBa'))
	// Ensure shuffle doesn't change the passed value in place.
	do_not_change_me := _s('abcdefABCDEF')
	do_not_change_me_orig := copy_slice(do_not_change_me)
	shuffled := consistent_shuffle(do_not_change_me, _s('some salty salt'))
	assert array_eq(do_not_change_me, do_not_change_me_orig)
	if !array_eq(do_not_change_me, do_not_change_me_orig) {
		println('do not change me was: $do_not_change_me_orig')
		println('do not change me is:  $do_not_change_me')
	}
}

fn test_unique_chars() {
	assert array_eq(unique_chars(_s('abc')), _s('abc'))
	assert array_eq(unique_chars(_s('aaabbcc')), _s('abc'))
	assert array_eq(unique_chars(_s('aaaaaabbccccaaa')), _s('abc'))
	assert array_eq(unique_chars(_s('abc123abc123')), _s('abc123'))
}

fn test_exchange_in() {
	assert array_eq(exchange_in(_s('abcdeABCDE'), _s('bB'), 'X'), _s('aXcdeAXCDE'))
	assert array_eq(exchange_in(_s('abc'), _s('abc'), 'f'), _s('fff'))
	assert array_eq(exchange_in(_s('abc'), _s('def'), 'X'), _s('abc'))
}

fn test_remove_in() {
	assert array_eq(remove_in(_s('abcde'), _s('de')), _s('abc'))
	assert array_eq(remove_in(_s('abc'), _s('abc')), [])
	assert array_eq(remove_in(_s('abc'), _s('xyz')), _s('abc'))
}

fn test_remove_not_in() {
	assert array_eq(remove_not_in(_s('abcde'), _s('abc')), _s('abc'))
	assert array_eq(remove_not_in(_s('abc'), _s('def')), [])
	assert array_eq(remove_not_in(_s('aabbcc'), _s('axy')), _s('aa'))
}

fn test_copy_slice() {
	assert array_eq(copy_slice(_s('abc')), _s('abc'))
	assert array_eq(copy_slice(_s('')), [])
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

fn i_array_eq(a, b []int) bool {
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

fn _s(s string) []string {
	return s.split('')
}
