pragma solidity ^0.4.13;

import "truffle/Assert.sol";
import "../contracts/StringUtilsLib.sol";

contract TestStringUtilsLibOne {
	using StringUtilsLib for *;

	StringUtilsLib.slice tSliceOne;
	StringUtilsLib.slice tSliceTwo;

	function testToSliceToString() {
		string memory s = "Ethereum is awesome!";
		s.toSlice().toString();
		Assert.equal(s, "Ethereum is awesome!","The original string should be returned.");
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

	function testStrLenRunes() {
		tSliceOne = "Ethereum is awesome".toSlice();
		uint r = tSliceOne.len();

		Assert.equal(r, 19, "The len function should return the length of the string.");
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

		tSliceOne = "What".toSlice();
		tSliceTwo = "My name is".toSlice();
		res = tSliceOne.compare(tSliceTwo);
		bool oneIsAfterTwo = res > 0;

		Assert.isTrue(oneIsAfterTwo,"What string should be after my name is string");

		tSliceOne = "Chika".toSlice();
		tSliceTwo = "Chika".toSlice();
		res = tSliceOne.compare(tSliceTwo);

		Assert.equal(res, 0, "Slim Shady");
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
	}

	function testOrd() {
		tSliceOne = "Arachnid is awesome!".toSlice();
		uint res = tSliceOne.ord();

		Assert.equal(res, 65, "The function should return the decimal code point for first letter");

		tSliceOne = "Do exactly like he did.".toSlice();
		res = tSliceOne.ord();

		Assert.equal(res, 68, "The function should return the decimal code point for first letter");
	}

	function testStartsWith() {
		tSliceOne = "My brains dead weight".toSlice();
		tSliceTwo = "My".toSlice();

		bool oneStartsWithTwo = tSliceOne.startsWith(tSliceTwo);
		Assert.isTrue(oneStartsWithTwo,"The function should return true if slice one starts with two.");

		tSliceTwo = "my".toSlice();
		bool oneDoesNotStartWithTwo = !(tSliceOne.startsWith(tSliceTwo));
		Assert.isTrue(oneDoesNotStartWithTwo,"Capitalization matters.");
	}

	function testBeyond() {
		tSliceOne = "Tryin to get my head straight".toSlice();
		tSliceTwo = "Tryin".toSlice();

		string memory str = tSliceOne.beyond(tSliceTwo).toString();

		Assert.equal(str, " to get my head straight", "The function should remove needle from string.");
	}

	function testEndsWith() {
		tSliceOne = "I cant figure out which".toSlice();
		tSliceTwo = "which".toSlice();

		bool oneEndsWithTwo = tSliceOne.endsWith(tSliceTwo);
		Assert.isTrue(oneEndsWithTwo,"The function should return true if slice one ends with two.");
	}

}
