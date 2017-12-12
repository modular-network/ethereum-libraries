TokenLib
=========================

[![Build Status](https://travis-ci.org/Modular-Network/ethereum-libraries.svg?branch=master)](https://travis-ci.org/Modular-Network/ethereum-libraries)
[![Discord](https://img.shields.io/discord/102860784329052160.svg)](https://discord.gg/crxYSF2)   

A library [provided by Modular](https://modular.network "Modular's Website") to abstract token creation. This library was inspired by [Aragon's blog post on library usage](https://blog.aragon.one/library-driven-development-in-solidity-2bebcaf88736 "Library blog post") .

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Library Address](#library-address)
  - [v1.2.1](#v121)
  - [v1.0.0](#v100)
- [License and Warranty](#license-and-warranty)
- [How to install](#how-to-install)
  - [Truffle Installation](#truffle-installation)
    - [Manual install:](#manual-install)
    - [Testing the library in truffle](#testing-the-library-in-truffle)
  - [solc Installation](#solc-installation)
    - [With standard JSON input](#with-standard-json-input)
    - [solc without standard JSON input](#solc-without-standard-json-input)
    - [solc documentation](#solc-documentation)
  - [solc-js Installation](#solc-js-installation)
    - [Solc-js Installation via Linking](#solc-js-installation-via-linking)
    - [Solc-js documentation](#solc-js-documentation)
- [Basic Usage](#basic-usage)
  - [Usage Example](#usage-example)
- [Change Log](#change-log)
  - [v1.2.0](#v120)
  - [v1.1.0](#v110)
- [Functions](#functions)
    - [Standard Token Functions](#standard-token-functions)
    - [init(TokenLib.TokenStorage storage, address, string, string, uint8, uint256, bool) public](#inittokenlibtokenstorage-storage-address-string-string-uint8-uint256-bool-public)
      - [Arguments](#arguments)
      - [Returns](#returns)
    - [transfer(TokenLib.TokenStorage storage, address, uint256) public returns (bool)](#transfertokenlibtokenstorage-storage-address-uint256-public-returns-bool)
      - [Arguments](#arguments-1)
      - [Returns](#returns-1)
    - [transferFrom(TokenLib.TokenStorage storage, address, address, uint256) public returns (bool)](#transferfromtokenlibtokenstorage-storage-address-address-uint256-public-returns-bool)
      - [Arguments](#arguments-2)
      - [Returns](#returns-2)
    - [balanceOf(TokenLib.TokenStorage storage, address) public vew returns (uint256)](#balanceoftokenlibtokenstorage-storage-address-public-vew-returns-uint256)
      - [Arguments](#arguments-3)
      - [Returns](#returns-3)
    - [approve(TokenLib.TokenStorage storage, address, uint256) public returns (bool)](#approvetokenlibtokenstorage-storage-address-uint256-public-returns-bool)
      - [Arguments](#arguments-4)
      - [Returns](#returns-4)
    - [allowance(TokenLib.TokenStorage storage, address, address) public view returns (uint256)](#allowancetokenlibtokenstorage-storage-address-address-public-view-returns-uint256)
      - [Arguments](#arguments-5)
      - [Returns](#returns-5)
  - [Enhanced Token Functions](#enhanced-token-functions)
    - [approveChange(TokenLib.TokenStorage storage, address, uint256, bool) public returns (bool)](#approvechangetokenlibtokenstorage-storage-address-uint256-bool-public-returns-bool)
      - [Arguments](#arguments-6)
      - [Returns](#returns-6)
    - [changeOwner(TokenLib.TokenStorage storage, address) public returns (bool)](#changeownertokenlibtokenstorage-storage-address-public-returns-bool)
      - [Arguments](#arguments-7)
      - [Returns](#returns-7)
    - [mintToken(TokenLib.TokenStorage storage, uint256) public returns (bool)](#minttokentokenlibtokenstorage-storage-uint256-public-returns-bool)
      - [Arguments](#arguments-8)
      - [Returns](#returns-8)
    - [closeMint(TokenLib.TokenStorage storage) public returns (bool)](#closeminttokenlibtokenstorage-storage-public-returns-bool)
      - [Arguments](#arguments-9)
      - [Returns](#returns-9)
    - [burnToken(TokenLib.TokenStorage storage, uint256) public returns (bool)](#burntokentokenlibtokenstorage-storage-uint256-public-returns-bool)
      - [Arguments](#arguments-10)
      - [Returns](#returns-10)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Library Address

### v1.2.1

**ENS**: TBD   
**Main Ethereum Network**: 0x5462311485a381621D6B768c28157c2a70cBB55e   
**Rinkeby Test Network**: 0xE563CD95728fEaA94f96a5D97AA9f1ad5A16c1a7   
**Ropsten Test Network**: 0x276E7b5F6b03839Aa8E4aA8a6610a8E31f4E99f0  

### v1.0.0
*Note: No ENS address is provided for older versions at this time. (We're still thinking about how to design and integrate the system.)*
**Main Ethereum Network**: 0x0Aa4e6E25a76f81F079Aa300C33621E20C632E6a   
**Rinkeby Test Network**: 0x4EFd23dA884251417907a6526b0241595cD3449a   
**Ropsten Test Network**: 0x0F1064372D2C28C06f04279116e48E7A4d1C45f9   

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

## How to install

### Truffle Installation

**version 4.0.1**

First install truffle via npm using `npm install -g truffle` .

Please [visit Truffle's installation guide](http://truffleframework.com/docs/getting_started/installation "Truffle installation guide") for further information and requirements.

#### Manual install:

This process will allow you to both link your contract to the current on-chain library as well as deploy it in your local environment for development. The TokenLib uses the BasicMathLib as a lower level library so you must go through the install of that library first. If you do not have [BasicMathLib in your project please start there](https://github.com/Modular-Network/ethereum-libraries/tree/master/BasicMathLib "BasicMathLib link") and then come back.

1. [Install BasicMathLib](https://github.com/Modular-Network/ethereum-libraries/tree/master/BasicMathLib "BasicMathLib link") .
2. Place the TokenLib.sol file in your truffle `contracts/` directory.
3. Place the TokenLib.json file in your truffle `build/contracts/` directory.
4. Amend the deployment .js file in your truffle `migrations/` directory as follows:

```js
var BasicMathLib = artifacts.require("./BasicMathLib");
var TokenLib = artifacts.require("./TokenLib.sol");
var OtherLibs = artifacts.require("./OtherLibs.sol");
var YourStandardTokenContract = artifacts.require("./YourStandardTokenContract.sol");
...

//Input your parameters
var name = //"Your Token Name";
var symbol = //"YTS";
var decimals = //18;
var initialSupply = //10;
module.exports = function(deployer) {
  deployer.deploy(BasicMathLib,{overwrite: false});
  deployer.link(BasicMathLib, TokenLib);
  deployer.deploy(TokenLib, {overwrite: false});
  deployer.link(TokenLib, YourStandardTokenContract);
  deployer.deploy(YourStandardTokenContract, name, symbol, decimals, initialSupply);
};
```

**Note**: The `.link()` function should be called *before* you `.deploy(YourStandardTokenContract)`. Also, be sure to include the `{overwrite: false}` when writing the deployer i.e. `.deploy(TokenLib, {overwrite: false})`. This prevents deploying the library onto the main network or Rinkeby test network at your cost and uses the library already on the blockchain. The function should still be called however because it allows you to use it in your development environment. *See below*

#### Testing the library in truffle

The following process will allow you to `truffle test` this library in your project.

1. Clone or download the ethereum-libraries repository into its own directory on your computer. You can also use subversion to download just this truffle directory by running `svn checkout https://github.com/Modular-Network/ethereum-libraries/trunk/TokenLib/truffle`.    
   Each folder in the truffle directory correlates to the folders in your truffle project.   
2. Go into the TokenLib truffle directory on your computer and place each file in their respective directory in **your** truffle project.
   **Note**: The `2_deploy_test_contracts.js` file should either be renamed to the next highest number among your migrations files i.e. `3_deploy_test_contracts.js` or you can place the code in your existing deployment migration file. *See Quick Install above.*
3. [Download and start Ganache](http://truffleframework.com/ganache/ "Ganache Download")
4. In your terminal go to your truffle project directory.
5. Ensure the `development` object in your truffle.js file points to the same port Ganache uses, default is 7545.
6. Run `truffle test`.  

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
    "BasicMathLib.sol": {
      "content": "[Contents of BasicMathLib.sol]"
    },
    "TokenLib.sol": {
      "content": "[Contents of TokenLib.sol]"
    }
  },
  "settings":
  {
    ...
    "libraries": {
      "TokenLib.sol": {
        "BasicMathLib" : "0x01671229Bbf99b30203F9807C5A577a7B8C358Fc"
      },
      "YourTokenContract.sol": {
        "TokenLib": "0x6d271cbF16be9E9D037DDA5F0dc507777bA27a1c"
      }
    }
  }
}
```
**Note**: The library name should match the name used in your contract.

#### solc without standard JSON input

When creating unlinked binary, the compiler currently leaves special substrings in the compiled bytecode in the form of '__LibraryName______' which leaves a 20 byte space for the library's address. In order to include the deployed library in your bytecode add the following flag to your command:

`--libraries "TokenLib:0x6d271cbF16be9E9D037DDA5F0dc507777bA27a1c"`

Additionally, if you have multiple libraries, you can create a file with one library string per line and include this library as follows:

`"TokenLib:0x6d271cbF16be9E9D037DDA5F0dc507777bA27a1c"`

then add the following flag to your command:

`--libraries filename`

Finally, if you have an unlinked binary already stored with the '__LibraryName______' placeholder, you can run the compiler with the --link flag and also include the following flag:

`--libraries "TokenLib:0x6d271cbF16be9E9D037DDA5F0dc507777bA27a1c"`

#### solc documentation

[See the solc documentation for further information](https://solidity.readthedocs.io/en/develop/using-the-compiler.html#using-the-commandline-compiler "Solc CLI Doc").

### solc-js Installation

**version 0.4.18**

Solc-js provides javascript bindings for the Solidity compiler and [can be found here](https://github.com/ethereum/solc-js "Solc-js compiler"). Please refer to their documentation for detailed use.

This version of Solc-js also uses the [standard JSON input](#with-standard-json-input) to compile a contract. The entry function is `compileStandardWrapper()` and you can create a standard JSON object explained under the [solc section](#with-standard-json-input) and incorporate it as follows:

```js
var solc = require('solc');
var fs = require('fs');

var file = fs.readFileSync('/path/to/YourTokenContract.sol','utf8');
var basicMath = fs.readFileSync('./path/to/BasicMathLib.sol','utf8');
var lib = fs.readFileSync('./path/to/TokenLib.sol','utf8');

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
    "TokenLib.sol": {
      "content": lib
    }
  },
  "settings":
  {
    ...
    "libraries": {
      "TokenLib": {
        "BasicMathLib": "0x01671229Bbf99b30203F9807C5A577a7B8C358Fc"
      },
      "YourContract.sol": {
        "TokenLib": "0x6d271cbF16be9E9D037DDA5F0dc507777bA27a1c"
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
 bytecode = solc.linkBytecode(bytecode, { 'TokenLib': '0x6d271cbF16be9E9D037DDA5F0dc507777bA27a1c' });
 ```

#### Solc-js documentation

[See the Solc-js documentation for further information](https://github.com/ethereum/solc-js "Solc-js compiler").

## Basic Usage

*Disclaimer: While we make every effort to produce professional grade code we can not guarantee the security and performance of these libraries in your smart contracts. Please use good judgement and security practices while developing, we do not take responsibility for any issues you, your customers, or your applications encounter when using these open source resources.*

For a detailed explanation on how libraries are used please read the following from the Solidity documentation:

   * [Libraries](http://solidity.readthedocs.io/en/develop/contracts.html#libraries)
   * [Using For](http://solidity.readthedocs.io/en/develop/contracts.html#using-for)

The TokenLib abstracts away all of the functions required for several token variations. Users will include this library in their token contract and use it to make state changes.

In order to use the TokenLib, import it into your token contract and then bind it as follows:

### Usage Example

```
pragma solidity ^0.4.18;

import "./TokenLib.sol";

contract TokenLibTestContract {
  using TokenLib for TokenLib.TokenStorage;

  TokenLib.TokenStorage token;

  function TokenLibTestContract(address owner,
                                string name,
                                string symbol,
                                uint8 decimals,
                                uint256 initialSupply,
                                bool allowMinting) {
    token.init(name, symbol, decimals, initialSupply, allowMinting);
  }

  function owner() constant returns (string) {
    return token.owner;
  }

  function name() constant returns (string) {
    return token.name;
  }

  ...
}
```

Binding the library allows you to call the function in the format [firstParameter].function(secondParameter) . For a complete ERC20 standard token example, [please visit our Ethereum Contracts repository](https://www.github.com/Modular-Network/ethereum-contracts "Modular-Network contracts repo").

## Change Log

### v1.2.0

* Changed INITIAL_SUPPLY to initialSupply since it is not a defined constant at runtime.   

* Changed the initialization check to an initialization flag as suggested by Noel Maersk.   

* Changed `approve` function to check for current approval to be 0 before changing to be more inline with the current spec.   

### v1.1.0

* Changed the `init()` function to set the balance of the `_owner` as the initial supply. It was previously the `msg.sender`.

## Functions

The following is the list of functions available to use in your token contract.

#### Standard Token Functions

#### init(TokenLib.TokenStorage storage, address, string, string, uint8, uint256, bool) public   
*(TokenLib.sol, line 64)*

Initialize token with owner address, token name, symbol, decimals, supply, and minting status. Standard decimals is 18, the decimals used for Ether. If no additional tokens will be minted `_allowMinting` should be false.

##### Arguments
**TokenLib.TokenStorage storage** `self` The storage token in the calling contract.   
**address** `_owner` Owning address of token contract.
**string** `_name Name` of the token.   
**string** `_symbol` Symbol of the token.   
**uint8** `_decimals` Decimal places for token represented.   
**uint256** `_initial_supply` Initial supply for the token.   
**bool** `_allowMinting` True if more tokens will be created, false otherwise.

##### Returns
Nada

#### transfer(TokenLib.TokenStorage storage, address, uint256) public returns (bool)   
*(TokenLib.sol, line 90)*

Transfer tokens from msg.sender to another account.

##### Arguments
**TokenLib.TokenStorage storage variable** `self`   
**address** `_to`   
**uint256** `_value`   

##### Returns
**bool** Returns true after successful transfer.     

#### transferFrom(TokenLib.TokenStorage storage, address, address, uint256) public returns (bool)   
*(TokenLib.sol, line 110)*

Authorized spender, msg.sender, transfers tokens from one account to another.

##### Arguments
**TokenLib.TokenStorage storage** `self`   
**address** `_from`   
**address** `_to`   
**uint256** `_value`   

##### Returns
**bool**      

#### balanceOf(TokenLib.TokenStorage storage, address) public vew returns (uint256)   
*(TokenLib.sol, line 140)*   

Retrieve the token balance of the given account.

##### Arguments
**TokenLib.TokenStorage storage** `self`   
**address** `_owner`   

##### Returns
**uint256** `balance`    

#### approve(TokenLib.TokenStorage storage, address, uint256) public returns (bool)   
*(TokenLib.sol, line 149)*   

msg.sender approves a third party to spend up to `_value` in tokens.

##### Arguments
**TokenLib.TokenStorage storage** `self`    
**address** `_spender`   
**uint256** `_value`   

##### Returns
**bool**   

#### allowance(TokenLib.TokenStorage storage, address, address) public view returns (uint256)   
*(TokenLib.sol, line 163)*

Check the remaining allowance spender has from owner.

##### Arguments
**TokenStorage storage** `self`   
**address** `_owner`   
**address** `_spender`   

##### Returns
**uint256** `remaining`   

### Enhanced Token Functions

These are additional functions beyond the standard that can enhance token functionality.   

#### approveChange(TokenLib.TokenStorage storage, address, uint256, bool) public returns (bool)   
*(TokenLib.sol, line 177)*   

`msg.sender` approves a third party to spend tokens by increasing or decreasing the allowance by an amount equal to `_valueChange`. `_increase` should be `true` if increasing the approval amount and `false` if decreasing the approval amount. This is an enhancement to the `approve` function which subverts [the attack vector described here](https://docs.google.com/document/d/1YLPtQxZu1UAvO9cZ1O2RPXBbT0mooh4DYKjA_jp-RLM/edit#heading=h.m9fhqynw2xvt "ERC20 approve attack vector") by acting on the allowance delta rather than the amount explicitly.   

##### Arguments
**TokenLib.TokenStorage storage** `self `   
**address** `_spender`   
**uint256** `_valueChange` The amount to change approval by.   
**bool** `_increase` True if increasing approval, false if decreasing.      

##### Returns
**bool**   

#### changeOwner(TokenLib.TokenStorage storage, address) public returns (bool)   
*(TokenLib.sol, line 204)*   

Changes the owning address of the token contract.   

##### Arguments
**TokenLib.TokenStorage storage** `self`    
**address** `_newOwner`   

##### Returns
**bool**   

#### mintToken(TokenLib.TokenStorage storage, uint256) public returns (bool)   
*(TokenLib.sol, line 216)*   

Mints new tokens if allowed, increases totalSupply. New tokens go to the token contract owner address.   

##### Arguments
**TokenLib.TokenStorage storage** `self`    
**uint256** `_value` Amount of tokens to mint.   

##### Returns
**bool**    

#### closeMint(TokenLib.TokenStorage storage) public returns (bool)   
*(TokenLib.sol, line 233)*   

Permanently closes minting capability.   

##### Arguments
**TokenLib.TokenStorage storage** `self`    

##### Returns
**bool**   

#### burnToken(TokenLib.TokenStorage storage, uint256) public returns (bool)   
*(TokenLib.sol, line 245)*   

Allows to permanently burn tokens, reduces totalSupply.   

##### Arguments
**TokenLib.TokenStorage storage** `self`    
**uint256** `_value` Amount of tokens to burn.   

##### Returns
**bool**   
