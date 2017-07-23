ERC20Lib
=========================

[![Build Status](https://travis-ci.org/Majoolr/ethereum-libraries.svg?branch=master)](https://travis-ci.org/Majoolr/ethereum-libraries)    

A library [provided by Majoolr](https://github.com/Majoolr "Majoolr's Github") to abstract token creation. This library was inspired by [Aragon's blog post on library usage](https://blog.aragon.one/library-driven-development-in-solidity-2bebcaf88736 "Library blog post") .

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Library Address](#library-address)
- [License and Warranty](#license-and-warranty)
- [How to install](#how-to-install)
  - [Truffle Installation](#truffle-installation)
    - [Manual install:](#manual-install)
    - [Testing the library in truffle](#testing-the-library-in-truffle)
    - [EthPM install:](#ethpm-install)
  - [solc Installation](#solc-installation)
    - [With standard JSON input](#with-standard-json-input)
    - [solc without standard JSON input](#solc-without-standard-json-input)
    - [solc documentation](#solc-documentation)
  - [solc-js Installation](#solc-js-installation)
    - [Solc-js Installation via Linking](#solc-js-installation-via-linking)
    - [Solc-js documentation](#solc-js-documentation)
- [Basic Usage](#basic-usage)
  - [Usage Example](#usage-example)
- [Functions](#functions)
  - [init(TokenStorage storage self, uint256 _initial_supply)](#inittokenstorage-storage-self-uint256-_initial_supply)
    - [Arguments](#arguments)
  - [transfer(TokenStorage storage self, address _to, uint256 _value) returns (bool success)](#transfertokenstorage-storage-self-address-_to-uint256-_value-returns-bool-success)
    - [Arguments](#arguments-1)
    - [Returns](#returns)
  - [transferFrom(TokenStorage storage self,](#transferfromtokenstorage-storage-self)
    - [Arguments](#arguments-2)
    - [Returns](#returns-1)
  - [balanceOf(TokenStorage storage self, address _owner) constant returns (uint256 balance)](#balanceoftokenstorage-storage-self-address-_owner-constant-returns-uint256-balance)
    - [Arguments](#arguments-3)
    - [Returns](#returns-2)
  - [approve(TokenStorage storage self, address _spender, uint256 _value) returns (bool success)](#approvetokenstorage-storage-self-address-_spender-uint256-_value-returns-bool-success)
    - [Arguments](#arguments-4)
    - [Returns](#returns-3)
  - [allowance(TokenStorage storage self,](#allowancetokenstorage-storage-self)
    - [Arguments](#arguments-5)
    - [Returns](#returns-4)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Library Address

**ENS**: ERC20Lib.majoolr.eth   
**Main Ethereum Network**: 0x7bc3a3d4d304127d04f6aec09dd546d254e02ce1  
**Rinkeby Test Network**: 0x9b40715474cb7b384438821d69f8455c79c0f0dc   
**Ropsten Test Network**: 0xc5f20410e1c6db8090c842d2ade8b42c214199dd

## License and Warranty

Be advised that while we strive to provide professional grade, tested code we cannot
guarantee its fitness for your application. This is released under [The MIT License (MIT)](https://github.com/Majoolr/ethereum-libraries/blob/master/LICENSE "MIT License")
and as such we will not be held liable for lost funds, etc. Please use your best
judgment and note the following:   

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## How to install

### Truffle Installation

**version 3.3.0**

First install truffle via npm using `npm install -g truffle` .

Please [visit Truffle's installation guide](http://truffleframework.com/docs/getting_started/installation "Truffle installation guide") for further information and requirements.

#### Manual install:

This process will allow you to both link your contract to the current on-chain library as well as deploy it in your local environment for development. The ERC20Lib uses the BasicMathLib as a lower level library so you must go through the install of that library first. If you do not have [BasicMathLib in your project please start there](https://github.com/Majoolr/ethereum-libraries/tree/master/BasicMathLib "BasicMathLib link") and then come back.

1. [Install BasicMathLib](https://github.com/Majoolr/ethereum-libraries/tree/master/BasicMathLib "BasicMathLib link") .
2. Place the ERC20Lib.sol file in your truffle `contracts/` directory.
3. Place the ERC20Lib.json file in your truffle `build/contracts/` directory.
4. Amend the deployment .js file in your truffle `migrations/` directory as follows:

```js
var BasicMathLib = artifacts.require("./BasicMathLib");
var ERC20Lib = artifacts.require("./ERC20Lib.sol");
var OtherLibs = artifacts.require("./OtherLibs.sol");
var YourStandardTokenContract = artifacts.require("./YourStandardTokenContract.sol");
...

module.exports = function(deployer) {
  deployer.deploy(BasicMathLib,{overwrite: false});
  deployer.link(BasicMathLib, ERC20Lib);
  deployer.deploy(ERC20Lib, {overwrite: false});
  deployer.link(ERC20Lib, YourStandardTokenContract);
  deployer.deploy(YourStandardTokenContract);
};
```

**Note**: The `.link()` function should be called *before* you `.deploy(YourStandardTokenContract)`. Also, be sure to include the `{overwrite: false}` when writing the deployer i.e. `.deploy(ERC20Lib, {overwrite: false})`. This prevents deploying the library onto the main network or Rinkeby test network at your cost and uses the library already on the blockchain. The function should still be called however because it allows you to use it in your development environment. *See below*

#### Testing the library in truffle

The following process will allow you to `truffle test` this library in your project.

1. `git clone --recursive` or download the truffle directory.
   Each folder in the truffle directory correlates to the folders in your truffle installation.
2. Place each file in their respective directory in **your** truffle project.
   **Note**: The `2_deploy_test_contracts.js` file should either be renamed to the next highest number among your migrations files i.e. `3_deploy_test_contracts.js` or you can place the code in your existing deployment migration file. *See Quick Install above.*
3. [Start a testrpc node](https://github.com/ethereumjs/testrpc "testrpc's Github")
4. In your terminal go to your truffle project directory and run `truffle migrate`.
5. After migration run `truffle test`.

#### EthPM install:

We were experiencing errors with EthPM deployment and will update this when those are resolved.

### solc Installation

**version 0.4.11**

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
    },
    "ERC20Lib.sol": {
      "content": "[Contents of ERC20Lib.sol]"
    }
  },
  "settings":
  {
    ...
    "libraries": {
      "ERC20Lib.sol": {
        "BasicMathLib" : "0x3e25cde3fb9c93e4c617fe91c8c0d6720c87d61e"
      },
      "YourTokenContract.sol": {
        "ERC20Lib": "0x71ecde7c4b184558e8dba60d9f323d7a87411946"
      }
    }
  }
}
```
**Note**: The library name should match the name used in your contract.

#### solc without standard JSON input

When creating unlinked binary, the compiler currently leaves special substrings in the compiled bytecode in the form of '__LibraryName______' which leaves a 20 byte space for the library's address. In order to include the deployed library in your bytecode add the following flag to your command:

`--libraries "ERC20Lib:0x71ecde7c4b184558e8dba60d9f323d7a87411946"`

Additionally, if you have multiple libraries, you can create a file with one library string per line and inlcude this library as follows:

`"ERC20Lib:0x71ecde7c4b184558e8dba60d9f323d7a87411946"`

then add the following flag to your command:

`--libraries filename`

Finally, if you have an unlinked binary already stored with the '__LibraryName______' placeholder, you can run the compiler with the --link flag and also include the following flag:

`--libraries "ERC20Lib:0x71ecde7c4b184558e8dba60d9f323d7a87411946"`

#### solc documentation

[See the solc documentation for further information](https://solidity.readthedocs.io/en/develop/using-the-compiler.html#using-the-commandline-compiler "Solc CLI Doc").

### solc-js Installation

**version 0.4.11**

Solc-js provides javascript bindings for the Solidity compiler and [can be found here](https://github.com/ethereum/solc-js "Solc-js compiler"). Please refer to their documentation for detailed use.

This version of Solc-js also uses the [standard JSON input](#with-standard-json-input) to compile a contract. The entry function is `compileStandardWrapper()` and you can create a standard JSON object explained under the [solc section](#with-standard-json-input) and incorporate it as follows:

```js
var solc = require('solc');
var fs = require('fs');

var file = fs.readFileSync('/path/to/YourTokenContract.sol','utf8');
var basicMath = fs.readFileSync('./path/to/BasicMathLib.sol','utf8');
var lib = fs.readFileSync('./path/to/ERC20Lib.sol','utf8');

var input = {
  "language": "Solidity",
  "sources":
  {
    "YourTokenContract.sol": {
      "content": file
    },
    "BasicMathLib": {
      "content": basicMath
    },
    "ERC20Lib.sol": {
      "content": lib
    }
  },
  "settings":
  {
    ...
    "libraries": {
      "ERC20Lib": {
        "BasicMathLib": "0x3e25cde3fb9c93e4c617fe91c8c0d6720c87d61e"
      },
      "YourContract.sol": {
        "ERC20Lib": "0x71ecde7c4b184558e8dba60d9f323d7a87411946"
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
 bytecode = solc.linkBytecode(bytecode, { 'ERC20Lib': '0x71ecde7c4b184558e8dba60d9f323d7a87411946' });
 ```

#### Solc-js documentation

[See the Solc-js documentation for further information](https://github.com/ethereum/solc-js "Solc-js compiler").

## Basic Usage

*Disclaimer: While we make every effort to produce professional grade code we can not guarantee the security and performance of these libraries in your smart contracts. Please use good judgement and security practices while developing, we do not take responsibility for any issues you, your customers, or your applications encounter when using these open source resources.

For a detailed explanation on how libraries are used please read the following from the Solidity documentation:

   * [Libraries](http://solidity.readthedocs.io/en/develop/contracts.html#libraries)
   * [Using For](http://solidity.readthedocs.io/en/develop/contracts.html#using-for)

The ERC20Lib abstracts away all of the functions required for an ERC20 standard token. Users will include this library in their standard token contract and use it to make state changes. When there is an overspend, the library will not make any state changes and will **not** throw an error. It will return an error event with a message string stating what happened. If you are using your standard token to make state changes in other contracts, then you will need to decide how to handle an overspend. When an account is overspent, the transfer functions will return false. If the standard token contract is not being used in other contracts then there will be no state changes if an account overspends.

In order to use the ERC20Lib, import it into your token contract and then bind it as follows:

### Usage Example

```
pragma solidity ^0.4.11;

import "./ERC20Lib.sol";

contract ERC20LibTestContract {
  using ERC20Lib for ERC20Lib.TokenStorage;

  ERC20Lib.TokenStorage token;

  string public name = "MyToken";
  string public symbol = "PLZ";
  uint public decimals = 18;
  //10,000,000 tokens with 18 decimal zeros
  uint public INITIAL_SUPPLY = 10000000000000000000000000;

  function ERC20LibTestContract() {
    token.init(INITIAL_SUPPLY);
  }

  function totalSupply() constant returns (uint) {
    return token.totalSupply;
  }

  function balanceOf(address who) constant returns (uint) {
    return token.balanceOf(who);
  }

  function allowance(address owner, address spender) constant returns (uint) {
    return token.allowance(owner, spender);
  }

  function transfer(address to, uint value) returns (bool ok) {
    return token.transfer(to, value);
  }

  function transferFrom(address from, address to, uint value) returns (bool ok) {
    return token.transferFrom(from, to, value);
  }

  function approve(address spender, uint value) returns (bool ok) {
    return token.approve(spender, value);
  }
}
```

Binding the library allows you to call the function in the format [firstParameter].function(secondParameter)

## Functions

The following is the list of functions available to use in your token contract.

   ### init(TokenStorage storage self, uint256 _initial_supply)
   *(ERC20Lib.sol, line 55)*

   Initialize token with supply.

   #### Arguments
   *TokenStorage storage variable* self   
   *uint256* _initial_supply   

   ### transfer(TokenStorage storage self, address _to, uint256 _value) returns (bool success)
   *(ERC20Lib.sol, line 65)*

   Transfer tokens from msg.sender to another account.

   #### Arguments
   *TokenStorage storage variable* self   
   *address* _to   
   *uint256* _value   

   #### Returns
   *bool* success   

   ### transferFrom(TokenStorage storage self,
                         address _from,
                         address _to,
                         uint256 _value)
                         returns (bool success) {
   *(ERC20Lib.sol, line 87)*

   Authorized spender, msg.sender, transfers tokens from one account to another.

   #### Arguments
   *TokenStorage storage variable* self   
   *address* _from   
   *address* _to   
   *uint256* _value   

   #### Returns
   *bool* success   

   ### balanceOf(TokenStorage storage self, address _owner) constant returns (uint256 balance)
   *(ERC20Lib.sol, line 120)*

   Retrieve the token balance of the given account.

   #### Arguments
   *TokenStorage storage variable* self   
   *address* _owner   

   #### Returns
   *uint256* balance    

   ### approve(TokenStorage storage self, address _spender, uint256 _value) returns (bool success)
   *(ERC20Lib.sol, line 129)*

   msg.sender approves a third party to spend up to _value in tokens.

   #### Arguments
   *TokenStorage storage variable* self    
   *address* _spender   
   *uint256* _value   

   #### Returns
   success *bool*

   ### allowance(TokenStorage storage self,
                      address _owner,
                      address _spender)
                      constant returns (uint256 remaining)
   *(ERC20Lib.sol, line 140)*

   Check the remaining allowance spender has from owner.

   #### Arguments
   *TokenStorage storage variable* self   
   *address* _owner   
   *address* _spender   

   #### Returns
   *uint256* remaining   
