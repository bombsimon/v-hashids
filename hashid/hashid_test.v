module hashid

fn test_unique_alphabet() {
    assert unique_alphabet("abc") == "abc"
    assert unique_alphabet("aaabbcc") == "abc"
    assert unique_alphabet("aaaaaabbccccaaa") == "abc"
    assert unique_alphabet("abc123abc123") == "123abc"
}
