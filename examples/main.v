module main

import hashids
import os

const (
	alphabet        = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'
	salt            = 'this is salt'
	min_hash_length = 30
)

fn main() {
	if os.args.len < 2 {
		println('missing number as argument')
		return
	}

	x := os.args[1..]
	n := x.map(it.int())

	example_default_values(n)
	example_custom_values(n)
}

fn example_default_values(n []int) {
	hid := hashids.new()
	encoded := hid.encode(n)
	decoded := hid.decode(encoded)

	display_result(n, encoded, decoded, 0)
}

fn example_custom_values(n []int) {
	hid := hashids.new_with_config(alphabet, salt, min_hash_length)
	encoded := hid.encode(n)
	decoded := hid.decode(encoded)

	display_result(n, encoded, decoded, min_hash_length)
}

fn display_result(n []int, encoded string, decoded []int, min_length int) {
	println('with an instance with minimum length ${min_length}')
	println(' > given ${n} we encode to "${encoded}"')
	println(' > decoding "${encoded}" back gives ${decoded}')
	println('')
}
