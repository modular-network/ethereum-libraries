pragma solidity ^0.4.13;

import "truffle/Assert.sol";
import "../contracts/StringUtilsLib.sol";

contract TestStringUtilsLibTwo {
	using StringUtilsLib for *;

	StringUtilsLib.slice tSliceOne;
	StringUtilsLib.slice tSliceTwo;

	event Print(string message, bytes32 data);

	function testUntil() {
		tSliceOne = "My English teacher wanted".toSlice();
		tSliceTwo = " wanted".toSlice();

		string memory str = tSliceOne.until(tSliceTwo).toString();
		Assert.equal(str, "My English teacher", "The function should remove needle from string.");

		tSliceOne = "My English".toSlice();
		tSliceTwo = "English teacher wanted".toSlice();

		str = tSliceOne.until(tSliceTwo).toString();
		Assert.equal(str, "My English", "The function should keep string the same.");
	}

	function testFind() {
		tSliceOne = "Next semester Ill be thirty-five".toSlice();
		tSliceTwo = "Ill".toSlice();
		tSliceOne = tSliceOne.find(tSliceTwo);
		string memory str = tSliceOne.toString();

		Assert.equal(str, "Ill be thirty-five", "The function should return the slice starting at needle.");

		tSliceOne = "Next semester Ill be thirty-five".toSlice();
		tSliceTwo = "Thanks".toSlice();
		tSliceOne = tSliceOne.find(tSliceTwo);
		str = tSliceOne.toString();

		Assert.equal(str, "", "The function should return empty if needle not found.");

		tSliceOne = "Next semester Ill be thirty-five. Now I have to make this a super long string to test a long needle".toSlice();
		tSliceTwo = "be thirty-five. Now I have to make this a super long string to test a long needle".toSlice();
		tSliceOne = tSliceOne.find(tSliceTwo);
		str = tSliceOne.toString();

		Assert.equal(str, "be thirty-five. Now I have to make this a super long string to test a long needle", "The function should return the slice starting at needle.");
	}

	function testRfind() {
		tSliceOne = "Chased him with a stapler".toSlice();
		tSliceTwo = "with".toSlice();
		tSliceOne = tSliceOne.rfind(tSliceTwo);
		string memory str = tSliceOne.toString();

		Assert.equal(str, "Chased him with", "The function should return the slice ending with needle.");

		tSliceOne = "Chased him with a stapler".toSlice();
		tSliceTwo = "stapled".toSlice();
		tSliceOne = tSliceOne.rfind(tSliceTwo);
		str = tSliceOne.toString();

		Assert.equal(str, "", "The function should return empty if needle not found.");

		tSliceOne = "Chased him with a stapler. Now I have to do another long string to test the endurance of yet another needle".toSlice();
		tSliceTwo = "to do another long string to test the endurance of yet another".toSlice();
		tSliceOne = tSliceOne.rfind(tSliceTwo);
		str = tSliceOne.toString();

		Assert.equal(str, "Chased him with a stapler. Now I have to do another long string to test the endurance of yet another", "The function should return the slice ending with needle.");

		tSliceOne = "Chased him ".toSlice();
		tSliceTwo = "with a stapler".toSlice();
		tSliceOne = tSliceOne.rfind(tSliceTwo);
		str = tSliceOne.toString();

		Assert.equal(str, "", "The function should set to empty slice if needle not found.");
	}

	function testSplit() {
		StringUtilsLib.slice memory ts = "WhoodyHooo".toSlice();
		StringUtilsLib.slice memory tst = "oo".toSlice();
		StringUtilsLib.slice memory tok;

		tok = ts.split(tst);
		string memory str = ts.toString();
		string memory strt = tok.toString();
		Assert.equal(strt,"Wh", "The function should return the string before the needle.");
		Assert.equal(str,"dyHooo", "The function should modify the original slice to everything after needle.");

		tok = ts.split(tst);
		str = ts.toString();
		strt = tok.toString();
		Assert.equal(strt,"dyH", "The function should return the string before the needle.");
		Assert.equal(str,"o", "The function should modify the original slice to everything after needle.");

		ts = "Another String".toSlice();
		tst = "Not".toSlice();
		tok = ts.split(tst);
		str = ts.toString();
		strt = tok.toString();
		Assert.equal(strt,"Another String", "The token should be the entire string if needle not contained.");
		Assert.equal(str,"", "The function should modify the original slice to 0 if needle not contained.");

	}

	function testRsplit() {
		StringUtilsLib.slice memory ts = "WhoodyHooo".toSlice();
		StringUtilsLib.slice memory tst = "oo".toSlice();
		StringUtilsLib.slice memory tok;

		tok = ts.rsplit(tst);
		string memory str = ts.toString();
		string memory strt = tok.toString();
		Assert.equal(strt,"", "The function should return the string after the needle.");
		Assert.equal(str,"WhoodyHo", "The function should modify the original slice to everything before needle.");

		tok = ts.rsplit(tst);
		str = ts.toString();
		strt = tok.toString();
		Assert.equal(strt,"dyHo", "The function should return the string after the needle.");
		Assert.equal(str,"Wh", "The function should modify the original slice to everything before needle.");

		ts = "Another String".toSlice();
		tst = "Not".toSlice();
		tok = ts.rsplit(tst);
		str = ts.toString();
		strt = tok.toString();
		Assert.equal(strt,"Another String", "The token should be the entire string if needle not contained.");
		Assert.equal(str,"", "The function should modify the original slice to 0 if needle not contained.");
	}

	function testCount() {
		tSliceOne = "How mowny times cown yow find ow?".toSlice();
		tSliceTwo = "ow".toSlice();

		uint res = tSliceOne.count(tSliceTwo);

		Assert.equal(res, 5, "The function should return the number of occurrences of slice two.");
	}

	function testContains() {
		tSliceOne = "Is the needle here".toSlice();
		tSliceTwo = "eR".toSlice();

		bool oneDoesNotContainTwo = !(tSliceOne.contains(tSliceTwo));
		Assert.isTrue(oneDoesNotContainTwo,"Slice one should not show as containing two.");

		tSliceTwo = "er".toSlice();
		bool oneDoesContainTwo = tSliceOne.contains(tSliceTwo);
		Assert.isTrue(oneDoesContainTwo,"Slice one should not show as containing two.");
	}

	function testConcat() {
		string memory str;
		tSliceOne = "This is".toSlice();
		tSliceTwo = " amazing".toSlice();
		str = tSliceOne.concat(tSliceTwo);

		Assert.equal(str,"This is amazing","The function should concat two onto one.");
	}

	function testJoin() {
		StringUtilsLib.slice[] memory parts = new StringUtilsLib.slice[](4);
		string memory str;
		parts[0] = "All".toSlice();
		parts[1] = "done".toSlice();
		parts[2] = "with".toSlice();
		parts[3] = "this!".toSlice();
		tSliceOne = " ".toSlice();
		str = tSliceOne.join(parts);

		Assert.equal(str,"All done with this!","The function should join parts using a space.");

		StringUtilsLib.slice[] memory noParts = new StringUtilsLib.slice[](0);
		str = tSliceOne.join(noParts);

		Assert.equal(str,"","The function should provide empty string if no parts.");
	}

}
