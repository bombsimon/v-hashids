# Hashids

[v](https://vlang.io/) implementation of Hash [Hash ID](http://hashids.org)

**NOTE** This is in development and not yet completed.

## Usage

```v
module main

import (
	hashid
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
	hid := hashid.new()
	//
	encoded := hid.encode(n)
	decoded := hid.decode(encoded)
	//
	println('given $n we encode to $encoded')
	println('decoding $encoded gives $decoded')
}
```

## Testing

```sh
$ v test hashid
```
