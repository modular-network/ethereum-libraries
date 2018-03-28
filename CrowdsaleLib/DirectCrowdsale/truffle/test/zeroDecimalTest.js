var Promise = require('bluebird');
var time = require('../helpers/time');

const DirectCrowdsaleTestZeroD = artifacts.require("DirectCrowdsaleTestZeroD");
const CrowdsaleTestTokenZeroD = artifacts.require("CrowdsaleTestTokenZeroD");

var saleContract;
var token;
var errorThrown;

contract('Setting Variables', ()=>{
  it("should properly set variables", async () => {
    saleContract = await DirectCrowdsaleTestZeroD.deployed();
    token = await CrowdsaleTestTokenZeroD.deployed();
  });
})

contract('CrowdsaleTestTokenZeroD', (accounts) => {

  it("should properly initialize token data", async () => {
    const name = await token.name.call();
    const symbol = await token.symbol.call();
    const decimals = await token.decimals.call();
    const totalSupply = await token.totalSupply.call();

    assert.equal(name.valueOf(), 'Zero Decimals', "Name should be set to Zero Decimals.");
    assert.equal(symbol.valueOf(), 'ZERO', "Symbol should be set to ETEEN.");
    assert.equal(decimals.valueOf(), 0, "Decimals should be set to 0.");
    assert.equal(totalSupply.valueOf(), 50000000, "Total supply should reflect 50000000.");
  });
});

