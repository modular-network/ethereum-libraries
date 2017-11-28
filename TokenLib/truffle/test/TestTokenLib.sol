pragma solidity ^0.4.15;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/ThrowProxy.sol";
import "../contracts/TokenLibTestContract.sol";
import "../contracts/TokenLibTestSpender.sol";

// To call for test coverage
import "../contracts/BasicMathLib.sol";

contract TestTokenLib {
  using BasicMathLib for uint256;

  TokenLibTestContract instance;
  ThrowProxy tokenThrow;
  TokenLibTestSpender spender;
  ThrowProxy spenderThrow;
  uint8 expectedDecimals = 0x12;
  uint256 expectedSupply = 0x64;

  function beforeAll(){
    address ia = new TokenLibTestContract(this, "Tester Token", "TST", 18, 100, true);
    instance = TokenLibTestContract(ia);
    tokenThrow = new ThrowProxy(ia);
    address sa = new TokenLibTestSpender(instance);
    spender = TokenLibTestSpender(sa);
    spenderThrow = new ThrowProxy(sa);

  }

  function testInitialParams(){
    uint decimals = instance.decimals();
    uint256 supply = instance.totalSupply();

    Assert.equal(decimals, expectedDecimals, "Decimals should be initialized.");
    Assert.equal(supply,expectedSupply,"Total supply should be the amount of tokens initiated.");
  }

  function testBalanceOfFunction(){
    uint256 balance = instance.balanceOf(this);

    Assert.equal(balance,expectedSupply,"All tokens should be owned by the creating account");
  }

  function testApproveFunction(){
    bool ret = instance.approve(spender, 20);

    Assert.isTrue(ret,"The owner should be able to approve any amount.");
  }

  function testAllowanceFunction(){
    uint256 expectedAllowance = instance.allowance(this,spender);

    Assert.equal(expectedAllowance,20,"The spender should be authorized 20 tokens");
  }

  function testApproveChangeFunction(){
    bool ret = instance.approveChange(spender, 10, true);
    uint256 expectedAllowance = instance.allowance(this,spender);

    Assert.equal(expectedAllowance, 30, "The spender authorization should increase by 10");

    ret = instance.approveChange(spender, 5, false);
    expectedAllowance = instance.allowance(this,spender);

    Assert.equal(expectedAllowance, 25, "The spender authorization should decrease by 5");

    ret = instance.approveChange(spender, 30, false);
    expectedAllowance = instance.allowance(this,spender);

    Assert.equal(expectedAllowance, 0, "The spender authorization should reduce to 0");

    ret = instance.approveChange(spender, 20, true);
  }

  function testTransfer(){
    bool sendToProxy = instance.transfer(tokenThrow, 8);
    TokenLibTestContract(address(tokenThrow)).transfer(spender, 20);
    bool firstTry = tokenThrow.execute.gas(200000)();
    TokenLibTestContract(address(tokenThrow)).transfer(spender, 5);
    bool secondTry = tokenThrow.execute.gas(200000)();

    Assert.isFalse(firstTry,"The owner cannot spend more tokens than she owns");
    Assert.isTrue(secondTry,"The owner should be able to spend owned tokens");
  }

  function testTransferFrom(){
    TokenLibTestSpender(address(spenderThrow)).spend(this, 150);
    bool firstTry = spenderThrow.execute.gas(200000)();
    TokenLibTestSpender(address(spenderThrow)).spend(this, 2);
    bool secondTry = spenderThrow.execute.gas(200000)();

    Assert.isFalse(firstTry,"The spender cannot spend more tokens than the owner has");
    Assert.isTrue(secondTry,"The spender should be able to spend authorized tokens");
  }

  function testChangeOwnerFunction(){
    bool ret = instance.changeOwner(spender);
    address owner = instance.owner();

    Assert.equal(address(spender), owner, "The spender should now be the owner");

    TokenLibTestContract(address(tokenThrow)).changeOwner(this);
    bool co = tokenThrow.execute.gas(200000)();

    Assert.isFalse(co, "The proxy contract cannot change owners.");
  }

  function testMintToken() returns (bool) {
    TokenLibTestContract(address(tokenThrow)).mintToken(50);
    bool mt = tokenThrow.execute.gas(200000)();

    Assert.isFalse(mt, "The proxy should not be allowed to mint tokens.");

    spender.changeOwnerBack(address(tokenThrow));
    address owner = instance.owner();

    Assert.equal(address(tokenThrow), owner, "The owner should be the proxy contract");

    mt = tokenThrow.execute.gas(200000)();

    Assert.isTrue(mt, "Tokens should now be minted");

    uint256 total = instance.totalSupply();
    Assert.equal(total, 150, "Total supply should now be 150");
  }

  function testCloseMintFunction(){
    TokenLibTestContract(address(tokenThrow)).closeMint();
    bool cm = tokenThrow.execute.gas(200000)();

    Assert.isTrue(cm, "Mint should be closed.");

    TokenLibTestContract(address(tokenThrow)).mintToken(50);
    bool mt = tokenThrow.execute.gas(200000)();

    Assert.isFalse(mt, "The proxy should not be allowed to mint tokens.");
  }

  function testBurnTokenFunction() {
    TokenLibTestContract(address(tokenThrow)).burnToken(60);
    bool firstTry = tokenThrow.execute.gas(200000)();
    TokenLibTestContract(address(tokenThrow)).burnToken(50);
    bool secondTry = tokenThrow.execute.gas(200000)();

    Assert.isFalse(firstTry,"The spender cannot burn more tokens than they have");
    Assert.isTrue(secondTry,"The spender should be able to burn tokens");

    uint256 b = instance.balanceOf(address(tokenThrow));

    Assert.equal(b, 3, "Proxy should have three tokens left.");

    uint256 ts = instance.totalSupply();

    Assert.equal(ts, 100, "Total supply should be reduced by 50");
  }

  function testRunBMLFuncsForCoverage() {
    uint256 a = 2;
    uint256 b = 2;

    a.times(b);
    a.dividedBy(b);
  }
}
