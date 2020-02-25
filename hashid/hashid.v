module hashid

const (
    version = "1.0.0"
    default_alphabet = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    default_seps = "cfhistuCFHISTU"
    default_min_alphabet_length = 16
    default_min_hash_length = 0
    default_salt = ""
)

struct HashID {
    alphabet string
    seps string
    salt string
    min_length int
}

pub fn new() HashID {
    return new_with_config(default_alphabet, default_min_hash_length, default_salt)
}

pub fn new_with_config(alphabet string, min_length int, salt string) HashID {
    unique := unique_alphabet(alphabet)

    if unique.len < default_min_alphabet_length {
        panic("too short alphabet")
    }

    alphabet_without_seps := remove_in(unique, default_seps)
    seps_in_alphabet := remove_not_in(default_seps, unique)

    return HashID{
        alphabet: alphabet_without_seps,
        seps: seps_in_alphabet,
        salt: salt
        min_length: min_length,
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

fn remove_in(a, b string) string {
    a_arr := a.split("")
    b_arr := b.split("")
    mut final_arr := []string

    for x in a_arr {
        if x in b_arr {
            continue
        }

        final_arr << x
    }

    return final_arr.join("")
}

fn remove_not_in(a, b string) string {
    a_arr := a.split("")
    b_arr := b.split("")
    mut final_arr := []string

    for x in a_arr {
        if !x in b_arr {
            continue
        }

        final_arr << x
    }

    return final_arr.join("")
}
