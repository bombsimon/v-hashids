module main

import (
	hashids
	os
)

fn main() {
	if os.args.len < 2 {
		println('missing number as argument')
		return
	}
	//
	x := os.args[1..]
	n := x.map(it.int())
	hid := hashids.new()
	//
	encoded := hid.encode(n)
	decoded := hid.decode(encoded)
	//
	println('given $n we encode to $encoded')
	println('decoding $encoded gives $decoded')
}
