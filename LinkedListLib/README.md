LinkedListLib
=========================   

[![Build Status](https://travis-ci.org/Modular-Network/ethereum-libraries.svg?branch=master)](https://travis-ci.org/Modular-Network/ethereum-libraries)
[![Discord](https://img.shields.io/discord/102860784329052160.svg)](https://discord.gg/crxYSF2)    

A linked list library [provided by Modular-Network](https://github.com/Modular-Network "Modular-Network's Github") for using linked list data structures in your project.   

This utility library was forked from https://github.com/o0ragman0o/LibCLL into the Modular-Network ethereum-libraries repo at https://github.com/Modular-Network/ethereum-libraries

It has been updated to add additional functionality and be more compatible with solidity 0.4.18 coding patterns.

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
    - [solc documentation](#solc-documentation)
  - [solc-js Installation](#solc-js-installation)
    - [Solc-js documentation](#solc-js-documentation)
- [Overview](#overview)
  - [Basic Usage](#basic-usage)
  - [Mutations to State](#mutations-to-state)
- [Functions](#functions)
    - [listExists(LinkedListLib.LinkedList storage)](#listexistslinkedlistliblinkedlist-storage)
      - [Arguments](#arguments)
      - [Returns](#returns)
    - [nodeExists(LinkedListLib.LinkedList storage)](#nodeexistslinkedlistliblinkedlist-storage)
      - [Arguments](#arguments-1)
      - [Returns](#returns-1)
    - [sizeOf(LinkedListLib.LinkedList storage)](#sizeoflinkedlistliblinkedlist-storage)
      - [Arguments](#arguments-2)
      - [Returns](#returns-2)
    - [getNode(LinkedListLib.LinkedList storage, uint256)](#getnodelinkedlistliblinkedlist-storage-uint256)
      - [Arguments](#arguments-3)
      - [Returns](#returns-3)
    - [getAdjacent(LinkedListLib.LinkedList storage, uint256, bool)](#getadjacentlinkedlistliblinkedlist-storage-uint256-bool)
      - [Arguments](#arguments-4)
      - [Returns](#returns-4)
    - [getSortedSpot(LinkedListLib.LinkedList storage, uint256, uint256, bool)](#getsortedspotlinkedlistliblinkedlist-storage-uint256-uint256-bool)
      - [Arguments](#arguments-5)
      - [Returns](#returns-5)
    - [createLink(LinkedListLib.LinkedList storage, uint256, uint256, bool)](#createlinklinkedlistliblinkedlist-storage-uint256-uint256-bool)
      - [Arguments](#arguments-6)
      - [Returns](#returns-6)
    - [insert(LinkedListLib.LinkedList storage, uint256, uint256, bool)](#insertlinkedlistliblinkedlist-storage-uint256-uint256-bool)
      - [Arguments](#arguments-7)
      - [Returns](#returns-7)
    - [remove(LinkedListLib.LinkedList storage, uint256)](#removelinkedlistliblinkedlist-storage-uint256)
      - [Arguments](#arguments-8)
      - [Returns](#returns-8)
    - [push(LinkedListLib.LinkedList storage, uint256, bool)](#pushlinkedlistliblinkedlist-storage-uint256-bool)
      - [Arguments](#arguments-9)
      - [Returns](#returns-9)
    - [pop(LinkedListLib.LinkedList storage, bool)](#poplinkedlistliblinkedlist-storage-bool)
      - [Arguments](#arguments-10)
      - [Returns](#returns-10)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Library Address   

This library includes only internal functions at this time and therefore does not
need to be deployed for use.  

## License and Warranty   

Be advised that while we strive to provide professional grade, tested code we cannot guarantee its fitness for your application. This is released under [The MIT License (MIT)](https://github.com/Modular-Network/ethereum-libraries/blob/master/LICENSE "MIT License") and as such we will not be held liable for lost funds, etc. Please use your best judgment and note the following:   

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
## How to install

### Truffle Installation

**version 4.0.1**   

First install truffle via npm using `npm install -g truffle` .   

Please [visit Truffle's installation guide](http://truffleframework.com/docs/getting_started/installation "Truffle installation guide") for further information and requirements.

#### Manual Install

This process will allow you to both link your contract to the current on-chain library as well as deploy it in your local environment for development.   

1. Place the LinkedListLib.sol file in your truffle `contracts/` directory.
2. Place the LinkedListLib.json file in your truffle `build/contracts/` directory.
3. Amend the deployment .js file in your truffle `migrations/` directory as follows:

```js
var LinkedListLib = artifacts.require("./LinkedListLib.sol");
var YourOtherContract = artifacts.require("./YourOtherContract.sol");
...

module.exports = function(deployer) {
  deployer.deploy(YourOtherContract);
};
```

#### Testing the library in truffle

The following process will allow you to `truffle test` this library in your project.

1. Clone or download the ethereum-libraries repository into its own directory on your computer. You can also use subversion to download just this truffle directory by running `svn checkout https://github.com/Modular-Network/ethereum-libraries/trunk/LinkedListLib/truffle`.    
2. Place each file in their respective directory in **your** truffle project.   
   **Note**: The `2_deploy_test_contracts.js` file should either be renamed to the next highest number among your migrations files i.e. `3_deploy_test_contracts.js` or you can place the code in your existing deployment migration file. *See Quick Install above.*
3. [Download and start Ganache](http://truffleframework.com/ganache/ "Ganache Download")
4. In your terminal go to your truffle project directory and run `truffle migrate`.    +4. In your terminal go to your truffle project directory.
5. After migration run `truffle test`.     +5. Ensure the `development` object in your truffle.js file points to the same port Ganache uses, default is 7545.
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
    "StringUtilsLib.sol": {
      "content": "[Contents of LinkedListLib.sol]"
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
var StringUtilsLib = fs.readFileSync('./path/to/LinkedListLib.sol','utf8');

var input = {
  "language": "Solidity",
  "sources":
  {
    "YourContract.sol": {
      "content": file
    },
    "StringUtilsLib.sol": {
      "content": LinkedListLib
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

### Basic Usage

The Linked List library provides functionality needed to create and manipulate a Circular Linked List Data structure by allowing a multitude of different functions to be used to interact with the struct.  Functions like push() and pop() can be used to create a FILO stack or FIFO ring buffer.  getAdjacent() can also be used to iterate over the list.  Brief description of functionality:

   * Can check if the list exists and find the size.
   * Can check if a certain node exists.
   * Gets adjacent nodes to a specified node.
   * Finds a spot in a sorted list for a new node to be placed.
   * Insert nodes and create links between nodes.
   * Remove, push, and pop nodes from the list.

LinkedList is a nested mapping with the first key being the node index (uint256) and the second being the bidirectional link (bool) to a neighboring node. Key 0 implies the head so writes to LinkedList.list[0] or manually linking to Linkedlist.list[0] (e.g. `list[var1][false] = 0;`) are to be avoided by the calling contract.

```
    struct LinkedList{
        mapping (uint256 => mapping (bool => uint256)) cll;
    }
```
### Mutations to State

The bidirectional links consist of two State slots (2x uint256) which are written to by the function createLink(). insert() calls createLink() twice for a total of 4 state mutations. remove calls createLink() once and deletes two slots.

**DISCLAIMER:** As always, please ensure you review this code thoroughly for your team's use. We strive to make our code as solid, clean, and well documented as possible but will not accept liability for unforeseen circumstances in which value is lost or stolen. This includes but not limited to any inability to meet signature requirements to move funds, loss of private keys, transactions you deem unauthorized from an owner's account, etc. The library code has been thoroughly tested by our team and believe it to be suitable enough to be posted in our open source repository, however, you are still responsible for its implementation and security in your smart contract. Please use your best judgment. Please [let us know immediately](https://modular.network \"Modular-Network website\") if you have discovered any issues or vulnerabilities with this library.

## Functions

The following is the list of functions available to use in your smart contract.

#### listExists(LinkedListLib.LinkedList storage)   
*(LinkedListLib.sol, line 46)*

Checks to see if the list exists. If there is only a head node, it does not exist.

##### Arguments
**LinkedListLib.LinkedList** self

##### Returns
**bool**   

#### nodeExists(LinkedListLib.LinkedList storage)   
*(LinkedListLib.sol, line 51)*

Checks to see if a specific node exists.

##### Arguments
**LinkedListLib.LinkedList** self
**uint256** _node index of the node to look for

##### Returns
**bool**   

#### sizeOf(LinkedListLib.LinkedList storage)   
*(LinkedListLib.sol, line 78)*

Finds the size of the linked list.  Head node does not count toward size.

##### Arguments
**LinkedListLib.LinkedList** self

##### Returns
**uint256**   

#### getNode(LinkedListLib.LinkedList storage, uint256)   
*(LinkedListLib.sol, line 92)*

Returns the links of a node as a tuple.

##### Arguments
**LinkedListLib.LinkedList** self   
 **uint256** _node index of the node to look for

##### Returns
**(bool,uint256,uint256)** bool indicating if the node exists or not, then the PREV and NEXT node, in that order, both 0 if the node doesn't exist.  

#### getAdjacent(LinkedListLib.LinkedList storage, uint256, bool)   
*(LinkedListLib.sol, line 106)*

 Returns the link of a node `_node` in direction `_direction`.

##### Arguments
**LinkedListLib.LinkedList** self   
 **uint256** _node an existing node to search from   
 **bool** _direction a direction to search in

##### Returns
**(bool,uint256)**  bool indicating if the node exists, then the adjacent node

#### getSortedSpot(LinkedListLib.LinkedList storage, uint256, uint256, bool)   
*(LinkedListLib.sol, line 122)*

Finds the spot in a sorted list where 'value' can be inserted.  Used before insert to build a sorted list.

##### Arguments
**LinkedListLib.LinkedList** self   
 **uint256** _node an existing node to search from   
 **uint256** _value node nubmer to find a place for **bool** _direction a direction to search in. if NEXT, returns the node after the found spot, if BEFORE, returns the node before.

##### Returns
**uint256**   

#### createLink(LinkedListLib.LinkedList storage, uint256, uint256, bool)   
*(LinkedListLib.sol, line 138)*

Creates a bidirectional link between two nodes in direction `_direction`.

##### Arguments
**LinkedListLib.LinkedList** self   
 **uint256** _node first node to link.   
 **uint256** _link node to link to   
 **bool** _direction a direction to link in (from the first node)

##### Returns


#### insert(LinkedListLib.LinkedList storage, uint256, uint256, bool)   
*(LinkedListLib.sol, line 148)*

 Insert node `_new` beside existing node `_node` in direction `_direction`.

##### Arguments
**LinkedListLib.LinkedList** self   
 **uint256** _node an existing node to insert next to.   
 **uint256** a new node to insert in the list.   
 **bool** _direction a direction to insert in

##### Returns


#### remove(LinkedListLib.LinkedList storage, uint256)   
*(LinkedListLib.sol, line 162)*

Removes node _node from the list.

##### Arguments
**LinkedListLib.LinkedList** self   
 **uint256** _node an existing node to remove.  

##### Returns
**uint256**   

#### push(LinkedListLib.LinkedList storage, uint256, bool)   
*(LinkedListLib.sol, line 174)*

pushes a new node to one end of the list.

##### Arguments
**LinkedListLib.LinkedList** self   
 **uint256** _node an existing node to push to the list.   
 **bool** _direction direction to push the node. NEXT for head. PREV for tail.

##### Returns


#### pop(LinkedListLib.LinkedList storage, bool)   
*(LinkedListLib.sol, line 181)*

Pops a node of an end of the list.

##### Arguments
**LinkedListLib.LinkedList** self   
 **bool** _direction a direction to pop the node from.  NEXT for head. PREV for tail.

##### Returns
**uint256**   
