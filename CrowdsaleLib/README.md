DirectCrowdsaleLib
=========================   

[![Build Status](https://travis-ci.org/Majoolr/ethereum-libraries.svg?branch=master)](https://travis-ci.org/Majoolr/ethereum-libraries)
[![Join the chat at https://gitter.im/Majoolr/EthereumLibraries](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/Majoolr/EthereumLibraries?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)    

A crowdsale library [provided by Majoolr](https://github.com/Majoolr "Majoolr's Github") to use for crowdsale contract deployment.   

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Library Address](#library-address)
- [License and Warranty](#license-and-warranty)
- [How to install](#how-to-install)
  - [Truffle Installation](#truffle-installation)
    - [Manual Install](#manual-install)
    - [Testing the library in truffle](#testing-the-library-in-truffle)
  - [solc Installation](#solc-installation)
    - [With standard JSON input](#with-standard-json-input)
    - [solc without standard JSON input](#solc-without-standard-json-input)
    - [solc documentation](#solc-documentation)
  - [solc-js Installation](#solc-js-installation)
    - [Solc-js Installation via Linking](#solc-js-installation-via-linking)
    - [Solc-js documentation](#solc-js-documentation)
  - [Basic Usage](#basic-usage)
- [Functions](#functions)
    - [init(DirectCrowdsaleLib.DirectCrowdsaleStorage storage, address, uint256, uint256, uint256,uint256[], uint256, uint256, uint8, CrowdsaleToken)](#initdirectcrowdsalelibdirectcrowdsalestorage-storage-address-uint256-uint256-uint256uint256-uint256-uint256-uint8-crowdsaletoken)
      - [Arguments](#arguments)
      - [Returns](#returns)
    - [receivePurchase(DirectCrowdsaleLib.DirectCrowdsaleStorage storage, uint256)](#receivepurchasedirectcrowdsalelibdirectcrowdsalestorage-storage-uint256)
      - [Arguments](#arguments-1)
      - [Returns](#returns-1)
    - [setTokenExchangeRate(DirectCrowdsaleLib.DirectCrowdsaleStorage storage, uint256)](#settokenexchangeratedirectcrowdsalelibdirectcrowdsalestorage-storage-uint256)
      - [Arguments](#arguments-2)
      - [Returns](#returns-2)
    - [setTokens(DirectCrowdsaleLib.DirectCrowdsaleStorage storage)](#settokensdirectcrowdsalelibdirectcrowdsalestorage-storage)
      - [Arguments](#arguments-3)
      - [Returns](#returns-3)
    - [withdrawTokens(DirectCrowdsaleLib.DirectCrowdsaleStorage storage)](#withdrawtokensdirectcrowdsalelibdirectcrowdsalestorage-storage)
      - [Arguments](#arguments-4)
      - [Returns](#returns-4)
    - [withdrawLeftoverWei(DirectCrowdsaleLib.DirectCrowdsaleStorage storage)](#withdrawleftoverweidirectcrowdsalelibdirectcrowdsalestorage-storage)
      - [Arguments](#arguments-5)
      - [Returns](#returns-5)
    - [withdrawOwnerEth(DirectCrowdsaleLib.DirectCrowdsaleStorage storage)](#withdrawownerethdirectcrowdsalelibdirectcrowdsalestorage-storage)
      - [Arguments](#arguments-6)
      - [Returns](#returns-6)
    - [crowdsaleActive(DirectCrowdsaleLib.DirectCrowdsaleStorage storage)](#crowdsaleactivedirectcrowdsalelibdirectcrowdsalestorage-storage)
      - [Arguments](#arguments-7)
      - [Returns](#returns-7)
    - [crowdsaleEnded(DirectCrowdsaleLib.DirectCrowdsaleStorage storage)](#crowdsaleendeddirectcrowdsalelibdirectcrowdsalestorage-storage)
      - [Arguments](#arguments-8)
      - [Returns](#returns-8)
    - [validPurchase(DirectCrowdsaleLib.DirectCrowdsaleStorage storage)](#validpurchasedirectcrowdsalelibdirectcrowdsalestorage-storage)
      - [Arguments](#arguments-9)
      - [Returns](#returns-9)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Library Address   

**ENS**: CrowdsaleLib.majoolr.eth   
**Main Ethereum Network**: 0xcd9e2e077d7f4e94812c6fd6ecc1e22e267c52e1   
**Ropsten Test Network**: 0x37ea7b78992192ebbbf848294f6af338ae7ea1c5   
**Rinkeby Test Network**: 0x33a5bb89721af20d992732bf16f7f17e7553f3ff   

**ENS**: DirectCrowdsaleLib.majoolr.eth   
**Main Ethereum Network**: 0x49a4dfad9797a1726da60098a1c06616cacfc1ec   
**Ropsten Test Network**: 0xbcaa0de389454de19ae7692e0832a116bc5b44ea   
**Rinkeby Test Network**: 0xc1593efa265ae1a01672f344de8fcaca21946db5   

## License and Warranty   

Be advised that while we strive to provide professional grade, tested code we cannot guarantee its fitness for your application. This is released under [The MIT License (MIT)](https://github.com/Majoolr/ethereum-libraries/blob/master/LICENSE "MIT License") and as such we will not be held liable for lost funds, etc. Please use your best judgment and note the following:   

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## How to install

### Truffle Installation

**version 3.4.9**   

First install truffle via npm using `npm install -g truffle` .   

Please [visit Truffle's installation guide](http://truffleframework.com/docs/getting_started/installation "Truffle installation guide") for further information and requirements.

#### Manual Install

This process will allow you to both link your contract to the current on-chain library as well as deploy it in your local environment for development.   

1. Place the CrowdsaleLib.sol and DirectCrowdsaleLib.sol file in your truffle `contracts/` directory.
2. Place the CrowdsaleLib.sol and DirectCrowdsaleLib.json file in your truffle `build/contracts/` directory.
3. Amend the deployment .js file in your truffle `migrations/` directory as follows:

```js
var CrowdsaleLib = artifacts.require("./CrowdsaleLib.sol")
var DirectCrowdsaleLib = artifacts.require("./DirectCrowdsaleLib.sol");
var OtherLibs = artifacts.require("./OtherLibs.sol");
var YourCrowdsaleContract = artifacts.require("./YourCrowdsaleContract.sol");
...

module.exports = function(deployer) {
  deployer.deploy(CrowdsaleLib, {overwrite: false});
  deployer.deploy(DirectCrowdsaleLib, {overwrite: false});
  deployer.link(CrowdsaleLib, YourCrowdsaleContract)
  deployer.link(DirectCrowdsaleLib, YourCrowdsaleContract);
  deployer.deploy(YourCrowdsaleContract, arg1, arg2,...);
};
```

**Note**: The `.link()` function should be called *before* you `.deploy(YourCrowdsaleContract)`. Also, be sure to include the `{overwrite: false}` when writing the deployer i.e. `.deploy(DirectCrowdsaleLib, {overwrite: false})`. This prevents deploying the library onto the main network at your cost and uses the library already on the blockchain. The function should still be called however because it allows you to use it in your development environment. *See below*

#### Testing the library in truffle

The following process will allow you to `truffle test` this library in your project.

1. Clone or download the ethereum-libraries repository into its own directory on your computer. You can also use subversion to download just this truffle directory by running `svn checkout https://github.com/Majoolr/ethereum-libraries/trunk/DirectCrowdsaleLib/truffle`.    
   Each folder in the truffle directory correlates to the folders in your truffle project.    
2. Place each file in their respective directory in **your** truffle project.   
   **Note**: The `2_deploy_test_contracts.js` file should either be renamed to the next highest number among your migrations files i.e. `3_deploy_test_contracts.js` or you can place the code in your existing deployment migration file. *See Quick Install above.*
3. [Start a testrpc node](https://github.com/ethereumjs/testrpc \"testrpc's Github\")   
   This particular library needs specific flags set due to gas requirements. Use the following string when starting the testrpc:   

   `testrpc --gasLimit 0xffffffffffff --account="0xfacec5711eb0a84bbd13b9782df26083fc68cf41b2210681e4d478687368fdc3,100000000000000000000000000" --account="0xb7d90a23546b263a9a68a26ed7045cd6ce7d3b0dfa7d3c7b66434a4a89453cf7,100000000000000000000000000" --account="0x58823bde84d19ad2bdb6739f9ef1fc8ca4ba0c617ecc9a1fa675282175a9bc02,100000000000000000000000000" --account="0x42891283028bba9611583fcaa0dea947251b9f980a1e3d9858cd33b0e8077195,100000000000000000000000000" --account="0x6009fc3fda6c5976cfecc36b9c0c9423f78bcc971ade88f32c0e016225c1601a,100000000000000000000000000" --account="0xe598179ebee08a9b1f1afaef6ac526e5cfe615d87831aed8b080c988773bda6d,100000000000000000000000000"`

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
    "YourCrowdsaleContract.sol": {
      ...
      ...
    },
    "CrowdsaleLib.sol": {
      "content": "[Contents of CrowdsaleLib.sol]"
    },
    "DirectCrowdsaleLib.sol": {
      "content": "[Contents of DirectCrowdsaleLib.sol]"
    }
  },
  "settings":
  {
    ...
    "libraries": {
      "YourContract.sol": {
        "CrowdsaleLib": "0xcd9e2e077d7f4e94812c6fd6ecc1e22e267c52e1",
        "DirectCrowdsaleLib": "0x49a4dfad9797a1726da60098a1c06616cacfc1ec"
      }
    }
  }
}
```

#### solc without standard JSON input

When creating unlinked binary, the compiler currently leaves special substrings in the compiled bytecode in the form of '__LibraryName______' which leaves a 20 byte space for the library's address. In order to include both deployed libraries in your bytecode create a file with one library string per line  as follows:    

```
"CrowdsaleLib:0xcd9e2e077d7f4e94812c6fd6ecc1e22e267c52e1"
"DirectCrowdsaleLib:0x49a4dfad9797a1726da60098a1c06616cacfc1ec"
```

then add the following flag to your command:

`--libraries filename`

Finally, if you have an unlinked binary already stored with the '__LibraryName______' placeholder, you can run the compiler with the --link flag and also include the following flag:

`--libraries filename`

#### solc documentation

[See the solc documentation for further information](https://solidity.readthedocs.io/en/develop/using-the-compiler.html#using-the-commandline-compiler "Solc CLI Doc").

### solc-js Installation

**version 0.4.15**

Solc-js provides javascript bindings for the Solidity compiler and [can be found here](https://github.com/ethereum/solc-js "Solc-js compiler"). Please refer to their documentation for detailed use.   

This version of Solc-js also uses the [standard JSON input](#with-standard-json-input) to compile a contract. The entry function is `compileStandardWrapper()` and you can create a standard JSON object explained under the [solc section](#with-standard-json-input) and incorporate it as follows:

```js
var solc = require('solc');
var fs = require('fs');

var file = fs.readFileSync('/path/to/YourCrowdsaleContract.sol','utf8');
var crowdsaleLib = fs.readFileSync('./path/to/CrowdsaleLib.sol','utf8');
var directCrowdsaleLib = fs.readFileSync('./path/to/DirectCrowdsaleLib.sol','utf8');

var input = {
  "language": "Solidity",
  "sources":
  {
    "YourCrowdsaleContract.sol": {
      "content": file
    },
    "DirectyCrowdsaleLib.sol": {
      "content": directCrowdsaleLib
    },
    "CrowdsaleLib.sol": {
      "content": crowdsaleLib
    }
  },
  "settings":
  {
    ...
    "libraries": {
      "YourCrowdsaleContract.sol": {
        "CrowdsaleLib": "0xcd9e2e077d7f4e94812c6fd6ecc1e22e267c52e1",
        "DirectCrowdsaleLib": "0x49a4dfad9797a1726da60098a1c06616cacfc1ec"
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
bytecode = solc.linkBytecode(bytecode, { 'CrowdsaleLib': '0xcd9e2e077d7f4e94812c6fd6ecc1e22e267c52e1' });
```

#### Solc-js documentation

[See the Solc-js documentation for further information](https://github.com/ethereum/solc-js "Solc-js compiler").

### Basic Usage

The Direct Crowdsale library provides functionality needed to launch an ETH in/token out crowdsale. It is made up of two library contracts, a base library and a library specific to this type of crowdsale structure. Both should be included in your project. The crowdsale will have some of the following characteristics:

   * Sets a raise cap in terms of dollars and cents.
   * Can provide price points in terms of dollars and cents for stepping up or stepping down prices during the sale.
   * Can set the interval between price changes.
   * Sets an exchange rate for dollars/ETH up to three days before the sale begins.
   * Can set a percentage of extra tokens to burn after the sale ends with the remainder going back to the owners.

The crowdsale contract should put the `init` function in the constructor with the required parameters given. The crowdsale library functions will generally return false and log an error event when submitted parameters are either wrong or the call will not work.

**DISCLAIMER:** As always, please ensure you review this code thoroughly for your team's use. We strive to make our code as solid, clean, and well documented as possible but will not accept liability for unforeseen circumstances in which value is lost or stolen. This includes but not limited to any inability to meet signature requirements to move funds, loss of private keys, transactions you deem unauthorized from an owner's account, etc. The library code has been thoroughly tested by our team and believe it to be suitable enough to be posted in our open source repository, however, you are still responsible for its implementation and security in your smart contract. Please use your best judgment. Please [let us know immediately](https://majoolr.io \"Majoolr website\") if you have discovered any issues or vulnerabilities with this library.

## Functions

The following is the list of functions available to use in your smart contract.

#### init(DirectCrowdsaleLib.DirectCrowdsaleStorage storage, address, uint256, uint256, uint256,uint256[], uint256, uint256, uint8, CrowdsaleToken)   
*(DirectCrowdsaleLib.sol, line 67)*

Constructor. Initialize the crowdsale with owner, token price (in cents), raise cap, startTime, endTime, burn percentage, an array of token price points (in cents) that will be used throughout the sale, a fallback USD-Ether exchange rate, a time Interval between price changes, and the address of the deployed token contract.  Passes some values to the base constructor then sets the direct crowdsale specific storage variables.

##### Arguments
**DirectCrowdsaleLib.DirectCrowdsaleStorage** self   
**address[]** _owner Address of crowdsale owner   
**uint256** _capAmountInCents For example, $300/ETH should be 30000   
**uint256** _startTime Timestamp of the start time.   
**uint256** _endTime Timestamp of the end time.   
**uint256[]** _tokenPricePoints An array of each token price point during the sale, in terms of cents.   
**uint256** _fallbackExchangeRate Used as a last resort if this is not set prior to the sale.   
**uint256** _changeInterval Amount of time in seconds between each price change   
**uint8** _percentBurn Percentage of extra tokens to burn after the sale.   
**CrowdsaleToken** _token Token being sold in the crowdsale.

##### Returns
No return   

#### receivePurchase(DirectCrowdsaleLib.DirectCrowdsaleStorage storage, uint256)   
*(DirectCrowdsaleLib.sol, line 102)*

Accepts payment for tokens and allocates tokens available to withdraw to the buyers place in the token mapping.  Calls validPurchase to check if the purchase is legal.  If the purchase goes over the raise cap for the sale, the ether is returned and no tokens are transferred.  This also updates the token's price when the time interval passes by checking an internal variable that keeps track of when the last change happened and checking to see if the time interval has passed since that change.   

Tokens purchased are calculated by multiplying the wei contributed by the tokensPerEth value, then moving the decimal place to reflect the token's specified granularity.  Mappings for buyer contribution, tokens purchased, and any leftover wei are updated, as well as total wei raised in the sale.

##### Arguments
**DirectCrowdsaleLib.DirectCrowdsaleStorage** self The data storage in the calling contract.   
**uint256** _amount Amount being paid in terms of wei.

##### Returns
**bool** True if transaction confirmed or revoked successfully.   

#### setTokenExchangeRate(DirectCrowdsaleLib.DirectCrowdsaleStorage storage, uint256)   
*(DirectCrowdsaleLib.sol, line 169)*

Function that is called by the owner to set the exhange rate (cents/ETH).  In addition to setting the exchange rate, it calculates the corresponding price of the tokens in tokens per ETH.  Only the owner can call this function and it can only be called within 3 days of the crowdsale officially starting to get an accurate ETH-USD price.  It can also only be called once.  Once the price is set, it cannot be changed.

##### Arguments
**DirectCrowdsaleLib.DirectCrowdsaleStorage** self   
**uint256** _amount

##### Returns
**bool**   

#### setTokens(DirectCrowdsaleLib.DirectCrowdsaleStorage storage)   
*(DirectCrowdsaleLib.sol, line 173)*

Used as a last resort function in case the exchange rate is not set prior to the sale start.

##### Arguments
**DirectCrowdsaleLib.DirectCrowdsaleStorage** self

##### Returns
**bool**   

#### withdrawTokens(DirectCrowdsaleLib.DirectCrowdsaleStorage storage)   
*(DirectCrowdsaleLib.sol, line 177)*

Allows a user to withdraw their purchased tokens whenever they want, provided they actually have purchased some.  The token's transferFrom function is called so that the token contract transfers tokens from the owners address to the buyer's address.  The owner can also call this function after the sale is over to withdraw the remaining tokens that were not sold and trigger the functionality to burn unwanted tokens.

##### Arguments
**DirectCrowdsaleLib.DirectCrowdsaleStorage** self

##### Returns
**bool**   

#### withdrawLeftoverWei(DirectCrowdsaleLib.DirectCrowdsaleStorage storage)   
*(DirectCrowdsaleLib.sol, line 181)*

If a user had sent wei that didn't add up exactly to a whole number of tokens, the leftover wei will be recorded in the leftoverWei mapping for that user.  This function allows the user to withdraw the excess.

##### Arguments
**DirectCrowdsaleLib.DirectCrowdsaleStorage** self

##### Returns
**bool**   

#### withdrawOwnerEth(DirectCrowdsaleLib.DirectCrowdsaleStorage storage)   
*(DirectCrowdsaleLib.sol, line 185)*

Allows the owner of the crowdsale to withdraw all the contributed ether after the sale is over.  ETH must have been contributed in the sale.  It sets the owner's balance to 0 and transfers all the ETH.

##### Arguments
**DirectCrowdsaleLib.DirectCrowdsaleStorage** self

##### Returns
**bool**   

#### crowdsaleActive(DirectCrowdsaleLib.DirectCrowdsaleStorage storage)   
*(DirectCrowdsaleLib.sol, line 189)*

Returns true if the crowdsale is currently active. (If now is between the start and end time)

##### Arguments
**DirectCrowdsaleLib.DirectCrowdsaleStorage** self

##### Returns
**bool**   

#### crowdsaleEnded(DirectCrowdsaleLib.DirectCrowdsaleStorage storage)   
*(DirectCrowdsaleLib.sol, line 193)*

Returns true if the crowdsale is over. (now is after the end time)

##### Arguments
**DirectCrowdsaleLib.DirectCrowdsaleStorage** self

##### Returns
**bool**   

#### validPurchase(DirectCrowdsaleLib.DirectCrowdsaleStorage storage)   
*(DirectCrowdsaleLib.sol, line 197)*

Returns true if a purchase is valid, by checking that it is during the active crowdsale and the amount of ether sent is more than 0.

##### Arguments
**DirectCrowdsaleLib.DirectCrowdsaleStorage** self

##### Returns
**bool**   
