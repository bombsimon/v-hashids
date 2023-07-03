# Hashids

[v](https://vlang.io/) implementation of [Hash IDs](http://hashids.org).

Heavily inspired by previous implementations but mainly
[go-hashids](https://github.com/speps/go-hashids) and
[hashids.rb](https://github.com/peterhellberg/hashids.rb) - thank you!

## Installation

Currently `vpm` and general package management is a work in progress. Until
then, clone this repository (as is or add as a submodule) to your project,
ensure the folder is named `hashids` like the module.

```sh
git clone https://github.com/bombsimon/v-hashids.git hashids
```

## Usage

```v
module main

import hashids
import os

fn main() {
	if os.args.len < 2 {
		println('missing number as argument')
		return
	}

	// Read command line arguments and convert to integer slice.
	x := os.args[1..]
	n := x.map(it.int())
	hid := hashid.new()

	// Encode the number(s)
	encoded := hid.encode(n)
	println('given $n we encode to $encoded')

	// Decode the hash to ensure we get the same numbers back.
	decoded := hid.decode(encoded)
	println('decoding $encoded gives $decoded')
}
```

See [examples](examples) for more details.

```sh
v run examples 1 2 3
```

### Create instance

You can create an instance of the module with default or custom values in three
separate ways.

```v
// Use all defaults
hid := hashids.new()
```

```v
// Use custom salt
hid := hashids.new_with_salt('my salt')
```

```v
// Use none defaults
alphabet := 'abcdefABCDEF0123456789'
salt := 'my salt'
min_length := 16
hid := hashids.newwith_config(alphabet, salt, min_length)
```

### Encode and Decode

```v
// Encode a slice of integer(s)
hash := hid.encode([1, 2, 3])

// Decode to slice of integers
numbers := hid.decode(hash)
```

```v
// Encode a single number
hash := hid.encode_one(1)

// Decode to a single integer
number := hid.decode_one(hash)
```

```v
// Encode hexadecimal string
hash := hid.encode_hex('f00ba12')

// Decode to hexadecimal string
hex := hid.decode_hex(hash)
```

## Testing

```sh
v test .
```

## Licence

MIT Licence. See [LICENCE](LICENCE)

## Disclaimer

I used this as a project to learn more about [vlang](https://vlang.io/). I don't
use this library personally so I won't find bugs myself. I've tried to create
reasonable test coverage where I compare to other implementations to ensure
stability. If you find a bug, please report an issue.

The version of `v` as of this writing is `V 0.4.0 2e9f8e6`. I intend to ensure
everything is working as long as possible.
