var Promise = require('bluebird');
var time = require('../helpers/time');

const CrowdsaleTestTokenEteenD = artifacts.require("./CrowdsaleTestTokenEteenD.sol");
const EvenDistroTestEteenD = artifacts.require("./EvenDistroTestEteenD.sol");

const CrowdsaleTestTokenTenD = artifacts.require("./CrowdsaleTestTokenTenD.sol");
const EvenDistroTestTenD = artifacts.require("./EvenDistroTestTenD.sol");

var saleContract;
var token;
var errorThrown;

contract('Setting Variables', ()=>{
  it("should properly set variables", async () => {
    saleContract = await EvenDistroTestEteenD.deployed();
    token = await CrowdsaleTestTokenEteenD.deployed();
  });
});

contract('CrowdsaleTestTokenEteenD', (accounts) => {

  it("should properly initialize token data", async () => {
    const name = await token.name.call();
    const symbol = await token.symbol.call();
    const decimals = await token.decimals.call();
    const totalSupply = await token.totalSupply.call();

    assert.equal(name.valueOf(), 'Eighteen Decimals', "Name should be set to Eighteen Decimals.");
    assert.equal(symbol.valueOf(), 'ETEEN', "Symbol should be set to ETEEN.");
    assert.equal(decimals.valueOf(), 18, "Decimals should be set to 18.");
    assert.equal(totalSupply.valueOf(), 50000000000000000000000000, "Total supply should reflect 50000000000000000000000000.");
  });
});

/*************************************************************************

This version is testing the even distribution version of the sale where
the cap per address is calculated after all the addresses have registered
and no more registration is allowed

**************************************************************************/

