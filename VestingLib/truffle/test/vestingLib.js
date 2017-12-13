// import {advanceBlock} from './helpers/advanceToBlock'
// import {increaseTimeTo, duration} from './helpers/increaseTime'
// import latestTime from './helpers/latestTime'
// const { should } = require('./helpers/utils')
var time = require('../helpers/time');
const VestingLibTokenTestContract = artifacts.require("VestingLibTokenTestContract");
const VestingLibETHTestContract = artifacts.require("VestingLibETHTestContract");
const CrowdsaleToken = artifacts.require("CrowdsaleToken");
//const timeout = ms => new Promise(res => setTimeout(res, ms));

contract('VestingLibTokenTestContract', (accounts) => {
  it("should initialize the vesting contract data correctly", async () => {
    const c = await VestingLibTokenTestContract.deployed();
    const owner = await c.getOwner.call();
    const totalSupply = await c.getTotalSupply.call();
    const contractBalance = await c.getContractBalance.call();
    const isToken = await c.getIsToken.call();
    const startTime = await c.getStartTime.call();
    const endTime = await c.getEndTime.call();
    const numRegistered = await c.getNumRegistered.call();
    const timeInterval = await c.getTimeInterval.call();
    const percentPerInterval = await c.getPercentPerInterval.call();
    console.log('Time  now  is ' + (new Date().valueOf())/1000);
    console.log('Start time is ' + startTime.valueOf());
    console.log('End   time is ' + endTime.valueOf());

    assert.equal(owner.valueOf(), accounts[5], "Owner should be set to accounts[5].");
    assert.equal(totalSupply.valueOf(), 0, "Total supply should be 0.");
    assert.equal(contractBalance.valueOf(), 0, "contract balance should be 0");
    assert.equal(isToken.valueOf(), true, "isToken should be set to true!");
    assert.equal(numRegistered.valueOf(),0, "numRegistered should be 0!");
    assert.equal(timeInterval.valueOf(), 6, "interval between vestings should be 6!");
    assert.equal(percentPerInterval.valueOf(), 20, "Percentage of Tokens to be released every vesting period should be 20!");
  });

  it("should initialize the token balance", async () => {
    const c = await VestingLibTokenTestContract.deployed();
    const t = await CrowdsaleToken.deployed();

    await t.transfer(c.contract.address,1100000,{from:accounts[5]});

    await c.initializeTokenBalance(t.address, 1100000, {from:accounts[5]});

    const totalSupply = await c.getTotalSupply.call();

    assert.equal(totalSupply.valueOf(), 1100000, "Total supply should be 1100000.");
  });

  it("should accept group user registrations", async () => {
    const c = await VestingLibTokenTestContract.deployed();

    await c.registerUsers([accounts[0],accounts[1],accounts[2],accounts[3]], 200000, 0, {from:accounts[5]});

    const numRegistered = await c.getNumRegistered.call();
    const contractBalance = await c.getContractBalance.call();

    assert.equal(numRegistered.valueOf(),4, "numRegistered should be 4!");
    assert.equal(contractBalance.valueOf(), 300000, "contract balance should be 300000");
  });

  it("should deny invalid registrations", async () => {
    const c = await VestingLibTokenTestContract.deployed();

    const alreadyRegistered = await c.registerUser(accounts[0], 2000, 200, {from:accounts[5]});

    const bigBonus = await c.registerUser(accounts[4],2000,200000, {from:accounts[5]});

    assert.equal(alreadyRegistered.logs[0].args.Msg,"Registrant address is already registered for the vesting!", "should fail because accounts[0] is already registered");
    assert.equal(bigBonus.logs[0].args.Msg,"Bonus is larger than vest amount, please reduce bonus!","should fail because bonus is larger than vest amount");
  });

  it("should deny invalid un-registrations", async () => {
    const c = await VestingLibTokenTestContract.deployed();

    const notRegistered = await c.unregisterUser(accounts[4],{from:accounts[5]});

    assert.equal(notRegistered.logs[0].args.Msg,"Registrant address not registered for the vesting!", "should fail because the address is not registered");
  });

  it("should accept group user un-registrations", async () => {
    const c = await VestingLibTokenTestContract.deployed();

    await c.unregisterUsers([accounts[0],accounts[1],accounts[2],accounts[3]],{from:accounts[5]});

    const numRegisteredbefore = await c.getNumRegistered.call();
    const contractBalancebefore = await c.getContractBalance.call();

    assert.equal(numRegisteredbefore.valueOf(),0, "numRegistered should be 0!");
    assert.equal(contractBalancebefore.valueOf(), 1100000, "contract balance should be 1100000");

    await c.registerUsers([accounts[0],accounts[1],accounts[2],accounts[3]], 200000, 0, {from:accounts[5]});

    const numRegisteredafter = await c.getNumRegistered.call();
    const contractBalanceafter = await c.getContractBalance.call();

    assert.equal(numRegisteredafter.valueOf(),4, "numRegistered should be 4!");
    assert.equal(contractBalanceafter.valueOf(), 300000, "contract balance should be 300000");
  });

  it("should allow participants to withdraw vested tokens and swap registrations", async () => {
    const c = await VestingLibTokenTestContract.deployed();
    const t = await CrowdsaleToken.deployed();

    await time.move(web3, 12);
    await web3.eth.sendTransaction({from: accounts[3]});

    const badRegistrationTiming = await c.registerUser(accounts[4],20000,200, {from:accounts[5]});
    assert.equal(badRegistrationTiming.logs[0].args.Msg,"Can only register users before the vesting starts!","should fail because vesting has started");

    const badUnregistrationTiming = await c.unregisterUser(accounts[0],{from:accounts[5]});
    assert.equal(badUnregistrationTiming.logs[0].args.Msg,"Can only register and unregister users before the vesting starts!","should fail because vesting has started");

    // withdraw tokens after first vest
    await c.withdrawTokens(t.address, {from:accounts[0]});
    var tokenBalance = await t.balanceOf(accounts[0]);
    assert.equal(tokenBalance.valueOf(),40000, "accounts[0] token balance should be 40000!");

    await c.withdrawTokens(t.address, {from:accounts[1]});
    tokenBalance = await t.balanceOf(accounts[1]);
    assert.equal(tokenBalance.valueOf(),40000, "accounts[1] token balance should be 40000!");

    await c.sendTokens(t.address, accounts[2], {from:accounts[5]});
    tokenBalance = await t.balanceOf(accounts[2]);
    assert.equal(tokenBalance.valueOf(),40000, "accounts[2] token balance should be 40000!");

    await time.move(web3, 5);
    await web3.eth.sendTransaction({from: accounts[3]});

    await c.sendTokens(t.address, accounts[0], {from:accounts[5]});
    tokenBalance = await t.balanceOf(accounts[0]);
    assert.equal(tokenBalance.valueOf(),80000, "accounts[0] token balance should be 80000!");

    await c.swapRegistration(accounts[4], {from:accounts[2]});
    const numRegistered = await c.getNumRegistered.call();
    const vestingAmount = await c.getVestingAmount.call(accounts[4]);
    let hasWithdrawn = await c.getHasWithdrawn.call(accounts[4]);
    const noVestingAmount = await c.getVestingAmount.call(accounts[2]);
    const noHasWithdrawn = await c.getHasWithdrawn.call(accounts[2]);

    assert.equal(numRegistered.valueOf(),4,"there should still be 4 addresses registered!");
    assert.equal(vestingAmount.valueOf(), 200000, "accounts[4] should now have the vested amount!");
    assert.equal(hasWithdrawn.valueOf(),40000, "accounts[4] should have the withdrawn amount!");
    assert.equal(noVestingAmount.valueOf(), 0, "accounts[2] should not have the vested amount!");
    assert.equal(noHasWithdrawn.valueOf(),0, "accounts[2] should not have the withdrawn amount!");

    await time.move(web3, 6);
    await web3.eth.sendTransaction({from: accounts[3]});

    await c.sendTokens(t.address, accounts[4], {from:accounts[5]});
    hasWithdrawn = await c.getHasWithdrawn.call(accounts[4]);
    tokenBalance = await t.balanceOf(accounts[4]);

    assert.equal(hasWithdrawn.valueOf(),120000, "accounts[4] should have withdrawn 120000 tokens!");
    assert.equal(tokenBalance.valueOf(),80000, "accounts[4] token balance should be 80000!");

    await time.move(web3, 6);
    await web3.eth.sendTransaction({from: accounts[3]});

    hasWithdrawn = await c.getHasWithdrawn.call(accounts[3]);
    assert.equal(hasWithdrawn.valueOf(),0, "accounts[3] should have no tokens withdrawn!");

    await c.withdrawTokens(t.address, {from:accounts[3]});
    tokenBalance = await t.balanceOf(accounts[3]);

    assert.equal(tokenBalance.valueOf(),160000, "accounts[3] token balance should be 160000!");
    //move time two hours
    await time.move(web3, 10);
    await web3.eth.sendTransaction({from: accounts[3]});

    await c.ownerWithdrawExtraTokens(t.address, {from:accounts[5]});
    tokenBalance = await t.balanceOf(accounts[5]);
    assert.equal(tokenBalance.valueOf(), 1999999200000, "owner should have withdrawn all the extra tokens!");
  });
});


