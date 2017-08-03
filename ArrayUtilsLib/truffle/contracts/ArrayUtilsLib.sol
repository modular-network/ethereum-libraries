pragma solidity ^0.4.13;

/**
 * @title Array Utilities Library
 * @author Majoolr.io
 *
 * version 1.0.1
 * Copyright (c) 2017 Majoolr, LLC
 * The MIT License (MIT)
 * https://github.com/Majoolr/ethereum-libraries/blob/master/LICENSE
 *
 * The Array Utilities Library provides a few utility functions to work with
 * storage arrays in place. Majoolr works on open source projects in the Ethereum
 * community with the purpose of testing, documenting, and deploying reusable
 * code onto the blockchain to improve security and usability of smart
 * contracts. Majoolr also strives to educate non-profits, schools, and other
 * community members about the application of blockchain technology.
 * For further information: majoolr.io
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

library ArrayUtilsLib {

  function rightShift(uint256 term, uint128 numBytes) constant returns (uint256 result) {
    assembly {
      switch numBytes 
      case 1 {
        for { let j := 0 } lt(j, 1) { j := add(j, 1) } {
          term := div(term,256)
        }
      }
      case 16 {
        for { let j := 0 } lt(j, 16) { j := add(j, 1) } {
          term := div(term,256)
        }
      }
      result := term
    }
  }


  /// @dev Sum vector
  /// @param self Storage array containing uint256 type variables
  /// @return sum The sum of all elements, does not check for overflow
  function sumElements(uint256[] storage self) constant returns(uint256 sum) {
    assembly { 
      mstore(0x60,self_slot) 

      for { let i := 0 } lt(i, sload(self_slot)) { i := add(i, 1) } {
        sum := add(sload(add(sha3(0x60,0x20),i)),sum)
      }
    }
  }

  function sumElements(uint128[] storage self) constant returns(uint128 sum) {
    uint256 term;
    assembly { 
      mstore(0x60,self_slot) 

      for { let i := 0 } lt(i, sload(self_slot)) { i := add(i, 1) } {
        term := sload(add(sha3(0x60,0x20),div(i,2)))

        //term := rightShift(term, 16) 

        switch mod(i,2)
        case 1 {
          for { let j := 0 } lt(j, 4) { j := add(j, 1) } {
            term := div(term,4294967296)
          }
          
        }

        term := and(0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff,term)
        sum := add(term,sum)

      }
    }
  }

  function sumElements(uint64[] storage self) constant returns(uint64 sum) {
    uint256 term;
    assembly { 
      mstore(0x60,self_slot) 

      for { let i := 0 } lt(i, sload(self_slot)) { i := add(i, 1) } {
        term := sload(add(sha3(0x60,0x20),div(i,4)))

        switch mod(i,4)
        case 1 {
          for { let j := 0 } lt(j, 2) { j := add(j, 1) } {
            term := div(term,4294967296)
          }
        }
        case 2 {
          for { let j := 0 } lt(j, 4) { j := add(j, 1) } {
            term := div(term,4294967296)
          }
        }
        case 3 {
          for { let j := 0 } lt(j, 6) { j := add(j, 1) } {
            term := div(term,4294967296)
          }
        }

        term := and(0x000000000000000000000000000000000000000000000000ffffffffffffffff,term)
        sum := add(term,sum)

      }
    }
  }

  function sumElements(uint32[] storage self) constant returns(uint32 sum) {
    uint256 term;
    assembly { 
      mstore(0x60,self_slot) 

      for { let i := 0 } lt(i, sload(self_slot)) { i := add(i, 1) } {
        term := sload(add(sha3(0x60,0x20),div(i,8)))

        switch mod(i,8)
        case 1 {
          for { let j := 0 } lt(j, 1) { j := add(j, 1) } {
            term := div(term,4294967296)
          }
        }
        case 2 {
          for { let j := 0 } lt(j, 2) { j := add(j, 1) } {
            term := div(term,4294967296)
          }
        }
        case 3 {
          for { let j := 0 } lt(j, 3) { j := add(j, 1) } {
            term := div(term,4294967296)
          }
        }
        case 4 {
          for { let j := 0 } lt(j, 4) { j := add(j, 1) } {
            term := div(term,4294967296)
          }
        }
        case 5 {
          for { let j := 0 } lt(j, 5) { j := add(j, 1) } {
            term := div(term,4294967296)
          }
        }
        case 6 {
          for { let j := 0 } lt(j, 6) { j := add(j, 1) } {
            term := div(term,4294967296)
          }
        }
        case 7 {
          for { let j := 0 } lt(j, 7) { j := add(j, 1) } {
            term := div(term,4294967296)
          }
        }

        term := and(0x00000000000000000000000000000000000000000000000000000000ffffffff,term)
        sum := add(term,sum)

      }
    }
  }

  function sumElements(uint16[] storage self) constant returns(uint16 sum) {
    uint256 term;
    assembly { 
      mstore(0x60,self_slot) 

      for { let i := 0 } lt(i, sload(self_slot)) { i := add(i, 1) } {
        term := sload(add(sha3(0x60,0x20),div(i,16)))

        switch mod(i,16)
        case 1 {
          for { let j := 0 } lt(j, 1) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 2 {
          for { let j := 0 } lt(j, 2) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 3 {
          for { let j := 0 } lt(j, 3) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 4 {
          for { let j := 0 } lt(j, 4) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 5 {
          for { let j := 0 } lt(j, 5) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 6 {
          for { let j := 0 } lt(j, 6) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 7 {
          for { let j := 0 } lt(j, 7) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 8 {
          for { let j := 0 } lt(j, 8) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 9 {
          for { let j := 0 } lt(j, 9) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 10 {
          for { let j := 0 } lt(j, 10) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 11 {
          for { let j := 0 } lt(j, 11) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 12 {
          for { let j := 0 } lt(j, 12) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 13 {
          for { let j := 0 } lt(j, 13) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 14 {
          for { let j := 0 } lt(j, 14) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 15 {
          for { let j := 0 } lt(j, 15) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }

        term := and(0x000000000000000000000000000000000000000000000000000000000000ffff,term)
        sum := add(term,sum)

      }
    }
  }

  function sumElements(uint8[] storage self) constant returns(uint8 sum) {
    uint256 term;
    assembly { 
      mstore(0x60,self_slot) 

      for { let i := 0 } lt(i, sload(self_slot)) { i := add(i, 1) } {
        term := sload(add(sha3(0x60,0x20),div(i,32)))

        switch mod(i,32)
        case 1 {
          for { let j := 0 } lt(j, 1) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 2 {
          for { let j := 0 } lt(j, 2) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 3 {
          for { let j := 0 } lt(j, 3) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 4 {
          for { let j := 0 } lt(j, 4) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 5 {
          for { let j := 0 } lt(j, 5) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 6 {
          for { let j := 0 } lt(j, 6) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 7 {
          for { let j := 0 } lt(j, 7) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 8 {
          for { let j := 0 } lt(j, 8) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 9 {
          for { let j := 0 } lt(j, 9) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 10 {
          for { let j := 0 } lt(j, 10) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 11 {
          for { let j := 0 } lt(j, 11) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 12 {
          for { let j := 0 } lt(j, 12) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 13 {
          for { let j := 0 } lt(j, 13) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 14 {
          for { let j := 0 } lt(j, 14) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 15 {
          for { let j := 0 } lt(j, 15) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 16 {
          for { let j := 0 } lt(j, 16) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 17 {
          for { let j := 0 } lt(j, 17) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 18 {
          for { let j := 0 } lt(j, 18) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 19 {
          for { let j := 0 } lt(j, 19) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 20 {
          for { let j := 0 } lt(j, 20) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 21 {
          for { let j := 0 } lt(j, 21) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 22 {
          for { let j := 0 } lt(j, 22) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 23 {
          for { let j := 0 } lt(j, 23) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 24 {
          for { let j := 0 } lt(j, 24) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 25 {
          for { let j := 0 } lt(j, 25) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 26 {
          for { let j := 0 } lt(j, 26) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 27 {
          for { let j := 0 } lt(j, 27) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 28 {
          for { let j := 0 } lt(j, 28) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 29 {
          for { let j := 0 } lt(j, 29) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 30 {
          for { let j := 0 } lt(j, 30) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 31 {
          for { let j := 0 } lt(j, 31) { j := add(j, 1) } {
            term := div(term,256)
          }
        }

        term := and(0x000000000000000000000000000000000000000000000000000000000000ffff,term)
        sum := add(term,sum)

      }
    }
  }

  /// @dev Returns the max value in an array.
  /// @param self Storage array containing uint256 type variables
  /// @return maxValue The highest value in the array
  function getMax(uint256[] storage self) constant returns(uint256 maxValue) {
    assembly { 
      mstore(0x60,self_slot) 
      maxValue := sload(sha3(0x60,0x20))

      for { let i := 0 } lt(i, sload(self_slot)) { i := add(i, 1) } {
        switch gt(sload(add(sha3(0x60,0x20),i)), maxValue)
        case 1 {
          maxValue := sload(add(sha3(0x60,0x20),i))
        }
      }
    }
  }

  function getMax(uint128[] storage self) constant returns(uint128 maxValue) {
    uint256 term;
    assembly { 
      mstore(0x60,self_slot) 
      maxValue := 0

      for { let i := 0 } lt(i, sload(self_slot)) { i := add(i, 1) } {
        term := sload(add(sha3(0x60,0x20),div(i,2)))

        switch mod(i,2)
        case 1 {
          for { let j := 0 } lt(j, 4) { j := add(j, 1) } {
            term := div(term,4294967296)
          }
        }

        term := and(0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff,term)
        switch lt(maxValue, term)
        case 1 {
          maxValue := term
        }
      }
    }
  }

  function getMax(uint64[] storage self) constant returns(uint64 maxValue) {
    uint256 term;
    assembly { 
      mstore(0x60,self_slot) 
      maxValue := 0

      for { let i := 0 } lt(i, sload(self_slot)) { i := add(i, 1) } {
        term := sload(add(sha3(0x60,0x20),div(i,4)))

        switch mod(i,4)
        case 1 {
          for { let j := 0 } lt(j, 2) { j := add(j, 1) } {
            term := div(term,4294967296)
          }
        }
        case 2 {
          for { let j := 0 } lt(j, 4) { j := add(j, 1) } {
            term := div(term,4294967296)
          }
        }
        case 3 {
          for { let j := 0 } lt(j, 6) { j := add(j, 1) } {
            term := div(term,4294967296)
          }
        }

        term := and(0x000000000000000000000000000000000000000000000000ffffffffffffffff,term)
        switch lt(maxValue, term)
        case 1 {
          maxValue := term
        }
      }
    }
  }

  function getMax(uint32[] storage self) constant returns(uint32 maxValue) {
    uint256 term;
    assembly { 
      mstore(0x60,self_slot) 
      maxValue := 0

      for { let i := 0 } lt(i, sload(self_slot)) { i := add(i, 1) } {
        term := sload(add(sha3(0x60,0x20),div(i,8)))

        switch mod(i,8)
        case 1 {
          for { let j := 0 } lt(j, 1) { j := add(j, 1) } {
            term := div(term,4294967296)
          }
        }
        case 2 {
          for { let j := 0 } lt(j, 2) { j := add(j, 1) } {
            term := div(term,4294967296)
          }
        }
        case 3 {
          for { let j := 0 } lt(j, 3) { j := add(j, 1) } {
            term := div(term,4294967296)
          }
        }
        case 4 {
          for { let j := 0 } lt(j, 4) { j := add(j, 1) } {
            term := div(term,4294967296)
          }
        }
        case 5 {
          for { let j := 0 } lt(j, 5) { j := add(j, 1) } {
            term := div(term,4294967296)
          }
        }
        case 6 {
          for { let j := 0 } lt(j, 6) { j := add(j, 1) } {
            term := div(term,4294967296)
          }
        }
        case 7 {
          for { let j := 0 } lt(j, 7) { j := add(j, 1) } {
            term := div(term,4294967296)
          }
        }

        term := and(0x00000000000000000000000000000000000000000000000000000000ffffffff,term)
        switch lt(maxValue, term)
        case 1 {
          maxValue := term
        }
      }
    }
  }

  function getMax(uint16[] storage self) constant returns(uint16 maxValue) {
    uint256 term;
    assembly { 
      mstore(0x60,self_slot) 
      maxValue := 0

      for { let i := 0 } lt(i, sload(self_slot)) { i := add(i, 1) } {
        term := sload(add(sha3(0x60,0x20),div(i,16)))

        switch mod(i,16)
        case 1 {
          for { let j := 0 } lt(j, 1) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 2 {
          for { let j := 0 } lt(j, 2) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 3 {
          for { let j := 0 } lt(j, 3) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 4 {
          for { let j := 0 } lt(j, 4) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 5 {
          for { let j := 0 } lt(j, 5) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 6 {
          for { let j := 0 } lt(j, 6) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 7 {
          for { let j := 0 } lt(j, 7) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 8 {
          for { let j := 0 } lt(j, 8) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 9 {
          for { let j := 0 } lt(j, 9) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 10 {
          for { let j := 0 } lt(j, 10) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 11 {
          for { let j := 0 } lt(j, 11) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 12 {
          for { let j := 0 } lt(j, 12) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 13 {
          for { let j := 0 } lt(j, 13) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 14 {
          for { let j := 0 } lt(j, 14) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 15 {
          for { let j := 0 } lt(j, 15) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }

        term := and(0x000000000000000000000000000000000000000000000000000000000000ffff,term)
        switch lt(maxValue, term)
        case 1 {
          maxValue := term
        }
      }
    }
  }

  function getMax(uint8[] storage self) constant returns(uint8 maxValue) {
    uint256 term;
    assembly { 
      mstore(0x60,self_slot) 
      maxValue := 0

      for { let i := 0 } lt(i, sload(self_slot)) { i := add(i, 1) } {
        term := sload(add(sha3(0x60,0x20),div(i,32)))

        switch mod(i,32)
        case 1 {
          for { let j := 0 } lt(j, 1) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 2 {
          for { let j := 0 } lt(j, 2) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 3 {
          for { let j := 0 } lt(j, 3) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 4 {
          for { let j := 0 } lt(j, 4) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 5 {
          for { let j := 0 } lt(j, 5) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 6 {
          for { let j := 0 } lt(j, 6) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 7 {
          for { let j := 0 } lt(j, 7) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 8 {
          for { let j := 0 } lt(j, 8) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 9 {
          for { let j := 0 } lt(j, 9) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 10 {
          for { let j := 0 } lt(j, 10) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 11 {
          for { let j := 0 } lt(j, 11) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 12 {
          for { let j := 0 } lt(j, 12) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 13 {
          for { let j := 0 } lt(j, 13) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 14 {
          for { let j := 0 } lt(j, 14) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 15 {
          for { let j := 0 } lt(j, 15) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 16 {
          for { let j := 0 } lt(j, 16) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 17 {
          for { let j := 0 } lt(j, 17) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 18 {
          for { let j := 0 } lt(j, 18) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 19 {
          for { let j := 0 } lt(j, 19) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 20 {
          for { let j := 0 } lt(j, 20) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 21 {
          for { let j := 0 } lt(j, 21) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 22 {
          for { let j := 0 } lt(j, 22) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 23 {
          for { let j := 0 } lt(j, 23) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 24 {
          for { let j := 0 } lt(j, 24) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 25 {
          for { let j := 0 } lt(j, 25) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 26 {
          for { let j := 0 } lt(j, 26) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 27 {
          for { let j := 0 } lt(j, 27) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 28 {
          for { let j := 0 } lt(j, 28) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 29 {
          for { let j := 0 } lt(j, 29) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 30 {
          for { let j := 0 } lt(j, 30) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 31 {
          for { let j := 0 } lt(j, 31) { j := add(j, 1) } {
            term := div(term,256)
          }
        }

        term := and(0x00000000000000000000000000000000000000000000000000000000000000ff,term)
        switch lt(maxValue, term)
        case 1 {
          maxValue := term
        }
      }
    }
  }

  /// @dev Returns the minimum value in an array.
  /// @param self Storage array containing uint256 type variables
  /// @return minValue The highest value in the array
  function getMin(uint256[] storage self) constant returns(uint256 minValue) {
    assembly { 
      mstore(0x60,self_slot) 
      minValue := sload(sha3(0x60,0x20))

      for { let i := 0 } lt(i, sload(self_slot)) { i := add(i, 1) } {
        switch gt(sload(add(sha3(0x60,0x20),i)), minValue)
        case 0 {
          minValue := sload(add(sha3(0x60,0x20),i))
        }
      }
    }
  }  

  function getMin(uint128[] storage self) constant returns(uint128 minValue) {
    uint256 term;
    assembly { 
      mstore(0x60,self_slot)

      for { let i := 0 } lt(i, sload(self_slot)) { i := add(i, 1) } {
        term := sload(add(sha3(0x60,0x20),div(i,2)))

        switch mod(i,2)
        case 1 {
          for { let j := 0 } lt(j, 4) { j := add(j, 1) } {
            term := div(term,4294967296)
          }
        }

        term := and(0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff,term)
        switch eq(i,0)
        case 1 {
          minValue := term
        }
        switch gt(minValue, term)
        case 1 {
          minValue := term
        }
      }
    }
  }

  function getMin(uint64[] storage self) constant returns(uint64 minValue) {
    uint256 term;
    assembly { 
      mstore(0x60,self_slot)

      for { let i := 0 } lt(i, sload(self_slot)) { i := add(i, 1) } {
        term := sload(add(sha3(0x60,0x20),div(i,4)))

        switch mod(i,4)
        case 1 {
          for { let j := 0 } lt(j, 2) { j := add(j, 1) } {
            term := div(term,4294967296)
          }
        }
        case 2 {
          for { let j := 0 } lt(j, 4) { j := add(j, 1) } {
            term := div(term,4294967296)
          }
        }
        case 3 {
          for { let j := 0 } lt(j, 6) { j := add(j, 1) } {
            term := div(term,4294967296)
          }
        }

        term := and(0x000000000000000000000000000000000000000000000000ffffffffffffffff,term)

        switch eq(i,0)
        case 1 {
          minValue := term
        }
        switch gt(minValue, term)
        case 1 {
          minValue := term
        }
      }
    }
  }

  function getMin(uint32[] storage self) constant returns(uint32 minValue) {
    uint256 term;
    assembly { 
      mstore(0x60,self_slot)

      for { let i := 0 } lt(i, sload(self_slot)) { i := add(i, 1) } {
        term := sload(add(sha3(0x60,0x20),div(i,8)))

        switch mod(i,8)
        case 1 {
          for { let j := 0 } lt(j, 1) { j := add(j, 1) } {
            term := div(term,4294967296)
          }
        }
        case 2 {
          for { let j := 0 } lt(j, 2) { j := add(j, 1) } {
            term := div(term,4294967296)
          }
        }
        case 3 {
          for { let j := 0 } lt(j, 3) { j := add(j, 1) } {
            term := div(term,4294967296)
          }
        }
        case 4 {
          for { let j := 0 } lt(j, 4) { j := add(j, 1) } {
            term := div(term,4294967296)
          }
        }
        case 5 {
          for { let j := 0 } lt(j, 5) { j := add(j, 1) } {
            term := div(term,4294967296)
          }
        }
        case 6 {
          for { let j := 0 } lt(j, 6) { j := add(j, 1) } {
            term := div(term,4294967296)
          }
        }
        case 7 {
          for { let j := 0 } lt(j, 7) { j := add(j, 1) } {
            term := div(term,4294967296)
          }
        }

        term := and(0x00000000000000000000000000000000000000000000000000000000ffffffff,term)

        switch eq(i,0)
        case 1 {
          minValue := term
        }
        switch gt(minValue, term)
        case 1 {
          minValue := term
        }
      }
    }
  }

  function getMin(uint16[] storage self) constant returns(uint16 minValue) {
    uint256 term;
    assembly { 
      mstore(0x60,self_slot)

      for { let i := 0 } lt(i, sload(self_slot)) { i := add(i, 1) } {
        term := sload(add(sha3(0x60,0x20),div(i,16)))

        switch mod(i,16)
        case 1 {
          for { let j := 0 } lt(j, 1) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 2 {
          for { let j := 0 } lt(j, 2) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 3 {
          for { let j := 0 } lt(j, 3) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 4 {
          for { let j := 0 } lt(j, 4) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 5 {
          for { let j := 0 } lt(j, 5) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 6 {
          for { let j := 0 } lt(j, 6) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 7 {
          for { let j := 0 } lt(j, 7) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 8 {
          for { let j := 0 } lt(j, 8) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 9 {
          for { let j := 0 } lt(j, 9) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 10 {
          for { let j := 0 } lt(j, 10) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 11 {
          for { let j := 0 } lt(j, 11) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 12 {
          for { let j := 0 } lt(j, 12) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 13 {
          for { let j := 0 } lt(j, 13) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 14 {
          for { let j := 0 } lt(j, 14) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }
        case 15 {
          for { let j := 0 } lt(j, 15) { j := add(j, 1) } {
            term := div(term,65536)
          }
        }

        term := and(0x000000000000000000000000000000000000000000000000000000000000ffff,term)

        switch eq(i,0)
        case 1 {
          minValue := term
        }
        switch gt(minValue, term)
        case 1 {
          minValue := term
        }
      }
    }
  }

  function getMin(uint8[] storage self) constant returns(uint8 minValue) {
    uint256 term;
    assembly { 
      mstore(0x60,self_slot)

      for { let i := 0 } lt(i, sload(self_slot)) { i := add(i, 1) } {
        term := sload(add(sha3(0x60,0x20),div(i,32)))

        switch mod(i,32)
        case 1 {
          for { let j := 0 } lt(j, 1) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 2 {
          for { let j := 0 } lt(j, 2) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 3 {
          for { let j := 0 } lt(j, 3) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 4 {
          for { let j := 0 } lt(j, 4) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 5 {
          for { let j := 0 } lt(j, 5) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 6 {
          for { let j := 0 } lt(j, 6) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 7 {
          for { let j := 0 } lt(j, 7) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 8 {
          for { let j := 0 } lt(j, 8) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 9 {
          for { let j := 0 } lt(j, 9) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 10 {
          for { let j := 0 } lt(j, 10) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 11 {
          for { let j := 0 } lt(j, 11) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 12 {
          for { let j := 0 } lt(j, 12) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 13 {
          for { let j := 0 } lt(j, 13) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 14 {
          for { let j := 0 } lt(j, 14) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 15 {
          for { let j := 0 } lt(j, 15) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 16 {
          for { let j := 0 } lt(j, 16) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 17 {
          for { let j := 0 } lt(j, 17) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 18 {
          for { let j := 0 } lt(j, 18) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 19 {
          for { let j := 0 } lt(j, 19) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 20 {
          for { let j := 0 } lt(j, 20) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 21 {
          for { let j := 0 } lt(j, 21) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 22 {
          for { let j := 0 } lt(j, 22) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 23 {
          for { let j := 0 } lt(j, 23) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 24 {
          for { let j := 0 } lt(j, 24) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 25 {
          for { let j := 0 } lt(j, 25) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 26 {
          for { let j := 0 } lt(j, 26) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 27 {
          for { let j := 0 } lt(j, 27) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 28 {
          for { let j := 0 } lt(j, 28) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 29 {
          for { let j := 0 } lt(j, 29) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 30 {
          for { let j := 0 } lt(j, 30) { j := add(j, 1) } {
            term := div(term,256)
          }
        }
        case 31 {
          for { let j := 0 } lt(j, 31) { j := add(j, 1) } {
            term := div(term,256)
          }
        }

        term := and(0x00000000000000000000000000000000000000000000000000000000000000ff,term)
        switch eq(i,0)
        case 1 {
          minValue := term
        }
        switch gt(minValue, term)
        case 1 {
          minValue := term
        }
      }
    }
  }

  /// @dev Finds the index of a given value in an array
  /// @param self Storage array containing uint256 type variables
  /// @param value The value to search for
  /// @param isSorted True if the array is sorted, false otherwise
  /// @return found True if the value was found, false otherwise
  /// @return index The index of the given value, returns 0 if found is false
  function indexOf(uint256[] storage self, uint256 value, bool isSorted) constant
           returns(bool found, uint256 index) {
    assembly{
      mstore(0x60,self_slot)
      switch isSorted  
      case 1 {
        let high := sub(sload(self_slot),1)
        let mid := 0
        let low := 0
        for { } iszero(gt(low, high)) { } {
          mid := div(add(low,high),2)
          
          switch lt(sload(add(sha3(0x60,0x20),mid)),value)
          case 1 {  
             low := add(mid,1)
          }  
          case 0 {
            switch gt(sload(add(sha3(0x60,0x20),mid)),value)
            case 1 {
              high := sub(mid,1)
            }
            case 0 {
              found := 1
              index := mid
              low := add(high,1) 
            }                       
          }
        }          
      }
      case 0 {
        for { let low := 0 } lt(low, sload(self_slot)) { low := add(low, 1) } {
          switch eq(sload(add(sha3(0x60,0x20),low)), value)
          case 1 {
            found := 1
            index := low
            low := sload(self_slot)
          }
        }
      }
    }
  }

  function indexOf(uint128[] storage self, uint128 value, bool isSorted) constant
           returns(bool found, uint128 index) {
    uint256 term;
    assembly{
      mstore(0x60,self_slot)
      switch isSorted  
      case 1 {
        let high := sub(sload(self_slot),1)
        let mid := 0
        let low := 0
        for { } iszero(gt(low, high)) { } {
          mid := div(add(low,high),2)
          term := sload(add(sha3(0x60,0x20),div(mid,2)))

          switch mod(mid,2)
          case 1 {
            for { let j := 0 } lt(j, 4) { j := add(j, 1) } {
              term := div(term,4294967296)
            }
          }
          
          term := and(term,0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff)

          switch lt(term,value)
          case 1 {  
             low := add(mid,1)
          }  
          case 0 {
            switch gt(term,value)
            case 1 {
              high := sub(mid,1)
            }
            case 0 {
              found := 1
              index := mid
              low := add(high,1) 
            }                       
          }
        }          
      }
      case 0 {
        for { let i := 0 } lt(i, sload(self_slot)) { i := add(i, 1) } {
          term := sload(add(sha3(0x60,0x20),div(i,2)))
          switch mod(i,2)
          case 1 {
            for { let j := 0 } lt(j, 4) { j := add(j, 1) } {
              term := div(term,4294967296)
            }
          }

          term := and(term,0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff)

          switch eq(term, value)
          case 1 {
            found := 1
            index := i
            i := sload(self_slot)
          }
        }
      }
    }
  }

  /// @dev Utility function for heapSort
  /// @param index The index of child node
  /// @return pI The parent node index
  function getParentI(uint256 index) constant private returns (uint256 pI) {
    uint256 i = index - 1;
    pI = i/2;
  }

  /// @dev Utility function for heapSort
  /// @param index The index of parent node
  /// @return lcI The index of left child
  function getLeftChildI(uint256 index) constant private returns (uint256 lcI) {
    uint256 i = index * 2;
    lcI = i + 1;
  }

  /// @dev Sorts given array in place
  /// @param self Storage array containing uint256 type variables
  function heapSort(uint256[] storage self) {
    uint256 end = self.length - 1;
    uint256 start = getParentI(end);
    uint256 root = start;
    uint256 lChild;
    uint256 rChild;
    uint256 swap;
    uint256 temp;
    while(start >= 0){
      root = start;
      lChild = getLeftChildI(start);
      while(lChild <= end){
        rChild = lChild + 1;
        swap = root;
        if(self[swap] < self[lChild])
          swap = lChild;
        if((rChild <= end) && (self[swap]<self[rChild]))
          swap = rChild;
        if(swap == root)
          lChild = end+1;
        else {
          temp = self[swap];
          self[swap] = self[root];
          self[root] = temp;
          root = swap;
          lChild = getLeftChildI(root);
        }
      }
      if(start == 0)
        break;
      else
        start = start - 1;
    }
    while(end > 0){
      temp = self[end];
      self[end] = self[0];
      self[0] = temp;
      end = end - 1;
      root = 0;
      lChild = getLeftChildI(0);
      while(lChild <= end){
        rChild = lChild + 1;
        swap = root;
        if(self[swap] < self[lChild])
          swap = lChild;
        if((rChild <= end) && (self[swap]<self[rChild]))
          swap = rChild;
        if(swap == root)
          lChild = end + 1;
        else {
          temp = self[swap];
          self[swap] = self[root];
          self[root] = temp;
          root = swap;
          lChild = getLeftChildI(root);
        }
      }
    }
  }

}