contract('EvenDistroTestEteenD', function(accounts) {
  it("should initialize the even crowdsale contract data", async () => {
      const owner = await saleContract.getOwner.call();
      const tokensPerEth = await saleContract.getTokensPerEth.call();
      const startTime = await saleContract.getStartTime.call();
      const endTime = await saleContract.getEndTime.call();
      const ownerBalance = await saleContract.getEthRaised.call();
      const saleData = await saleContract.getSaleData.call(0);
      const saleDataEnd = await saleContract.getSaleData.call(endTime.valueOf());

      assert.equal(owner.valueOf(), accounts[5], "Owner should be set to the account 5");
      assert.equal(tokensPerEth.valueOf(), 600000000000000000000, "Tokens per ETH should be 900000000000000000000");
      assert.equal(endTime.valueOf() - 2592000,startTime.valueOf(), "end time should be 30 days");
      assert.equal(ownerBalance.valueOf(), 0, "Amount of wei raised in the crowdsale should be zero");
  });

  it("accept tokens from the owner", async () => {
    const tokenTransfer = await token.transfer(saleContract.address, 160000000000000000000000,{ from:accounts[0] });
    const balance = await token.balanceOf.call(saleContract.address);
    assert.equal(balance.valueOf(), 160000000000000000000000,  "crowdsale's token balance should be 160000000000000000000000!");
  });

  it("should deny non-owner transactions pre-crowdsale, allow user registration, and set exchange rate and address cap", async () => {

    const crowdsaleActive = await saleContract.crowdsaleActive.call();
    assert.equal(crowdsaleActive.valueOf(), false, "Crowsale should not be active!");

    const crowdsaleEnded = await saleContract.crowdsaleEnded.call();
    assert.equal(crowdsaleEnded.valueOf(), false, "Crowsale should not be ended!");

    const withdrawTokens = await saleContract.withdrawTokens({ from:accounts[0] });
    assert.equal(withdrawTokens.logs[0].args.Msg,
                'Sender has no tokens to withdraw!',
                "should give message that token sale has not ended");

    try{
      await saleContract.sendPurchase({ value: 40000000000000000000, from: accounts[1] });
    } catch(e) {
      errorThrown = true;
    }
    assert.isTrue(errorThrown, "should give an error message since sale has not started");
    errorThrown = false;

    try{
      await saleContract.sendPurchase({ value: 20000000000000000000, from: accounts[0] });
    } catch(e) {
      errorThrown = true;
    }
    assert.isTrue(errorThrown, "should give an error message since sale has not started");
    errorThrown = false;

    var reglog = await saleContract.registerUser(accounts[0],{from:accounts[5]});
    // var receipt1 = await web3.eth.getTransactionReceipt(reglog.receipt.transactionHash);

    // console.log("Reglog "+receipt1.logs[0].topics[0]);
    const registerTwice = await saleContract.registerUser(accounts[0],{from:accounts[5]});
    assert.equal(registerTwice.logs[0].args.Msg, 'Registrant address is already registered for the sale!', "Should give error message that the user is already registered");
    // var receipt2 = await web3.eth.getTransactionReceipt(registerTwice.receipt.transactionHash);

    // console.log("Regerr "+receipt2.logs[0].topics[0]);

    const accountZeroReg = await saleContract.isRegistered(accounts[0]);
    assert.equal(accountZeroReg.valueOf(),true, "accounts[0] should be registered");

    const accountOneReg = await saleContract.isRegistered(accounts[1]);
    assert.equal(accountOneReg.valueOf(),false, "accounts[1] should not be registered");

    const accountOneUnreg = await saleContract.unregisterUser(accounts[1],{from:accounts[5]});
    assert.equal(accountOneUnreg.logs[0].args.Msg,
                 'Registrant address not registered for the sale!',
                 "Should give error message that the user is not registered");

    await saleContract.registerUser(accounts[1],{from:accounts[5]});
    const accountOneRegTwo = await saleContract.isRegistered(accounts[1]);
    assert.equal(accountOneRegTwo.valueOf(),true, "accounts[1] should now be registered");

    var unreg = await saleContract.unregisterUser(accounts[1],{from:accounts[5]});
    const accountOneUnregTwo = await saleContract.isRegistered(accounts[1]);
    assert.equal(accountOneUnregTwo.valueOf(),false, "accounts[1] should now be unregistered");
    // var receipt3 = await web3.eth.getTransactionReceipt(unreg.receipt.transactionHash);

    // console.log("unreg "+receipt3.logs[0].topics[0]);

    await saleContract.registerUser(accounts[1],{from:accounts[5]});
    await saleContract.registerUser(accounts[2],{from:accounts[5]});
    await saleContract.registerUser(accounts[3],{from:accounts[5]});

    let numReg = await saleContract.getNumRegistered.call();
    assert.equal(numReg.valueOf(),4,"Four Users should be registered!");

    await saleContract.unregisterUsers([accounts[0],accounts[1],accounts[2]],{from:accounts[5]});

    const accountOneRegThree = await saleContract.isRegistered(accounts[1]);
    assert.equal(accountOneRegThree.valueOf(),false, "accounts[1] should not be registered");

    numReg = await saleContract.getNumRegistered.call();
    assert.equal(numReg.valueOf(),1,"One User should be registered!");

    await saleContract.registerUsers([accounts[0],accounts[1],accounts[2]],{from:accounts[5]});

    const accountOneRegFour = await saleContract.isRegistered(accounts[1]);
    assert.equal(accountOneRegFour.valueOf(),true, "accounts[1] should be registered");

    numReg = await saleContract.getNumRegistered.call();
    assert.equal(numReg.valueOf(),4,"Four users should be registered!");

  });

  it("moves 2 hours and sets the tokens", async () => {
    await time.move(web3, 7200);
    await web3.eth.sendTransaction({from: accounts[3]});
    var capcalc = await saleContract.setTokens({from:accounts[5]});
    // var receipt4 = await web3.eth.getTransactionReceipt(capcalc.receipt.transactionHash);

    // console.log("capcalc "+receipt4.logs[0].topics[0]);
  });

  it("move time 3 days and 2 hours", async () => {
    await time.move(web3, 266400);
    await web3.eth.sendTransaction({from: accounts[3]});
  });

  it("denies setting tokens after being set", async () => {
    try{
      await saleContract.setTokens({from:accounts[5]});
    } catch(e) {
      errorThrown = true;
    }
    assert.isTrue(errorThrown, "should give an error message since the tokens have been set");
    errorThrown = false;
  });

  it("should have set all values correctly", async () => {

    const tokensPerEth = await saleContract.getTokensPerEth.call();
    assert.equal(tokensPerEth.valueOf(), 600000000000000000000, "tokensPerEth should have been set to 600000000000000000000!");

    const addrCap = await saleContract.getAddressTokenCap.call();
    assert.equal(addrCap.valueOf(),
                 40000000000000000000000,
                 "Address token cap should have been calculated to correct number!");

  });

  it("should deny invalid payments during the sale and accept payments that are reflected in token balance", async () => {

    let withdraw = await saleContract.withdrawTokens({from:accounts[0]});
    assert.equal(withdraw.logs[0].args.Msg,
                 'Sender has no tokens to withdraw!',
                 "should give message that the sender cannot withdraw any tokens");

    withdraw = await saleContract.withdrawLeftoverWei({from:accounts[3]});
    assert.equal(withdraw.logs[0].args.Msg,
                 'Sender has no extra wei to withdraw!',
                 "should give message that the sender cannot withdraw any wei");


    let tokenPurchase = await saleContract.sendPurchase({value:39990000000000000000,from:accounts[0]});
    withdraw = await saleContract.getLeftoverWei.call(accounts[0]);
    assert.equal(withdraw.valueOf(),0, "should show that accounts0 has 0 leftover wei");
    // var receipt5 = await web3.eth.getTransactionReceipt(tokenPurchase.receipt.transactionHash);

    // console.log("tokenPurchase "+receipt5.logs[0].topics[0]);

    let contrib = await saleContract.getContribution.call(accounts[0], {from:accounts[0]});
    assert.equal(contrib.valueOf(),39990000000000000000, "accounts[0] amount of wei contributed should be 39990000000000000000 wei");

    tokenPurchase = await saleContract.getTokenPurchase.call(accounts[0]);
    assert.equal(tokenPurchase.valueOf(), 23994000000000000000000, "accounts[0] tokens purchased should be 23994000000000000000000");

    try{
      await saleContract.sendPurchase({from:accounts[0]});
    } catch(e) {
      errorThrown = true;
    }
    assert.isTrue(errorThrown, "should give an error message since no value was sent");
    errorThrown = false;

    tokenPurchase = await saleContract.sendPurchase({value:68000000000000000000,from:accounts[2]});

    try{
      await saleContract.sendPurchase({value:5000000000000000000,from:accounts[2]});
    } catch(e) {
      errorThrown = true;
    }
    assert.isTrue(errorThrown, "should give an error message since no address cap was reached");
    errorThrown = false;

    leftover = await saleContract.getLeftoverWei.call(accounts[0], {from:accounts[0]});
    assert.equal(leftover.valueOf(),0, "should show that accounts0 has 0 leftover wei");

    const l = await saleContract.getSaleData.call(1);
    console.log(l[2].valueOf());
    leftover = await saleContract.getLeftoverWei.call(accounts[2], {from:accounts[0]});
    assert.equal(leftover.valueOf(),1333333333333333334, "should show that accounts2 has 1333333333333333334 leftover wei");

    withdraw = await saleContract.withdrawTokens({from:accounts[5]});
    assert.equal(withdraw.logs[0].args.Msg,
                 "Owner cannot withdraw extra tokens until after the sale!",
                 "should give message that owner cannot withdraw tokens");

    withdraw = await saleContract.withdrawOwnerEth({from:accounts[5]});
    assert.equal(withdraw.logs[0].args.Msg,
                 "Cannot withdraw owner ether until after the sale!",
                 "should give message that owner cannot withdraw ether");
  });

  it("move time 8 days", async () => {
    await time.move(web3, 691200);
    await web3.eth.sendTransaction({from: accounts[3]});
  });

  it("should update the token price", async () => {
    var change = await saleContract.sendPurchase({value:1000000000000000000,from:accounts[1]});
    // var receipt7 = await web3.eth.getTransactionReceipt(change.receipt.transactionHash);

    // console.log("capchange "+receipt7.logs[0].topics[0]);
    // console.log("pricechange "+receipt7.logs[1].topics[0]);
    const tokensPerEth = await saleContract.getTokensPerEth.call();
    assert.equal(tokensPerEth.valueOf(),600000000000000000000, "token price should be 600000000000000000000");
  });

  it("move time 22 days and 1 hour", async () => {
    await time.move(web3, 1900800);
    await web3.eth.sendTransaction({from: accounts[3]});
  });

  ///********************************************************
  //  AFTER SALE
  //******************************************************
  it("should deny payments after the sale and allow users to withdraw their tokens/owner to withdraw ether", async () => {

    const active = await saleContract.crowdsaleActive.call();
    assert.equal(active.valueOf(), false, "Crowsale should not be active!");

    const ended = await saleContract.crowdsaleEnded.call();
    assert.equal(ended.valueOf(), true, "Crowsale should be ended!");

    const regUser = await saleContract.registerUser(accounts[4],{from:accounts[5]});
    assert.equal(regUser.logs[0].args.Msg,
                 'Can only register users earlier than 2 hours before the sale!',
                 "Should give an error that users cannot be registered close to the sale");

    const unregUser = await saleContract.unregisterUser(accounts[1],{from:accounts[5]});
    assert.equal(unregUser.logs[0].args.Msg, 'Can only unregister users earlier than 2 hours before the sale!', "Should give an error that users cannot be unregistered close to the sale");

    let tokenPurchase = await saleContract.getTokenPurchase.call(accounts[0],{from:accounts[0]});
    assert.equal(tokenPurchase.valueOf(),23994000000000000000000, "accounts[0] amount of tokens purchased should be 23994000000000000000000 tokens");

    tokenPurchase = await saleContract.getTokenPurchase.call(accounts[3],{from:accounts[3]});
    assert.equal(tokenPurchase.valueOf(),0,"accounts[3] should have withdrawn all tokens and should now have zero in the contract");

    withdraw = await saleContract.withdrawOwnerEth({from:accounts[5]});
    assert.equal(withdraw.logs[0].args.Msg,
                 'Crowdsale owner has withdrawn all funds!',
                 "Should give message that the owner has withdrawn all funds");


    //******************
    //* TOKEN CONTRACT BALANCE CHECKS
    //******************

    balance = await token.balanceOf.call(accounts[2],{from:accounts[2]});
    assert.equal(balance.valueOf(), 0, "accounts2 token balance should be 0");

    balance = await token.balanceOf.call(accounts[4],{from:accounts[4]});
    assert.equal(balance.valueOf(), 0, "accounts4 token balance should be 0");

    balance = await token.balanceOf.call(saleContract.address);
    assert.equal(balance.valueOf(), 160000000000000000000000,  "crowdsale's token balance should be 160000000000000000000000!");

    tokenPurchase = await saleContract.getTokenPurchase.call(accounts[5],{from:accounts[5]});
    assert.equal(tokenPurchase.valueOf(),95406000000000000000400, "Owners available tokens to withdraw should be 95406000000000000000400");

    const tokensSold = await saleContract.getTokensSold.call();
    assert.equal(tokensSold.valueOf(),64593999999999999999600, "64593999999999999999600 tokens should have been sold.")

    withdraw = await saleContract.withdrawTokens({from:accounts[5]});

    tokenPurchase = await saleContract.getTokenPurchase.call(accounts[5],{from:accounts[5]});
    assert.equal(tokenPurchase.valueOf(),0, "Owner should have withdrawn all the leftover tokens from the sale!");

    balance = await token.balanceOf.call(accounts[5],{from:accounts[5]});
    assert.equal(balance.valueOf(), 0, "accounts5 token balance should be 0 because all tokens were burned");

    await saleContract.withdrawTokens({from:accounts[0]});
    await saleContract.withdrawTokens({from:accounts[1]});
    await saleContract.withdrawTokens({from:accounts[2]});
    balance = await token.balanceOf.call(saleContract.address);
    assert.equal(balance.valueOf(), 0,  "crowdsale's token balance should be 0!");

    const initSupply = await token.initialSupply();
    assert.equal(initSupply.valueOf(), 50000000000000000000000000,  "The token's initial supply was 50M");

    const totalSupply = await token.totalSupply();
    assert.equal(totalSupply.valueOf(), 49904593999999999999999600,  "The token's new supply is 49904593999999999999999600");
  });

  it("move time 7 days for the next sale", async () => {
    await time.move(web3, 604800);
    await web3.eth.sendTransaction({from: accounts[3]});
  });
});

