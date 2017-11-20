const TimeDirectCrowdsaleTestContract = artifacts.require("TimeDirectCrowdsaleTestContract");
const CrowdsaleToken = artifacts.require("CrowdsaleToken");

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
      assert.equal(returnObj.totalSupply.valueOf(), 20000000000000000000000000, "Total supply should reflect 20000000000000000000.");
    });
  });
});

contract('TimeDirectCrowdsaleTestContract', function(accounts) {
  it("should initialize the direct crowdsale contract data", function() {
    var returnObj = {};
    var c;

    return TimeDirectCrowdsaleTestContract.deployed().then(function(instance) {
      c = instance;

      return c.getOwner.call();
    }).then(function(o){
      returnObj.owner = o;
      return c.getTokensPerEth.call();
    }).then(function(tpe) {
      returnObj.tokensPerEth = tpe;
      return c.getCapAmount.call();
    }).then(function(ca){
      returnObj.capAmount = ca;
      return c.getStartTime.call();
    }).then(function(st){
      returnObj.startTime = st;
      return c.getEndTime.call();
    }).then(function(et){
      returnObj.endTime = et;
      return c.getExchangeRate.call();
    }).then(function(er) {
      returnObj.exchangeRate = er;
      return c.getEthRaised.call();
    }).then(function(ob) {
      returnObj.ownerBalance = ob;
      return c.getSaleData.call(0);
    }).then(function(pd){
      console.log(pd);
      assert.equal(returnObj.owner.valueOf(), accounts[5], "Owner should be set to the account5");
      assert.equal(returnObj.tokensPerEth.valueOf(), 206, "Tokens per ETH should be 205");
      assert.equal(returnObj.capAmount.valueOf(), 58621000000000000000000, "capAmount should be set to 56821000000000000000000 wei");
      assert.equal(returnObj.startTime.valueOf(),105, "start time should be 105");
      assert.equal(returnObj.endTime.valueOf(),125, "end time should be 125");
      assert.equal(returnObj.exchangeRate.valueOf(),29000, "exchangeRate should be 29000");
      assert.equal(returnObj.ownerBalance.valueOf(), 0, "Amount of wei raised in the crowdsale should be zero");
    });
  });
  it("should deny all requests to interact with the contract before the crowdsale starts", function() {
    var c;

    return TimeDirectCrowdsaleTestContract.deployed().then(function(instance) {
      c = instance;

      return CrowdsaleToken.deployed().then(function(instance) {
      t = instance;
      return t.transfer(c.contract.address,12000000000000000000000000,{from:accounts[5]});
    }).then(function(ret) {
      return t.balanceOf.call(c.contract.address);
    }).then(function(ret) {
      assert.equal(ret.valueOf(), 12000000000000000000000000,  "crowdsale's token balance should be 20000000000000000000000000!");
      return c.crowdsaleActive.call(101);
    }).then(function(ret) {
      assert.equal(ret.valueOf(), false, "Crowsale should not be active!");
      return c.crowdsaleEnded.call(101);
    }).then(function(ret) {
      assert.equal(ret.valueOf(), false, "Crowsale should not be ended!");
      return c.withdrawTokens(103,{from:accounts[0]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, 'Sender has no tokens to withdraw!', "should give message that token sale has not ended");
      return c.receivePurchase(103,{value: 40000000000000000000, from: accounts[1]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, 'Invalid Purchase! Check send time and amount of ether.', "should give an error message since sale has not started");
      return c.receivePurchase(103,{value: 20000000000000000000, from: accounts[5]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, 'Owner cannot send ether to contract', "should give an error message since sale has not started");
      return c.withdrawOwnerEth(104,{from: accounts[5]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, 'Cannot withdraw owner ether until after the sale', "Should give an error that sale ether cannot be withdrawn till after the sale");
      return c.getContribution.call(accounts[1]);
    }).then(function(ret) {
      assert.equal(ret.valueOf(),0,"accounts[1] ether contribution should be 0");
      return c.getTokenPurchase.call(accounts[1]);
    }).then(function(ret) {
      assert.equal(ret.valueOf(), 0,"accounts[1] token balance should be 0");
      return c.setTokenExchangeRate(30000,101, {from:accounts[5]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, 'Owner can only set the exchange rate once up to three days before the sale!', "Should give an error message that timing for setting the exchange rate is wrong.");
      return c.setTokenExchangeRate(30000,103, {from:accounts[5]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, "Owner has sent the exchange Rate and tokens bought per ETH!", "Should give success message that the exchange rate was set.");
      return c.setTokenExchangeRate(30000,101, {from:accounts[5]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, 'Owner can only set the exchange rate once up to three days before the sale!', "Should give an error message that timing for setting the exchange rate is wrong.");
      return c.getExchangeRate.call();
    }).then(function(ret) {
      assert.equal(ret.valueOf(), 30000, "exchangeRate should have been set to 30000!");
      return c.getTokensPerEth.call();
    }).then(function(ret) {
      assert.equal(ret.valueOf(), 213, "tokensPerEth should have been set to 212!");
      return c.withdrawOwnerEth(104, {from:accounts[5]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, "Cannot withdraw owner ether until after the sale", "Should give error message that the owner cannot withdraw any ETH yet");
      return c.withdrawTokens(104, {from:accounts[5]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, "Owner cannot withdraw extra tokens until after the sale!", "Should give error message that the owner cannot withdraw any extra tokens yet");
      return c.withdrawLeftoverWei({from:accounts[0]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, 'Sender has no extra wei to withdraw!', "should give message that the sender cannot withdraw any wei");
    });
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
  //     return c.withdrawOwnerEth(106,{from: accounts[5]});
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
  //     return c.withdrawOwnerEth(111,{from:accounts[5]});
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

      return c.crowdsaleActive.call(106);
    }).then(function(ret) {
      assert.equal(ret.valueOf(), true, "Crowsale should be active!");
      return c.crowdsaleEnded.call(106);
    }).then(function(ret) {
      assert.equal(ret.valueOf(), false, "Crowsale should not be ended!");
//      return c.changeInterval.call();
//    }).then(function(ret) {
//      assert.equal(ret.valueOf(),5, "Price Change time interval should be 5!");
      return c.withdrawTokens(106,{from:accounts[0]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, 'Sender has no tokens to withdraw!', "should give message that the sender cannot withdraw any tokens");
      return c.withdrawLeftoverWei({from:accounts[3]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, 'Sender has no extra wei to withdraw!', "should give message that the sender cannot withdraw any wei");
      return c.withdrawLeftoverWei({from:accounts[5]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, 'Sender has no extra wei to withdraw!', "should give message that the sender cannot withdraw any wei");
      return c.receivePurchase(106,{from:accounts[0]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, 'Invalid Purchase! Check send time and amount of ether.', "should give an error message since no ether was sent");
      return c.receivePurchase(106,{value:39990000000000000000,from:accounts[0]});
    }).then(function(ret) {
      return c.getLeftoverWei.call(accounts[0]);
    }).then(function(ret) {
      return c.receivePurchase(106,{value:10000000000000000,from:accounts[0]});
    }).then(function(ret) {
      return c.getLeftoverWei.call(accounts[0]);
    }).then(function(ret) {
      assert.equal(ret.valueOf(),0, "should show that accounts0 has 0 leftover wei");
      //assert.equal(ret.logs[0].args.Msg, 'Sender has no extra wei to withdraw!', "should give message that the sender cannot withdraw any wei");
      return c.getContribution.call(accounts[0], {from:accounts[0]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),40000000000000000000, "accounts[0] amount of wei contributed should be 40000000000000000000 wei");
      return c.getTokenPurchase.call(accounts[0]);
    }).then(function(ret) {
      assert.equal(ret.valueOf(), 8520000000000000000000, "accounts[0] tokens purchased should be 8520000000000000000000");
      return c.receivePurchase(111,{value: 40000000000000000000, from:accounts[0]});
    }).then(function(ret) {
      return c.getTokensPerEth.call();
    }).then(function(ret) {
      assert.equal(ret.valueOf(), 194, "tokensPerEth should have been set to 194!");
      return c.getContribution.call(accounts[0], {from:accounts[0]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),80000000000000000000, "accounts[0] amount of wei contributed should be 80000000000000000000 wei");
      return c.getTokenPurchase.call(accounts[0],{from:accounts[0]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),16280000000000000000000, "accounts[0] amount of tokens purchased should be 16280000000000000000000 tokens");
      return c.receivePurchase(111, {value: 40000000000000000000, from:accounts[0]});
    }).then(function(ret) {
      return c.getContribution.call(accounts[0],{from:accounts[0]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),120000000000000000000, "accounts[0] amount of wei contributed should be 120000000000000000000 wei");
      return c.getTokenPurchase.call(accounts[0],{from:accounts[0]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),24040000000000000000000, "accounts[0] amount of tokens purchased should be 24040000000000000000000 tokens");
      return c.setTokenExchangeRate(30000,112, {from:accounts[5]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, 'Owner can only set the exchange rate once up to three days before the sale!', "Should give an error message that timing for setting the exchange rate is wrong.");
      return c.setTokenExchangeRate(30000,112, {from:accounts[4]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, 'Owner can only set the exchange rate!', "Should give an error message that timing for setting the exchange rate is wrong.");
      return c.receivePurchase(112,{value: 120000000000000000000, from: accounts[5]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, 'Owner cannot send ether to contract', "should give an error message since the owner cannot donate to its own contract");
      return c.withdrawOwnerEth(112,{from: accounts[5]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, 'Cannot withdraw owner ether until after the sale', "Should give an error that sale ether cannot be withdrawn till after the sale");
      return c.getContribution.call(accounts[5]);
    }).then(function(ret) {
      assert.equal(ret.valueOf(),0,"accounts[5] (owner) ether contribution should be 0");
      return c.receivePurchase(116, {value: 500000000000000111111, from:accounts[3]});
    }).then(function(ret) {
      return c.getContribution.call(accounts[3],{from:accounts[3]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),500000000000000111111, "accounts[3] amount of wei contributed should be 50000000000000111111 wei");
      return c.getTokenPurchase.call(accounts[3],{from:accounts[3]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),91000000000000018200000, "accounts[3] amount of tokens purchased should be 9100000000000018200000 tokens");
      return c.getTokensPerEth.call();
    }).then(function(ret) {
      assert.equal(ret.valueOf(),182, "New token price should be 182 tokens per ether!");
      return c.withdrawTokens(116,{from:accounts[0]});
    }).then(function(ret) {
      return c.getTokenPurchase.call(accounts[0],{from:accounts[0]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),0,"accounts[0] should have withdrawn all tokens and should now have zero in the contract");
      return c.withdrawTokens(104, {from:accounts[5]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, "Owner cannot withdraw extra tokens until after the sale!", "Should give error message that the owner cannot withdraw any extra tokens yet");
      return c.setTokenExchangeRate(100, 116, {from:accounts[5]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, 'Owner can only set the exchange rate once up to three days before the sale!', "Should give an error message that timing for setting the exchange rate is wrong.");
      return c.receivePurchase(116, {value: 56670000000000000000000, from: accounts[2]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, 'buyer ether sent exceeds cap of ether to be raised!', "should give error message that the raise cap has been exceeded");
      return c.receivePurchase(117, {value: 60000000000000000000000, from: accounts[2]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, 'buyer ether sent exceeds cap of ether to be raised!', "should give error message that the raise cap has been exceeded");
      return c.receivePurchase(122, {value: 500000000000000100000, from:accounts[4]});
    }).then(function(ret) {
      return c.getContribution.call(accounts[4],{from:accounts[4]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),500000000000000100000, "accounts[4] amount of wei contributed should be 500000000000000100000 wei");
      return c.getTokenPurchase.call(accounts[4],{from:accounts[4]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),91000000000000018200000, "accounts[4] amount of tokens purchased should be 91000000000000018200000 tokens");
      return c.getLeftoverWei.call(accounts[4],{from:accounts[4]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),0, "accounts[4] leftover wei should be 0");
      return c.withdrawLeftoverWei({from:accounts[4]});
    }).then(function(ret) {
      return c.getLeftoverWei.call(accounts[4],{from:accounts[4]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),0, "accounts[4] should have no leftover wei because it was just withdrawn");
    });
  });
//});



  /********************************************************
    AFTER SALE - YES PRICE CHANGE
  /*******************************************************/
  it("should deny payments after the sale and allow users to withdraw their tokens/owner to withdraw ether", function() {
    var c;

    return TimeDirectCrowdsaleTestContract.deployed().then(function(instance) {
      c = instance;
      return c.crowdsaleActive.call(126);
    }).then(function(ret) {
      assert.equal(ret.valueOf(), false, "Crowsale should not be active!");
      return c.crowdsaleEnded.call(126);
    }).then(function(ret) {
      assert.equal(ret.valueOf(), true, "Crowsale should be ended!");
      return c.getEthRaised.call();
    }).then(function(ret) {
      return c.getTokenPurchase.call(accounts[0],{from:accounts[0]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),0, "accounts[0] amount of tokens purchased should be 0 tokens");
      return c.withdrawTokens(126,{from:accounts[0]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, "Sender has no tokens to withdraw!", "Accounts[0] alread withdrew all tokens. should be error");
      return c.getTokenPurchase.call(accounts[3],{from:accounts[3]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),91000000000000018200000, "accounts[3] amount of tokens purchased should be 9100000000000018200000 tokens");
      return c.withdrawTokens(126,{from:accounts[3]});
    }).then(function(ret) {
      return c.getTokenPurchase.call(accounts[3],{from:accounts[3]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),0,"accounts[3] should have withdrawn all tokens and should now have zero in the contract");
      return c.withdrawLeftoverWei({from:accounts[4]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, "Sender has no extra wei to withdraw!", "should give error message because accounts4 already withdrew wei");
      return c.withdrawLeftoverWei({from:accounts[3]});
    }).then(function(ret) {
      return c.getLeftoverWei.call(accounts[3],{from:accounts[3]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),0, "accounts[4] should have no leftover wei because it was just withdrawn");
      return c.receivePurchase(126,{from:accounts[2]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, 'Invalid Purchase! Check send time and amount of ether.', "should give an error message since no ether was sent");
      return c.withdrawTokens(127,{from:accounts[2]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, 'Sender has no tokens to withdraw!', "should give message that the sender cannot withdraw any tokens");
      return c.withdrawOwnerEth(127,{from:accounts[5]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, 'crowdsale owner has withdrawn all funds', "Should give message that the owner has withdrawn all funds");
      return c.withdrawTokens(126,{from:accounts[4]});
    }).then(function(ret) {
      return c.getTokenPurchase.call(accounts[4],{from:accounts[4]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),0,"accounts[4] should have withdrawn all tokens and should now have zero in the contract");

      return c.getEthRaised.call();
    }).then(function(ret) {
      assert.equal(ret.valueOf(), 0, "Owner's ether balance in the contract should be zero!");

      /******************
      * TOKEN CONTRACT BALANCE CHECKS
      *******************/
      return CrowdsaleToken.deployed().then(function(instance) {
      t = instance;
      return t.balanceOf.call(accounts[0],{from:accounts[0]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(), 24040000000000000000000, "accounts0 token balance should be 24040000000000000000000");
      return t.balanceOf.call(accounts[1],{from:accounts[1]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(), 0, "accounts1 token balance should be 0");
      return t.balanceOf.call(accounts[2],{from:accounts[2]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(), 0, "accounts2 token balance should be 0");
      return t.balanceOf.call(accounts[3],{from:accounts[3]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(), 91000000000000018200000, "accounts3 token balance should be 91000000000000018200000");
      return t.balanceOf.call(accounts[4],{from:accounts[4]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(), 91000000000000018200000, "accounts4 token balance should be 91000000000000018200000");
      return t.balanceOf.call(accounts[5],{from:accounts[5]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(), 8000000000000000000000000, "accounts5 token balance should be 8000000000000000000000000");
      return t.balanceOf.call(c.contract.address);
    }).then(function(ret) {
      assert.equal(ret.valueOf(), 11793959999999999963600000,  "crowdsale's token balance should be 11793959999999999963600000!");

      return c.withdrawTokens(128,{from:accounts[5]});
    }).then(function(ret) {
      return c.getTokenPurchase.call(accounts[5],{from:accounts[5]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),0, "Owner should have withdrawn all the leftover tokens from the sale!");
      return t.balanceOf.call(accounts[5],{from:accounts[5]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(), 13896979999999999981800000, "accounts5 token balance should be 13896979999999999981800000");
      return t.balanceOf.call(c.contract.address);
    }).then(function(ret) {
      assert.equal(ret.valueOf(), 0,  "crowdsale's token balance should be 0!");
      return t.initialSupply();
    }).then(function(ret){
      assert.equal(ret.valueOf(), 20000000000000000000000000,  "The token's initial supply was 20M");
      return t.totalSupply();
    }).then(function(ret){
      assert.equal(ret.valueOf(), 14103020000000000018200000,  "The token's new supply is 14103020000000000018200000");
    });
  });
  });
});