/*================================================================
  ETH CONTRACT
=================================================================*/

contract('VestingLibETHTestContract', (accounts) => {
  it("should initialize the vesting contract data correctly", async () => {
    const c = await VestingLibETHTestContract.deployed();
    const owner = await c.getOwner.call();
    const totalSupply = await c.getTotalSupply.call();
    const contractBalance = await c.getContractBalance.call();
    const isToken = await c.getIsToken.call();
    const startTime = await c.getStartTime.call();
    const endTime = await c.getEndTime.call();
    const numRegistered = await c.getNumRegistered.call();
    const timeInterval = await c.getTimeInterval.call();
    const percentPerInterval = await c.getPercentPerInterval.call();
    console.log('Time  now  is ' + (new Date().valueOf())/1000);
    console.log('Start time is ' + startTime.valueOf());
    console.log('End   time is ' + endTime.valueOf());

    assert.equal(owner.valueOf(), accounts[5], "Owner should be set to accounts[5].");
    assert.equal(totalSupply.valueOf(), 0, "Total supply should be 0.");
    assert.equal(contractBalance.valueOf(), 0, "contract balance should be 0");
    assert.equal(isToken.valueOf(), false, "isToken should be set to false!");
    assert.equal(numRegistered.valueOf(),0, "numRegistered should be 0!");
    assert.equal(timeInterval.valueOf(), 6, "interval between vestings should be 6!");
    assert.equal(percentPerInterval.valueOf(), 20, "Percentage of Tokens to be released every vesting period should be 20!");
  });

  it("should initialize the wei balance and accept registrations before the vesting starts", async () => {
    const c = await VestingLibETHTestContract.deployed();

    await c.initializeETHBalance({from:accounts[5], value: 1000000});

    await c.registerUsers([accounts[0],accounts[1],accounts[2],accounts[3]], 200000, 0, {from:accounts[5]});

    const totalSupply = await c.getTotalSupply.call();
    const contractBalance = await c.getContractBalance.call();
    const numRegistered = await c.getNumRegistered.call();

    assert.equal(totalSupply.valueOf(), 1000000, "Total supply should be 1000000.");
    assert.equal(contractBalance.valueOf(), 200000, "contract balance should be 200000");
    assert.equal(numRegistered.valueOf(),4, "numRegistered should be 4!");

  });

  it("should allow participants to withdraw vested ETH and swap registrations", async () => {
    const c = await VestingLibETHTestContract.deployed();

    await time.move(web3, 12);
    await web3.eth.sendTransaction({from: accounts[3]});
    // withdraw ETH after first vest
    let ret = await c.withdrawETH({from:accounts[0]});
    assert.equal(ret.logs[0].args.amount, 40000, "accounts[0] should have withdrawn 40000 wei!");

    ret = await c.withdrawETH({from:accounts[1]});
    assert.equal(ret.logs[0].args.amount, 40000, "accounts[1] should have withdrawn 40000 wei!");

    ret = await c.sendETH(accounts[2], {from:accounts[5]});
    assert.equal(ret.logs[0].args.amount, 40000, "accounts[2] should have withdrawn 40000 wei!");

    await time.move(web3, 6);
    await web3.eth.sendTransaction({from: accounts[3]});

    ret = await c.sendETH(accounts[0], {from:accounts[5]});
    assert.equal(ret.logs[0].args.amount, 40000, "accounts[0] should have withdrawn 40000 wei!");

    await c.swapRegistration(accounts[4], {from:accounts[2]});
    const numRegistered = await c.getNumRegistered.call();
    const vestingAmount = await c.getVestingAmount.call(accounts[4]);
    let hasWithdrawn = await c.getHasWithdrawn.call(accounts[4]);
    const noVestingAmount = await c.getVestingAmount.call(accounts[2]);
    const noHasWithdrawn = await c.getHasWithdrawn.call(accounts[2]);

    assert.equal(numRegistered.valueOf(),4,"there should still be 4 addresses registered!");
    assert.equal(vestingAmount.valueOf(), 200000, "accounts[4] should now have the vested amount!");
    assert.equal(hasWithdrawn.valueOf(),40000, "accounts[4] should have the withdrawn amount!");
    assert.equal(noVestingAmount.valueOf(), 0, "accounts[2] should not have the vested amount!");
    assert.equal(noHasWithdrawn.valueOf(),0, "accounts[2] should not have the withdrawn amount!");

    await time.move(web3, 6);
    await web3.eth.sendTransaction({from: accounts[3]});

    ret = await c.sendETH(accounts[4], {from:accounts[5]});
    hasWithdrawn = await c.getHasWithdrawn.call(accounts[4]);

    assert.equal(hasWithdrawn.valueOf(),120000, "accounts[4] should have withdrawn 120000 tokens!");
    assert.equal(ret.logs[0].args.amount, 80000, "accounts[0] should have withdrawn 80000 wei!");

    await time.move(web3, 6);
    await web3.eth.sendTransaction({from: accounts[3]});

    hasWithdrawn = await c.getHasWithdrawn.call(accounts[3]);
    assert.equal(hasWithdrawn.valueOf(),0, "accounts[3] should have no tokens withdrawn!");

    ret = await c.withdrawETH({from:accounts[3]});
    assert.equal(ret.logs[0].args.amount, 160000, "accounts[3] should have withdrawn 160000 wei!");

    await time.move(web3, 10);
    await web3.eth.sendTransaction({from: accounts[3]});

    ret = await c.ownerWithdrawExtraETH({from:accounts[5]});
    assert.equal(ret.logs[0].args.amount, 200000, "owner should have withdrawn all the extra ETH!");
  });
});
