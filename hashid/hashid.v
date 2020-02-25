module hashid

const (
    version = "1.0.0"
    default_alphabet = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    default_seps = "cfhistuCFHISTU"
    default_min_alphabet_length = 16
)

struct HashID {
    alphabet string
    min_length int
    salt string
}

pub fn new() HashID {
    return new_with_config(default_alphabet, 0, "")
}

pub fn new_with_config(alphabet string, min_length int, salt string) HashID {
    unique := unique_alphabet(alphabet)

    if unique.len < default_min_alphabet_length {
        panic("too short alphabet")
    }

    return HashID{
        alphabet: unique,
        min_length: min_length,
        salt: salt
    }
}

pub fn (h HashID) encode(digit int) string {
    return h.alphabet
}

fn unique_alphabet(alphabet string) string {
    mut m := map[string]bool

    for c in alphabet.split("") {
        m[c] = true
    }

    mut unique := []string

    for c, _ in m {
        if c == " " {
            continue
        }

        unique << c
    }

    unique.sort()

    return unique.join("")
}
