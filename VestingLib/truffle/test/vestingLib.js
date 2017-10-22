const VestingLibTokenTestContract = artifacts.require("VestingLibTokenTestContract");
const VestingLibETHTestContract = artifacts.require("VestingLibETHTestContract");
const CrowdsaleToken = artifacts.require("CrowdsaleToken");
const timeout = ms => new Promise(res => setTimeout(res, ms));

contract('CrowdsaleToken', (accounts) => {
  it("should properly initialize token data", async () => {
    const c = await CrowdsaleToken.deployed();
    const name = await c.name.call();
    const symbol = await c.symbol.call();
    const decimals = await c.decimals.call();
    const totalSupply = await c.totalSupply.call();

    assert.equal(name.valueOf(), 'Tester Token', "Name should be set to Tester Token.");
    assert.equal(symbol.valueOf(), 'TST', "Symbol should be set to TST.");
    assert.equal(decimals.valueOf(), 18, "Decimals should be set to 18.");
    assert.equal(totalSupply.valueOf(), 2000000000000, "Total supply should reflect 2000000000000.");
  });
});

/*************************************************************************
**************************************************************************/

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

  it("should initialize the token balance and accept registrations before the vesting starts", async () => {
    const c = await VestingLibTokenTestContract.deployed();
    const t = await CrowdsaleToken.deployed();

    await t.transfer(c.contract.address,1100000,{from:accounts[5]});

    await c.initializeTokenBalance(t.address, 1100000, {from:accounts[5]});

    await c.registerUsers([accounts[0],accounts[1],accounts[2],accounts[3]], 200000, 0, {from:accounts[5]});

    const totalSupply = await c.getTotalSupply.call();
    const contractBalance = await c.getContractBalance.call();
    const numRegistered = await c.getNumRegistered.call();

    assert.equal(totalSupply.valueOf(), 1100000, "Total supply should be 1100000.");
    assert.equal(contractBalance.valueOf(), 300000, "contract balance should be 300000");
    assert.equal(numRegistered.valueOf(),4, "numRegistered should be 4!");

  });

  it("should allow participants to withdraw vested tokens and swap registrations", async () => {
    const c = await VestingLibTokenTestContract.deployed();
    const t = await CrowdsaleToken.deployed();
    await timeout(12000);
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
    await timeout(6000);

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
    await timeout(6000);

    await c.sendTokens(t.address, accounts[4], {from:accounts[5]});
    hasWithdrawn = await c.getHasWithdrawn.call(accounts[4]);
    tokenBalance = await t.balanceOf(accounts[4]);

    assert.equal(hasWithdrawn.valueOf(),120000, "accounts[4] should have withdrawn 120000 tokens!");
    assert.equal(tokenBalance.valueOf(),80000, "accounts[4] token balance should be 80000!");
    await timeout(6000);

    hasWithdrawn = await c.getHasWithdrawn.call(accounts[3]);
    assert.equal(hasWithdrawn.valueOf(),0, "accounts[3] should have no tokens withdrawn!");

    await c.withdrawTokens(t.address, {from:accounts[3]});
    tokenBalance = await t.balanceOf(accounts[3]);

    assert.equal(tokenBalance.valueOf(),160000, "accounts[3] token balance should be 160000!");
    await timeout(10000);

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

    await timeout(10000);
    // withdraw ETH after first vest
    let ret = await c.withdrawETH({from:accounts[0]});
    assert.equal(ret.logs[0].args.amount, 40000, "accounts[0] should have withdrawn 40000 wei!");

    ret = await c.withdrawETH({from:accounts[1]});
    assert.equal(ret.logs[0].args.amount, 40000, "accounts[1] should have withdrawn 40000 wei!");

    ret = await c.sendETH(accounts[2], {from:accounts[5]});
    assert.equal(ret.logs[0].args.amount, 40000, "accounts[2] should have withdrawn 40000 wei!");
    await timeout(6000);

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
    await timeout(6000);

    ret = await c.sendETH(accounts[4], {from:accounts[5]});
    hasWithdrawn = await c.getHasWithdrawn.call(accounts[4]);

    assert.equal(hasWithdrawn.valueOf(),120000, "accounts[4] should have withdrawn 120000 tokens!");
    assert.equal(ret.logs[0].args.amount, 80000, "accounts[0] should have withdrawn 80000 wei!");
    await timeout(6000);

    hasWithdrawn = await c.getHasWithdrawn.call(accounts[3]);
    assert.equal(hasWithdrawn.valueOf(),0, "accounts[3] should have no tokens withdrawn!");

    ret = await c.withdrawETH({from:accounts[3]});
    assert.equal(ret.logs[0].args.amount, 160000, "accounts[3] should have withdrawn 160000 wei!");
    await timeout(10000);

    ret = await c.ownerWithdrawExtraETH({from:accounts[5]});
    assert.equal(ret.logs[0].args.amount, 200000, "owner should have withdrawn all the extra ETH!");
  });
});
