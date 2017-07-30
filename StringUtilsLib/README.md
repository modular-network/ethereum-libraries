StringUtilsLib
=========================

[![Build Status](https://travis-ci.org/Majoolr/ethereum-libraries.svg?branch=master)](https://travis-ci.org/Majoolr/ethereum-libraries)
[![Join the chat at https://gitter.im/Majoolr/EthereumLibraries](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/Majoolr/EthereumLibraries?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)    

A library [provided by Arachnid](https://github.com/Arachnid "Arachnid's Github") and [forked here by Majoolr](https://github.com/Majoolr "Majoolr's Github") to provide internal string utility functions for smart contracts on an Ethereum network. Big thanks to Nick Johnson for allowing us to add
this to our collective library repository. The library is currently an exact copy
of the original however we are in the process of adding external functionality
for utf-8 byte arrays in contract storage.   

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Library Address](#library-address)
- [License and Warranty](#license-and-warranty)
- [How to install](#how-to-install)
  - [Truffle Installation](#truffle-installation)
    - [Manual install:](#manual-install)
    - [Testing the library in truffle](#testing-the-library-in-truffle)
  - [solc Installation](#solc-installation)
    - [With standard JSON input](#with-standard-json-input)
    - [solc documentation](#solc-documentation)
  - [solc-js Installation](#solc-js-installation)
    - [Solc-js documentation](#solc-js-documentation)
- [Overview](#overview)
- [Examples](#examples)
  - [Basic usage](#basic-usage)
  - [Getting the character length of a string](#getting-the-character-length-of-a-string)
  - [Splitting a string around a delimiter](#splitting-a-string-around-a-delimiter)
  - [Splitting a string into an array](#splitting-a-string-into-an-array)
  - [Extracting the middle part of a string](#extracting-the-middle-part-of-a-string)
  - [Converting a slice back to a string](#converting-a-slice-back-to-a-string)
  - [Finding and returning the first occurrence of a substring](#finding-and-returning-the-first-occurrence-of-a-substring)
  - [Finding and returning the last occurrence of a substring](#finding-and-returning-the-last-occurrence-of-a-substring)
  - [Finding without modifying the original slice.](#finding-without-modifying-the-original-slice)
  - [Prefix and suffix matching](#prefix-and-suffix-matching)
  - [Removing a prefix or suffix](#removing-a-prefix-or-suffix)
  - [Finding and returning the string up to the first match](#finding-and-returning-the-string-up-to-the-first-match)
  - [Concatenating strings](#concatenating-strings)
- [Reference](#reference)
  - [toSlice(string self) internal returns (slice)](#toslicestring-self-internal-returns-slice)
  - [copy(slice self) internal returns (slice)](#copyslice-self-internal-returns-slice)
  - [toString(slice self) internal returns (string)](#tostringslice-self-internal-returns-string)
  - [len(slice self) internal returns (uint)](#lenslice-self-internal-returns-uint)
  - [empty(slice self) internal returns (bool)](#emptyslice-self-internal-returns-bool)
  - [compare(slice self, slice other) internal returns (int)](#compareslice-self-slice-other-internal-returns-int)
  - [equals(slice self, slice other) internal returns (bool)](#equalsslice-self-slice-other-internal-returns-bool)
  - [nextRune(slice self, slice rune) internal returns (slice)](#nextruneslice-self-slice-rune-internal-returns-slice)
  - [nextRune(slice self) internal returns (slice ret)](#nextruneslice-self-internal-returns-slice-ret)
  - [ord(slice self) internal returns (uint ret)](#ordslice-self-internal-returns-uint-ret)
  - [keccak(slice self) internal returns (bytes32 ret)](#keccakslice-self-internal-returns-bytes32-ret)
  - [startsWith(slice self, slice needle) internal returns (bool)](#startswithslice-self-slice-needle-internal-returns-bool)
  - [beyond(slice self, slice needle) internal returns (slice)](#beyondslice-self-slice-needle-internal-returns-slice)
  - [endsWith(slice self, slice needle) internal returns (bool)](#endswithslice-self-slice-needle-internal-returns-bool)
  - [until(slice self, slice needle) internal returns (slice)](#untilslice-self-slice-needle-internal-returns-slice)
  - [find(slice self, slice needle) internal returns (slice)](#findslice-self-slice-needle-internal-returns-slice)
  - [rfind(slice self, slice needle) internal returns (slice)](#rfindslice-self-slice-needle-internal-returns-slice)
  - [split(slice self, slice needle, slice token) internal returns (slice)](#splitslice-self-slice-needle-slice-token-internal-returns-slice)
  - [split(slice self, slice needle) internal returns (slice token)](#splitslice-self-slice-needle-internal-returns-slice-token)
  - [rsplit(slice self, slice needle, slice token) internal returns (slice)](#rsplitslice-self-slice-needle-slice-token-internal-returns-slice)
  - [rsplit(slice self, slice needle) internal returns (slice token)](#rsplitslice-self-slice-needle-internal-returns-slice-token)
  - [count(slice self, slice needle) internal returns (uint count)](#countslice-self-slice-needle-internal-returns-uint-count)
  - [contains(slice self, slice needle) internal returns (bool)](#containsslice-self-slice-needle-internal-returns-bool)
  - [concat(slice self, slice other) internal returns (string)](#concatslice-self-slice-other-internal-returns-string)
  - [join(slice self, slice[] parts) internal returns (string)](#joinslice-self-slice-parts-internal-returns-string)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Library Address

This library includes only internal functions at this time and therefore does not
need to be deployed for use.   

## License and Warranty
Licensed under the Apache License, Version 2.0 (the "License"). You may not use
this file except in compliance with the License. You may obtain a copy of the
License at   

      http://www.apache.org/licenses/LICENSE-2.0   

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for the
specific language governing permissions and limitations under the License.   

## How to install

### Truffle Installation

**version 3.4.6**

First install truffle via npm using `npm install -g truffle` .

Please [visit Truffle's installation guide](http://truffleframework.com/docs/getting_started/installation "Truffle installation guide") for further information and requirements.

#### Manual install:

This process will allow you to both link your contract to this library.

1. Place the StringUtilsLib.sol file in your truffle `contracts/` directory.
2. Amend the deployment .js file in your truffle `migrations/` directory as follows:

```js
var StringUtilsLib = artifacts.require("./StringUtilsLib.sol");
var YourContract = artifacts.require("./YourContract.sol");
...

module.exports = function(deployer) {
  deployer.deploy(YourContract);
};
``` 

#### Testing the library in truffle

The following process will allow you to `truffle test` this library in your project.

1. `git clone --recursive` or download the truffle directory.
   Each folder in the truffle directory correlates to the folders in your truffle installation.
2. [Start a testrpc node](https://github.com/ethereumjs/testrpc "testrpc's Github")   

**Note**: The tests are written using Truffle's testing mechanisms and they are gas hungry. When starting your testrpc node be sure to set the gas and starting ether options high to allow for consumption. For example:

   ```
   $ testrpc --gasLimit 0xffffffffffff --account="0xfacec5711eb0a84bbd13b9782df26083fc68cf41b2210681e4d478687368fdc3,100000000000000000000000000"
   ```

   Additionally you need to set the caller's gas limit high enough as well. This is done in the truffle.js file and it should look like this:

   ```js
    //imports and such
    ...
    module.exports = {
      networks: {
         development: {
           host: "localhost",
           port: 8545,
           gas: 470000000, //This is the important line
           network_id: "*",
         },
         ...
         //other network configurations
       }
    }
   ```
3. Run `truffle test`.

### solc Installation

**version 0.4.13**

For direction and instructions on how the Solidity command line compiler works [see the documentation](https://solidity.readthedocs.io/en/develop/using-the-compiler.html#using-the-commandline-compiler "Solc CLI Doc").

#### With standard JSON input

[The Standard JSON Input](https://solidity.readthedocs.io/en/develop/using-the-compiler.html#input-description "Standard JSON Input") provides an easy interface to include libraries. Include the following as part of your JSON input file:

```json
{
  "language": "Solidity",
  "sources":
  {
    "YourContract.sol": {
      ...
      ...
    },
    "StringUtilsLib.sol": {
      "content": "[Contents of StringUtilsLib.sol]"
    }
  },
  "settings":
  {
    ...
    "libraries": {}
  }
}
```
**Note**: Since this library currently uses all internal or private functions
the compiler will not create unlinked binary.

#### solc documentation

[See the solc documentation for further information](https://solidity.readthedocs.io/en/develop/using-the-compiler.html#using-the-commandline-compiler "Solc CLI Doc").

### solc-js Installation

**version 0.4.13**

Solc-js provides javascript bindings for the Solidity compiler and [can be found here](https://github.com/ethereum/solc-js "Solc-js compiler"). Please refer to their documentation for detailed use.

This version of Solc-js also uses the [standard JSON input](#with-standard-json-input) to compile a contract. The entry function is `compileStandardWrapper()` and you can create a standard JSON object explained under the [solc section](#with-standard-json-input) and incorporate it as follows:

```js
var solc = require('solc');
var fs = require('fs');

var file = fs.readFileSync('/path/to/YourContract.sol','utf8');
var StringUtilsLib = fs.readFileSync('./path/to/StringUtilsLib.sol','utf8');

var input = {
  "language": "Solidity",
  "sources":
  {
    "YourContract.sol": {
      "content": file
    },
    "StringUtilsLib.sol": {
      "content": StringUtilsLib
    }
  },
  "settings":
  {
    ...
    "libraries": {}
    ...
  }
}

var output = JSON.parse(solc.compileStandardWrapper(JSON.stringify(input)));

//Where the output variable is a standard JSON output object.
```

#### Solc-js documentation

[See the Solc-js documentation for further information](https://github.com/ethereum/solc-js "Solc-js compiler").


## Overview
Functionality in this library is largely implemented using an abstraction called a 'slice'. A slice represents a part of a string - anything from the entire string to a single character, or even no characters at all (a 0-length slice). Since a slice only has to specify an offset and a length, copying and manipulating slices is a lot less expensive than copying and manipulating the strings they reference.

To further reduce gas costs, most functions on slice that need to return a slice modify the original one instead of allocating a new one; for instance, `s.split(".")` will return the text up to the first '.', modifying s to only contain the remainder of the string after the '.'. In situations where you do not want to modify the original slice, you can make a copy first with `.copy()`, for example: `s.copy().split(".")`. Try and avoid using this idiom in loops; since Solidity has no memory management, it will result in allocating many short-lived slices that are later discarded.

Functions that return two slices come in two versions: a non-allocating version that takes the second slice as an argument, modifying it in place, and an allocating version that allocates and returns the second slice; see `nextRune` for example.

Functions that have to copy string data will return strings rather than slices; these can be cast back to slices for further processing if required.

## Examples
### Basic usage
    import "./StringUtilsLib.sol";

    contract Contract {
        using StringUtilsLib for *;

        // ...
    }

### Getting the character length of a string
    var len = "Unicode snowman ☃".toSlice().len(); // 17

### Splitting a string around a delimiter
    var s = "foo bar baz".toSlice();
    var foo = s.split(" ".toSlice());

After the above code executes, `s` is now "bar baz", and `foo` is now "foo".

### Splitting a string into an array
    var s = "www.google.com".toSlice();
    var delim = ".".toSlice();
    var parts = new string[](s.count(delim) + 1);
    for(uint i = 0; i < parts.length; i++) {
        parts[i] = s.split(delim).toString();
    }

### Extracting the middle part of a string
    var s = "www.google.com".toSlice();
    strings.slice memory part;
    s.split(".".toSlice(), part); // part and return value is "www"
    s.split(".".toSlice(), part); // part and return value is "google"

This approach uses less memory than the above, by reusing the slice `part` for each section of string extracted.

### Converting a slice back to a string
    var myString = mySlice.toString();

### Finding and returning the first occurrence of a substring
    var s = "A B C B D".toSlice();
    s.find("B".toSlice()); // "B C B D"

`find` modifies `s` to contain the part of the string from the first match onwards.

### Finding and returning the last occurrence of a substring
    var s = "A B C B D".toSlice();
    s.rfind("B".toSlice()); // "A B C B"

`rfind` modifies `s` to contain the part of the string from the last match back to the start.

### Finding without modifying the original slice.
    var s = "A B C B D".toSlice();
    var substring = s.copy().rfind("B".toSlice()); // "A B C B"

`copy` lets you cheaply duplicate a slice so you don't modify the original.

### Prefix and suffix matching
    var s = "A B C B D".toSlice();
    s.startsWith("A".toSlice()); // True
    s.endsWith("D".toSlice()); // True
    s.startsWith("B".toSlice()); // False

### Removing a prefix or suffix
    var s = "A B C B D".toSlice();
    s.beyond("A ".toSlice()).until(" D".toSlice()); // "B C B"

`beyond` modifies `s` to contain the text after its argument; `until` modifies `s` to contain the text up to its argument. If the argument isn't found, `s` is unmodified.

### Finding and returning the string up to the first match
    var s = "A B C B D".toSlice();
    var needle = "B".toSlice();
    var substring = s.until(s.copy().find(needle).beyond(needle));

Calling `find` on a copy of `s` returns the part of the string from `needle` onwards; calling `.beyond(needle)` removes `needle` as a prefix, and finally calling `s.until()` removes the entire end of the string, leaving everything up to and including the first match.

### Concatenating strings
    var s = "abc".toSlice().concat("def".toSlice()); // "abcdef"

## Reference

### toSlice(string self) internal returns (slice)
Returns a slice containing the entire string.

Arguments:

 - self The string to make a slice from.

Returns A newly allocated slice containing the entire string.

### copy(slice self) internal returns (slice)
Returns a new slice containing the same data as the current slice.

Arguments:

 - self The slice to copy.

Returns A new slice containing the same data as `self`.

### toString(slice self) internal returns (string)

Copies a slice to a new string.

Arguments:

 - self The slice to copy.

Returns A newly allocated string containing the slice's text.

### len(slice self) internal returns (uint)

Returns the length in runes of the slice. Note that this operation takes time proportional to the length of the slice; avoid using it in loops, and call `slice.empty()` if you only need to know whether the slice is empty or not.

Arguments:

 - self The slice to operate on.

Returns The length of the slice in runes.

### empty(slice self) internal returns (bool)

Returns true if the slice is empty (has a length of 0).

Arguments:

 - self The slice to operate on.

Returns True if the slice is empty, False otherwise.

### compare(slice self, slice other) internal returns (int)

Returns a positive number if `other` comes lexicographically after `self`, a negative number if it comes before, or zero if the contents of the two slices are equal. Comparison is done per-rune, on unicode codepoints.

Arguments:

 - self The first slice to compare.
 - other The second slice to compare.

Returns The result of the comparison.

### equals(slice self, slice other) internal returns (bool)

Returns true if the two slices contain the same text.

Arguments:

 - self The first slice to compare.
 - self The second slice to compare.

Returns True if the slices are equal, false otherwise.

### nextRune(slice self, slice rune) internal returns (slice)

Extracts the first rune in the slice into `rune`, advancing the slice to point to the next rune and returning `self`.

Arguments:

 - self The slice to operate on.
 - rune The slice that will contain the first rune.

Returns `rune`.

### nextRune(slice self) internal returns (slice ret)

Returns the first rune in the slice, advancing the slice to point to the next rune.

Arguments:

 - self The slice to operate on.

Returns A slice containing only the first rune from `self`.

### ord(slice self) internal returns (uint ret)

Returns the number of the first codepoint in the slice.

Arguments:

 - self The slice to operate on.

Returns The number of the first codepoint in the slice.

### keccak(slice self) internal returns (bytes32 ret)

Returns the keccak-256 hash of the slice.

Arguments:

 - self The slice to hash.

Returns The hash of the slice.

### startsWith(slice self, slice needle) internal returns (bool)

Returns true if `self` starts with `needle`.

Arguments:

 - self The slice to operate on.
 - needle The slice to search for.

Returns True if the slice starts with the provided text, false otherwise.

### beyond(slice self, slice needle) internal returns (slice)

If `self` starts with `needle`, `needle` is removed from the beginning of `self`. Otherwise, `self` is unmodified.

Arguments:

 - self The slice to operate on.
 - needle The slice to search for.

Returns `self`

### endsWith(slice self, slice needle) internal returns (bool)

Returns true if the slice ends with `needle`.

Arguments:

 - self The slice to operate on.
 - needle The slice to search for.

Returns True if the slice starts with the provided text, false otherwise.

### until(slice self, slice needle) internal returns (slice)

If `self` ends with `needle`, `needle` is removed from the end of `self`. Otherwise, `self` is unmodified.

Arguments:

 - self The slice to operate on.
 - needle The slice to search for.

Returns `self`

### find(slice self, slice needle) internal returns (slice)

Modifies `self` to contain everything from the first occurrence of `needle` to the end of the slice. `self` is set to the empty slice if `needle` is not found.

Arguments:

 - self The slice to search and modify.
 - needle The text to search for.

Returns `self`.

### rfind(slice self, slice needle) internal returns (slice)

Modifies `self` to contain the part of the string from the start of `self` to the end of the first occurrence of `needle`. If `needle` is not found, `self` is set to the empty slice.

Arguments:

 - self The slice to search and modify.
 - needle The text to search for.

Returns `self`.

### split(slice self, slice needle, slice token) internal returns (slice)

Splits the slice, setting `self` to everything after the first occurrence of `needle`, and `token` to everything before it. If `needle` does not occur in `self`, `self` is set to the empty slice, and `token` is set to the entirety of `self`.

Arguments:

 - self The slice to split.
 - needle The text to search for in `self`.
 - token An output parameter to which the first token is written.

Returns `token`.

### split(slice self, slice needle) internal returns (slice token)

Splits the slice, setting `self` to everything after the first occurrence of `needle`, and returning everything before it. If `needle` does not occur in `self`, `self` is set to the empty slice, and the entirety of `self` is returned.

Arguments:

 - self The slice to split.
 - needle The text to search for in `self`.

Returns The part of `self` up to the first occurrence of `delim`.

### rsplit(slice self, slice needle, slice token) internal returns (slice)

Splits the slice, setting `self` to everything before the last occurrence of `needle`, and `token` to everything after it. If `needle` does not occur in `self`, `self` is set to the empty slice, and `token` is set to the entirety of `self`.

Arguments:

 - self The slice to split.
 - needle The text to search for in `self`.
 - token An output parameter to which the first token is written.

Returns `token`.

### rsplit(slice self, slice needle) internal returns (slice token)

Splits the slice, setting `self` to everything before the last occurrence of `needle`, and returning everything after it. If `needle` does not occur in `self`, `self` is set to the empty slice, and the entirety of `self` is returned.

Arguments:

 - self The slice to split.
 - needle The text to search for in `self`.

Returns The part of `self` after the last occurrence of `delim`.

### count(slice self, slice needle) internal returns (uint count)

Counts the number of nonoverlapping occurrences of `needle` in `self`.

Arguments:

 - self The slice to search.
 - needle The text to search for in `self`.

Returns The number of occurrences of `needle` found in `self`.

### contains(slice self, slice needle) internal returns (bool)

Returns True if `self` contains `needle`.

Arguments:

 - self The slice to search.
 - needle The text to search for in `self`.

Returns True if `needle` is found in `self`, false otherwise.

### concat(slice self, slice other) internal returns (string)

Returns a newly allocated string containing the concatenation of `self` and `other`.

Arguments:

 - self The first slice to concatenate.
 - other The second slice to concatenate.

Returns The concatenation of the two strings.

### join(slice self, slice[] parts) internal returns (string)

Joins an array of slices, using `self` as a delimiter, returning a newly allocated string.

Arguments:

 - self The delimiter to use.
 - parts A list of slices to join.

Returns A newly allocated string containing all the slices in `parts`, joined with `self`.
