pragma solidity ^0.4.11;

//import "truffle/Assert.sol";
//import "truffle/DeployedAddresses.sol";
//import "../contracts/WalletLibTestContract.sol";

contract TestWalletLib {
/*  WalletLibTestContract instance;
  uint256 expectedSupply = 0xa;
  event numbEvent(uint n);
  event addrEvent(address a);
  event bytesEvent(bytes32 b);
  event boolEvent(bool t);

  address[] owners;

  function beforeAll(){
    owners.push(0);
    owners.push(0x40333d950b4c682e8aad143c216af52877d828bf);
    owners.push(0x0a1f4fcde83ba12ee8343488964811218da3e00e);
    owners.push(0x79b63228ff63659248b7c688870de388bdcf0c14);
    owners.push(this);
    owners.push(0x36994c7cff11859ba8b9715120a68aa9499329ee);
    address ia = new WalletLibTestContract();
    instance = WalletLibTestContract(ia);
  }

  function testInitialization(){
    uint256 mo = instance.maxOwners();
    uint256 oc = instance.ownerCount();
    uint256 ra = instance.requiredAdmin();
    uint256 rmi = instance.requiredMinor();
    uint256 rma = instance.requiredMajor();
    address[51] memory o = instance.owners();
    for(uint i = 1; i <= oc; i++){
     Assert.equal(owners[i], o[i], "Owners should be put in the owner array.");
    }
    //uint[2] memory cs = instance.currentSpend(0);
    uint256 mt = instance.majorThreshold(0);
    numbEvent(mo);
    numbEvent(oc);
    numbEvent(ra);
    numbEvent(rmi);
    numbEvent(rma);
    //numbEvent(cs[0]);
    //numbEvent(cs[1]);
    numbEvent(mt);
    Assert.equal(mo, 50, "Max owners should be set to 50.");
    Assert.equal(oc, 5, "Owner count should reflect 5.");
    Assert.equal(ra, 4, "Required sigs for admin should reflect 4.");
    Assert.equal(rmi, 1, "Required sigs for minor tx should show 1.");
    Assert.equal(rma, 3, "Required sigs for major tx should show 3.");
    Assert.equal(mt, 100000000000000000000, "Max threshold should reflect 100 ether.");
  }

  function testChangeOwnerDeny() {
    bool success;
    bytes32 txid;

    (success, txid) = instance.changeOwner(0x36994c7cff11859ba8b9715120a68aa9499329ee,0xb4e205cd196bbe4b1b3767a5e32e15f50eb79623,true);
    boolEvent(success);
    bytesEvent(txid);
    address[51] memory o = instance.owners();
    for(uint i = 1; i <= 5; i++){
     addrEvent(o[i]);
    }
    Assert.isTrue(false,"Test");
  }
/*
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
  }*/
}
