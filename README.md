# Aerospike Bloom filter UDF module (pure luajit iplementation)

![MIT license](https://img.shields.io/badge/license-MIT-blue.svg)

Storage based on probabilistic structure [Bloom filter](https://en.wikipedia.org/wiki/Bloom_filter)

Suitable for storing huge amount of data and quering if element is present or not

### Installation

`git clone --recursive`

```bash
echo "REGISTER MODULE 'pure-lua-bloom-filter/luaxxhash/luaxxhash.lua'" | aql
echo "REGISTER MODULE 'pure-lua-bloom-filter/bloom_filter.lua'" | aql
echo "REGISTER MODULE 'bloom.lua'" | aql
```

### Usage

Use Aerospike apply

Module: bloom

Method: add

Example in python:
```python
as_client.apply(key, "bloom", "add", ["bin", value, {}])) #returns 1 if not found else 0
```
### API

#### Add
Params: bin, value, conf
Adds value to bloom filter, when already present returns 0, otherwise 1.

Last param is conf, when empty defaults defined on first lines of the code are used.
Default size is **10000** elements with precision **0.01** and ttl **4** hours.
Configurations options are:
- items - count of elements
- probabilty - precision 0 > p > 1
- ttl - AS ttl (0 for never) 

#### Query
Params: bin, value
Returns 1 if value was found and 0 if not

#### Clear
params: bin
Clears whole bloom filter

### TODO

- [ ] Any ideas how to test this

### Development

Feel free to contribute with PR.

### Copyright and License

&copy; 2016 [Vít Listík](http://tivvit.cz)

Released under [MIT licence](https://github.com/tivvit/aerospike-pure-lua-bloom-filter/blob/master/LICENSE)
