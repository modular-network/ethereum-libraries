pragma solidity ^0.4.13;

import "truffle/Assert.sol";
import "../contracts/StringUtilsLib.sol";

contract TestStringUtilsLibOne {
	using StringUtilsLib for *;

	StringUtilsLib.slice tSliceOne;
	StringUtilsLib.slice tSliceTwo;

	function testToSliceToString() {
		string memory s = "Ethereum is so super awesome and I love it so much!";
		s.toSlice().toString();
		Assert.equal(s, "Ethereum is so super awesome and I love it so much!","The original string should be returned.");
	}

	function testToSliceB32() {
		string memory s = "Ethereum";
		bytes32 ba;
    assembly {
        ba := mload(add(s, 32))
    }
		ba.toSliceB32().toString();
		Assert.equal(ba, "Ethereum", "The original string should be returned.");
	}

	function testStrLenBytes() {
		string memory s = "Ethereum";
		bytes32 ba;
    assembly {
        ba := mload(add(s, 32))
    }
		uint length = ba.len();
		Assert.equal(length, 8, "The len function should return the length of the string.");
	}

	function testStrLenZero() {
		string memory s = "";
		bytes32 ba;
    assembly {
        ba := mload(add(s, 32))
    }
		uint length = ba.len();
		Assert.equal(length, 0, "The len function should return zero.");
	}

	function testStrLenFour() {
		string memory s = "Hero";
		bytes32 ba;
    assembly {
        ba := mload(add(s, 32))
    }
		uint length = ba.len();
		Assert.equal(length, 4, "The len function should return four.");
	}

	function testStrLenTwo() {
		string memory s = "CB";
		bytes32 ba;
    assembly {
        ba := mload(add(s, 32))
    }
		uint length = ba.len();
		Assert.equal(length, 2, "The len function should return two.");
	}

	function testStrLenOne() {
		string memory s = "J";
		bytes32 ba;
    assembly {
        ba := mload(add(s, 32))
    }
		uint length = ba.len();
		Assert.equal(length, 1, "The len function should return one.");
	}

	function testStrLenRunes() {
		tSliceOne = "Ethereum is awesome".toSlice();
		uint r = tSliceOne.len();

		Assert.equal(r, 19, "The len function should return the length of the string.");
	}

	function testStrLenRunesMore() {
		tSliceOne = "¡Spanish phrase!".toSlice();
		uint r = tSliceOne.len();

		Assert.equal(r, 16, "The len function should return the length of the string.");
	}

	function testStrLenRunesEvenMore() {
		tSliceOne = "⌘ test".toSlice();
		uint r = tSliceOne.len();

		Assert.equal(r, 6, "The len function should return the length of the string.");
	}

	function testStrLenRunesMost() {
		tSliceOne = "More 𐀀 weirdness!".toSlice();
		uint r = tSliceOne.len();

		Assert.equal(r, 17, "The len function should return the length of the string.");
	}

	function testStrLenRunesEvenMoster() {
		uint ptr;
		bytes memory myBytes = new bytes(1);
		myBytes[0] = 0xfb;
		assembly {
      ptr := add(myBytes, 0x20)
    }
		tSliceOne._len = 1;
		tSliceOne._ptr = ptr;
		uint r = tSliceOne.len();

		Assert.equal(r, 1, "For code coverage.");
	}

	function testStrLenRunesMostest() {
		uint ptr;
		bytes memory myBytes = new bytes(1);
		myBytes[0] = 0xfd;
		assembly {
      ptr := add(myBytes, 0x20)
    }
		tSliceOne._len = 1;
		tSliceOne._ptr = ptr;
		uint r = tSliceOne.len();

		Assert.equal(r, 1, "For code coverage.");
	}

	function testCopy() {
		tSliceOne = "My name is".toSlice();
		tSliceTwo = tSliceOne.copy();

		Assert.equal(tSliceOne._len,tSliceTwo._len,"The slice copy length should equal the test slice length.");
		Assert.equal(tSliceOne._ptr,tSliceTwo._ptr,"The slice copy pointer should equal the test slice pointer.");
	}

	function testEmpty() {
		tSliceOne = "  ".toSlice();
		tSliceTwo = "".toSlice();
		bool oneIsNotEmpty = !(tSliceOne.empty());
		bool twoIsEmpty = tSliceTwo.empty();

		Assert.isTrue(oneIsNotEmpty,"The first string should not return as empty.");
		Assert.isTrue(twoIsEmpty, "The second string should return as empty.");
	}

	function testCompare() {
		tSliceOne = "Hi".toSlice();
		tSliceTwo = "My name is".toSlice();
		int res = tSliceOne.compare(tSliceTwo);
		bool oneIsBeforeTwo = res < 0;

		Assert.isTrue(oneIsBeforeTwo,"Hi string should be before My name is string");

		tSliceOne = "My name is".toSlice();
		tSliceTwo = "What".toSlice();
		res = tSliceOne.compare(tSliceTwo);
		oneIsBeforeTwo = res < 0;

		Assert.isTrue(oneIsBeforeTwo,"What string should be after my name is string");

		tSliceOne = "Chika".toSlice();
		tSliceTwo = "Chika".toSlice();
		res = tSliceOne.compare(tSliceTwo);

		Assert.equal(res, 0, "Slim Shady");
	}

	function testEquals() {
		tSliceOne = "These two equal!".toSlice();
		tSliceTwo = "These two equal!".toSlice();
		bool res = tSliceOne.equals(tSliceTwo);

		Assert.isTrue(res,"These strings equal each other.");
	}

	function testNextRune() {
		StringUtilsLib.slice memory ts = "Hi kids!".toSlice();
		StringUtilsLib.slice memory tsr;
		tsr = ts.nextRune();
		string memory str = ts.toString();
		string memory strt = tsr.toString();

		Assert.equal(str, "i kids!", "The first slice should drop the first letter.");
		Assert.equal(strt, "H", "The return slice should contain the first letter.");

		tsr = ts.nextRune();
		str = ts.toString();
		strt = tsr.toString();

		Assert.equal(str, " kids!", "The first slice should drop the first letter.");
		Assert.equal(strt, "i", "The return slice should contain the first letter.");

		ts = "".toSlice();
		tsr = ts.nextRune();
		bool isZero = tsr._len == 0;
		Assert.isTrue(isZero, "Empty string gives empty rune");

		ts = "¡⌘𐀀".toSlice();
		ts._len = 1;
		tsr = ts.nextRune();

		Assert.equal(ts._len, 0, "Should return 0 if codepoint truncated.");

		ts = "⌘𐀀".toSlice();
		tsr = ts.nextRune();
		strt = tsr.toString();

		Assert.equal(strt, "⌘", "The return slice should contain the next weird character.");

		tsr = ts.nextRune();
		strt = tsr.toString();

		Assert.equal(strt, "𐀀", "The return slice should contain the final weird character.");
	}

	function testOrd() {
		tSliceOne = "Arachnid is awesome!".toSlice();
		uint res = tSliceOne.ord();

		Assert.equal(res, 65, "The function should return the decimal code point for first letter");

		tSliceOne = "".toSlice();
		res = tSliceOne.ord();

		Assert.equal(res, 0, "The function should return the decimal code point for first letter");

		tSliceOne = "¡".toSlice();
		tSliceOne._len = 1;
		res = tSliceOne.ord();

		Assert.equal(res, 0, "Should return 0 if truncated code point.");

		uint ptr;
		bytes memory myBytes = new bytes(2);
		myBytes[0] = 0xfb;
		myBytes[1] = 0xff;
		assembly {
      ptr := add(myBytes, 0x20)
    }
		tSliceOne._len = 4;
		tSliceOne._ptr = ptr;
		res = tSliceOne.ord();

		Assert.equal(res, 0, "The function should return zero if invalid utf8 sequence");

		tSliceOne = "⌘".toSlice();
		res = tSliceOne.ord();

		Assert.equal(res, 8984, "The function should return the decimal code point for first letter");

		tSliceOne = "𐀀".toSlice();
		res = tSliceOne.ord();

		Assert.equal(res, 65536, "The function should return the decimal code point for first letter");
	}

	function testKeccak() {
		tSliceOne = "Hash this slice".toSlice();
		bytes32 sliceHash = tSliceOne.keccak();
		bytes32 stringHash = sha3("Hash this slice");

		Assert.equal(stringHash, sliceHash, "The hash of the slice should equal the hash of the string.");
	}

	function testStartsWith() {
		tSliceOne = "My brains dead weight".toSlice();
		tSliceTwo = "My".toSlice();

		bool oneStartsWithTwo = tSliceOne.startsWith(tSliceTwo);
		Assert.isTrue(oneStartsWithTwo,"The function should return true if slice one starts with two.");

		bool oneStartsWithOne = tSliceOne.startsWith(tSliceOne);
		Assert.isTrue(oneStartsWithOne,"The function should return true if slices are the same.");

		tSliceOne = "My".toSlice();
		tSliceTwo = "My brains dead weight".toSlice();

		oneStartsWithTwo = tSliceOne.startsWith(tSliceTwo);
		Assert.isFalse(oneStartsWithTwo,"The function should return false if two is longer than one.");

		tSliceTwo = "my".toSlice();
		bool oneDoesNotStartWithTwo = !(tSliceOne.startsWith(tSliceTwo));
		Assert.isTrue(oneDoesNotStartWithTwo,"Capitalization matters.");
	}

	function testBeyond() {
		tSliceOne = "Tryin to get my head straight".toSlice();
		tSliceTwo = "Tryin".toSlice();

		string memory str = tSliceOne.beyond(tSliceTwo).toString();

		Assert.equal(str, " to get my head straight", "The function should remove needle from string.");

		tSliceOne = "Tryin".toSlice();
		tSliceTwo = "Tryin to get my head straight".toSlice();

		str = tSliceOne.beyond(tSliceTwo).toString();

		Assert.equal(str, "Tryin", "The function should return string if needle is longer.");
	}

	function testEndsWith() {
		tSliceOne = "I cant figure out which".toSlice();
		tSliceTwo = "which".toSlice();

		bool oneEndsWithTwo = tSliceOne.endsWith(tSliceTwo);
		Assert.isTrue(oneEndsWithTwo,"The function should return true if slice one ends with two.");

		tSliceOne = "I cant".toSlice();
		tSliceTwo = "cant figure out which".toSlice();

		oneEndsWithTwo = tSliceOne.endsWith(tSliceTwo);
		Assert.isFalse(oneEndsWithTwo,"The function should return false if slice one does not end with two.");

		tSliceOne = "I cant".toSlice();

		bool oneEndsWithOne = tSliceOne.endsWith(tSliceOne);
		Assert.isTrue(oneEndsWithOne,"The function should return true if slice is the same pointer.");
	}

}
