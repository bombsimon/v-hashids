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

    x := os.args[1..]
    n := x.map(it.int())
    encoded := hashid.new().encode(n)
    decoded := hashid.new().decode(encoded)

    println('given $n we encode to $encoded')

    println('decoding $encoded gives $decoded')
}
