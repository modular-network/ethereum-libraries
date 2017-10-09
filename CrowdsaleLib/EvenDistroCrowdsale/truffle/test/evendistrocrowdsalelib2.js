var TimeEvenDistroCrowdsaleTestContract2 = artifacts.require("TimeEvenDistroCrowdsaleTestContract2");
var CrowdsaleToken2 = artifacts.require("CrowdsaleToken2");

contract('CrowdsaleToken2', function(accounts) {
  it("should properly initialize token data", function() {
    var returnObj = {};
    var c;

    return CrowdsaleToken2.deployed().then(function(instance) {
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
      assert.equal(returnObj.decimals.valueOf(), 0, "Decimals should be set to 0.");
      assert.equal(returnObj.totalSupply.valueOf(), 500000000, "Total supply should reflect 500000000.");
    });
  });
});

contract('TimeEvenDistroCrowdsaleTestContract2', function(accounts) {
  it("should initialize the even crowdsale contract data", function() {
    var returnObj = {};
    var c;

    return TimeEvenDistroCrowdsaleTestContract2.deployed().then(function(instance) {
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
      return c.getPercentBurn.call();
    }).then(function(pb) {
      returnObj.percentBurn = pb;
      return c.getEthRaised.call();
    }).then(function(ob){
      returnObj.ownerBalance = ob;
      assert.equal(returnObj.owner.valueOf(), accounts[5], "Owner should be set to the account5");
      assert.equal(returnObj.tokensPerEth.valueOf(), 580, "Tokens per ETH should be 580");
      assert.equal(returnObj.capAmount.valueOf(), 1379311000000000000000000, "capAmount should be set to 1379311000000000000000000 wei");
    });
  });
});

contract('TimeEvenDistroCrowdsaleTestContract2', function(accounts) {
  it("should initialize the start time correctly", function() {
    var returnObj = {};
    var c;

    return TimeEvenDistroCrowdsaleTestContract2.deployed().then(function(instance) {
      c = instance;

      return c.getStartTime.call();
    }).then(function(st){
      returnObj.startTime = st;
      assert.equal(returnObj.startTime.valueOf(),105, "start time should be 105");
    });
  });
});

contract('TimeEvenDistroCrowdsaleTestContract2', function(accounts) {
  it("should initialize the end time correctly", function() {
    var returnObj = {};
    var c;

    return TimeEvenDistroCrowdsaleTestContract2.deployed().then(function(instance) {
      c = instance;

      return c.getEndTime.call();
    }).then(function(et){
      returnObj.endTime = et;
      assert.equal(returnObj.endTime.valueOf(),165, "end time should be 165");
    });
  });
});

contract('TimeEvenDistroCrowdsaleTestContract2', function(accounts) {
  it("should initialize the exchange rate correctly", function() {
    var returnObj = {};
    var c;

    return TimeEvenDistroCrowdsaleTestContract2.deployed().then(function(instance) {
      c = instance;

      return c.getExchangeRate.call();
    }).then(function(er) {
      returnObj.exchangeRate = er;
      assert.equal(returnObj.exchangeRate.valueOf(),29000, "exchangeRate should be 29000");
    });
  });
});

contract('TimeEvenDistroCrowdsaleTestContract2', function(accounts) {
  it("should initialize the ownerBalance to 0", function() {
    var returnObj = {};
    var c;

    return TimeEvenDistroCrowdsaleTestContract2.deployed().then(function(instance) {
      c = instance;

      return c.getEthRaised.call();
    }).then(function(ob){
      returnObj.ownerBalance = ob;
      assert.equal(returnObj.ownerBalance.valueOf(), 0, "Amount of wei raised in the crowdsale should be zero");
    });
  });
});

contract('TimeEvenDistroCrowdsaleTestContract2', function(accounts) {
  it("should initialize the percentage to burn correctly", function() {
    var returnObj = {};
    var c;

    return TimeEvenDistroCrowdsaleTestContract2.deployed().then(function(instance) {
      c = instance;

      return c.getPercentBurn.call();
    }).then(function(pb) {
      returnObj.percentBurn = pb;
      assert.equal(returnObj.percentBurn.valueOf(), 100, "Percentage of Tokens to burn after the crowdsale should be 100!");
    });
  });
});

