module main

import (
    hashid
    os
)

fn main() {
    if os.args.len < 2 {
        println("missing number as argument")
        return
    }

    h := hashid.new()
    encoded := h.encode(os.args[1].int())

    println(encoded)
}
