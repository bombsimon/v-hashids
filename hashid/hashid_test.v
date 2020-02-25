module hashid

fn test_new_with_config() {
    hid := new_with_config(
        default_alphabet,
        default_min_hash_length,
        "my salt"
    )

    assert hid.alphabet == remove_in(default_alphabet, default_seps)
    assert hid.min_length == default_min_hash_length
    assert hid.salt == "my salt"
}

fn test_unique_alphabet() {
    assert unique_alphabet("abc") == "abc"
    assert unique_alphabet("aaabbcc") == "abc"
    assert unique_alphabet("aaaaaabbccccaaa") == "abc"
    assert unique_alphabet("abc123abc123") == "123abc"
}

fn test_remove_in() {
    assert remove_in("abcde", "de") == "abc"
    assert remove_in("abc", "abc") == ""
    assert remove_in("abc", "xyz") == "abc"
}

fn test_remove_not_in() {
    assert remove_not_in("abcd", "abc") == "abc"
    assert remove_not_in("abc", "def") == ""
    assert remove_not_in("aabbcc", "axy") == "aa"
}