contract('TimeEvenDistroCrowdsaleTestContract2', function(accounts) {
  it("should initialize the sale data correctly", function() {
    var returnObj = {};
    var c;

    return TimeEvenDistroCrowdsaleTestContract2.deployed().then(function(instance) {
      c = instance;

      return c.getSaleData.call(100);
    }).then(function(sd) {
      assert.equal(sd[0].valueOf(), 105, "First timestamp should be 105");
      assert.equal(sd[1].valueOf(), 50, "First price should be 50 cents");
      assert.equal(sd[2].valueOf(), 50000, "First token max should be 50000");
    });
  });
});

contract('TimeEvenDistroCrowdsaleTestContract2', function(accounts) {
  it("should return the proper sale data", function() {
    var returnObj = {};
    var c;

    return TimeEvenDistroCrowdsaleTestContract2.deployed().then(function(instance) {
      c = instance;

      return c.getSaleData.call(140);
    }).then(function(sd) {
      assert.equal(sd[0].valueOf(), 135, "Last timestamp should be 135");
      assert.equal(sd[1].valueOf(), 75, "Last price should be 100 cents");
      assert.equal(sd[2].valueOf(), 50000, "Last token max should be 50000");
    });
  });
});

contract('TimeEvenDistroCrowdsaleTestContract2', function(accounts) {
  it("should return the proper sale data", function() {
    var returnObj = {};
    var c;

    return TimeEvenDistroCrowdsaleTestContract2.deployed().then(function(instance) {
      c = instance;

      return c.getSaleData.call(116);
    }).then(function(sd) {
      assert.equal(sd[0].valueOf(), 105, "Should give fist timestamp");
      assert.equal(sd[1].valueOf(), 50, "Should give first price");
      assert.equal(sd[2].valueOf(), 50000, "Token max should be 50000");
    });
  });
});

