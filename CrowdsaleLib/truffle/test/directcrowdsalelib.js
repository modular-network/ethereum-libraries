var WalletLibTestContract = artifacts.require("WalletLibTestContract");
var TimeDirectCrowdsaleTestContract = artifacts.require("TimeDirectCrowdsaleTestContract");
var CrowdsaleToken = artifacts.require("CrowdsaleToken");

var WalletAddress;
var TokenInstance;

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
      return c.majorThreshold.call(0);
    }).then(function(mt){
      returnObj.mt = mt;
      assert.equal(returnObj.mo.valueOf(), 50, "Max owners should be set to 50.");
      assert.equal(returnObj.oc.valueOf(), 5, "Owner count should reflect 5.");
      assert.equal(returnObj.ra.valueOf(), 4, "Required sigs for admin should reflect 4.");
      assert.equal(returnObj.rmi.valueOf(), 1, "Required sigs for minor tx should show 1.");
      assert.equal(returnObj.rma.valueOf(), 3, "Required sigs for major tx should show 3.");
      assert.equal(returnObj.mt.valueOf(), 100000000000000000000, "Max threshold should reflect 100 ether.");
    });
  });
});

contract('CrowdsaleToken', function(accounts) {
  it("should properly initialize token data", function() {
    var returnObj = {};
    var c;

    return CrowdsaleToken.deployed().then(function(instance) {
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
      assert.equal(returnObj.name.valueOf(), 'Tester Token', "Name should be set to Tester Token.");
      assert.equal(returnObj.symbol.valueOf(), 'TST', "Symbol should be set to TST.");
      assert.equal(returnObj.decimals.valueOf(), 18, "Decimals should be set to 18.");
      assert.equal(returnObj.totalSupply.valueOf(), 1000000, "Total supply should reflect 1000000.");
    });
  });
});

