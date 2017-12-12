Array Utility Libraries
=========================

[![Build Status](https://travis-ci.org/Modular-Network/ethereum-libraries.svg?branch=master)](https://travis-ci.org/Modular-Network/ethereum-libraries)
[![Discord](https://img.shields.io/discord/102860784329052160.svg)](https://discord.gg/crxYSF2)   

An array utility library [provided by Modular](https://modular.network "Modular's Website") .   

*Note: Each uint array type now has its own library. If your storage array contains uint16[] types, for instance, then you would link to the Array16Lib.sol library. This README uses the Array256Lib for all examples.*

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Library Addresses](#library-addresses)
  - [Array256Lib](#array256lib)
  - [Array128Lib](#array128lib)
  - [Array64Lib](#array64lib)
  - [Array32Lib](#array32lib)
  - [Array16Lib](#array16lib)
  - [Array8Lib](#array8lib)
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
  - [Usage Note](#usage-note)
- [Functions](#functions)
    - [sumElements(uint256[] storage) public view returns(uint256)](#sumelementsuint256-storage-public-view-returnsuint256)
      - [Arguments](#arguments)
      - [Returns](#returns)
    - [getMax(uint256[] storage) public view returns(uint256)](#getmaxuint256-storage-public-view-returnsuint256)
      - [Arguments](#arguments-1)
      - [Returns](#returns-1)
    - [getMin(uint256[] storage) public view returns(uint256)](#getminuint256-storage-public-view-returnsuint256)
      - [Arguments](#arguments-2)
      - [Returns](#returns-2)
    - [indexOf(uint256[] storage, uint256, bool) public view returns(bool, uint256)](#indexofuint256-storage-uint256-bool-public-view-returnsbool-uint256)
      - [Arguments](#arguments-3)
      - [Returns](#returns-3)
    - [heapSort(uint256[] storage self) public](#heapsortuint256-storage-self-public)
      - [Arguments](#arguments-4)
    - [uniq(uint256[] storage) public returns (uint256)](#uniquint256-storage-public-returns-uint256)
      - [Arguments](#arguments-5)
      - [Returns](#returns-4)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Library Addresses

### Array256Lib   
**ENS**: TBD   
**Main Ethereum Network**: 0xD620Ce17fC516671F0fA84Ac88e39dCBb0a1615A   
**Rinkeby Test Network**: 0x8d05ae16246A22dc8C75bcF8De6c418782c174f5   
**Ropsten Test Network**: 0x2a54B21BA120BEd011356EAF11Dc6e5CA8132B91    

### Array128Lib   
**ENS**: TBD   
**Main Ethereum Network**: 0xaaed720C987B25E8CC0f4C0d1827F8b0C8545B41   
**Rinkeby Test Network**: 0x31D5f41761D4145433b6F39C59781Ae331148C4F   
**Ropsten Test Network**: 0x3EA41321B4787262827fD76D33f1ddfa76A47184    

### Array64Lib   
**ENS**: TBD   
**Main Ethereum Network**: 0xa13533142ddd31dDb2C9DA7F82BB083696182C71   
**Rinkeby Test Network**: 0x5b597FD52bbE6455E0A86006C6Fd8FECA2785Ff0   
**Ropsten Test Network**: 0xc0cCE76F81D5c6694b7adA58855E372899B2b005    

### Array32Lib   
**ENS**: TBD   
**Main Ethereum Network**: 0x58ab2F692C606c520ACaf784FE4F0553ccD4Db8a   
**Rinkeby Test Network**: 0xd1Cd92b015f483255f8a305D2c7a99E0A0B4d818   
**Ropsten Test Network**: 0x144AEAF15EC3f9850cc88F31928F3a55cB849360    

### Array16Lib   
**ENS**: TBD   
**Main Ethereum Network**: 0xb6Cbc04D803d323f678b430751a8ED23276A5A57   
**Rinkeby Test Network**: 0x90AdcDa446f6f42583965A13FF1703b094090BA3   
**Ropsten Test Network**: 0xC94821766f2C8c2a98BA5532C5ea7ea174A140E2    

### Array8Lib   
**ENS**: TBD   
**Main Ethereum Network**: 0x85D2317f73e45bF266283b653B7407C95c0D2Ba6   
**Rinkeby Test Network**: 0x41773f6A40C4A8049225b3E2ADCe67326fb023da   
**Ropsten Test Network**: 0xe1ca2c0C8ec95b20E6f8a02318441221b232C3B6   

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

This process will allow you to both link your contract to the current on-chain library as well as deploy it in your local environment for development.

1. Place the Array256Lib.sol file in your truffle `contracts/` directory.
2. Place the Array256Lib.json file in your truffle `build/contracts/` directory.
3. Amend the deployment .js file in your truffle `migrations/` directory as follows:

```js
var Array256Lib = artifacts.require("./Array256Lib.sol");
var OtherLibs = artifacts.require("./OtherLibs.sol");
var YourOtherContract = artifacts.require("./YourOtherContract.sol");
...

module.exports = function(deployer) {
  deployer.deploy(Array256Lib, {overwrite: false});
  deployer.link(Array256Lib, YourOtherContract);
  deployer.deploy(YourOtherContract);
};
```

**Note**: The `.link()` function should be called *before* you `.deploy(YourOtherContract)`. Also, be sure to include the `{overwrite: false}` when writing the deployer i.e. `.deploy(Array256Lib, {overwrite: false})`. This prevents deploying the library onto the main network or Rinkeby test network at your cost and uses the library already on the blockchain. The function should still be called however because it allows you to use it in your development environment. *See below*

#### Testing the library in truffle

The following process will allow you to `truffle test` this library in your project.

1. Clone or download the ethereum-libraries repository into its own directory on your computer. You can also use subversion to download just this truffle directory by running `svn checkout https://github.com/Modular-Network/ethereum-libraries/trunk/ArrayUtilsLib/truffle`.    
   Each folder in the truffle directory correlates to the folders in your truffle project.   
2. Go into the ArrayUtilsLib truffle directory on your computer and place each file in their respective directory in **your** truffle project.
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
    "Array256Lib.sol": {
      "content": "[Contents of Array256Lib.sol]"
    }
  },
  "settings":
  {
    ...
    "libraries": {
      "YourContract.sol": {
        "Array256Lib": "0xD620Ce17fC516671F0fA84Ac88e39dCBb0a1615A"
      }
    }
  }
}
```
**Note**: The library name should match the name used in your contract.

#### solc without standard JSON input

When creating unlinked binary, the compiler currently leaves special substrings in the compiled bytecode in the form of '__LibraryName______' which leaves a 20 byte space for the library's address. In order to include the deployed library in your bytecode add the following flag to your command:

`--libraries "Array256Lib:0xD620Ce17fC516671F0fA84Ac88e39dCBb0a1615A"`

Additionally, if you have multiple libraries, you can create a file with one library string per line and include this library as follows:

`"Array256Lib:0xD620Ce17fC516671F0fA84Ac88e39dCBb0a1615A"`

then add the following flag to your command:

`--libraries filename`

Finally, if you have an unlinked binary already stored with the '__LibraryName______' placeholder, you can run the compiler with the --link flag and also include the following flag:

`--libraries "Array256Lib:0xD620Ce17fC516671F0fA84Ac88e39dCBb0a1615A"`

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
var lib = fs.readFileSync('./path/to/Array256Lib.sol','utf8');

var input = {
  "language": "Solidity",
  "sources":
  {
    "YourContract.sol": {
      "content": file
    },
    "Array256Lib.sol": {
      "content": lib
    }
  },
  "settings":
  {
    ...
    "libraries": {
      "YourContract.sol": {
        "Array256Lib": "0xD620Ce17fC516671F0fA84Ac88e39dCBb0a1615A"
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
 bytecode = solc.linkBytecode(bytecode, { 'Array256Lib': '0xD620Ce17fC516671F0fA84Ac88e39dCBb0a1615A' });
 ```

#### Solc-js documentation

[See the Solc-js documentation for further information](https://github.com/ethereum/solc-js "Solc-js compiler").

## Basic Usage

*Disclaimer: While we make every effort to produce professional grade code we can not guarantee the security and performance of these libraries in your smart contracts. Please use good judgement and security practices while developing, we do not take responsibility for any issues you, your customers, or your applications encounter when using these open source resources.

For a detailed explanation on how libraries are used please read the following from the Solidity documentation:

   * [Libraries](http://solidity.readthedocs.io/en/develop/contracts.html#libraries)
   * [Using For](http://solidity.readthedocs.io/en/develop/contracts.html#using-for)

The Array Utility libraries provide several utility functions for contracts that contain storage arrays. Each library handles the specified uint type and either returns the uint value or, in the case of heapSort, sorts the given array in place which helps to reduce gas costs because of low memory usage.   

When using the `indexOf` function be sure to provide a return tuple and check to ensure the value was found in the array. The function will return 0 as the index if the value was not found. See the usage example below.

### Usage Example

```
pragma solidity ^0.4.18;

import "./Array256Lib.sol";

contract YourContract {
  using Array256Lib for uint256[];

  uint256[] array;

  //Then in your function you can call array.function([second argument])
  //Your arguments should be of the same type you bound the library to
  function getSortedIndexOf() returns (bool,uint256){
    bool found;
    uint256 index;
    //The first value in the arguments is the value we're searching for and true
    //indicates the array is sorted
    (found,index) = array.indexOf(7,true);

    //found will now be true if 7 is in the array and index will be the index of 7
  }

  function sortMyStorageArray(){
    array.heapSort();

    //Your array is now sorted
  }
}
```

Binding the library allows you to call the function in the format array.function(otherParameter)

### Usage Note

All of the functions only accept storage arrays containing the approprate uint type.

## Functions

The following is the list of functions available to use in your smart contract.

#### sumElements(uint256[] storage) public view returns(uint256)
*(Array256Lib.sol, line 35)*   

Returns the sum of the array elements

##### Arguments
**uint256[] storage variable** self   

##### Returns
**uint256** sum    

#### getMax(uint256[] storage) public view returns(uint256)
*(Array256Lib.sol, line 48)*

Returns the maximum value in the given array.

##### Arguments
**uint256[] storage** self   

##### Returns
**uint256** maxValue   

#### getMin(uint256[] storage) public view returns(uint256)
*(Array256Lib.sol, line 65)*

Returns the minimum value in the given array.

##### Arguments
**uint256[] storage** self   

##### Returns
**uint256** minValue    

#### indexOf(uint256[] storage, uint256, bool) public view returns(bool, uint256)
*(Array256Lib.sol, line 85)*

Returns true and the index of the given value if found or false and 0 otherwise

##### Arguments
**uint256[] storage** self   
**uint256** value   
**bool** isSorted    

##### Returns
**bool** found    
**uint256** index    

#### heapSort(uint256[] storage self) public
*(ArrayUtilsLib.sol, line 147)*

Sorts the given array.

##### Arguments
**uint256[] storage** self   

#### uniq(uint256[] storage) public returns (uint256)
*(Array256Lib.sol, line 209)*

Removes duplicates from a given array.

##### Arguments
**uint256[] storage** self   

##### Returns
**uint256** length    
