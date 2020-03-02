# Hashids

[v](https://vlang.io/) implementation of Hash [Hash ID](http://hashids.org)

**NOTE** This is in development and not yet completed.

## Usage

```v
import hashid

fn main() {
    h := hashid.new()
    encoded := h.encode([33, 22, 32])  // y5q8r
}
```

## Testing

```sh
$ v test hashid
```