contract('TimeEvenDistroCrowdsaleTestContract2', function(accounts) {
  it("should deny non-owner transactions pre-crowdsale, allow user registration, and set exchange rate and address cap", function() {
    var c;

    return TimeEvenDistroCrowdsaleTestContract2.deployed().then(function(instance) {
      c = instance;

      return CrowdsaleToken2.deployed().then(function(instance) {
        t = instance;
        return t.transfer(c.contract.address,400000000,{from:accounts[5]});
      }).then(function(ret) {
        return t.balanceOf.call(c.contract.address);
      }).then(function(ret) {
        assert.equal(ret.valueOf(), 400000000,  "crowdsale's token balance should be 400000000!");
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
        return c.registerUser(accounts[0],96,{from:accounts[5]});
      }).then(function(ret) {
        return c.registerUser(accounts[0],96,{from:accounts[5]});
      }).then(function(ret) {
        assert.equal(ret.logs[0].args.Msg, 'Registrant address is already registered for the sale!', "Should give error message that the user is already registered");
        return c.isRegistered(accounts[0]);
      }).then(function(ret) {
        assert.equal(ret.valueOf(),true, "accounts[0] should be registered");
        return c.isRegistered(accounts[1]);
      }).then(function(ret) {
        assert.equal(ret.valueOf(),false, "accounts[1] should not be registered");
        return c.unregisterUser(accounts[1],100,{from:accounts[5]});
      }).then(function(ret) {
        assert.equal(ret.logs[0].args.Msg, 'Registrant address not registered for the sale!', "Should give error message that the user is not registered");
        return c.registerUser(accounts[1],96,{from:accounts[5]});
      }).then(function(ret) {
        return c.isRegistered(accounts[1]);
      }).then(function(ret) {
        assert.equal(ret.valueOf(),true, "accounts[1] should be registered");
        return c.unregisterUser(accounts[1],100,{from:accounts[5]});
      }).then(function(ret) {
        return c.isRegistered(accounts[1]);
      }).then(function(ret) {
        assert.equal(ret.valueOf(),false, "accounts[1] should not be registered");
        return c.registerUser(accounts[1],99,{from:accounts[5]});
      }).then(function(ret) {
        return c.isRegistered(accounts[1]);
      }).then(function(ret) {
        assert.equal(ret.valueOf(),true, "accounts[1] should be registered");
        return c.registerUser(accounts[2],99,{from:accounts[5]});
      }).then(function(ret) {
        return c.registerUser(accounts[3],99,{from:accounts[5]});
      }).then(function(ret) {
        return c.registerUser(accounts[4],104,{from:accounts[5]});
      }).then(function(ret) {
        assert.equal(ret.logs[0].args.registrant, accounts[4], "Should allow registration because of static cap");
        return c.unregisterUser(accounts[1],104,{from:accounts[5]});
      }).then(function(ret) {
        assert.equal(ret.logs[0].args.registrant, accounts[1], "Should allow unregistration because of static cap");
        return c.getNumRegistered.call();
      }).then(function(ret) {
        assert.equal(ret.valueOf(),4,"Four Users should be registered!");
        return c.unregisterUsers([accounts[0],accounts[1],accounts[2]],101,{from:accounts[5]});
      }).then(function(ret) {
        return c.isRegistered(accounts[1]);
      }).then(function(ret) {
        assert.equal(ret.valueOf(),false, "accounts[1] should not be registered");
        return c.getNumRegistered.call();
      }).then(function(ret) {
        assert.equal(ret.valueOf(),3,"Three users should be registered!");
        return c.registerUsers([accounts[0],accounts[1],accounts[2]],101,{from:accounts[5]});
      }).then(function(ret) {
        return c.isRegistered(accounts[1]);
      }).then(function(ret) {
        assert.equal(ret.valueOf(),true, "accounts[1] should be registered");
        return c.getNumRegistered.call();
      }).then(function(ret) {
        assert.equal(ret.valueOf(),5,"Five Users should be registered!");
        return c.setTokenExchangeRate(30000,101, {from:accounts[5]});
      }).then(function(ret) {
        assert.equal(ret.logs[0].args.Msg, 'Owner can only set the exchange rate once up to three days before the sale!', "Should give an error message that timing for setting the exchange rate is wrong.");
        return c.setTokenExchangeRate(30000,104, {from:accounts[5]});
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
        assert.equal(ret.valueOf(), 600, "tokensPerEth should have been set to 600!");
        return c.getAddressTokenCap.call();
      }).then(function(ret) {
        assert.equal(ret.valueOf(), 50000, "Address cap should have been calculated to correct number!");
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

  it("should deny invalid payments during the sale and accept payments that are reflected in token balance", function() {
    var c;

    return TimeEvenDistroCrowdsaleTestContract2.deployed().then(function(instance) {
      c = instance;

      return c.crowdsaleActive.call(106);
    }).then(function(ret) {
      assert.equal(ret.valueOf(), true, "Crowsale should be active!");
      return c.crowdsaleEnded.call(106);
    }).then(function(ret) {
      assert.equal(ret.valueOf(), false, "Crowsale should not be ended!");
      return c.registerUser(accounts[4],106,{from:accounts[5]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, 'Registrant address is already registered for the sale!', "Should not allow registration because account is registered");
      return c.unregisterUser(accounts[1],106,{from:accounts[5]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.registrant, accounts[1], "Should allow unregistration because of static cap");
      return c.getNumRegistered.call();
    }).then(function(ret) {
      assert.equal(ret.valueOf(),4,"Four Users should be registered!");
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
      assert.equal(ret.logs[0].args.amount, 23994, "should have bought correct amount of tokens");
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
      assert.equal(ret.valueOf(), 24000, "accounts[0] tokens purchased should be 24000");
      return c.receivePurchase(108,{value: 40000000000000000000000, from:accounts[0]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, "Cap Per Address has been exceeded! Please withdraw leftover Wei!","should show message that the addressTokenCap was exceeded");
      return c.receivePurchase(108,{value: 40000000000000000000, from:accounts[4]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.amount, 24000, "accounts[4] tokens purchased should be 24000");
      return c.receivePurchase(108,{value: 40000000000000000000000, from:accounts[1]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, "Buyer is not registered for the sale!","the address is not registered");
      return c.getLeftoverWei.call(accounts[0]);
    }).then(function(ret) {
      assert.equal(ret.valueOf(),39956668333333333333334,"accounts0 LeftoverWei should be 39957666666666666666467");
      return c.getLeftoverWei.call(accounts[1]);
    }).then(function(ret) {
      assert.equal(ret.valueOf(),0,"accounts1 LeftoverWei should be 0");
      return c.getTokensPerEth.call();
    }).then(function(ret) {
      assert.equal(ret.valueOf(), 600, "tokensPerEth should stay the same!");
      return c.getTokenPurchase(accounts[0]);
    }).then(function(ret) {
      assert.equal(ret.valueOf(),49999, "accounts[0] amount of wei contributed should be 14655250000000000000000 wei");
      return c.getContribution.call(accounts[1], {from:accounts[1]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),0, "accounts[1] amount of wei contributed should be 0 wei");
      return c.getTokenPurchase.call(accounts[0],{from:accounts[0]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),49999, "accounts0 amount of tokens purchased should be 49999 tokens");
      return c.getTokenPurchase.call(accounts[1],{from:accounts[1]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),0, "accounts1 amount of tokens purchased should be 0 tokens");
      return c.receivePurchase(140, {value: 40000000000000000000, from:accounts[0]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, "Address cap has increased!", "Should give message the the address cap has increased!");
      return c.getAddressTokenCap.call();
    }).then(function(ret) {
      assert.equal(ret.valueOf(),50000, "Address cap should be 50000");
      return c.getContribution.call(accounts[0],{from:accounts[0]});
    }).then(function(ret) {
      console.log(ret.valueOf());
      assert.equal(ret.valueOf(),83334166666666666666, "accounts[0] amount of wei contributed should be 83331666666666666666 wei");
      return c.getTokenPurchase.call(accounts[0],{from:accounts[0]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),50000, "accounts[0] amount of tokens purchased should be 49999 tokens");
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
      return c.receivePurchase(114, {value: 500000000000000111111, from:accounts[3]});
    }).then(function(ret) {
      return c.getContribution.call(accounts[3],{from:accounts[3]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),125000000000000000000, "accounts[3] amount of wei contributed should be 50000000000000111111 wei");
      return c.getTokenPurchase.call(accounts[3],{from:accounts[3]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),50000, "accounts[3] amount of tokens purchased should be 50000 tokens");
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
      return c.receivePurchase(121, {value: 56670000000000000000000, from: accounts[3]});
    }).then(function(ret) {
      console.log(ret.logs[0].args);
      assert.equal(ret.logs[0].args.Msg, 'Cannot but anymore tokens!', "should give error message that the buyer cannot buy anymore");
      return c.receivePurchase(121, {value: 60000000000000000000000, from: accounts[3]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, 'Cannot but anymore tokens!', "should give error message that the buyer cannot buy anymore");
      return c.receivePurchase(122, {value: 000000000000100000, from:accounts[2]});
    }).then(function(ret) {
      return c.getTokenPurchase.call(accounts[2],{from:accounts[4]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),0, "accounts[2] amount of tokens bought should be 0");
      return c.getTokenPurchase.call(accounts[1],{from:accounts[4]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),0, "accounts[1] amount of tokens purchased should be 0 tokens");
      return c.getLeftoverWei.call(accounts[1],{from:accounts[4]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),0, "accounts[1] leftover wei should be 0");
      return c.withdrawLeftoverWei({from:accounts[0]});
    }).then(function(ret) {
      return c.getLeftoverWei.call(accounts[0],{from:accounts[4]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),0, "accounts[0] should have no leftover wei because it was just withdrawn");
    });
  });



  ///********************************************************
  //  AFTER SALE
  //******************************************************
  it("should deny payments after the sale and allow users to withdraw their tokens/owner to withdraw ether", function() {
    var c;

    return TimeEvenDistroCrowdsaleTestContract2.deployed().then(function(instance) {
      c = instance;
      return c.crowdsaleActive.call(166);
    }).then(function(ret) {
      assert.equal(ret.valueOf(), false, "Crowsale should not be active!");
      return c.crowdsaleEnded.call(167);
    }).then(function(ret) {
      assert.equal(ret.valueOf(), true, "Crowsale should be ended!");
      return c.registerUser(accounts[4],145,{from:accounts[5]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, 'Registrant address is already registered for the sale!', "Should give an error that user is registered for the sale");
      return c.unregisterUser(accounts[1],137,{from:accounts[5]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, 'Registrant address not registered for the sale!', "Should give an error that user was not registered");
      return c.getNumRegistered.call();
    }).then(function(ret) {
      assert.equal(ret.valueOf(),4,"Four Users should be registered!");
      return c.getEthRaised.call();
    }).then(function(ret) {
      console.log(ret.valueOf());
      return c.getContribution.call(accounts[0]);
    }).then(function(ret) {
      console.log(ret.valueOf());
      return c.getContribution.call(accounts[4]);
    }).then(function(ret) {
      console.log(ret.valueOf());
      return c.getContribution.call(accounts[3]);
    }).then(function(ret) {
      console.log(ret.valueOf());
      return c.getTokenPurchase.call(accounts[0],{from:accounts[0]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),0, "accounts[0] amount of tokens purchased should be 0 tokens");
      return c.withdrawTokens(126,{from:accounts[0]});
    }).then(function(ret) {
      assert.equal(ret.logs[0].args.Msg, "Sender has no tokens to withdraw!", "Accounts[0] alread withdrew all tokens. should be error");
      return c.getTokenPurchase.call(accounts[3],{from:accounts[3]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),50000, "accounts[3] amount of tokens purchased should be 50000 tokens");
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
      return c.withdrawOwnerEth(167,{from:accounts[5]});
    }).then(function(ret) {
      console.log(ret.logs[0].args);
      assert.equal(ret.logs[0].args.Msg, 'crowdsale owner has withdrawn all funds', "Should give message that the owner has withdrawn all funds");
      return c.getTokenPurchase.call(accounts[1],{from:accounts[1]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),0,"accounts[1] should have 0 tokens available to withdraw");
      return c.withdrawTokens(126,{from:accounts[1]});
    }).then(function(ret) {
      return c.getTokenPurchase.call(accounts[1],{from:accounts[1]});
    }).then(function(ret) {
      assert.equal(ret.valueOf(),0,"accounts[1] should have withdrawn all tokens and should now have zero in the contract");
      return c.getEthRaised.call();
    }).then(function(ret) {
      assert.equal(ret.valueOf(), 0, "Owner's ether balance in the contract should be zero!");

      //******************
      //* TOKEN CONTRACT BALANCE CHECKS
      //******************
      return CrowdsaleToken2.deployed().then(function(instance) {
        t = instance;
        return t.balanceOf.call(accounts[0],{from:accounts[0]});
      }).then(function(ret) {
        assert.equal(ret.valueOf(), 50000, "accounts0 token balance should be 50000");
        return t.balanceOf.call(accounts[1],{from:accounts[1]});
      }).then(function(ret) {
        assert.equal(ret.valueOf(), 0, "accounts1 token balance should be 0");
        return t.balanceOf.call(accounts[2],{from:accounts[2]});
      }).then(function(ret) {
        assert.equal(ret.valueOf(), 0, "accounts2 token balance should be 0");
        return t.balanceOf.call(accounts[3],{from:accounts[3]});
      }).then(function(ret) {
        assert.equal(ret.valueOf(), 50000, "accounts3 token balance should be 50000");
        return t.balanceOf.call(accounts[4],{from:accounts[4]});
      }).then(function(ret) {
        assert.equal(ret.valueOf(), 0, "accounts4 token balance should be 0");
        return c.withdrawTokens(190,{from:accounts[4]});
      }).then(function(ret){
        return t.balanceOf.call(accounts[5],{from:accounts[5]});
      }).then(function(ret) {
        assert.equal(ret.valueOf(), 100000000, "accounts5 token balance should be 100000000");
        return t.balanceOf.call(c.contract.address);
      }).then(function(ret) {
        assert.equal(ret.valueOf(), 399876000,  "crowdsale's token balance should be 399900000!");
        return c.getTokenPurchase.call(accounts[5],{from:accounts[5]});
      }).then(function(ret) {
        assert.equal(ret.valueOf(),399876000, "Owners available tokens to withdraw should be 399876000");
        return c.withdrawTokens(170,{from:accounts[5]});
      }).then(function(ret) {
        return c.getTokenPurchase.call(accounts[5],{from:accounts[5]});
      }).then(function(ret) {
        assert.equal(ret.valueOf(),0, "Owner should have withdrawn all the leftover tokens from the sale!");
        return t.balanceOf.call(accounts[5],{from:accounts[5]});
      }).then(function(ret) {
        assert.equal(ret.valueOf(), 100000000, "accounts5 token balance should be 100000000");
        return t.balanceOf.call(c.contract.address);
      }).then(function(ret) {
        assert.equal(ret.valueOf(), 0,  "crowdsale's token balance should be 0!");
        return t.initialSupply();
      }).then(function(ret){
        assert.equal(ret.valueOf(), 500000000,  "The token's initial supply was 500M");
        return t.totalSupply();
      }).then(function(ret){
        assert.equal(ret.valueOf(), 100124000,  "The token's new supply is 100124000");
      });
    });
  });
});
