EvenDistroCrowdsaleLib
=========================   

[![Build Status](https://travis-ci.org/Majoolr/ethereum-libraries.svg?branch=master)](https://travis-ci.org/Majoolr/ethereum-libraries)
[![Join the chat at https://gitter.im/Majoolr/EthereumLibraries](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/Majoolr/EthereumLibraries?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)    

A crowdsale library [provided by Majoolr](https://github.com/Majoolr "Majoolr's Github") to use for pre-registered, even token distribution crowdsale contract deployment.   

<!-- START doctoc -->
<!-- END doctoc -->

## Library Address   

**ENS**: TBD   
**Main Ethereum Network**: TBD   
**Ropsten Test Network**: TBD   
**Rinkeby Test Network**: 0xd0c49af4e8b8abadc0803899f1fb5203f4b4a6c2   

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

1. Place the CrowdsaleLib.sol (from the root CrowdsaleLib directory) and EvenDistroCrowdsaleLib.sol file in your truffle `contracts/` directory.
2. Place the CrowdsaleLib.json and EvenDistroCrowdsaleLib.json file in your truffle `build/contracts/` directory.
3. Amend the deployment .js file in your truffle `migrations/` directory as follows:

```js
var CrowdsaleLib = artifacts.require("./CrowdsaleLib.sol")
var EvenDistroCrowdsaleLib = artifacts.require("./EvenDistroCrowdsaleLib.sol");
var OtherLibs = artifacts.require("./OtherLibs.sol");
var YourCrowdsaleContract = artifacts.require("./YourCrowdsaleContract.sol");
...

module.exports = function(deployer) {
  deployer.deploy(CrowdsaleLib, {overwrite: false});
  deployer.deploy(EvenDistroCrowdsaleLib, {overwrite: false});
  deployer.link(CrowdsaleLib, YourCrowdsaleContract)
  deployer.link(EvenDistroCrowdsaleLib, YourCrowdsaleContract);
  deployer.deploy(YourCrowdsaleContract, arg1, arg2,...);
};
```

**Note**: The `.link()` function should be called *before* you `.deploy(YourOtherContract)`. Also, be sure to include the `{overwrite: false}` when writing the deployer i.e. `.deploy(EvenDistroCrowdsaleLib, {overwrite: false})`. This prevents deploying the library onto the main network at your cost and uses the library already on the blockchain. The function should still be called however because it allows you to use it in your development environment. *See below*

#### Testing the library in truffle

The following process will allow you to `truffle test` this library in your project.

1. Clone or download the ethereum-libraries repository into its own directory on your computer. You can also use subversion to download just this truffle directory by running `svn checkout https://github.com/Majoolr/ethereum-libraries/trunk/EvenDistroCrowdsaleLib/truffle`.    
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
    "EvenDistroCrowdsaleLib.sol": {
      "content": "[Contents of EvenDistroCrowdsaleLib.sol]"
    }
  },
  "settings":
  {
    ...
    "libraries": {
      "YourCrowdsaleContract.sol": {
        "CrowdsaleLib": "0xcd9e2e077d7f4e94812c6fd6ecc1e22e267c52e1",
        "EvenDistroCrowdsaleLib": ""
      }
    }
  }
}
```

#### solc without standard JSON input

When creating unlinked binary, the compiler currently leaves special substrings in the compiled bytecode in the form of '__LibraryName______' which leaves a 20 byte space for the library's address. In order to include both deployed libraries in your bytecode create a file with one library string per line  as follows:    

```
"CrowdsaleLib:0xcd9e2e077d7f4e94812c6fd6ecc1e22e267c52e1"
"EvenDistroCrowdsaleLib:"
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
var lib = fs.readFileSync('./path/to/EvenDistroCrowdsaleLib.sol','utf8');

var input = {
  "language": "Solidity",
  "sources":
  {
    "YourCrowdsaleContract.sol": {
      "content": file
    },
    "EvenDistroCrowdsaleLib.sol": {
      "content": lib
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
        "EvenDistroCrowdsaleLib": ""
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

The Even Distribution Crowdsale library provides functionality needed to launch a crowdsale where users pre-register and there is a cap of how much ether an address can contribute. It is made up of two library contracts, a base library and a library specific to this type of crowdsale structure. Both should be included in your project. The crowdsale will have some of the following characteristics:

   * Sets a raise cap in terms of dollars and cents.
   * Allows single and batch user registration handled by the owner.
   * Can set the interval between changes in the address cap.
   * Can set a static cap for use throughout the sale, or can calculate a cap based on the number of participants registered for the sale.
   * Sets an exchange rate for dollars/ETH up to three days before the sale begins, which also calculates the cap at the same time.
   * Can set a percentage of extra tokens to burn after the sale ends with the remainder going back to the owners.

The crowdsale contract should put the `init` function in the constructor with the required parameters given. The crowdsale library functions will generally return false and log an error event when submitted parameters are either wrong or the call will not work.

**DISCLAIMER:** As always, please ensure you review this code thoroughly for your team's use. We strive to make our code as solid, clean, and well documented as possible but will not accept liability for unforeseen circumstances in which value is lost or stolen. This includes but not limited to any inability to meet signature requirements to move funds, loss of private keys, transactions you deem unauthorized from an owner's account, etc. The library code has been thoroughly tested by our team and believe it to be suitable enough to be posted in our open source repository, however, you are still responsible for its implementation and security in your smart contract. Please use your best judgment. Please [let us know immediately](https://majoolr.io \"Majoolr website\") if you have discovered any issues or vulnerabilities with this library.

## Functions

The following is the list of functions available to use in your smart contract.

#### init(EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage storage, address, uint256, uint256, uint256,uint256[], uint256, uint256, uint8, CrowdsaleToken)   
*(EvenDistroCrowdsaleLib.sol, line 90)*

Constructor. Initialize the crowdsale with owner, raise cap (in cents), startTime, endTime, token price (in cents), fall back exchange rate, a time interval between address cap changes, burn percentage, a multiplier that will be used to increase the address cap, a fallback address cap, and the address of the deployed token contract.  Passes some values to the base constructor then sets the direct crowdsale specific storage variables.

##### Arguments
**EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage** self   
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

#### registerUser(EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage storage, address)   
*(EvenDistroCrowdsaleLib.sol, line 130)*

Registers an individual user for the crowdsale.  Only the owner can call this function.  If the sale has a static cap, there is no restriction on when it can be called.  If the cap is calculated, it has to be called more than 3 days before the sale.

##### Arguments
**EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage** self   
**address** _registrant Address of a buyer who is registering for the sale.

##### Returns
**bool**   

#### registerUsers(EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage storage, address[])   
*(EvenDistroCrowdsaleLib.sol, line 158)*

Registers a group of users for the crowdsale.  Only the owner can call this function. If the sale has a static cap, there is no restriction on when it can be called.  If the cap is calculated, it has to be called more than 3 days before the sale.

##### Arguments
**EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage** self   
**address[]** _registrants Addresses of buyers who are registering for the sale.

##### Returns
**bool**   

#### unregisterUser(EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage storage, address)   
*(EvenDistroCrowdsaleLib.sol, line 172)*

Registers an individual user for the crowdsale.  Only the owner can call this function. If the sale has a static cap, there is no restriction on when it can be called.  If the cap is calculated, it has to be called more than 3 days before the sale.

##### Arguments
**EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage** self   
**address** _registrant Address of a buyer who is unregistering for the sale.

##### Returns
**bool**   

#### unregisterUsers(EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage storage, address[])   
*(EvenDistroCrowdsaleLib.sol, line 199)*

UnRegisters a group of users for the crowdsale.  Only the owner can call this function.  If the sale has a static cap, there is no restriction on when it can be called.  If the cap is calculated, it has to be called more than 3 days before the sale.

##### Arguments
**EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage** self   
**address[]** _registrants Addresses of buyers who are unregistering for the sale.

##### Returns
**bool**   

#### calculateAddressCap(EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage storage)   
*(EvenDistroCrowdsaleLib.sol, line 211)*

Internal function used for calculating the puchase cap per address.  It divides the total Ether raise cap by the total number of registrants to find the cap and emits an event.

##### Arguments
**EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage** self

##### Returns
**bool**   

#### receivePurchase(EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage storage, uint256)   
*(EvenDistroCrowdsaleLib.sol, line 244)*

Accepts payment for tokens and allocates tokens available to withdraw to the buyers place in the token mapping.  Calls validPurchase to check if the purchase is legal.  If the purchase goes over the raise cap for the sale, the ether is returned and no tokens are transferred.  If the payment exceeds the address cap, the tokens are still credited to the buyer and the leftover wei is indicated in the leftoverWei mapping. If the time interval for cap changes has passed, it also calculates the new address cap by multiplying the old cap by the percentage multiplier.  

Tokens purchased are calculated by multiplying the wei contributed by the tokensPerEth value, then moving the decimal place to reflect the token's specified granularity.  Mappings for buyer contribution, tokens purchased, and any leftover wei are updated, as well as total wei raised in the sale.

##### Arguments
**EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage** self The data storage in the calling contract.   
**uint256** _amount Amount being paid in terms of wei.

##### Returns
**bool** True if transaction confirmed or revoked successfully.   

#### setTokenExchangeRate(EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage storage, uint256)   
*(EvenDistroCrowdsaleLib.sol, line 327)*

Function that is called by the owner to set the exhange rate (cents/ETH).  In addition to setting the exchange rate, it calculates the corresponding price of the tokens in tokens per ETH.  Calling this will also call the calculateAddressCap function.  Only the owner can call this function and it can only be called within 3 days of the crowdsale officially starting to get an accurate ETH-USD price.  It can also only be called once.  Once the price is set, it cannot be changed.

##### Arguments
**EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage** self   
**uint256** _amount

##### Returns
**bool**   
