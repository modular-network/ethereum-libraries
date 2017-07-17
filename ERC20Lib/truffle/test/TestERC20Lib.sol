pragma solidity ^0.4.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/ERC20LibTestContract.sol";
import "../contracts/ERC20LibTestSpender.sol";

contract TestERC20Lib {
  ERC20LibTestContract instance;
  ERC20LibTestSpender spender;
  uint256 expectedSupply = 0xa;

  function beforeAll(){
    address ia = new ERC20LibTestContract();
    instance = ERC20LibTestContract(ia);
    address sa = new ERC20LibTestSpender(instance);
    spender = ERC20LibTestSpender(sa);
  }

  function testTotalSupplyFunction(){
    uint256 supply = instance.totalSupply();

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

  function testTransfer(){
    bool firstTry = instance.transfer(spender, 20);
    bool secondTry = instance.transfer(spender, 5);

    Assert.isFalse(firstTry,"The owner cannot spend more tokens than she owns");
    Assert.isTrue(secondTry,"The owner should be able to spend owned tokens");
  }

  function testTransferFrom(){
    bool firstTry = spender.spend(this, 15);
    bool secondTry = spender.spend(this, 2);

    Assert.isFalse(firstTry,"The spender cannot spend more tokens than the owner has");
    Assert.isTrue(secondTry,"The spender should be able to spend authorized tokens");
  }
}
