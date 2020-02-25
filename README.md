# Hashids

[v](https://vlang.io/) implementation of Hash [Hash ID](http://hashids.org)

## Usage

```v
import hashid

fn main() {
    h := hashid.new().with_salt("my salt")
    h.encode(5544)  // xxx
}
```

## Testing

```sh
$ v test hash
```
