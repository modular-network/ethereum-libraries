StringUtilsLib
=========================

[![Build Status](https://travis-ci.org/Modular-Network/ethereum-libraries.svg?branch=master)](https://travis-ci.org/Modular-Network/ethereum-libraries)
[![Discord](https://img.shields.io/discord/102860784329052160.svg)](https://discord.gg/crxYSF2)   

A library [provided by Arachnid](https://github.com/Arachnid "Arachnid's Github") and [forked here by Modular](https://modular.network "Modular's Website") to provide internal string utility functions for smart contracts on an Ethereum network. Big thanks to Nick Johnson for allowing us to add
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
    - [toSlice(string) internal returns (StringUtilsLib.slice)](#toslicestring-internal-returns-stringutilslibslice)
      - [Arguments](#arguments)
      - [Returns](#returns)
    - [copy(StringUtilsLib.slice) internal returns (StringUtilsLib.slice)](#copystringutilslibslice-internal-returns-stringutilslibslice)
      - [Arguments](#arguments-1)
      - [Returns](#returns-1)
    - [toString(StringUtilsLib.slice) internal view returns (string)](#tostringstringutilslibslice-internal-view-returns-string)
      - [Arguments](#arguments-2)
      - [Returns](#returns-2)
    - [len(StringUtilsLib.slice) internal view returns (uint)](#lenstringutilslibslice-internal-view-returns-uint)
      - [Arguments](#arguments-3)
      - [Returns](#returns-3)
    - [empty(StringUtilsLib.slice) internal view returns (bool)](#emptystringutilslibslice-internal-view-returns-bool)
      - [Arguments](#arguments-4)
      - [Returns](#returns-4)
    - [compare(StringUtilsLib.slice, StringUtilsLib.slice) internal view returns (int)](#comparestringutilslibslice-stringutilslibslice-internal-view-returns-int)
      - [Arguments](#arguments-5)
      - [Returns](#returns-5)
    - [equals(StringUtilsLib.slice, StringUtilsLib.slice) internal view returns (bool)](#equalsstringutilslibslice-stringutilslibslice-internal-view-returns-bool)
      - [Arguments](#arguments-6)
      - [Returns](#returns-6)
    - [nextRune(StringUtilsLib.slice, StringUtilsLib.slice) internal returns (StringUtilsLib.slice)](#nextrunestringutilslibslice-stringutilslibslice-internal-returns-stringutilslibslice)
      - [Arguments](#arguments-7)
      - [Returns](#returns-7)
    - [nextRune(StringUtilsLib.slice) internal returns (StringUtilsLib.slice)](#nextrunestringutilslibslice-internal-returns-stringutilslibslice)
      - [Arguments](#arguments-8)
      - [Returns](#returns-8)
    - [ord(StringUtilsLib.slice) internal view returns (uint)](#ordstringutilslibslice-internal-view-returns-uint)
      - [Arguments](#arguments-9)
      - [Returns](#returns-9)
    - [keccak(StringUtilsLib.slice) internal view returns (bytes32)](#keccakstringutilslibslice-internal-view-returns-bytes32)
      - [Arguments](#arguments-10)
      - [Returns](#returns-10)
    - [startsWith(StringUtilsLib.slice, StringUtilsLib.slice) internal view returns (bool)](#startswithstringutilslibslice-stringutilslibslice-internal-view-returns-bool)
      - [Arguments](#arguments-11)
      - [Returns](#returns-11)
    - [beyond(StringUtilsLib.slice, StringUtilsLib.slice) internal returns (StringUtilsLib.slice)](#beyondstringutilslibslice-stringutilslibslice-internal-returns-stringutilslibslice)
      - [Arguments](#arguments-12)
      - [Returns](#returns-12)
    - [endsWith(StringUtilsLib.slice, StringUtilsLib.slice) internal view returns (bool)](#endswithstringutilslibslice-stringutilslibslice-internal-view-returns-bool)
      - [Arguments](#arguments-13)
      - [Returns](#returns-13)
    - [until(StringUtilsLib.slice, StringUtilsLib.slice) internal returns (StringUtilsLib.slice)](#untilstringutilslibslice-stringutilslibslice-internal-returns-stringutilslibslice)
      - [Arguments](#arguments-14)
      - [Returns](#returns-14)
    - [find(StringUtilsLib.slice, StringUtilsLib.slice) internal returns (StringUtilsLib.slice)](#findstringutilslibslice-stringutilslibslice-internal-returns-stringutilslibslice)
      - [Arguments](#arguments-15)
      - [Returns](#returns-15)
    - [rfind(StringUtilsLib.slice, StringUtilsLib.slice) internal returns (StringUtilsLib.slice)](#rfindstringutilslibslice-stringutilslibslice-internal-returns-stringutilslibslice)
      - [Arguments](#arguments-16)
      - [Returns](#returns-16)
    - [split(StringUtilsLib.slice, StringUtilsLib.slice, StringUtilsLib.slice) internal returns (StringUtilsLib.slice)](#splitstringutilslibslice-stringutilslibslice-stringutilslibslice-internal-returns-stringutilslibslice)
      - [Arguments](#arguments-17)
      - [Returns](#returns-17)
    - [split(StringUtilsLib.slice, StringUtilsLib.slice) internal returns (StringUtilsLib.slice)](#splitstringutilslibslice-stringutilslibslice-internal-returns-stringutilslibslice)
      - [Arguments](#arguments-18)
      - [Returns](#returns-18)
    - [rsplit(StringUtilsLib.slice, StringUtilsLib.slice, StringUtilsLib.slice) internal returns (StringUtilsLib.slice)](#rsplitstringutilslibslice-stringutilslibslice-stringutilslibslice-internal-returns-stringutilslibslice)
      - [Arguments](#arguments-19)
      - [Returns](#returns-19)
    - [rsplit(StringUtilsLib.slice, StringUtilsLib.slice) internal returns (StringUtilsLib.slice)](#rsplitstringutilslibslice-stringutilslibslice-internal-returns-stringutilslibslice)
      - [Arguments](#arguments-20)
      - [Returns](#returns-20)
    - [count(StringUtilsLib.slice, StringUtilsLib.slice) internal view returns (uint)](#countstringutilslibslice-stringutilslibslice-internal-view-returns-uint)
      - [Arguments](#arguments-21)
      - [Returns](#returns-21)
    - [contains(StringUtilsLib.slice, StringUtilsLib.slice) internal view returns (bool)](#containsstringutilslibslice-stringutilslibslice-internal-view-returns-bool)
      - [Arguments](#arguments-22)
      - [Returns](#returns-22)
    - [concat(StringUtilsLib.slice, StringUtilsLib.slice) internal view returns (string)](#concatstringutilslibslice-stringutilslibslice-internal-view-returns-string)
      - [Arguments](#arguments-23)
      - [Returns](#returns-23)
    - [join(StringUtilsLib.slice, StringUtilsLib.slice[]) internal view returns (string)](#joinstringutilslibslice-stringutilslibslice-internal-view-returns-string)
      - [Arguments](#arguments-24)
      - [Returns](#returns-24)

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

**version 4.0.1**

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

1. Clone or download the ethereum-libraries repository into its own directory on your computer. You can also use subversion to download just this truffle directory by running `svn checkout https://github.com/Modular-Network/ethereum-libraries/trunk/StringUtilsLib/truffle`.    
   Each folder in the truffle directory correlates to the folders in your truffle project.   
2. Go into the StringUtilsLib truffle directory on your computer and place each file in their respective directory in **your** truffle project.
3. [Download and start Ganache](http://truffleframework.com/ganache/ "Ganache Download")   
4. In your terminal go to your truffle project directory.   
5. Ensure the `development` object in your truffle.js file points to the same port Ganache uses, default is 7545.  
6. Go to 'Settings' in the top right corner of Ganache, click on 'Chain', and set 'Gas Limit' to 1000000000000000.    

   Additionally you need to set the caller's gas limit high enough as well. This is done in the truffle.js file and it should look like this:

   ```js
    //imports and such
    ...
    module.exports = {
      networks: {
         development: {
           host: "localhost",
           port: 7545, //Ensure this is set for Ganache
           gas: 470000000, //This is the important line
           network_id: "*",
         },
         ...
         //other network configurations
       }
    }
   ```
7. Run `truffle test`.

### solc Installation

**version 0.4.18**

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

**version 0.4.18**

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

#### toSlice(string) internal returns (StringUtilsLib.slice)   
*(StringUtilsLib.sol, line 95)*   

Returns a slice containing the entire string.

##### Arguments
**string** self The string to make a slice from.     

##### Returns
**StringUtilsLib.slice** A newly allocated slice containing the entire string.   

#### copy(StringUtilsLib.slice) internal returns (StringUtilsLib.slice)   
*(StringUtilsLib.sol, line 157)*    

Returns a new slice containing the same data as the current slice.   

##### Arguments
**StringUtilsLib.slice** self The slice to copy.     

##### Returns
**StringUtilsLib.slice** A new slice containing the same data as `self`.   


#### toString(StringUtilsLib.slice) internal view returns (string)
*(StringUtilsLib.sol, line 166)*    

Copies a slice to a new string.   

##### Arguments
**StringUtilsLib.slice** self The slice to copy.     

##### Returns
**string** A newly allocated string containing the slice's text.   

#### len(StringUtilsLib.slice) internal view returns (uint)
*(StringUtilsLib.sol, line 184)*    

Returns the length in runes of the slice. Note that this operation takes time proportional to the length of the slice; avoid using it in loops, and call `slice.empty()` if you only need to know whether the slice is empty or not.   

##### Arguments
**StringUtilsLib.slice** self The slice to operate on.     

##### Returns
**uint** The length of the slice in runes.   

#### empty(StringUtilsLib.slice) internal view returns (bool)
*(StringUtilsLib.sol, line 215)*    

Returns true if the slice is empty (has a length of 0).   

##### Arguments
**StringUtilsLib.slice** self The slice to operate on.     

##### Returns
**bool** True if the slice is empty, false otherwise.   

#### compare(StringUtilsLib.slice, StringUtilsLib.slice) internal view returns (int)
*(StringUtilsLib.sol, line 228)*    

Returns a positive number if `other` comes lexicographically after `self`, a negative number if it comes before, or zero if the contents of the two slices are equal. Comparison is done per-rune, on unicode codepoints.   

##### Arguments
**StringUtilsLib.slice** self The first slice to compare.     
**StringUtilsLib.slice** other The second slice to compare.    

##### Returns
**int** The result of the comparison.   

#### equals(StringUtilsLib.slice, StringUtilsLib.slice) internal view returns (bool)   
*(StringUtilsLib.sol, line 261)*    

Returns true if the two slices contain the same text.   

##### Arguments
**StringUtilsLib.slice** self The first slice to compare.     
**StringUtilsLib.slice** other The second slice to compare.    

##### Returns
**bool** True if the slices are equal, false otherwise.   

#### nextRune(StringUtilsLib.slice, StringUtilsLib.slice) internal returns (StringUtilsLib.slice)   
*(StringUtilsLib.sol, line 272)*    

Extracts the first rune in the slice into `rune`, advancing the slice to point to the next rune and returning `self`.   

##### Arguments
**StringUtilsLib.slice** self The slice to operate on.     
**StringUtilsLib.slice** rune The slice that will contain the first rune.    

##### Returns
**StringUtilsLib.slice** rune      

#### nextRune(StringUtilsLib.slice) internal returns (StringUtilsLib.slice)   
*(StringUtilsLib.sol, line 314)*    

Returns the first rune in the slice, advancing the slice to point to the next rune.   

##### Arguments
**StringUtilsLib.slice** self The slice to operate on.     

##### Returns
**StringUtilsLib.slice** A slice containing only the first rune from `self`.      

#### ord(StringUtilsLib.slice) internal view returns (uint)   
*(StringUtilsLib.sol, line 323)*    

Returns the number of the first codepoint in the slice.   

##### Arguments
**StringUtilsLib.slice** self The slice to operate on.     

##### Returns
**uint** The number of the first codepoint in the slice.      

#### keccak(StringUtilsLib.slice) internal view returns (bytes32)
*(StringUtilsLib.sol, line 372)*    

Returns the keccak-256 hash of the slice.   

##### Arguments
**StringUtilsLib.slice** self The slice to hash.     

##### Returns
**bytes32** The hash of the slice.      

#### startsWith(StringUtilsLib.slice, StringUtilsLib.slice) internal view returns (bool)
*(StringUtilsLib.sol, line 384)*    

Returns true if `self` starts with `needle`.   

##### Arguments
**StringUtilsLib.slice** self The slice to operate on.     
**StringUtilsLib.slice** needle The slice to search for.     

##### Returns
**bool** True if the slice starts with the provided text, false otherwise.      

#### beyond(StringUtilsLib.slice, StringUtilsLib.slice) internal returns (StringUtilsLib.slice)
*(StringUtilsLib.sol, line 410)*    

If `self` starts with `needle`, `needle` is removed from the beginning of `self`. Otherwise, `self` is unmodified.   

##### Arguments
**StringUtilsLib.slice** self The slice to operate on.     
**StringUtilsLib.slice** needle The slice to search for.     

##### Returns
**StringUtilsLib.slice** self      

#### endsWith(StringUtilsLib.slice, StringUtilsLib.slice) internal view returns (bool)
*(StringUtilsLib.sol, line 439)*    

Returns true if the slice ends with `needle`.   

##### Arguments
**StringUtilsLib.slice** self The slice to operate on.     
**StringUtilsLib.slice** needle The slice to search for.     

##### Returns
**bool** True if the slice starts with the provided text, false otherwise.      

#### until(StringUtilsLib.slice, StringUtilsLib.slice) internal returns (StringUtilsLib.slice)
*(StringUtilsLib.sol, line 467)*    

If `self` ends with `needle`, `needle` is removed from the end of `self`. Otherwise, `self` is unmodified.   

##### Arguments
**StringUtilsLib.slice** self The slice to operate on.     
**StringUtilsLib.slice** needle The slice to search for.     

##### Returns
**StringUtilsLib.slice** self      

#### find(StringUtilsLib.slice, StringUtilsLib.slice) internal returns (StringUtilsLib.slice)
*(StringUtilsLib.sol, line 602)*    

Modifies `self` to contain everything from the first occurrence of `needle` to the end of the slice. `self` is set to the empty slice if `needle` is not found.

##### Arguments
**StringUtilsLib.slice** self The slice to operate on.     
**StringUtilsLib.slice** needle The text to search for.     

##### Returns
**StringUtilsLib.slice** self      

#### rfind(StringUtilsLib.slice, StringUtilsLib.slice) internal returns (StringUtilsLib.slice)
*(StringUtilsLib.sol, line 617)*    

Modifies `self` to contain the part of the string from the start of `self` to the end of the first occurrence of `needle`. If `needle` is not found, `self` is set to the empty slice.   

##### Arguments
**StringUtilsLib.slice** self The slice to search and modify.     
**StringUtilsLib.slice** needle The text to search for.     

##### Returns
**StringUtilsLib.slice** self      

#### split(StringUtilsLib.slice, StringUtilsLib.slice, StringUtilsLib.slice) internal returns (StringUtilsLib.slice)
*(StringUtilsLib.sol, line 633)*    

Splits the slice, setting `self` to everything after the first occurrence of `needle`, and `token` to everything before it. If `needle` does not occur in `self`, `self` is set to the empty slice, and `token` is set to the entirety of `self`.   

##### Arguments
**StringUtilsLib.slice** self The slice to split.     
**StringUtilsLib.slice** needle The text to search for in `self`.     
**StringUtilsLib.slice** token An output parameter to which the first token is written.     

##### Returns
**StringUtilsLib.slice** token      

#### split(StringUtilsLib.slice, StringUtilsLib.slice) internal returns (StringUtilsLib.slice)
*(StringUtilsLib.sol, line 656)*    

Splits the slice, setting `self` to everything after the first occurrence of `needle`, and returning everything before it. If `needle` does not occur in `self`, `self` is set to the empty slice, and the entirety of `self` is returned.   

##### Arguments
**StringUtilsLib.slice** self The slice to split.     
**StringUtilsLib.slice** needle The text to search for in `self`.     

##### Returns
**StringUtilsLib.slice** token The part of `self` up to the first occurrence of `needle`.      

#### rsplit(StringUtilsLib.slice, StringUtilsLib.slice, StringUtilsLib.slice) internal returns (StringUtilsLib.slice)
*(StringUtilsLib.sol, line 670)*    

Splits the slice, setting `self` to everything before the last occurrence of `needle`, and `token` to everything after it. If `needle` does not occur in `self`, `self` is set to the empty slice, and `token` is set to the entirety of `self`.   

##### Arguments
**StringUtilsLib.slice** self The slice to split.     
**StringUtilsLib.slice** needle The text to search for in `self`.     
**StringUtilsLib.slice** token An output parameter to which the first token is written.     

##### Returns
**StringUtilsLib.slice** token   

#### rsplit(StringUtilsLib.slice, StringUtilsLib.slice) internal returns (StringUtilsLib.slice)
*(StringUtilsLib.sol, line 670)*    

Splits the slice, setting `self` to everything before the last occurrence of `needle`, and returning everything after it. If `needle` does not occur in `self`, `self` is set to the empty slice, and the entirety of `self` is returned.   

##### Arguments
**StringUtilsLib.slice** self The slice to split.     
**StringUtilsLib.slice** needle The text to search for in `self`.     

##### Returns
**StringUtilsLib.slice** token The part of `self` after the last occurrence of `needle`.   

#### count(StringUtilsLib.slice, StringUtilsLib.slice) internal view returns (uint)
*(StringUtilsLib.sol, line 702)*    

Counts the number of non overlapping occurrences of `needle` in `self`.   

##### Arguments
**StringUtilsLib.slice** self The slice to split.     
**StringUtilsLib.slice** needle The text to search for in `self`.     

##### Returns
**uint** count The number of occurrences of `needle` found in `self`.   

#### contains(StringUtilsLib.slice, StringUtilsLib.slice) internal view returns (bool)
*(StringUtilsLib.sol, line 716)*    

Returns True if `self` contains `needle`.   

##### Arguments
**StringUtilsLib.slice** self The slice to search.     
**StringUtilsLib.slice** needle The text to search for in `self`.     

##### Returns
**bool** True if `needle` is found in `self`, false otherwise.   

#### concat(StringUtilsLib.slice, StringUtilsLib.slice) internal view returns (string)
*(StringUtilsLib.sol, line 727)*    

Returns a newly allocated string containing the concatenation of `self` and `other`.   

##### Arguments
**StringUtilsLib.slice** self The first slice to concatenate.     
**StringUtilsLib.slice** other The second slice to concatenate.     

##### Returns
**string** The concatenation of the two strings.   

#### join(StringUtilsLib.slice, StringUtilsLib.slice[]) internal view returns (string)
*(StringUtilsLib.sol, line 744)*    

Joins an array of slices, using `self` as a delimiter, returning a newly allocated string.   

##### Arguments
**StringUtilsLib.slice** self The delimiter to use.     
**StringUtilsLib.slice[]** parts A list of slices to join.     

##### Returns
**string** A newly allocated string containing all the slices in `parts`, joined with `self`.   
