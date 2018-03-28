BasicMathLib
=========================

[![Build Status](https://travis-ci.org/Modular-Network/ethereum-libraries.svg?branch=master)](https://travis-ci.org/Modular-Network/ethereum-libraries)
[![Discord](https://img.shields.io/discord/102860784329052160.svg)](https://discord.gg/crxYSF2)   

A utility library [provided by Modular](https://modular.network "Modular's Website") to protect math operations from overflow and invalid outputs.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Library Address](#library-address)
- [License and Warranty](#license-and-warranty)
- [Installation and Usage](#installation-and-usage)
  - [How to install](#how-to-install)
  - [How to link](#how-to-link)
  - [Testing](#testing)
  - [solc Installation](#solc-installation)
    - [With standard JSON input](#with-standard-json-input)
    - [solc without standard JSON input](#solc-without-standard-json-input)
    - [solc documentation](#solc-documentation)
  - [solc-js Installation](#solc-js-installation)
    - [Solc-js Installation via Linking](#solc-js-installation-via-linking)
    - [Solc-js documentation](#solc-js-documentation)
- [Basic Usage](#basic-usage)
  - [Usage Example](#usage-example)
  - [Usage Note](#usage-note)
- [Functions](#functions)
  - [times(numberOne, numberTwo) public pure returns (bool, uint256)](#timesnumberone-numbertwo-public-pure-returns-bool-uint256)
    - [Arguments](#arguments)
    - [Returns](#returns)
  - [dividedBy(uint256, uint256) public pure returns (bool, uint256)](#dividedbyuint256-uint256-public-pure-returns-bool-uint256)
    - [Arguments](#arguments-1)
    - [Returns](#returns-1)
  - [plus(uint256, uint256) public pure returns (bool, uint256)](#plusuint256-uint256-public-pure-returns-bool-uint256)
    - [Arguments](#arguments-2)
    - [Returns](#returns-2)
  - [minus(uint256, uint256) public pure returns (bool, uint256)](#minusuint256-uint256-public-pure-returns-bool-uint256)
    - [Arguments](#arguments-3)
    - [Returns](#returns-3)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Library Address

**Main Ethereum Network**: 0xc8Bc467B9A70A5824b7E71BE9D65906C72f13dDC     
**Rinkeby Test Network**: 0xa83b336F5501e6b6A3273c7c39dfCC5B18002733   

## License and Warranty

Be advised that while we strive to provide professional grade, tested code we cannot
guarantee its fitness for your application. This is released under [The MIT License (MIT)](https://github.com/Modular-Network/ethereum-libraries/blob/master/LICENSE "MIT License")
and as such we will not be held liable for lost funds, etc. Please use your best
judgment and note the following:   

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.  

## Installation and Usage

### How to install

`npm install ethereum-libraries-basic-math`

### How to link

This process will allow you to both link your contract to the current on-chain library as well as deploy it in your local environment for development.

Amend the deployment .js file in your truffle `migrations/` directory as follows:

```js
var BasicMathLib = require("ethereum-libraries-basic-math/build/contracts/BasicMathLib.json";
var OtherLibs = artifacts.require("./OtherLibs.sol");
var YourOtherContract = artifacts.require("./YourOtherContract.sol");
...

module.exports = function(deployer) {
  deployer.deploy(BasicMathLib, {overwrite: false});
  deployer.link(BasicMathLib, YourOtherContract);
  deployer.deploy(YourOtherContract);
};
```

**Note**: The `.link()` function should be called *before* you `.deploy(YourOtherContract)`. Also, be sure to include the `{overwrite: false}` when writing the deployer i.e. `.deploy(BasicMathLib, {overwrite: false})`. This prevents deploying the library onto the main network or Rinkeby test network at your cost and uses the library already on the blockchain. The function should still be called however because it allows you to use it in your development environment. *See below*

### Testing

Test: `npm run test`  

Test Coverage: `npm run test:coverage`

### solc Installation

**version 0.4.21**

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
    "BasicMathLib.sol": {
      "content": "[Contents of BasicMathLib.sol]"
    }
  },
  "settings":
  {
    ...
    "libraries": {
      "YourContract.sol": {
        "BasicMathLib": "0xc8Bc467B9A70A5824b7E71BE9D65906C72f13dDC"
      }
    }
  }
}
```
**Note**: The library name should match the name used in your contract.

#### solc without standard JSON input

When creating unlinked binary, the compiler currently leaves special substrings in the compiled bytecode in the form of '__LibraryName______' which leaves a 20 byte space for the library's address. In order to include the deployed library in your bytecode add the following flag to your command:

`--libraries "BasicMathLib:0xc8Bc467B9A70A5824b7E71BE9D65906C72f13dDC"`

Additionally, if you have multiple libraries, you can create a file with one library string per line and include this library as follows:

`"BasicMathLib:0xc8Bc467B9A70A5824b7E71BE9D65906C72f13dDC"`

then add the following flag to your command:

`--libraries filename`

Finally, if you have an unlinked binary already stored with the '__LibraryName______' placeholder, you can run the compiler with the --link flag and also include the following flag:

`--libraries "BasicMathLib:0xc8Bc467B9A70A5824b7E71BE9D65906C72f13dDC"`

#### solc documentation

[See the solc documentation for further information](https://solidity.readthedocs.io/en/develop/using-the-compiler.html#using-the-commandline-compiler "Solc CLI Doc").

### solc-js Installation

**version 0.4.21**

Solc-js provides javascript bindings for the Solidity compiler and [can be found here](https://github.com/ethereum/solc-js "Solc-js compiler"). Please refer to their documentation for detailed use.

This version of Solc-js also uses the [standard JSON input](#with-standard-json-input) to compile a contract. The entry function is `compileStandardWrapper()` and you can create a standard JSON object explained under the [solc section](#with-standard-json-input) and incorporate it as follows:

```js
var solc = require('solc');
var fs = require('fs');

var file = fs.readFileSync('/path/to/YourContract.sol','utf8');
var lib = fs.readFileSync('./path/to/BasicMathLib.sol','utf8');

var input = {
  "language": "Solidity",
  "sources":
  {
    "YourContract.sol": {
      "content": file
    },
    "BasicMathLib.sol": {
      "content": lib
    }
  },
  "settings":
  {
    ...
    "libraries": {
      "YourContract.sol": {
        "BasicMathLib": "0xc8Bc467B9A70A5824b7E71BE9D65906C72f13dDC"
      }
    }
    ...
  }
}

var output = JSON.parse(solc.compileStandardWrapper(JSON.stringify(input)));

//Where the output variable is a standard JSON output object.
```

#### Solc-js Installation via Linking

Solc-js also provides a linking method if you have compiled binary code already with the placeholder. To link this library the call would be:

 ```js
 var linker = require('solc/linker')

 bytecode = linker.linkBytecode(bytecode, { 'BasicMathLib': '0xc8Bc467B9A70A5824b7E71BE9D65906C72f13dDC' })
 ```

#### Solc-js documentation

[See the Solc-js documentation for further information](https://github.com/ethereum/solc-js "Solc-js compiler").

## Basic Usage

*Disclaimer: While we make every effort to produce professional grade code we can not guarantee the security and performance of these libraries in your smart contracts. Please use good judgement and security practices while developing, we do not take responsibility for any issues you, your customers, or your applications encounter when using these open source resources.*

For a detailed explanation on how libraries are used please read the following from the Solidity documentation:

   * [Libraries](http://solidity.readthedocs.io/en/develop/contracts.html#libraries)
   * [Using For](http://solidity.readthedocs.io/en/develop/contracts.html#using-for)

The BasicMathLib library does the four basic math functions for unsigned 256-bit integers and protects for overflow, underflow, and from dividing by 0 (yes, we know Solidity throws when dividing by zero but keep reading.) Each function returns two variables, the first being a boolean variable which indicates `true` if there is an error and `false` if there is no error. Error being an under/overflow condition or dividing by 0. The second variable is the result of the operation or 0 if there is an error.

When there is an error condition, BasicMathLib does not `throw`,`invalid`, or `revert`. This is important to understand for your smart contract workflow. The con to this is that **any state changes your contract has made up to this point will need to be handled by you, no state changes will be reverted by the library if there is an error condition.**

The results parallel javascript callback functions such that every return will have (err, result). This allows you to handle returns such as:

```
(err, res) = a.times(b);
if(err)
  //handle the error
else
  //there is no error, use res
```

Note: You can handle the error without throwing such as reverting yourself, this library gives you the flexibility to decide that tradeoff yourself.   

In order to use the BasicMathLib library, import it into your contract and then bind it as follows:

### Usage Example

```
pragma solidity ^0.4.19;

import "example-libraries-basic-math/contracts/BasicMathLib.sol";

contract YourContract {
  using BasicMathLib for uint256;

  //Then in your function you can call [first argument].function([second argument])
  //Your arguments should be of the same type you bound the library to
  function multiplyTwoNumbers(uint256 a, uint256 b) returns (bool,uint256){
    return a.times(b);
  }

  function divideTwoNumbers(uint256 a, uint256 b) returns (string success){
    bool err;
    uint256 res;
    (err, res) = a.dividedBy(b);
    if(!err)
      success = "I divided a number!"
  }
}
```

Binding the library allows you to call the function in the format [firstParameter].function(secondParameter)   

### Usage Note

All of the functions only accept uint256 types.

WORD OF CAUTION! If the function overflows or underflows, ie you subtract below
zero, the function will return 0 as the result. If you operate on a variable
but wish to preserve the value, you need to use a temporary variable to hold
that value until checks pass. Consider the following code:

```
pragma solidity ^0.4.19;

import "example-libraries-basic-math/contracts/BasicMathLib.sol";

contract YourContract {
  using BasicMathLib for uint256;

  uint256 a; //a is a state variable
  ...
  function badSubtract(uint256 b) returns (bool){
    bool err;
    (err, a) = a.minus(b);
    if(err)
      return false;
    //You have changed your state variable to zero
  }

  function goodSubtract(uint256 b) returns (bool){
    bool err;
    uint256 temp;
    (err, temp) = a.minus(b);
    if(err)
      return false;
    //Checks then effects
    a = temp;
  }
  ...
}
```

## Functions

The following is the list of functions available to use in your smart contract.

### times(numberOne, numberTwo) public pure returns (bool, uint256)
*(BasicMathLib.sol, line 38)*

Multiply two numbers. Checks for overflow.

#### Arguments
**uint256** `a`   
**uint256** `b`   

#### Returns
**bool** `err`
**uint256** `res`   

### dividedBy(uint256, uint256) public pure returns (bool, uint256)
*(BasicMathLib.sol, line 55)*

Divide two numbers. Checks for 0 divisor.

#### Arguments
**uint256** `a`   
**uint256** `b`   

#### Returns
**bool** `err`
**uint256** `res`   

### plus(uint256, uint256) public pure returns (bool, uint256)
*(BasicMathLib.sol, line 78)*

Add two numbers. Checks for overflow.

#### Arguments
**uint256** `a`   
**uint256** `b`    

#### Returns
**bool** `err`
**uint256** `res`   

### minus(uint256, uint256) public pure returns (bool, uint256)
*(BasicMathLib.sol, line 95)*

Subtract two numbers. Checks for underflow.

#### Arguments
**uint256** `a`   
**uint256** `b`  

#### Returns
**bool** `err`
**uint256** `res`   
