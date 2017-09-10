CrowdsaleLib
=========================

[![Build Status](https://travis-ci.org/Majoolr/ethereum-libraries.svg?branch=master)](https://travis-ci.org/Majoolr/ethereum-libraries)
[![Join the chat at https://gitter.im/Majoolr/EthereumLibraries](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/Majoolr/EthereumLibraries?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)    

A library [provided by Majoolr](https://github.com/Majoolr "Majoolr's Github") to abstract crowdsale creation. This library was inspired by [Aragon's blog post on library usage](https://blog.aragon.one/library-driven-development-in-solidity-2bebcaf88736 "Library blog post") .

Developed as a way to standardize creation of ICOs.  All types of ICOs share a few common storage variables and functions, and the aim of these Libraries is to create a standard template that companies can follow in ICO creation that ensures a base level of security, documentation, cost, and performance.  Work is still ongoing and suggestions for improvement are welcome.  

Structure of Libraries:

## CrowdsaleLib.sol

CrowdsaleLib.sol is the base library that all crowdsales will share.  It includes values like owner, number of tokens bought per Ether contributed, a cap for the amount of Ether that can be raised in the sale, the start time of the sale, and the end time of the sale.  There is also a mapping showing how much each address has contributed to the sale in ETH, and a mapping for the number of tokens an address has purchased and are available to withdraw.  Lastly, there is a storage value for the token contract that is used as the token template for this sale.  

This library also includes a variety of functions that apply to all crowdsales.  Descriptions of each function can be seen below.  

Take note that this library cannot be used as is for a crowdsale template, as there are no functions to handle transfer of ETH or purchase of tokens.  You can either include this library as a template for your crowdsale that you design, or you can use one of the other Crowdsale Libraries, which all include this library for a base layer of functionality underlying their distinct sale mechanisms.

## DirectCrowdsaleLib.sol 

DirectCrowdsaleLib.sol is the simplest implementation of a crowdsale, a direct ETH to token transfer with an optional periodic increase/decrease in token price.  In addition to the regular parameters that are needed by the base crowdsale template, owners provide a periodic change in price and the time interval between changes (both 0 if there is not price change) and a boolean showing if the price is increasing or decreasing.  There is a function that accepts payments and allocates tokens for addresses that have paid, while also changing the token price if the time interval as passed between purchases.  There is also a function which allows the owner of the crowdsale to withdraw all the ETH raised after the sale has ended.  See below for more detailed function descriptions. 

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
    - [solc without standard JSON input](#solc-without-standard-json-input)
    - [solc documentation](#solc-documentation)
  - [solc-js Installation](#solc-js-installation)
    - [Solc-js Installation via Linking](#solc-js-installation-via-linking)
    - [Solc-js documentation](#solc-js-documentation)
- [Basic Usage](#basic-usage)
  - [Usage Example](#usage-example)
- [Functions](#functions)
    - [init(TokenLib.TokenStorage storage, address, string, string, uint8, uint256, bool)](#inittokenlibtokenstorage-storage-address-string-string-uint8-uint256-bool)
      - [Arguments](#arguments)
      - [Returns](#returns)
    - [transfer(TokenLib.TokenStorage storage, address, uint256)](#transfertokenlibtokenstorage-storage-address-uint256)
      - [Arguments](#arguments-1)
      - [Returns](#returns-1)
    - [transferFrom(TokenLib.TokenStorage storage, address, address, uint256)](#transferfromtokenlibtokenstorage-storage-address-address-uint256)
      - [Arguments](#arguments-2)
      - [Returns](#returns-2)
    - [balanceOf(TokenLib.TokenStorage storage, address)](#balanceoftokenlibtokenstorage-storage-address)
      - [Arguments](#arguments-3)
      - [Returns](#returns-3)
    - [approve(TokenLib.TokenStorage storage, address, uint256)](#approvetokenlibtokenstorage-storage-address-uint256)
      - [Arguments](#arguments-4)
      - [Returns](#returns-4)
    - [allowance(TokenLib.TokenStorage storage, address, address)](#allowancetokenlibtokenstorage-storage-address-address)
      - [Arguments](#arguments-5)
      - [Returns](#returns-5)
  - [Enhanced Token Functions](#enhanced-token-functions)
    - [approveChange(TokenLib.TokenStorage storage, address, uint256, bool)](#approvechangetokenlibtokenstorage-storage-address-uint256-bool)
      - [Arguments](#arguments-6)
      - [Returns](#returns-6)
    - [changeOwner(TokenLib.TokenStorage storage, address)](#changeownertokenlibtokenstorage-storage-address)
      - [Arguments](#arguments-7)
      - [Returns](#returns-7)
    - [mintToken(TokenLib.TokenStorage storage, uint256)](#minttokentokenlibtokenstorage-storage-uint256)
      - [Arguments](#arguments-8)
      - [Returns](#returns-8)
    - [closeMint(TokenLib.TokenStorage storage)](#closeminttokenlibtokenstorage-storage)
      - [Arguments](#arguments-9)
      - [Returns](#returns-9)
    - [burnToken(TokenLib.TokenStorage storage, uint256)](#burntokentokenlibtokenstorage-storage-uint256)
      - [Arguments](#arguments-10)
      - [Returns](#returns-10)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Library Address

**ENS**:  
**Main Ethereum Network**:    
**Rinkeby Test Network**:    
**Ropsten Test Network**:    

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

**version 3.4.9**

First install truffle via npm using `npm install -g truffle` .

Please [visit Truffle's installation guide](http://truffleframework.com/docs/getting_started/installation "Truffle installation guide") for further information and requirements.

#### Manual install:

This process will allow you to both link your contract to the current on-chain library as well as deploy it in your local environment for development. The CrowdsaleLib uses the BasicMathLib, Array256Lib, and TokenLib as a lower level library so you must go through the install of that library first. If you do not have [BasicMathLib in your project please start there](https://github.com/Majoolr/ethereum-libraries/tree/master/BasicMathLib "BasicMathLib link") and then come back and repeat for the other Libraries.

1. [Install BasicMathLib](https://github.com/Majoolr/ethereum-libraries/tree/master/BasicMathLib "BasicMathLib link") .
2. Place the TokenLib.sol file in your truffle `contracts/` directory.
3. Place the TokenLib.json file in your truffle `build/contracts/` directory.
4. Amend the deployment .js file in your truffle `migrations/` directory as follows:

```js
var BasicMathLib = artifacts.require("./BasicMathLib");
var TokenLib = artifacts.require("./TokenLib.sol");
var Array256Lib = artifacts.require("./Array256Lib.sol");

var CrowdsaleLib = artifacts.require("./CrowdsaleLib.sol");
var DirectCrowdsaleLib = artifacts.require("./DirectCrowdsaleLib.sol");
var YourStandardTokenContract = artifacts.require("./YourStandardTokenContract.sol");
var YourStandardCrowdsaleContract = artifacts.require("./YourStandardCrowdsaleContract.sol");
...

//Input your parameters
//Token
var name = //"Your Token Name";
var symbol = //"YTS";
var decimals = //18;
var initialSupply = //10;

//Crowdsale
var owner =  //"owner of the crowdsale";
var tokenPrice = //"number of tokens received per ether contributed";
var capAmount = //"Maximum amount of ether to be raised";
var minimumTargetRaise = //"minimim amount of ether needed for successful crowdsale";
var startTime = //"start time of the sale";
var endTime = //"end time of the sale";
var periodicChange = //"how much the token price changes after each interval of time, 0 if no change";
var timeInterval = //"amount of time between price changes, 0 if no change";
var increase = //"true for price increasing, false for decreasing"

module.exports = function(deployer) {
  deployer.deploy(BasicMathLib,{overwrite: false});
  deployer.link(BasicMathLib, TokenLib);
  deployer.deploy(TokenLib, {overwrite: false});
  deployer.link(BasicMathLib,CrowdsaleLib);
  deployer.link(TokenLib,CrowdsaleLib);
  deployer.deploy(CrowdsaleLib, {overwrite: false});
  deployer.link(BasicMathLib,DirectCrowdsaleLib);
  deployer.link(TokenLib,DirectCrowdsaleLib);
  deployer.link(CrowdsaleLib,DirectCrowdsaleLib);
  deployer.deploy(DirectCrowdsaleLib, {overwrite:false});
  deployer.link(TokenLib, YourStandardTokenContract);
  deployer.link(CrowdsaleLib,YourStandardCrowdsaleContract);
  deployer.link(DirectCrowdsaleLib, YourStandardCrowdsaleContract);
  deployer.deploy(YourStandardTokenContract, name, symbol, decimals, initialSupply).then(function() {
    deployer.deploy(YourStandardCrowdsaleContract, owner, tokenPrice, capAmount, minimumTargetRaise, startTime, endTime, periodicChange, timeInterval, increase,YourStandardTokenContract.address);
  });
   
};
```

**Note**: The `.link()` function should be called *before* you `.deploy(YourStandardTokenContract)`. Also, be sure to include the `{overwrite: false}` when writing the deployer i.e. `.deploy(TokenLib, {overwrite: false})`. This prevents deploying the library onto the main network or Rinkeby test network at your cost and uses the library already on the blockchain. The function should still be called however because it allows you to use it in your development environment. *See below*

#### Testing the library in truffle

The following process will allow you to `truffle test` this library in your project.

1. Clone or download the ethereum-libraries repository into its own directory on your computer. You can also use subversion to download just this truffle directory by running `svn checkout https://github.com/Majoolr/ethereum-libraries/trunk/TokenLib/truffle`.    
   Each folder in the truffle directory correlates to the folders in your truffle project.   
2. Go into the TokenLib truffle directory on your computer and place each file in their respective directory in **your** truffle project.
   **Note**: The `2_deploy_test_contracts.js` file should either be renamed to the next highest number among your migrations files i.e. `3_deploy_test_contracts.js` or you can place the code in your existing deployment migration file. *See Quick Install above.*
3. [Start a testrpc node](https://github.com/ethereumjs/testrpc "testrpc's Github")
4. In your terminal go to your truffle project directory and run `truffle test`.

### solc Installation

**version 0.4.15**

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
        "BasicMathLib" : "0x74453cf53c97437066b1987e364e5d6b54bcaee6"
      },
      "YourTokenContract.sol": {
        "TokenLib": "0x0aa4e6e25a76f81f079aa300c33621e20c632e6a"
      }
    }
  }
}
```
**Note**: The library name should match the name used in your contract.

#### solc without standard JSON input

When creating unlinked binary, the compiler currently leaves special substrings in the compiled bytecode in the form of '__LibraryName______' which leaves a 20 byte space for the library's address. In order to include the deployed library in your bytecode add the following flag to your command:

`--libraries "TokenLib:0x0aa4e6e25a76f81f079aa300c33621e20c632e6a"`

Additionally, if you have multiple libraries, you can create a file with one library string per line and inlcude this library as follows:

`"TokenLib:0x0aa4e6e25a76f81f079aa300c33621e20c632e6a"`

then add the following flag to your command:

`--libraries filename`

Finally, if you have an unlinked binary already stored with the '__LibraryName______' placeholder, you can run the compiler with the --link flag and also include the following flag:

`--libraries "TokenLib:0x0aa4e6e25a76f81f079aa300c33621e20c632e6a"`

#### solc documentation

[See the solc documentation for further information](https://solidity.readthedocs.io/en/develop/using-the-compiler.html#using-the-commandline-compiler "Solc CLI Doc").

### solc-js Installation

**version 0.4.15**

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
    "YourCrowdsaleContract.sol": {
      "content": file
    },
    "BasicMathLib": {
      "content": basicMath
    },
    "CrowdsaleLib.sol": {
      "content": lib
    }
  },
  "settings":
  {
    ...
    "libraries": {
      "CrowdsaleLib": {
        "BasicMathLib": "0x74453cf53c97437066b1987e364e5d6b54bcaee6"
      },
      "YourContract.sol": {
        "CrowdsaleLib": "0x0aa4e6e25a76f81f079aa300c33621e20c632e6a"
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
 bytecode = solc.linkBytecode(bytecode, { 'CrowdsaleLib': '0x71ecde7c4b184558e8dba60d9f323d7a87411946' });
 ```

#### Solc-js documentation

[See the Solc-js documentation for further information](https://github.com/ethereum/solc-js "Solc-js compiler").

## Basic Usage

*Disclaimer: While we make every effort to produce professional grade code we can not guarantee the security and performance of these libraries in your smart contracts. Please use good judgement and security practices while developing, we do not take responsibility for any issues you, your customers, or your applications encounter when using these open source resources.*

For a detailed explanation on how libraries are used please read the following from the Solidity documentation:

   * [Libraries](http://solidity.readthedocs.io/en/develop/contracts.html#libraries)
   * [Using For](http://solidity.readthedocs.io/en/develop/contracts.html#using-for)

The CrowdsaleLib abstracts away all of the functions required for several crowdsale variations. Users will include these libraries in their crowdsale contract and use it to make state changes.

In order to use the CrowdsaleLib, import it into your crowdsale contract and then bind it as follows:

### Usage Example

```
pragma solidity ^0.4.15;

import "./DirectCrowdsaleLib.sol";

contract DirectCrowdsaleTestContract {
  using DirectCrowdsaleLib for DirectCrowdsaleLib.DirectCrowdsaleStorage;

  DirectCrowdsaleLib.DirectCrowdsaleStorage sale;

  function DirectCrowdsaleTestContract(
                address owner,
                uint256 tokenPrice,
                uint256 capAmount,
                uint256 minimumTargetRaise,
                uint256 startTime,
                uint256 endTime,
                uint256 periodicChange,
                uint256 timeInterval,
                bool increase,
                CrowdsaleToken token)
  {
    sale.init(owner, tokenPrice, capAmount, minimumTargetRaise, startTime, endTime, periodicChange, timeInterval, increase, token);
  }

  // fallback function can be used to buy tokens
  function () payable {
    receivePurchase();
  }

  function receivePurchase() payable returns (bool) {
    return sale.receivePurchase(msg.value);
  }

  function owner() constant returns (address) {
    return sale.base.owner;
  }

  function tokenPrice() constant returns (uint256) {
    return sale.base.tokenPrice;
  }

  ...
}
```

Binding the library allows you to call the function in the format [firstParameter].function(secondParameter) . For a complete ERC20 standard token example, [please visit our Ethereum Contracts repository](https://www.github.com/Majoolr/ethereum-contracts "Majoolr contracts repo").

## Function Descriptions

### Standard Crowdsale Library Functions

Init:

Initialize the crowdsale with owner, token price (in cents), raise cap, startTime, endTime, and the address of the deployed token contract.  Checks that the values have not already been initialized and that they are all valid before setting their corresponding storage values.


crowdsaleActive

Returns true if the crowdsale is currently active. (If now is between the start and end time)

crowdsaleEnded

Returns true if the crowdsale is over. (now is after the end time)

validPurchase

Returns true if a purchase is valid, by checking that it is during the active crowdsale and the amount of ether sent is more than 0.

withdrawTokens

Allows a user to withdraw their purchased tokens whenever they want, provided they actually have purchased some.  The token's transferFrom function is called so that the token contract transfers tokens from the owners address to the buyer's address.

changeTokenPrice

Internal function that is called when the time interval has passed and it is time for the price of tokens to change.

setExchangeRate

Function that is called by the owner to set the exhange rate (cents/ETH).  In addition to setting the exchange rate, it calculates the corresponding price of the tokens in tokens per ETH.  Only the owner can call this function and it can only be called between 48 and 24 hours before the crowdsale officially starts to get an accurate ETH-USD price.  It can also only be called once.  Once the price is set, it cannot be changed.

getContribution

Emits an event and returns the amount of wei that a specified buyer has contributed to the crowdsale.

getTokenPurchase

Emits an event and returns the amount of tokens that a specified buyer has purchased in the crowdsale.


### Direct Crowdsale Library Functions

init

Initialize the crowdsale with owner, token price (in cents), raise cap, startTime, endTime, an array of token price points (in cents) that will be used throughout the sale, time Interval between price changes, and the address of the deployed token contract.

receivePurchase

Accepts payment for tokens and allocates tokens available to withdraw to the buyers place in the token mapping.  Calls validPurchase to check if the purchase is legal.  If the purchase goes over the raise cap for the sale, the ether is returned and no tokens are transferred.  This also updates the token's price when the time interval passes by checking an internal variable that keeps track of when the last change happened and checking to see if the time interval has passed since that change.  

Tokens purchased are calculated by multiplying the wei contributed by the tokensPerEth value, then dividing it by 10^18 (wei to ETH conversion).  Mappings for buyer contribution and tokens purchased are updated, as well as total wei raised in the sale.

ownerWithdrawl

Allows the owner of the crowdsale to withdraw all the contributed ether after the sale is over.  ETH must have been contributed in the sale.  It sets the owner's balance to 0 and transfers all the ETH. 


