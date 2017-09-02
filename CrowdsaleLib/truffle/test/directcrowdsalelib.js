var WalletLibTestContract = artifacts.require("WalletLibTestContract");
var DirectCrowdsaleTestContract = artifacts.require("DirectCrowdsaleTestContract");
var CrowdsaleToken = artifacts.require("CrowdsaleToken");

var WalletAddress;
var TokenAddress;

contract('WalletLibTestContract', function(accounts) {
  it("should properly initialize wallet data", function() {
    var returnObj = {};
    var c;

    return WalletLibTestContract.deployed().then(function(instance) {
      c = instance;
      return c.maxOwners.call();
    }).then(function(mo){
      returnObj.mo = mo;
      return c.ownerCount.call();
    }).then(function(oc){
      returnObj.oc = oc;
      return c.requiredAdmin.call();
    }).then(function(ra){
      returnObj.ra = ra;
      return c.requiredMinor.call();
    }).then(function(rmi){
      returnObj.rmi = rmi;
      return c.requiredMajor.call();
    }).then(function(rma){
      returnObj.rma = rma;
      return c.owners.call();
    }).then(function(o){
      returnObj.o = o;
      console.log(returnObj.o);
      return c.majorThreshold.call(0);
    }).then(function(mt){
      returnObj.mt = mt;
      assert.equal(returnObj.mo.valueOf(), 50, "Max owners should be set to 50.");
      assert.equal(returnObj.oc.valueOf(), 5, "Owner count should reflect 5.");
      assert.equal(returnObj.ra.valueOf(), 4, "Required sigs for admin should reflect 4.");
      assert.equal(returnObj.rmi.valueOf(), 1, "Required sigs for minor tx should show 1.");
      assert.equal(returnObj.rma.valueOf(), 3, "Required sigs for major tx should show 3.");
      assert.equal(returnObj.mt.valueOf(), 100000000000000000000, "Max threshold should reflect 100 ether.");
      WalletAddress = c.address.call();
    });
  });
});

contract('CrowdsaleToken', function(accounts) {
  it("should properly initialize token data", function() {
    var returnObj = {};
    var c;

    return TokenLibTestContract.deployed().then(function(instance) {
      c = instance;
      return c.name.call();
    }).then(function(n){
      returnObj.name = n;
      return c.symbol.call();
    }).then(function(s){
      returnObj.symbol = s;
      return c.decimals.call();
    }).then(function(d){
      returnObj.decimals = d;
      return c.totalSupply.call();
    }).then(function(ts){
      returnObj.totalSupply = ts;
      return c.initialSupply.call();
    }).then(function(is){
      returnObj.initialSupply = is;
      assert.equal(returnObj.name.valueOf(), 'Tester Token', "Name should be set to Tester Token.");
      assert.equal(returnObj.symbol.valueOf(), 'TST', "Symbol should be set to TST.");
      assert.equal(returnObj.decimals.valueOf(), 18, "Decimals should be set to 18.");
      assert.equal(returnObj.totalSupply.valueOf(), 1000000, "Total supply should reflect 10.");
      assert.equal(returnObj.initialSupply.valueOf(), 1000000, "Initial supply should reflect 10.");
      TokenAddress = c.address.call();
    });
  });
});

contract('DirectCrowdsaleTestContract', function(accounts) {
  it("should initialize the direct crowdsale contract data", function() {
    var returnObj = {};
    var c;

    return DirectCrowdsaleTestContract.deployed().then(function(instance) {
      c = instance;
      return c.base.owner.call();
    }).then(function(o){
      returnObj.owner = o;
      return c.base.tokenPrice.call();
    }).then(function(t){
      returnObj.tokenPrice = t;
      return c.base.capAmount.call();
    }).then(function(ca){
      returnObj.capAmount = ca;
      return c.base.minimumTargetRaise.call();
    }).then(function(tr){
      returnObj.minimumTargetRaise = ts;
      return c.base.auctionSupply.call();
    }).then(function(as){
      returnObj.auctionSupply = as;
      assert.equal(returnObj.owner.valueOf(), WalletAddress, "Owner should be set to the address of the wallet contract");
      assert.equal(returnObj.tokenPrice.valueOf(), 1000000000000000, "Token price should be 1000000000000000 wei");
      assert.equal(returnObj.capAmount.valueOf(), 18, "capAmount should be set to 1000000000000000000000 wei");
      assert.equal(returnObj.minimumTargetRaise.valueOf(), 300000000000000000000, "Minimum sale target should be set to 300000000000000000000 wei");
      assert.equal(returnObj.auctionSupply.valueOf(), 800000, "Initial supply of tokens for the sale should reflect 800000.");
    });
  });
});