contract('DirectCrowdsaleTestZeroD', (accounts) => {

  it("should initialize the direct crowdsale contract data", async () => {
    const owner = await saleContract.getOwner.call();
    const tokensPerEth = await saleContract.getTokensPerEth.call();
    const startTime = await saleContract.getStartTime.call();
    const endTime = await saleContract.getEndTime.call();
    const ownerBalance = await saleContract.getEthRaised.call();
    const saleData = await saleContract.getSaleData.call(0);
    const saleDataEnd = await saleContract.getSaleData.call(endTime.valueOf());

    assert.equal(owner.valueOf(), accounts[0], "Owner should be set to the account 0");
    assert.equal(tokensPerEth.valueOf(), 900, "Tokens per ETH should be 900");
    assert.equal(endTime.valueOf() - 2592000,startTime.valueOf(), "end time should be 30 days");
    assert.equal(ownerBalance.valueOf(), 0, "Amount of wei raised in the crowdsale should be zero");
  });


  it("accept tokens from the owner", async () => {
    const tokenTransfer = await token.transfer(saleContract.address, 50000000,{ from:accounts[0] });
    const balance = await token.balanceOf.call(saleContract.address);
    assert.equal(balance.valueOf(), 50000000,  "crowdsale's token balance should be 50000000!");
  });

  it("should deny all requests to interact with the contract before the crowdsale starts", async () => {
    const crowdsaleActive = await saleContract.crowdsaleActive.call();
    assert.equal(crowdsaleActive.valueOf(), false, "Crowsale should not be active!");

    const crowdsaleEnded = await saleContract.crowdsaleEnded.call();
    assert.equal(crowdsaleEnded.valueOf(), false, "Crowsale should not be ended!");

    const withdrawTokens = await saleContract.withdrawTokens({ from:accounts[0] });
    // var receipt4 = await web3.eth.getTransactionReceipt(withdrawTokens.receipt.transactionHash);

    // console.log("Error "+receipt4.logs[0].topics[0]);
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

    const withdrawOwnerEth = await saleContract.withdrawOwnerEth({from: accounts[0]});
    assert.equal(withdrawOwnerEth.logs[0].args.Msg,
                'Cannot withdraw owner ether until after the sale!',
                "Should give an error that sale ether cannot be withdrawn till after the sale");

    const contribution = await saleContract.getContribution.call(accounts[1]);
    assert.equal(contribution.valueOf(),0,"accounts[1] ether contribution should be 0");

    const tokenPurchase = await saleContract.getTokenPurchase.call(accounts[1]);
    assert.equal(tokenPurchase.valueOf(), 0,"accounts[1] token balance should be 0");

    errorThrown = false;

    //move time two hours
    await time.move(web3, 7200);
    await web3.eth.sendTransaction({from: accounts[3]});

    await saleContract.setTokens({ from: accounts[0] });

    try{
      await saleContract.setTokens({ from:accounts[0] });
    } catch(e) {
      errorThrown = true;
    }
    assert.isTrue(errorThrown, "should give an error message since tokens are set");
    errorThrown = false;

    const tokensPerEth = await saleContract.getTokensPerEth.call();
    assert.equal(tokensPerEth.valueOf(), 900, "tokensPerEth should have been set to 900!");

    const secondWithdrawOwnerEth = await saleContract.withdrawOwnerEth({ from: accounts[0] });
    assert.equal(secondWithdrawOwnerEth.logs[0].args.Msg,
                "Cannot withdraw owner ether until after the sale!",
                "Should give error message that the owner cannot withdraw any ETH yet");

    const secondWithdrawTokens = await saleContract.withdrawTokens({ from: accounts[0] });
    assert.equal(secondWithdrawTokens.logs[0].args.Msg,
                "Owner cannot withdraw extra tokens until after the sale!",
                "Should give error message that the owner cannot withdraw any extra tokens yet");

    const withdrawLeftoverWei = await saleContract.withdrawLeftoverWei({ from: accounts[0] });
    // var receipt5 = await web3.eth.getTransactionReceipt(withdrawLeftoverWei.receipt.transactionHash);

    // console.log("Error "+receipt5.logs[0].topics[0]);
    assert.equal(withdrawLeftoverWei.logs[0].args.Msg,
                'Sender has no extra wei to withdraw!',
                "should give message that the sender cannot withdraw any wei");

  });

  it("move time 3 days and 1 hour", async () => {
    await time.move(web3, 262800);
    await web3.eth.sendTransaction({from: accounts[3]});
  });

  it("should deny invalid payments during the sale and accept payments that are reflected in token balance", async () => {
    const crowdsaleActive = await saleContract.crowdsaleActive.call();
    assert.equal(crowdsaleActive.valueOf(), true, "Crowsale should be active!");

    const crowdsaleEnded = await saleContract.crowdsaleEnded.call();
    assert.equal(crowdsaleEnded.valueOf(), false, "Crowsale should not be ended!");

    const firstWithdrawToken = await saleContract.withdrawTokens({ from:accounts[1] });
    assert.equal(firstWithdrawToken.logs[0].args.Msg,
                'Sender has no tokens to withdraw!',
                "should give message that the sender cannot withdraw any tokens");

    const firstWithdrawLeftoverWei = await saleContract.withdrawLeftoverWei({ from: accounts[3] });
    assert.equal(firstWithdrawLeftoverWei.logs[0].args.Msg,
                'Sender has no extra wei to withdraw!',
                "should give message that the sender cannot withdraw any wei");

    const secondWithdrawLeftoverWei = await saleContract.withdrawLeftoverWei({ from: accounts[5] });
    assert.equal(secondWithdrawLeftoverWei.logs[0].args.Msg,
                'Sender has no extra wei to withdraw!',
                "should give message that the sender cannot withdraw any wei");

    const purch = await saleContract.sendPurchase({ value: 39990000000000000000, from: accounts[1] });
    const acct0Leftover = await saleContract.getLeftoverWei.call(accounts[0]);
    assert.equal(acct0Leftover.valueOf(),0, "should show that accounts0 has 0 leftover wei");
    // var receipt6 = await web3.eth.getTransactionReceipt(purch.receipt.transactionHash);

    // console.log("Tokens bought "+receipt6.logs[0].topics[0]);

    await saleContract.sendPurchase({ value: 10000000000000000, from: accounts[1] });
    const leftoverWei = await saleContract.getLeftoverWei.call(accounts[1]);
    assert.equal(leftoverWei.valueOf(),0, "should show that accounts1 has 0 leftover wei");

    const contribution = await saleContract.getContribution.call(accounts[1], { from:accounts[0] });
    assert.equal(contribution.valueOf(),40000000000000000000,
                "accounts[1] amount of wei contributed should be 40000000000000000000 wei");

    const firstTokenPurchase = await saleContract.getTokenPurchase.call(accounts[1]);
    assert.equal(firstTokenPurchase.valueOf(), 36000, "accounts[1] tokens purchased should be 36000");

    const secondTokenPurchase = await saleContract.sendPurchase({ value: 40000000000000000000, from: accounts[3] });

    const secondContribution = await saleContract.getContribution.call(accounts[1], { from: accounts[0] });
    assert.equal(secondContribution.valueOf(), 40000000000000000000, "accounts[1] amount of wei contributed should be 40000000000000000000 wei");

    const nextTokenPurchase = await saleContract.getTokenPurchase.call(accounts[1],{from:accounts[0]});
    assert.equal(nextTokenPurchase.valueOf(), 36000, "accounts[1] amount of tokens purchased should be 3600 tokens");

    await saleContract.sendPurchase({ value: 40000000000000000000, from: accounts[1] });
    const thirdContribution = await saleContract.getContribution.call(accounts[1], { from: accounts[0] });
    assert.equal(thirdContribution.valueOf(), 80000000000000000000, "accounts[1] amount of wei contributed should be 80000000000000000000 wei");

    const thirdTokenPurchase = await saleContract.getTokenPurchase.call(accounts[1], { from:accounts[0] });
    assert.equal(thirdTokenPurchase.valueOf(), 72000, "accounts[1] amount of tokens purchased should be 72000 tokens");

    try{
      const ownerSendPurchase = await saleContract.sendPurchase({ value: 30000000000000000000, from: accounts[0] });
    } catch(e) {
      errorThrown = true;
    }
    assert.isTrue(errorThrown, "should give an error message since sale has not started");
    errorThrown = false;

    const withdrawOwnerEth = await saleContract.withdrawOwnerEth({from: accounts[0]});
    assert.equal(withdrawOwnerEth.logs[0].args.Msg,
                'Cannot withdraw owner ether until after the sale!',
                "Should give an error that sale ether cannot be withdrawn till after the sale");

    const fourthContribution = await saleContract.getContribution.call(accounts[5]);
    assert.equal(fourthContribution.valueOf(),0,"accounts[5] (owner) ether contribution should be 0");

    await saleContract.sendPurchase({ value: 50000000000000111111, from: accounts[3] });
    const fifthContribution = await saleContract.getContribution.call(accounts[3], { from: accounts[3] });
    assert.equal(fifthContribution.valueOf(),90000000000000000000, "accounts[3] amount of wei contributed should be 9000000000000000000 wei");

    const fouthTokenPurchase = await saleContract.getTokenPurchase.call(accounts[3], { from: accounts[3] });
    assert.equal(fouthTokenPurchase.valueOf(), 81000, "accounts[3] amount of tokens purchased should be 81000 tokens");
    // var receipt7 = await web3.eth.getTransactionReceipt(fouthTokenPurchase.receipt.transactionHash);

    // console.log("Token price change "+receipt7.logs[0].topics[0]);

    //const secondTokensPerEth = await saleContract.getTokensPerEth.call();
    //assert.equal(secondTokensPerEth.valueOf(), 182, "New token price should be 182 tokens per ether!");

    await saleContract.withdrawTokens({ from: accounts[1] });
    const fifthTokenPurchase = await saleContract.getTokenPurchase.call(accounts[1], { from: accounts[0] });
    assert.equal(fifthTokenPurchase.valueOf(), 0, "accounts[1] should have withdrawn all tokens and should now have zero in the contract");

    const thirdWithdrawTokens = await saleContract.withdrawTokens({ from: accounts[0] });
    assert.equal(thirdWithdrawTokens.logs[0].args.Msg,
                "Owner cannot withdraw extra tokens until after the sale!",
                "Should give error message that the owner cannot withdraw any extra tokens yet");

    const sixthContribution = await saleContract.getContribution.call(accounts[4], { from: accounts[4] });
    assert.equal(sixthContribution.valueOf(), 0, "accounts[4] amount of wei contributed should be 0 wei");

    const fourthTokenPurchase = await saleContract.getTokenPurchase.call(accounts[4], { from: accounts[4] });
    assert.equal(fourthTokenPurchase.valueOf(), 0, "accounts[4] amount of tokens purchased should be 0 tokens");

    const secondLeftoverWei = await saleContract.getLeftoverWei.call(accounts[4], { from: accounts[4] });
    assert.equal(secondLeftoverWei.valueOf(),0, "accounts[4] leftover wei should be 0");

    var ret = await saleContract.withdrawLeftoverWei({ from: accounts[4] });
    // var receipt2 = await web3.eth.getTransactionReceipt(ret.receipt.transactionHash);

    // console.log("Withdraw Leftover Wei "+receipt2.logs[0].topics[0]);

    const thirdLeftoverWei = await saleContract.getLeftoverWei.call(accounts[4],{ from: accounts[4] });
    assert.equal(thirdLeftoverWei.valueOf(),0, "accounts[4] should have no leftover wei because it was just withdrawn");

    // move forward 8 days
    await time.move(web3, 691200);
    await web3.eth.sendTransaction({from: accounts[3]});

    const finalTokenPurchase = await saleContract.sendPurchase({ value: 31000000000000000000, from: accounts[2] });
    // var receipt1 = await web3.eth.getTransactionReceipt(finalTokenPurchase.receipt.transactionHash);

    // console.log("Change "+receipt1.logs[0].topics[0]);
    const finalContribution = await saleContract.getContribution.call(accounts[2], { from: accounts[0] });
    assert.equal(finalContribution.valueOf(), 31000000000000000000, "accounts[2] amount of wei contributed should be 31000000000000000000 wei");

  });

  it("move time 22 days and 1 hour", async () => {
    await time.move(web3, 1900800);
    await web3.eth.sendTransaction({from: accounts[3]});
  });

  it("should deny payments after the sale and allow users to withdraw their tokens/owner to withdraw ether", async () => {

    const isCrowdSaleActive = await saleContract.crowdsaleActive.call();
    assert.equal(isCrowdSaleActive.valueOf(), false, "Crowsale should not be active!");

    const isCrowdSaleEnded = await saleContract.crowdsaleEnded.call();
    assert.equal(isCrowdSaleEnded.valueOf(), true, "Crowsale should be ended!");

    await saleContract.getEthRaised.call();

    const secondTokenPurchase = await saleContract.getTokenPurchase.call(accounts[4], { from:accounts[3] });
    assert.equal(secondTokenPurchase.valueOf(), 0, "accounts[4] amount of tokens purchased should be 0 tokens");

    await saleContract.withdrawTokens({from:accounts[3]});
    const thirdTokenPurchase = await saleContract.getTokenPurchase.call(accounts[3], { from: accounts[3] });
    assert.equal(thirdTokenPurchase.valueOf(), 0,"accounts[3] should have withdrawn all tokens and should now have zero in the contract");

    const firstWithdrawLeftoverWei = await saleContract.withdrawLeftoverWei({ from: accounts[4] });
    assert.equal(firstWithdrawLeftoverWei.logs[0].args.Msg,
                "Sender has no extra wei to withdraw!",
                "should give error message because accounts4 already withdrew wei");

    await saleContract.withdrawLeftoverWei({ from: accounts[3] });

    const firstLeftoverWei = await saleContract.getLeftoverWei.call(accounts[3], { from:accounts[3] });
    assert.equal(firstLeftoverWei.valueOf(),0, "accounts[3] should have no leftover wei because it was just withdrawn");

    try{
      const sendFirstPurchase = await saleContract.sendPurchase({ from: accounts[2] });
    } catch(e) {
      errorThrown = true;
    }
    assert.isTrue(errorThrown, "should give an error message since sale has not started");
    errorThrown = false;

    const fourthWithdrawToken = await saleContract.withdrawTokens({ from: accounts[2] });

    // var receipt1 = await web3.eth.getTransactionReceipt(fourthWithdrawToken.receipt.transactionHash);

    // console.log("WithdrawTokens "+receipt1.logs[0].topics[0]);

    const withdrawOwnerEth = await saleContract.withdrawOwnerEth({ from: accounts[0] });
    // var receipt3 = await web3.eth.getTransactionReceipt(withdrawOwnerEth.receipt.transactionHash);

    // console.log("Owner withdraw "+receipt3.logs[0].topics[0]);
    assert.equal(withdrawOwnerEth.logs[0].args.Msg,
                'Crowdsale owner has withdrawn all funds!',
                "Should give message that the owner has withdrawn all funds");

    await saleContract.withdrawTokens({ from: accounts[4] });
    const fourthTokenPurchase = await saleContract.getTokenPurchase.call(accounts[4], { from: accounts[4] });
    assert.equal(fourthTokenPurchase.valueOf(),0,"accounts[4] should have withdrawn all tokens and should now have zero in the contract");

    const ownerEthRaised = await saleContract.getEthRaised.call();
    assert.equal(ownerEthRaised.valueOf(), 0, "Owner's ether balance in the contract should be zero!");

    const tokensSold = await saleContract.getTokensSold.call();
    assert.equal(tokensSold.valueOf(), 173925, "Tokens sold should be 173925");

    /******************
    * TOKEN CONTRACT BALANCE CHECKS
    *******************/
    const tokenBalanceFirstAccount = await token.balanceOf.call(accounts[0], { from: accounts[0] });
    assert.equal(tokenBalanceFirstAccount.valueOf(), 0, "accounts0 token balance should be 0");

    const tokenBalanceOfSecondAccount = await token.balanceOf.call(accounts[1],{ from: accounts[1] });
    assert.equal(tokenBalanceOfSecondAccount.valueOf(), 72000, "accounts[1] token balance should be 72000");

    const tokenBalanceOfThirdAccount = await token.balanceOf.call(accounts[2], { from: accounts[2] });
    assert.equal(tokenBalanceOfThirdAccount.valueOf(), 20925, "accounts2 token balance should be 20925");

    const tokenBalanceOfFourthAccount = await token.balanceOf.call(accounts[3], { from: accounts[3] });
    assert.equal(tokenBalanceOfFourthAccount.valueOf(), 81000, "accounts3 token balance should be 81000");

    const tokenBalanceOfFivethAccount = await token.balanceOf.call(accounts[4],{from:accounts[4]});
    assert.equal(tokenBalanceOfFivethAccount.valueOf(), 0, "accounts4 token balance should be 0");

    const crowdsaleTokenBalance = await token.balanceOf.call(saleContract.address);
    assert.equal(crowdsaleTokenBalance.valueOf(), 49826075,  "crowdsale's token balance should be 49826075!");

    await saleContract.withdrawTokens({ from: accounts[0] });
    const fivethTokenPurchase = await saleContract.getTokenPurchase.call(accounts[0], { from: accounts[0] });
    assert.equal(fivethTokenPurchase.valueOf(), 0, "Owner should have withdrawn all the leftover tokens from the sale!");

    const tokenBalanceOfAfterWithdraw = await token.balanceOf.call(accounts[0], { from: accounts[0] });
    assert.equal(tokenBalanceOfAfterWithdraw.valueOf(), 24913038, "accounts[0] token balance should be 24913038");

    const crowdsaleTokenBalanceAfterWithdraw = await token.balanceOf.call(saleContract.address);
    assert.equal(crowdsaleTokenBalanceAfterWithdraw.valueOf(), 0,  "crowdsale's token balance should be 0!");

    const tokenInitialSupply = await token.initialSupply();
    assert.equal(tokenInitialSupply.valueOf(), 50000000,  "The token's initial supply was 50M");

    const tokenTotalSupply = await token.totalSupply();
    assert.equal(tokenTotalSupply.valueOf(), 25086963,  "The token's new supply is 25086963");
  });
});
