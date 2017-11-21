const TimeDirectCrowdsaleTestContract = artifacts.require("TimeDirectCrowdsaleTestContract");
const CrowdsaleToken = artifacts.require("CrowdsaleToken");

contract('CrowdsaleToken', (accounts) => {
  it("should properly initialize token data", async () => {
    const contract = await CrowdsaleToken.deployed();
    const name = await contract.name.call();
    const symbol = await contract.symbol.call();
    const decimals = await contract.decimals.call();
    const totalSupply = await contract.totalSupply.call();
    
    assert.equal(name.valueOf(), 'Tester Token', "Name should be set to Tester Token.");
    assert.equal(symbol.valueOf(), 'TST', "Symbol should be set to TST.");
    assert.equal(decimals.valueOf(), 18, "Decimals should be set to 18.");
    assert.equal(totalSupply.valueOf(), 20000000000000000000000000, "Total supply should reflect 20000000000000000000.");
  });
});

contract('TimeDirectCrowdsaleTestContract', (accounts) => {
  it("should initialize the direct crowdsale contract data", async () => {
    const contract = await TimeDirectCrowdsaleTestContract.deployed();
    const owner = await contract.getOwner.call();
    const tokensPerEth = await contract.getTokensPerEth.call();
    const capAmount = await contract.getCapAmount.call();
    const startTime = await contract.getStartTime.call();
    const endTime = await contract.getEndTime.call();
    const exchangeRate = await contract.getExchangeRate.call();
    const ownerBalance = await contract.getEthRaised.call();
    const saleData = await contract.getSaleData.call(0);
    
    console.log(saleData);
    assert.equal(owner.valueOf(), accounts[5], "Owner should be set to the account5");
    assert.equal(tokensPerEth.valueOf(), 206, "Tokens per ETH should be 205");
    assert.equal(capAmount.valueOf(), 58621000000000000000000, "capAmount should be set to 56821000000000000000000 wei");
    assert.equal(startTime.valueOf(),105, "start time should be 105");
    assert.equal(endTime.valueOf(),125, "end time should be 125");
    assert.equal(exchangeRate.valueOf(),29000, "exchangeRate should be 29000");
    assert.equal(ownerBalance.valueOf(), 0, "Amount of wei raised in the crowdsale should be zero");
  });
  it("should deny all requests to interact with the contract before the crowdsale starts", async () => {
    const contract = await TimeDirectCrowdsaleTestContract.deployed();
    const token = await CrowdsaleToken.deployed();
    const tokenTransfer = await token.transfer(contract.contract.address, 12000000000000000000000000,{ from:accounts[5] });
    const balance = await token.balanceOf.call(contract.contract.address);
    assert.equal(balance.valueOf(), 12000000000000000000000000,  "crowdsale's token balance should be 20000000000000000000000000!");
    
    const crowdsale = await contract.crowdsaleActive.call(101);
    assert.equal(crowdsale.valueOf(), false, "Crowsale should not be active!");
    
    const crowdsaleEnded = await contract.crowdsaleEnded.call(101);
    assert.equal(crowdsaleEnded.valueOf(), false, "Crowsale should not be ended!");
      
    const withdrawTokens = await contract.withdrawTokens(103, { from:accounts[0] });
    assert.equal(withdrawTokens.logs[0].args.Msg, 'Sender has no tokens to withdraw!', "should give message that token sale has not ended");
      
    const receivePurchase = await contract.receivePurchase(103, { value: 40000000000000000000, from: accounts[1] });
    assert.equal(receivePurchase.logs[0].args.Msg, 'Invalid Purchase! Check send time and amount of ether.', "should give an error message since sale has not started");
      
    const receivePurchase2 = await contract.receivePurchase(103, { value: 20000000000000000000, from: accounts[5] });
    assert.equal(receivePurchase2.logs[0].args.Msg, 'Owner cannot send ether to contract', "should give an error message since sale has not started");
      
    const withdrawOwnerEth = await contract.withdrawOwnerEth(104,{from: accounts[5]});
    assert.equal(withdrawOwnerEth.logs[0].args.Msg, 'Cannot withdraw owner ether until after the sale', "Should give an error that sale ether cannot be withdrawn till after the sale");
    
    const contribution = await contract.getContribution.call(accounts[1]);
    assert.equal(contribution.valueOf(),0,"accounts[1] ether contribution should be 0");
    
    const tokenPurchase = await contract.getTokenPurchase.call(accounts[1]);
    assert.equal(tokenPurchase.valueOf(), 0,"accounts[1] token balance should be 0");
    
    const tokenExchangeRate101 = await contract.setTokenExchangeRate(30000, 101, { from: accounts[5] });
    assert.equal(tokenExchangeRate101.logs[0].args.Msg, 'Owner can only set the exchange rate once up to three days before the sale!', "Should give an error message that timing for setting the exchange rate is wrong.");
      
    const tokenExchangeRate103 = await contract.setTokenExchangeRate(30000, 103, { from: accounts[5] });
    assert.equal(tokenExchangeRate103.logs[0].args.Msg, "Owner has sent the exchange Rate and tokens bought per ETH!", "Should give success message that the exchange rate was set.");
      
    const tokenExchangeRateBack101 = await contract.setTokenExchangeRate(30000, 101, { from:accounts[5] });
    assert.equal(tokenExchangeRateBack101.logs[0].args.Msg, 'Owner can only set the exchange rate once up to three days before the sale!', "Should give an error message that timing for setting the exchange rate is wrong.");
      
    const exchangeRate = await contract.getExchangeRate.call();
    assert.equal(exchangeRate.valueOf(), 30000, "exchangeRate should have been set to 30000!");
      
    const tokensPerEth = await contract.getTokensPerEth.call();
    assert.equal(tokensPerEth.valueOf(), 213, "tokensPerEth should have been set to 212!");
      
    const secondWithdrawOwnerEth = await contract.withdrawOwnerEth(104, { from: accounts[5] });
    assert.equal(secondWithdrawOwnerEth.logs[0].args.Msg, "Cannot withdraw owner ether until after the sale", "Should give error message that the owner cannot withdraw any ETH yet");
      
    const secondWithdrawTokens = await contract.withdrawTokens(104, { from: accounts[5] });
    assert.equal(secondWithdrawTokens.logs[0].args.Msg, "Owner cannot withdraw extra tokens until after the sale!", "Should give error message that the owner cannot withdraw any extra tokens yet");
      
    const withdrawLeftoverWei = await contract.withdrawLeftoverWei({ from: accounts[0] });
    assert.equal(withdrawLeftoverWei.logs[0].args.Msg, 'Sender has no extra wei to withdraw!', "should give message that the sender cannot withdraw any wei");
    
  });


  //   /********************************************************
  //   DURING SALE - NO PRICE CHANGE
  //   /*******************************************************/
  // it("should deny invalid payments during the sale and accept payments that are reflected in token balance", function() {
  //   var c;

  //   return TimeDirectCrowdsaleTestContract.deployed().then(function(instance) {
  //     c = instance;

  //     console.log(contract.contract.address);
  //     return CrowdsaleToken.deployed().then(function(instance) {
  //     return instance.approve(contract.contract.address,10000000,{from:accounts[5]});
  //   }).then(function(ret) {

  //     return contract.withdrawTokens({from:accounts[0]});
  //   }).then(function(ret) {
  //     assert.equal(ret.logs[0].args.Msg, 'Sender has no tokens to withdraw!', "should give message that the sender cannot withdraw any tokens");
  //     return contract.receivePurchase(106,{from:accounts[0]});
  //   }).then(function(ret) {
  //     assert.equal(ret.logs[0].args.Msg, 'Invalid Purchase! Check send time and amount of ether.', "should give an error message since no ether was sent");
  //     return contract.receivePurchase(106,{value:40000000000000000000,from:accounts[0]});
  //   }).then(function(ret) {
  //     return contract.getContribution.call(accounts[0], {from:accounts[0]});
  //   }).then(function(ret) {
  //     assert.equal(ret.valueOf(),40000000000000000000, "accounts[0] amount of wei contributed should be 40000000000000000000 wei");
  //     return contract.receivePurchase(106,{value: 40000000000000000000, from:accounts[0]});
  //   }).then(function(ret) {
  //     return contract.getContribution.call(accounts[0], {from:accounts[0]});
  //   }).then(function(ret) {
  //     assert.equal(ret.valueOf(),80000000000000000000, "accounts[0] amount of wei contributed should be 80000000000000000000 wei");
  //     return contract.getTokenPurchase.call(accounts[0],{from:accounts[0]});
  //   }).then(function(ret) {
  //     assert.equal(ret.valueOf(),80000, "accounts[0] amount of tokens purchased should be 80000 tokens");
  //     return contract.receivePurchase(106, {value: 40000000000000000000, from:accounts[0]});
  //   }).then(function(ret) {
  //     return contract.getContribution.call(accounts[0],{from:accounts[0]});
  //   }).then(function(ret) {
  //     assert.equal(ret.valueOf(),120000000000000000000, "accounts[0] amount of wei contributed should be 120000000000000000000 wei");
  //     return contract.getTokenPurchase.call(accounts[0],{from:accounts[0]});
  //   }).then(function(ret) {
  //     assert.equal(ret.valueOf(),120000, "accounts[0] amount of tokens purchased should be 120000 tokens");
  //     return contract.receivePurchase(106,{value: 120000000000000000000, from: accounts[5]});
  //   }).then(function(ret) {
  //     assert.equal(ret.logs[0].args.Msg, 'Owner cannot send ether to contract', "should give an error message since sale has not started");
  //     return contract.withdrawOwnerEth(106,{from: accounts[5]});
  //   }).then(function(ret) {
  //     assert.equal(ret.logs[0].args.Msg, 'Cannot withdraw owner ether until after the sale', "Should give an error that sale ether cannot be withdrawn till after the sale");
  //     return contract.getContribution.call(accounts[5]);
  //   }).then(function(ret) {
  //     assert.equal(ret.valueOf(),0,"accounts[5] (owner) ether contribution should be 0");
  //     return contract.receivePurchase(106, {value: 500000000000000000011, from:accounts[3]});
  //   }).then(function(ret) {
  //     return contract.getContribution.call(accounts[3],{from:accounts[3]});
  //   }).then(function(ret) {
  //     assert.equal(ret.valueOf(),500000000000000000011, "accounts[3] amount of wei contributed should be 1500000000000000000011 wei");
  //     return contract.getTokenPurchase.call(accounts[3],{from:accounts[3]});
  //   }).then(function(ret) {
  //     assert.equal(ret.valueOf(),500000, "accounts[3] amount of tokens purchased should be 500000 tokens");
  //     return contract.withdrawTokens({from:accounts[0]});
  //   }).then(function(ret) {
  //     return contract.getTokenPurchase.call(accounts[0],{from:accounts[0]});
  //   }).then(function(ret) {
  //     assert.equal(ret.valueOf(),0,"accounts[0] should have withdrawn all tokens and should now have zero in the contract");

  //     return contract.receivePurchase(107, {value: 1200000000000000000000, from: accounts[2]});
  //   }).then(function(ret) {
  //     assert.equal(ret.logs[0].args.Msg, 'buyer ether sent exceeds cap of ether to be raised!', "should give error message that the raise cap has been exceeded");
  //     return contract.receivePurchase(107, {value: 900000000000000000000, from: accounts[2]});
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
  //     return contract.ownerBalance.call();
  //   }).then(function(ret) {
  //     assert.equal(ret.valueOf(),620000000000000000000, "owners balance of ether should be 720!");
  //     return contract.getTokenPurchase.call(accounts[0],{from:accounts[0]});
  //   }).then(function(ret) {
  //     assert.equal(ret.valueOf(),0, "accounts[0] amount of tokens purchased should be 0 tokens");
  //     return contract.getTokenPurchase.call(accounts[3],{from:accounts[3]});
  //   }).then(function(ret) {
  //     assert.equal(ret.valueOf(),500000, "accounts[3] amount of tokens purchased should be 500000 tokens");
  //     return contract.withdrawTokens({from:accounts[3]});
  //   }).then(function(ret) {
  //     return contract.getTokenPurchase.call(accounts[3],{from:accounts[3]});
  //   }).then(function(ret) {
  //     assert.equal(ret.valueOf(),0,"accounts[3] should have withdrawn all tokens and should now have zero in the contract");

  //     return contract.receivePurchase(111,{from:accounts[2]});
  //   }).then(function(ret) {
  //     assert.equal(ret.logs[0].args.Msg, 'Invalid Purchase! Check send time and amount of ether.', "should give an error message since no ether was sent");
  //     return contract.withdrawTokens({from:accounts[2]});
  //   }).then(function(ret) {
  //     assert.equal(ret.logs[0].args.Msg, 'Sender has no tokens to withdraw!', "should give message that the sender cannot withdraw any tokens");
  //     return contract.withdrawOwnerEth(111,{from:accounts[5]});
  //   }).then(function(ret) {
  //     assert.equal(ret.logs[0].args.Msg, 'crowdsale owner has withdrawn all funds', "Should give message that the owner has withdrawn all funds");
  //     return contract.ownerBalance.call();
  //   }).then(function(ret) {
  //     assert.equal(ret.valueOf(), 0, "Owner's ether balance in the contract should be zero!");
  //   });

  // });

    /********************************************************
    DURING SALE - YES PRICE CHANGE
    /*******************************************************/
  it("should deny invalid payments during the sale and accept payments that are reflected in token balance", async () => {
    const contract = await TimeDirectCrowdsaleTestContract.deployed();
    const crowdsaleActive = await contract.crowdsaleActive.call(106);
    assert.equal(crowdsaleActive.valueOf(), true, "Crowsale should be active!");
      
    const crowdsaleEnded = await contract.crowdsaleEnded.call(106);
    assert.equal(crowdsaleEnded.valueOf(), false, "Crowsale should not be ended!");
      
    const firstWithdrawToken = await contract.withdrawTokens(106, { from:accounts[0] });
    assert.equal(firstWithdrawToken.logs[0].args.Msg, 'Sender has no tokens to withdraw!', "should give message that the sender cannot withdraw any tokens");
      
    const firstWithdrawLeftoverWei = await contract.withdrawLeftoverWei({ from: accounts[3] });
    assert.equal(firstWithdrawLeftoverWei.logs[0].args.Msg, 'Sender has no extra wei to withdraw!', "should give message that the sender cannot withdraw any wei");
      
    const secondWithdrawLeftoverWei = await contract.withdrawLeftoverWei({ from: accounts[5] });
    assert.equal(secondWithdrawLeftoverWei.logs[0].args.Msg, 'Sender has no extra wei to withdraw!', "should give message that the sender cannot withdraw any wei");
      
    const receiveFirstPurchase = await contract.receivePurchase(106, { from: accounts[0] });
    assert.equal(receiveFirstPurchase.logs[0].args.Msg, 'Invalid Purchase! Check send time and amount of ether.', "should give an error message since no ether was sent");
      
    await contract.receivePurchase(106, { value: 39990000000000000000, from: accounts[0] });
    await contract.getLeftoverWei.call(accounts[0]);
    await contract.receivePurchase(106, { value: 10000000000000000, from: accounts[0] });
    const leftoverWei = await contract.getLeftoverWei.call(accounts[0]);
    assert.equal(leftoverWei.valueOf(),0, "should show that accounts0 has 0 leftover wei");
      
    const contribution = await contract.getContribution.call(accounts[0], { from:accounts[0] });
    assert.equal(contribution.valueOf(),40000000000000000000, "accounts[0] amount of wei contributed should be 40000000000000000000 wei");
      
    const firstTokenPurchase = await contract.getTokenPurchase.call(accounts[0]);
    assert.equal(firstTokenPurchase.valueOf(), 8520000000000000000000, "accounts[0] tokens purchased should be 8520000000000000000000");
    
    await contract.receivePurchase(111, { value: 40000000000000000000, from: accounts[0] });
    const tokensPerEth = await contract.getTokensPerEth.call();
    assert.equal(tokensPerEth.valueOf(), 194, "tokensPerEth should have been set to 194!");
      
    const secondContribution = await contract.getContribution.call(accounts[0], { from: accounts[0] });
    assert.equal(secondContribution.valueOf(), 80000000000000000000, "accounts[0] amount of wei contributed should be 80000000000000000000 wei");
    
    const secondTokenPurchase = await contract.getTokenPurchase.call(accounts[0],{from:accounts[0]});
    assert.equal(secondTokenPurchase.valueOf(), 16280000000000000000000, "accounts[0] amount of tokens purchased should be 16280000000000000000000 tokens");
    
    await contract.receivePurchase(111, { value: 40000000000000000000, from: accounts[0] });
    const thirdContribution = await contract.getContribution.call(accounts[0], { from: accounts[0] });
    assert.equal(thirdContribution.valueOf(), 120000000000000000000, "accounts[0] amount of wei contributed should be 120000000000000000000 wei");

    const thirdTokenPurchase = await contract.getTokenPurchase.call(accounts[0], { from:accounts[0] });
    assert.equal(thirdTokenPurchase.valueOf(), 24040000000000000000000, "accounts[0] amount of tokens purchased should be 24040000000000000000000 tokens");
      
    const tokenExchangeRate112Owner = await contract.setTokenExchangeRate(30000, 112, { from: accounts[5] });
    assert.equal(tokenExchangeRate112Owner.logs[0].args.Msg, 'Owner can only set the exchange rate once up to three days before the sale!', "Should give an error message that timing for setting the exchange rate is wrong.");
      
    const tokenExchangeRate112NonOwner = await contract.setTokenExchangeRate(30000, 112, { from: accounts[4] });
    assert.equal(tokenExchangeRate112NonOwner.logs[0].args.Msg, 'Owner can only set the exchange rate!', "Should give an error message that timing for setting the exchange rate is wrong.");
      
    const ownerReceivePurchase = await contract.receivePurchase(112, { value: 120000000000000000000, from: accounts[5] });
    assert.equal(ownerReceivePurchase.logs[0].args.Msg, 'Owner cannot send ether to contract', "should give an error message since the owner cannot donate to its own contract");
      
    const withdrawOwnerEth = await contract.withdrawOwnerEth(112,{from: accounts[5]});
    assert.equal(withdrawOwnerEth.logs[0].args.Msg, 'Cannot withdraw owner ether until after the sale', "Should give an error that sale ether cannot be withdrawn till after the sale");
    
    const fourthContribution = await contract.getContribution.call(accounts[5]);
    assert.equal(fourthContribution.valueOf(),0,"accounts[5] (owner) ether contribution should be 0");
    
    await contract.receivePurchase(116, { value: 500000000000000111111, from: accounts[3] });
    const fivethContribution = await contract.getContribution.call(accounts[3], { from: accounts[3] });
    assert.equal(fivethContribution.valueOf(),500000000000000111111, "accounts[3] amount of wei contributed should be 50000000000000111111 wei");
      
    const fouthTokenPurchase = await contract.getTokenPurchase.call(accounts[3], { from: accounts[3] });
    assert.equal(fouthTokenPurchase.valueOf(), 91000000000000018200000, "accounts[3] amount of tokens purchased should be 9100000000000018200000 tokens");
      
    const secondTokensPerEth = await contract.getTokensPerEth.call();
    assert.equal(secondTokensPerEth.valueOf(), 182, "New token price should be 182 tokens per ether!");
      
    await contract.withdrawTokens(116, { from: accounts[0] });
    const fivethTokenPurchase = await contract.getTokenPurchase.call(accounts[0], { from: accounts[0] });
    assert.equal(fivethTokenPurchase.valueOf(), 0, "accounts[0] should have withdrawn all tokens and should now have zero in the contract");
      
    const thirdWithdrawTokens = await contract.withdrawTokens(104, { from: accounts[5] });
    assert.equal(thirdWithdrawTokens.logs[0].args.Msg, "Owner cannot withdraw extra tokens until after the sale!", "Should give error message that the owner cannot withdraw any extra tokens yet");
      
    const tokenExchangeRate116Owner = await contract.setTokenExchangeRate(100, 116, { from: accounts[5] });
    assert.equal(tokenExchangeRate116Owner.logs[0].args.Msg, 'Owner can only set the exchange rate once up to three days before the sale!', "Should give an error message that timing for setting the exchange rate is wrong.");
      
    const buyerReceivePurchase116 = await contract.receivePurchase(116, { value: 56670000000000000000000, from: accounts[2] });
    assert.equal(buyerReceivePurchase116.logs[0].args.Msg, 'buyer ether sent exceeds cap of ether to be raised!', "should give error message that the raise cap has been exceeded");
    
    const buyerReceivePurchase117 = await contract.receivePurchase(117, {value: 60000000000000000000000, from: accounts[2]});
    assert.equal(buyerReceivePurchase117.logs[0].args.Msg, 'buyer ether sent exceeds cap of ether to be raised!', "should give error message that the raise cap has been exceeded");
    await contract.receivePurchase(122, { value: 500000000000000100000, from: accounts[4] });

    const sixthContribution = await contract.getContribution.call(accounts[4], { from: accounts[4] });
    assert.equal(sixthContribution.valueOf(), 500000000000000100000, "accounts[4] amount of wei contributed should be 500000000000000100000 wei");
      
    const fourthTokenPurchase = await contract.getTokenPurchase.call(accounts[4], { from: accounts[4] });
    assert.equal(fourthTokenPurchase.valueOf(), 91000000000000018200000, "accounts[4] amount of tokens purchased should be 91000000000000018200000 tokens");
    
    const secondLeftoverWei = await contract.getLeftoverWei.call(accounts[4], { from: accounts[4] });
    assert.equal(secondLeftoverWei.valueOf(),0, "accounts[4] leftover wei should be 0");
    
    await contract.withdrawLeftoverWei({ from: accounts[4] });
    const thirdLeftoverWei = await contract.getLeftoverWei.call(accounts[4],{ from: accounts[4] });
    assert.equal(thirdLeftoverWei.valueOf(),0, "accounts[4] should have no leftover wei because it was just withdrawn");
  });

  /********************************************************
    AFTER SALE - YES PRICE CHANGE
  /*******************************************************/
  it("should deny payments after the sale and allow users to withdraw their tokens/owner to withdraw ether", async () => {
    
    const contract = await TimeDirectCrowdsaleTestContract.deployed();
    const isCrowdSaleActive = await contract.crowdsaleActive.call(126);
    assert.equal(isCrowdSaleActive.valueOf(), false, "Crowsale should not be active!");
      
    const isCrowdSaleEnded = await contract.crowdsaleEnded.call(126);
    assert.equal(isCrowdSaleEnded.valueOf(), true, "Crowsale should be ended!");
    
    await contract.getEthRaised.call();
    const firstTokenPurchase = await contract.getTokenPurchase.call(accounts[0], { from: accounts[0] });
    assert.equal(firstTokenPurchase.valueOf(),0, "accounts[0] amount of tokens purchased should be 0 tokens");
      
    const firstWithdrawTokens = await contract.withdrawTokens(126, { from: accounts[0] });
    assert.equal(firstWithdrawTokens.logs[0].args.Msg, "Sender has no tokens to withdraw!", "Accounts[0] alread withdrew all tokens. should be error");
      
    const secondTokenPurchase = await contract.getTokenPurchase.call(accounts[3], { from:accounts[3] });
    assert.equal(secondTokenPurchase.valueOf(), 91000000000000018200000, "accounts[3] amount of tokens purchased should be 9100000000000018200000 tokens");
      
    await contract.withdrawTokens(126,{from:accounts[3]});
    const thirdTokenPurchase = await contract.getTokenPurchase.call(accounts[3], { from: accounts[3] });
    assert.equal(thirdTokenPurchase.valueOf(),0,"accounts[3] should have withdrawn all tokens and should now have zero in the contract");
      
    const firstWithdrawLeftoverWei = await contract.withdrawLeftoverWei({ from: accounts[4] });
    assert.equal(firstWithdrawLeftoverWei.logs[0].args.Msg, "Sender has no extra wei to withdraw!", "should give error message because accounts4 already withdrew wei");
    await contract.withdrawLeftoverWei({ from: accounts[3] });
    
    const firstLeftoverWei = await contract.getLeftoverWei.call(accounts[3], { from:accounts[3] });
    assert.equal(firstLeftoverWei.valueOf(),0, "accounts[4] should have no leftover wei because it was just withdrawn");
      
    const receiveFirstPurchase = await contract.receivePurchase(126, { from: accounts[2] });
    assert.equal(receiveFirstPurchase.logs[0].args.Msg, 'Invalid Purchase! Check send time and amount of ether.', "should give an error message since no ether was sent");
      
    const fourthWithdrawToken = await contract.withdrawTokens(127, { from: accounts[2] });
    assert.equal(fourthWithdrawToken.logs[0].args.Msg, 'Sender has no tokens to withdraw!', "should give message that the sender cannot withdraw any tokens");
      
    const withdrawOwnerEth = await contract.withdrawOwnerEth(127, { from: accounts[5] });
    assert.equal(withdrawOwnerEth.logs[0].args.Msg, 'crowdsale owner has withdrawn all funds', "Should give message that the owner has withdrawn all funds");
      
    await contract.withdrawTokens(126, { from: accounts[4] });
    const fourthTokenPurchase = await contract.getTokenPurchase.call(accounts[4], { from: accounts[4] });
    assert.equal(fourthTokenPurchase.valueOf(),0,"accounts[4] should have withdrawn all tokens and should now have zero in the contract");

    const ownerEthRaised = await contract.getEthRaised.call();
    assert.equal(ownerEthRaised.valueOf(), 0, "Owner's ether balance in the contract should be zero!");

    /******************
    * TOKEN CONTRACT BALANCE CHECKS
    *******************/
    const token = await CrowdsaleToken.deployed();
    const tokenBalanceFirstAccount = await token.balanceOf.call(accounts[0], { from: accounts[0] });
    assert.equal(tokenBalanceFirstAccount.valueOf(), 24040000000000000000000, "accounts0 token balance should be 24040000000000000000000");
    
    const tokenBalanceOfSecondAccount = await token.balanceOf.call(accounts[1],{ from: accounts[1] });
    assert.equal(tokenBalanceOfSecondAccount.valueOf(), 0, "accounts1 token balance should be 0");
    
    const tokenBalanceOfThirdAccount = await token.balanceOf.call(accounts[2], { from: accounts[2] });
    assert.equal(tokenBalanceOfThirdAccount.valueOf(), 0, "accounts2 token balance should be 0");
    
    const tokenBalanceOfFourthAccount = await token.balanceOf.call(accounts[3], { from: accounts[3] });
    assert.equal(tokenBalanceOfFourthAccount.valueOf(), 91000000000000018200000, "accounts3 token balance should be 91000000000000018200000");
    
    const tokenBalanceOfFivethAccount = await token.balanceOf.call(accounts[4],{from:accounts[4]});
    assert.equal(tokenBalanceOfFivethAccount.valueOf(), 91000000000000018200000, "accounts4 token balance should be 91000000000000018200000");
    
    const tokenBalanceOfSixthAccount = await token.balanceOf.call(accounts[5], { from: accounts[5] });
    assert.equal(tokenBalanceOfSixthAccount.valueOf(), 8000000000000000000000000, "accounts5 token balance should be 8000000000000000000000000");
    
    const crowdsaleTokenBalance = await token.balanceOf.call(contract.contract.address);
    assert.equal(crowdsaleTokenBalance.valueOf(), 11793959999999999963600000,  "crowdsale's token balance should be 11793959999999999963600000!");

    await contract.withdrawTokens(128, { from: accounts[5] });
    const fivethTokenPurchase = await contract.getTokenPurchase.call(accounts[5], { from: accounts[5] });
    assert.equal(fivethTokenPurchase.valueOf(), 0, "Owner should have withdrawn all the leftover tokens from the sale!");
    
    const tokenBalanceOfAfterWithdraw = await token.balanceOf.call(accounts[5], { from: accounts[5] });
    assert.equal(tokenBalanceOfAfterWithdraw.valueOf(), 13896979999999999981800000, "accounts5 token balance should be 13896979999999999981800000");
    
    const crowdsaleTokenBalanceAfterWithdraw = await token.balanceOf.call(contract.contract.address);
    assert.equal(crowdsaleTokenBalanceAfterWithdraw.valueOf(), 0,  "crowdsale's token balance should be 0!");
    
    const tokenInitialSupply = await token.initialSupply();
    assert.equal(tokenInitialSupply.valueOf(), 20000000000000000000000000,  "The token's initial supply was 20M");
    
    const tokenTotalSupply = await token.totalSupply();
    assert.equal(tokenTotalSupply.valueOf(), 14103020000000000018200000,  "The token's new supply is 14103020000000000018200000");
  });
});