contract('Setting New Variables', ()=>{
  it("should properly set variables", async () => {
    saleContract = await EvenDistroTestTenD.deployed();
    token = await CrowdsaleTestTokenTenD.deployed();
  });
});

contract('CrowdsaleTestTokenTenD', (accounts) => {

  it("should properly initialize token data", async () => {
    const name = await token.name.call();
    const symbol = await token.symbol.call();
    const decimals = await token.decimals.call();
    const totalSupply = await token.totalSupply.call();

    assert.equal(name.valueOf(), 'Ten Decimals', "Name should be set to Ten Decimals.");
    assert.equal(symbol.valueOf(), 'TEN', "Symbol should be set to TEN.");
    assert.equal(decimals.valueOf(), 10, "Decimals should be set to 10.");
    assert.equal(totalSupply.valueOf(), 1000000000000000, "Total supply should reflect 1000000000000000.");
  });
});

/*************************************************************************

This version is testing the even distribution version of the sale where
the cap per address is set on deployment and the tokens are set late

**************************************************************************/

contract('EvenDistroTestTenD', function(accounts) {
  it("should initialize the even crowdsale contract data", async () => {
      const owner = await saleContract.getOwner.call();
      const tokensPerEth = await saleContract.getTokensPerEth.call();
      const startTime = await saleContract.getStartTime.call();
      const endTime = await saleContract.getEndTime.call();
      const ownerBalance = await saleContract.getEthRaised.call();
      const saleData = await saleContract.getSaleData.call(0);
      const saleDataEnd = await saleContract.getSaleData.call(endTime.valueOf());

      assert.equal(owner.valueOf(), accounts[0], "Owner should be set to the account 0");
      assert.equal(tokensPerEth.valueOf(), 4000000000000, "Tokens per ETH should be 4000000000000");
      assert.equal(ownerBalance.valueOf(), 0, "Amount of wei raised in the crowdsale should be zero");
  });

  it("accept tokens from the owner", async () => {
    const tokenTransfer = await token.transfer(saleContract.address, 100000000000000,{ from:accounts[0] });
    const balance = await token.balanceOf.call(saleContract.address);
    assert.equal(balance.valueOf(), 100000000000000,  "crowdsale's token balance should be 100000000000000!");
  });

  it("should deny non-owner transactions pre-crowdsale, allow user registration, and set exchange rate and address cap", async () => {

    const crowdsaleActive = await saleContract.crowdsaleActive.call();
    assert.equal(crowdsaleActive.valueOf(), true, "Crowsale already started!");

    const crowdsaleEnded = await saleContract.crowdsaleEnded.call();
    assert.equal(crowdsaleEnded.valueOf(), false, "Crowsale should not be ended!");

    const withdrawTokens = await saleContract.withdrawTokens({ from:accounts[0] });
    assert.equal(withdrawTokens.logs[0].args.Msg,
                'Sender has no tokens to withdraw!',
                "should give message that no tokens to withdraw");

    await saleContract.registerUser(accounts[5],{from:accounts[0]});
    const registerTwice = await saleContract.registerUser(accounts[5],{from:accounts[0]});
    assert.equal(registerTwice.logs[0].args.Msg, 'Registrant address is already registered for the sale!', "Should give error message that the user is already registered");

    const accountZeroReg = await saleContract.isRegistered(accounts[5]);
    assert.equal(accountZeroReg.valueOf(),true, "accounts[0] should be registered");

    const accountOneReg = await saleContract.isRegistered(accounts[1]);
    assert.equal(accountOneReg.valueOf(),false, "accounts[1] should not be registered");

    const accountOneUnreg = await saleContract.unregisterUser(accounts[1],{from:accounts[0]});
    assert.equal(accountOneUnreg.logs[0].args.Msg,
                 'Registrant address not registered for the sale!',
                 "Should give error message that the user is not registered");

    await saleContract.registerUser(accounts[1],{from:accounts[0]});
    const accountOneRegTwo = await saleContract.isRegistered(accounts[1]);
    assert.equal(accountOneRegTwo.valueOf(),true, "accounts[1] should now be registered");

    await saleContract.unregisterUser(accounts[1],{from:accounts[0]});
    const accountOneUnregTwo = await saleContract.isRegistered(accounts[1]);
    assert.equal(accountOneUnregTwo.valueOf(),false, "accounts[1] should now be unregistered");

    await saleContract.registerUser(accounts[1],{from:accounts[0]});
    await saleContract.registerUser(accounts[2],{from:accounts[0]});
    await saleContract.registerUser(accounts[3],{from:accounts[0]});

    let numReg = await saleContract.getNumRegistered.call();
    assert.equal(numReg.valueOf(),4,"Four Users should be registered!");

    await saleContract.unregisterUsers([accounts[5],accounts[1],accounts[2]],{from:accounts[0]});

    const accountOneRegThree = await saleContract.isRegistered(accounts[1]);
    assert.equal(accountOneRegThree.valueOf(),false, "accounts[1] should not be registered");

    numReg = await saleContract.getNumRegistered.call();
    assert.equal(numReg.valueOf(),1,"One User should be registered!");

    await saleContract.registerUsers([accounts[5],accounts[1],accounts[2]],{from:accounts[0]});

    const accountOneRegFour = await saleContract.isRegistered(accounts[1]);
    assert.equal(accountOneRegFour.valueOf(),true, "accounts[1] should be registered");

    numReg = await saleContract.getNumRegistered.call();
    assert.equal(numReg.valueOf(),4,"Four users should be registered!");

  });

  it("move time 3 days and 2 hours", async () => {
    await time.move(web3, 266400);
    await web3.eth.sendTransaction({from: accounts[3]});
  });

  it("should allow tokens to be set with the alternate function", async () => {
    await saleContract.setTokens({from:accounts[0]});
  });

  it("should have set all values correctly", async () => {

    const tokensPerEth = await saleContract.getTokensPerEth.call();
    assert.equal(tokensPerEth.valueOf(), 4000000000000, "tokensPerEth should have been set to 4000000000000!");

    const addrCap = await saleContract.getAddressTokenCap.call();
    assert.equal(addrCap.valueOf(),
                 0,
                 "Address token cap should have been calculated to correct number!");

  });

  it("should deny invalid payments during the sale and accept payments that are reflected in token balance", async () => {

    let withdraw = await saleContract.withdrawTokens({from:accounts[5]});
    assert.equal(withdraw.logs[0].args.Msg,
                 'Sender has no tokens to withdraw!',
                 "should give message that the sender cannot withdraw any tokens");

    withdraw = await saleContract.withdrawLeftoverWei({from:accounts[3]});
    assert.equal(withdraw.logs[0].args.Msg,
                 'Sender has no extra wei to withdraw!',
                 "should give message that the sender cannot withdraw any wei");


    let tokenPurchase = await saleContract.sendPurchase({value:16000000000000000000,from:accounts[5]});
    withdraw = await saleContract.getLeftoverWei.call(accounts[5]);
    assert.equal(withdraw.valueOf(),0, "should show that accounts5 has 0 leftover wei");

  });
});