contract('TimeDirectCrowdsaleTestContract', function(accounts) {
  it("should initialize the direct crowdsale contract data", function() {
    var returnObj = {};
    var c;

    return TimeDirectCrowdsaleTestContract.deployed().then(function(instance) {
      c = instance;

      return c.owner.call();
    }).then(function(o){
      WalletAddress = o.valueOf();
      console.log(WalletAddress);
      returnObj.owner = o;
      return c.tokenPriceinCents.call();
    }).then(function(t){
      returnObj.tokenPriceinCents = t;
      return c.capAmount.call();
    }).then(function(ca){
      returnObj.capAmount = ca;
      return c.startTime.call();
    }).then(function(st){
      returnObj.startTime = st;
      return c.endTime.call();
    }).then(function(et){
      returnObj.endTime = et;
      return c.firstPriceChange.call();
    }).then(function(pc) {
      returnObj.pc = pc;
      return c.ownerBalance.call();
    }).then(function(ob){
      returnObj.ownerBalance = ob;
      //assert.equal(returnObj.owner.valueOf(), "Owner should be set to the address of the wallet contract");
      assert.equal(returnObj.tokenPriceinCents.valueOf(), 50, "Token price in cents should be 50 cents");
      assert.equal(returnObj.capAmount.valueOf(), 2e+22, "capAmount should be set to 1000000000000000000000 wei");
      assert.equal(returnObj.pc.valueOf(), 75, "First price change should be 75 cents");
      assert.equal(returnObj.ownerBalance.valueOf(), 0, "Amount of wei raised in the crowdsale should be zero");
    });
  });
  it("should deny all requests to interact with the contract before the crowdsale starts", function() {
    var c;

    return TimeDirectCrowdsaleTestContract.deployed().then(function(instance) {
     c = instance;
     return c.withdrawTokens({from:accounts[0]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, 'Sender has no tokens to withdraw!', "should give message that token sale has not ended");
      return c.receivePurchase(103,{value: 40000000000000000000, from: accounts[1]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, 'Invalid Purchase! Check send time and amount of ether.', "should give an error message since sale has not started");
      return c.receivePurchase(103,{value: 20000000000000000000, from: accounts[5]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, 'Owner cannot send ether to contract', "should give an error message since sale has not started");
      return c.ownerWithdrawl(104,{from: accounts[5]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, 'Cannot withdraw owner ether until after the sale', "Should give an error that sale ether cannot be withdrawn till after the sale");
      return c.getContribution.call(accounts[1]);
    }).then(function(ret) {
      assert.equal(ret.valueOf(),0,"accounts[1] ether contribution should be 0");
      return c.getTokenPurchase.call(accounts[1]);
    }).then(function(ret) {
      assert.equal(ret.valueOf(), 0,"accounts[1] token balance should be 0");
      return c.setExchangeRate(30000,102, {from:accounts[5]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, 'Owner can only set the exchange rate two days before the sale!', "Should give an error message that timing for setting the exchange rate is wrong.");
      return c.setExchangeRate(30000,103, {from:accounts[5]});
    }).then(function(ret) {
      //assert.equal(ret.logs[0].args.Msg, "Owner has sent the exchange Rate and tokens bought per ETH!", "Should give success message that the exchange rate was set.");
      return c.tokensPerEth.call();
    }).then(function(ret) {
      assert.equal(ret.valueOf(), 600, "tokensPerEth should have been set to 600!");
    });
  });


  //   /********************************************************
  //   DURING SALE - NO PRICE CHANGE
  //   /*******************************************************/
  // it("should deny invalid payments during the sale and accept payments that are reflected in token balance", function() {
  //   var c;

  //   return TimeDirectCrowdsaleTestContract.deployed().then(function(instance) {
  //     c = instance;

  //     console.log(c.contract.address);
  //     return CrowdsaleToken.deployed().then(function(instance) {
  //     return instance.approve(c.contract.address,10000000,{from:accounts[5]});
  //   }).then(function(ret) {
      
  //     return c.withdrawTokens({from:accounts[0]});
  //   }).then(function(ret) {
  //     assert.equal(ret.logs[0].args.Msg, 'Sender has no tokens to withdraw!', "should give message that the sender cannot withdraw any tokens");
  //     return c.receivePurchase(106,{from:accounts[0]});
  //   }).then(function(ret) {
  //     assert.equal(ret.logs[0].args.Msg, 'Invalid Purchase! Check send time and amount of ether.', "should give an error message since no ether was sent");
  //     return c.receivePurchase(106,{value:40000000000000000000,from:accounts[0]});
  //   }).then(function(ret) {
  //     return c.getContribution.call(accounts[0], {from:accounts[0]});
  //   }).then(function(ret) {
  //     assert.equal(ret.valueOf(),40000000000000000000, "accounts[0] amount of wei contributed should be 40000000000000000000 wei");
  //     return c.receivePurchase(106,{value: 40000000000000000000, from:accounts[0]});
  //   }).then(function(ret) {
  //     return c.getContribution.call(accounts[0], {from:accounts[0]});
  //   }).then(function(ret) {
  //     assert.equal(ret.valueOf(),80000000000000000000, "accounts[0] amount of wei contributed should be 80000000000000000000 wei");
  //     return c.getTokenPurchase.call(accounts[0],{from:accounts[0]});
  //   }).then(function(ret) {
  //     assert.equal(ret.valueOf(),80000, "accounts[0] amount of tokens purchased should be 80000 tokens");
  //     return c.receivePurchase(106, {value: 40000000000000000000, from:accounts[0]});
  //   }).then(function(ret) {
  //     return c.getContribution.call(accounts[0],{from:accounts[0]});
  //   }).then(function(ret) {
  //     assert.equal(ret.valueOf(),120000000000000000000, "accounts[0] amount of wei contributed should be 120000000000000000000 wei");
  //     return c.getTokenPurchase.call(accounts[0],{from:accounts[0]});
  //   }).then(function(ret) {
  //     assert.equal(ret.valueOf(),120000, "accounts[0] amount of tokens purchased should be 120000 tokens");
  //     return c.receivePurchase(106,{value: 120000000000000000000, from: accounts[5]});
  //   }).then(function(ret) {
  //     assert.equal(ret.logs[0].args.Msg, 'Owner cannot send ether to contract', "should give an error message since sale has not started");
  //     return c.ownerWithdrawl(106,{from: accounts[5]});
  //   }).then(function(ret) {
  //     assert.equal(ret.logs[0].args.Msg, 'Cannot withdraw owner ether until after the sale', "Should give an error that sale ether cannot be withdrawn till after the sale");
  //     return c.getContribution.call(accounts[5]);
  //   }).then(function(ret) {
  //     assert.equal(ret.valueOf(),0,"accounts[5] (owner) ether contribution should be 0");
  //     return c.receivePurchase(106, {value: 500000000000000000011, from:accounts[3]});
  //   }).then(function(ret) {
  //     return c.getContribution.call(accounts[3],{from:accounts[3]});
  //   }).then(function(ret) {
  //     assert.equal(ret.valueOf(),500000000000000000011, "accounts[3] amount of wei contributed should be 1500000000000000000011 wei");
  //     return c.getTokenPurchase.call(accounts[3],{from:accounts[3]});
  //   }).then(function(ret) {
  //     assert.equal(ret.valueOf(),500000, "accounts[3] amount of tokens purchased should be 500000 tokens");
  //     return c.withdrawTokens({from:accounts[0]});
  //   }).then(function(ret) {
  //     return c.getTokenPurchase.call(accounts[0],{from:accounts[0]});
  //   }).then(function(ret) {
  //     assert.equal(ret.valueOf(),0,"accounts[0] should have withdrawn all tokens and should now have zero in the contract");

  //     return c.receivePurchase(107, {value: 1200000000000000000000, from: accounts[2]});
  //   }).then(function(ret) {
  //     assert.equal(ret.logs[0].args.Msg, 'buyer ether sent exceeds cap of ether to be raised!', "should give error message that the raise cap has been exceeded");
  //     return c.receivePurchase(107, {value: 900000000000000000000, from: accounts[2]});
  //   }).then(function(ret) {
  //     assert.equal(ret.logs[0].args.Msg, 'buyer ether sent exceeds cap of ether to be raised!', "should give error message that the raise cap has been exceeded");
  //   });
  // });
  // });



  // /********************************************************
  //   AFTER SALE - NO PRICE CHANGE
  // /*******************************************************/
  // it("should deny payments after the sale and allow users to withdraw their tokens/owner to withdraw ether", function() {
  //   var c;

  //   return TimeDirectCrowdsaleTestContract.deployed().then(function(instance) {
  //     c = instance;
  //     return c.ownerBalance.call();
  //   }).then(function(ret) {
  //     assert.equal(ret.valueOf(),620000000000000000000, "owners balance of ether should be 720!");
  //     return c.getTokenPurchase.call(accounts[0],{from:accounts[0]});
  //   }).then(function(ret) {
  //     assert.equal(ret.valueOf(),0, "accounts[0] amount of tokens purchased should be 0 tokens");
  //     return c.getTokenPurchase.call(accounts[3],{from:accounts[3]});
  //   }).then(function(ret) {
  //     assert.equal(ret.valueOf(),500000, "accounts[3] amount of tokens purchased should be 500000 tokens");
  //     return c.withdrawTokens({from:accounts[3]});
  //   }).then(function(ret) {
  //     return c.getTokenPurchase.call(accounts[3],{from:accounts[3]});
  //   }).then(function(ret) {
  //     assert.equal(ret.valueOf(),0,"accounts[3] should have withdrawn all tokens and should now have zero in the contract");

  //     return c.receivePurchase(111,{from:accounts[2]});
  //   }).then(function(ret) {
  //     assert.equal(ret.logs[0].args.Msg, 'Invalid Purchase! Check send time and amount of ether.', "should give an error message since no ether was sent");
  //     return c.withdrawTokens({from:accounts[2]});
  //   }).then(function(ret) {
  //     assert.equal(ret.logs[0].args.Msg, 'Sender has no tokens to withdraw!', "should give message that the sender cannot withdraw any tokens");
  //     return c.ownerWithdrawl(111,{from:accounts[5]});
  //   }).then(function(ret) {
  //     assert.equal(ret.logs[0].args.Msg, 'crowdsale owner has withdrawn all funds', "Should give message that the owner has withdrawn all funds");
  //     return c.ownerBalance.call();
  //   }).then(function(ret) {
  //     assert.equal(ret.valueOf(), 0, "Owner's ether balance in the contract should be zero!");
  //   });

  // });

    /********************************************************
    DURING SALE - YES PRICE CHANGE
    /*******************************************************/
  it("should deny invalid payments during the sale and accept payments that are reflected in token balance", function() {
    var c;

    return TimeDirectCrowdsaleTestContract.deployed().then(function(instance) {
      c = instance;

      console.log(c.contract.address);
      return CrowdsaleToken.deployed().then(function(instance) {
      return instance.transfer(1000000,{from:accounts[5]});
    }).then(function(ret) {
      return c.changeInterval.call();
    }).then(function(ret) {
      assert.equal(ret.valueOf(),5, "Price Change time interval should be 5!");      
      return c.withdrawTokens({from:accounts[0]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, 'Sender has no tokens to withdraw!', "should give message that the sender cannot withdraw any tokens");
      return c.receivePurchase(106,{from:accounts[0]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, 'Invalid Purchase! Check send time and amount of ether.', "should give an error message since no ether was sent");
      return c.receivePurchase(106,{value:39990000000000000000,from:accounts[0]});
    }).then(function(ret) {
      return c.receivePurchase(106,{value:10000000000000000,from:accounts[0]});
    }).then(function(ret) {
      return c.getContribution.call(accounts[0], {from:accounts[0]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),40000000000000000000, "accounts[0] amount of wei contributed should be 40000000000000000000 wei");
      return c.getTokenPurchase.call(accounts[0]);
    }).then(function(ret) {
      assert.equal(ret.valueOf(), 24000, "accounts[0] tokens purchased should be 24000");
      return c.receivePurchase(111,{value: 40000000000000000000, from:accounts[0]});
    }).then(function(ret) {
      return c.tokensPerEth.call();
    }).then(function(ret) {
      assert.equal(ret.valueOf(), 400, "tokensPerEth should have been set to 400!");
      return c.getContribution.call(accounts[0], {from:accounts[0]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),80000000000000000000, "accounts[0] amount of wei contributed should be 80000000000000000000 wei");
      return c.getTokenPurchase.call(accounts[0],{from:accounts[0]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),40000, "accounts[0] amount of tokens purchased should be 40000 tokens");
      return c.receivePurchase(111, {value: 40000000000000000000, from:accounts[0]});
    }).then(function(ret) {
      return c.getContribution.call(accounts[0],{from:accounts[0]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),120000000000000000000, "accounts[0] amount of wei contributed should be 120000000000000000000 wei");
      return c.getTokenPurchase.call(accounts[0],{from:accounts[0]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),56000, "accounts[0] amount of tokens purchased should be 56000 tokens");
      return c.receivePurchase(1112,{value: 120000000000000000000, from: accounts[5]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, 'Owner cannot send ether to contract', "should give an error message since the owner cannot donate to its own contract");
      return c.ownerWithdrawl(112,{from: accounts[5]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, 'Cannot withdraw owner ether until after the sale', "Should give an error that sale ether cannot be withdrawn till after the sale");
      return c.getContribution.call(accounts[5]);
    }).then(function(ret) {
      assert.equal(ret.valueOf(),0,"accounts[5] (owner) ether contribution should be 0");
      return c.receivePurchase(116, {value: 500000000000000000011, from:accounts[3]});
    }).then(function(ret) {
      return c.getContribution.call(accounts[3],{from:accounts[3]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),500000000000000000011, "accounts[3] amount of wei contributed should be 1500000000000000000011 wei");
      return c.getTokenPurchase.call(accounts[3],{from:accounts[3]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),150000, "accounts[3] amount of tokens purchased should be 150000 tokens");
      return c.tokensPerEth.call();
    }).then(function(ret) {
      assert.equal(ret.valueOf(),300, "New token price should be 300 tokens per ether!");
      return c.withdrawTokens({from:accounts[0]});
    }).then(function(ret) {
      return c.getTokenPurchase.call(accounts[0],{from:accounts[0]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),0,"accounts[0] should have withdrawn all tokens and should now have zero in the contract");
      return c.setExchangeRate(100, 113, {from:accounts[5]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, 'Owner can only set the exchange rate two days before the sale!', "Should give an error message that timing for setting the exchange rate is wrong.");
      return c.receivePurchase(116, {value: 20000000000000000000000, from: accounts[2]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, 'buyer ether sent exceeds cap of ether to be raised!', "should give error message that the raise cap has been exceeded");
      return c.receivePurchase(117, {value: 19800000000000000000000, from: accounts[2]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, 'buyer ether sent exceeds cap of ether to be raised!', "should give error message that the raise cap has been exceeded");
    });
  });
});



  /********************************************************
    AFTER SALE - YES PRICE CHANGE
  /*******************************************************/
  it("should deny payments after the sale and allow users to withdraw their tokens/owner to withdraw ether", function() {
    var c;

    return TimeDirectCrowdsaleTestContract.deployed().then(function(instance) {
      c = instance;
      return c.ownerBalance.call();
    }).then(function(ret) {
      console.log(ret.valueOf());
      assert.equal(ret.valueOf(),620000000000000000000, "owners balance of ether should be 620!");
      return c.getTokenPurchase.call(accounts[0],{from:accounts[0]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),0, "accounts[0] amount of tokens purchased should be 0 tokens");
      return c.getTokenPurchase.call(accounts[3],{from:accounts[3]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),150000, "accounts[3] amount of tokens purchased should be 150000 tokens");
      return c.withdrawTokens({from:accounts[3]});
    }).then(function(ret) {
      return c.getTokenPurchase.call(accounts[3],{from:accounts[3]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),0,"accounts[3] should have withdrawn all tokens and should now have zero in the contract");
      return c.receivePurchase(121,{from:accounts[2]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, 'Invalid Purchase! Check send time and amount of ether.', "should give an error message since no ether was sent");
      return c.withdrawTokens({from:accounts[2]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, 'Sender has no tokens to withdraw!', "should give message that the sender cannot withdraw any tokens");
      return c.ownerWithdrawl(121,{from:accounts[5]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, 'crowdsale owner has withdrawn all funds', "Should give message that the owner has withdrawn all funds");
      return c.ownerBalance.call();
    }).then(function(ret) {
      assert.equal(ret.valueOf(), 0, "Owner's ether balance in the contract should be zero!");
    });
  });
});