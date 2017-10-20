const TimeVestingLibTokenTestContract = artifacts.require("TimeVestingLibTokenTestContract");
const TimeVestingLibETHTestContract = artifacts.require("TimeVestingLibETHTestContract");
const CrowdsaleToken = artifacts.require("CrowdsaleToken");

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
    assert.equal(totalSupply.valueOf(), 2000000000000, "Total supply should reflect 20000000000000000000.");
  });
});

/*************************************************************************
**************************************************************************/

contract('TimeVestingLibTokenTestContract', (accounts) => {
  it("should initialize the vesting contract data correctly", async () => {
    const c = await TimeVestingLibTokenTestContract.deployed();
    const owner = await c.getOwner.call();
    const totalSupply = await c.getTotalSupply.call();
    const contractBalance = await c.getContractBalance.call();
    const bonus = await c.getBonus.call();
    const isToken = await c.getIsToken.call();
    const startTime = await c.getStartTime.call();
    const endTime = await c.getEndTime.call();
    const numRegistered = await c.getNumRegistered.call();
    const timeInterval = await c.getTimeInterval.call();
    const percentReleased = await c.getPercentReleased.call();

    assert.equal(owner.valueOf(), accounts[5], "Owner should be set to accounts[5].");
    assert.equal(totalSupply.valueOf(), 0, "Total supply should be 0.");
    assert.equal(contractBalance.valueOf(), 0, "contract balance should be 0");
    assert.equal(bonus.valueOf(), 0, "The bonus tokens should be 0");
    assert.equal(isToken.valueOf(), true, "isToken should be set to true!");
    assert.equal(startTime.valueOf(), 105, "Start time should be 105");
    assert.equal(endTime.valueOf(),150, "end time should be 150");
    assert.equal(numRegistered.valueOf(),0, "numRegistered should be 0!");
    assert.equal(timeInterval.valueOf(), 9, "interval between vestings should be 9!");
    assert.equal(percentReleased.valueOf(), 20, "Percentage of Tokens to be released every vesting period should be 20!");
  });

  it("should initialize the token balance and accept registrations before the vesting starts", async () => {
    const c = await TimeVestingLibTokenTestContract.deployed();
    const t = await CrowdsaleToken.deployed();

    await t.transfer(c.contract.address,1333333,{from:accounts[5]});

    await c.initializeTokenBalance(t.address, 1333333,333333, {from:accounts[5]});

    await c.registerUsers([accounts[0],accounts[1],accounts[2],accounts[3]], {from:accounts[5]});

    const totalSupply = await c.getTotalSupply.call();
    const contractBalance = await c.getContractBalance.call();
    const bonus = await c.getBonus.call();
    const numRegistered = await c.getNumRegistered.call();

    assert.equal(totalSupply.valueOf(), 1000000, "Total supply should be 1000000.");
    assert.equal(contractBalance.valueOf(), 1000000, "contract balance should be 1000000");
    assert.equal(bonus.valueOf(), 333333, "The bonus tokens should be 333333");
    assert.equal(numRegistered.valueOf(),4, "numRegistered should be 5!");
    
  });

  it("should allow participants to withdraw vested tokens and swap registrations", async () => {
    const c = await TimeVestingLibTokenTestContract.deployed();
    const t = await CrowdsaleToken.deployed();

    // withdraw tokens after first vest
    await c.withdrawTokens(t.address, 115, {from:accounts[0]});
    var tokenBalance = await t.balanceOf(accounts[0]);
    assert.equal(tokenBalance.valueOf(),50000, "accounts[0] token balance should be 50000!");

    await c.withdrawTokens(t.address, 124, {from:accounts[0]});
    tokenBalance = await t.balanceOf(accounts[0]);
    assert.equal(tokenBalance.valueOf(),100000, "accounts[0] token balance should be 100000!");

    await c.withdrawTokens(t.address, 124, {from:accounts[1]});
    tokenBalance = await t.balanceOf(accounts[1]);
    assert.equal(tokenBalance.valueOf(),100000, "accounts[1] token balance should be 100000!");

    await c.sendTokens(t.address, accounts[2], 137, {from:accounts[5]});
    tokenBalance = await t.balanceOf(accounts[2]);
    assert.equal(tokenBalance.valueOf(),150000, "accounts[2] token balance should be 150000!");

    await c.sendTokens(t.address, accounts[0], 144, {from:accounts[5]});
    tokenBalance = await t.balanceOf(accounts[0]);
    assert.equal(tokenBalance.valueOf(),200000, "accounts[0] token balance should be 200000!");
  
    await c.swapRegistration(accounts[4], {from:accounts[2]});
    const numRegistered = await c.getNumRegistered.call();
    const isRegistered = await c.getIsRegistered.call(accounts[4]);
    const isntRegistered = await c.getIsRegistered.call(accounts[2]);
    var hasWithdrawn = await c.getHasWithdrawn.call(accounts[4]);

    assert.equal(numRegistered.valueOf(),4,"there should still be 4 addresses registered!");
    assert.equal(isRegistered.valueOf(), true, "accounts[4] should now be registered!");
    assert.equal(isntRegistered.valueOf(),false, "accounts[2] should not be registered anymore!");
    assert.equal(hasWithdrawn.valueOf(),150000, "After the swap, accounts[4] should have \"withdrawn\" 150000 tokens!");

    await c.sendTokens(t.address, accounts[4], 155, {from:accounts[5]});
    hasWithdrawn = await c.getHasWithdrawn.call(accounts[4]);
    tokenBalance = await t.balanceOf(accounts[4]);

    assert.equal(hasWithdrawn.valueOf(),250000, "accounts[4] should have withdrawn all 250000 tokens!");
    assert.equal(tokenBalance.valueOf(),100000, "accounts[4] token balance should be 250000!");

    hasWithdrawn = await c.getHasWithdrawn.call(accounts[3]);
    assert.equal(hasWithdrawn.valueOf(),0, "accounts[3] should have no tokens withdrawn!");
    await c.withdrawTokens(t.address, 156, {from:accounts[3]});
    hasWithdrawn = await c.getHasWithdrawn.call(accounts[3]);
    tokenBalance = await t.balanceOf(accounts[3]);
    assert.equal(tokenBalance.valueOf(),333333, "accounts[3] token balance should be 333333!");
  
    await c.ownerWithdrawExtraTokens(t.address, {from:accounts[5]});
    tokenBalance = await t.balanceOf(accounts[5]);
    assert.equal(tokenBalance.valueOf(), 1999999116667, "owner should have withdrawn all the extra tokens!");
  });
});


/*================================================================
  ETH CONTRACT
=================================================================*/

contract('TimeVestingLibETHTestContract', (accounts) => {
  it("should initialize the vesting contract data correctly", async () => {
    const c = await TimeVestingLibETHTestContract.deployed();
    const owner = await c.getOwner.call();
    const totalSupply = await c.getTotalSupply.call();
    const contractBalance = await c.getContractBalance.call();
    const bonus = await c.getBonus.call();
    const isToken = await c.getIsToken.call();
    const startTime = await c.getStartTime.call();
    const endTime = await c.getEndTime.call();
    const numRegistered = await c.getNumRegistered.call();
    const timeInterval = await c.getTimeInterval.call();
    const percentReleased = await c.getPercentReleased.call();

    assert.equal(owner.valueOf(), accounts[5], "Owner should be set to accounts[5].");
    assert.equal(totalSupply.valueOf(), 0, "Total supply should be 0.");
    assert.equal(contractBalance.valueOf(), 0, "contract balance should be 0");
    assert.equal(bonus.valueOf(), 0, "The bonus wei should be 0");
    assert.equal(isToken.valueOf(), false, "isToken should be set to false!");
    assert.equal(startTime.valueOf(), 105, "Start time should be 105");
    assert.equal(endTime.valueOf(),150, "end time should be 150");
    assert.equal(numRegistered.valueOf(),0, "numRegistered should be 0!");
    assert.equal(timeInterval.valueOf(), 9, "interval between vestings should be 9!");
    assert.equal(percentReleased.valueOf(), 20, "Percentage of wei to be released every vesting period should be 20!");
  });

  it("should initialize the wei balance and accept registrations before the vesting starts", async () => {
    const c = await TimeVestingLibETHTestContract.deployed();

    await c.initializeETHBalance(1333333,333333, {from:accounts[5], value: 1333333});

    await c.registerUsers([accounts[0],accounts[1],accounts[2],accounts[3]], {from:accounts[5]});

    const totalSupply = await c.getTotalSupply.call();
    const contractBalance = await c.getContractBalance.call();
    const bonus = await c.getBonus.call();
    const numRegistered = await c.getNumRegistered.call();

    assert.equal(totalSupply.valueOf(), 1000000, "Total supply should be 1000000.");
    assert.equal(contractBalance.valueOf(), 1000000, "contract balance should be 1000000");
    assert.equal(bonus.valueOf(), 333333, "The bonus ETH should be 333333");
    assert.equal(numRegistered.valueOf(),4, "numRegistered should be 5!");
    
  });

  it("should allow participants to withdraw vested ETH and swap registrations", async () => {
    const c = await TimeVestingLibETHTestContract.deployed();

    // withdraw ETH after first vest
    var ret = await c.withdrawETH(115, {from:accounts[0]});
    assert.equal(ret.logs[0].args.amount, 50000, "accounts[0] should have withdrawn 50000 wei!");

    ret = await c.withdrawETH(124, {from:accounts[0]});
    assert.equal(ret.logs[0].args.amount, 50000, "accounts[0] should have withdrawn 50000 wei!");

    ret = await c.withdrawETH( 124, {from:accounts[1]});
    assert.equal(ret.logs[0].args.amount, 100000, "accounts[0] should have withdrawn 100000 wei!");
    
    ret = await c.sendETH( accounts[2], 137, {from:accounts[5]});
    assert.equal(ret.logs[0].args.amount, 150000, "accounts[2] should have withdrawn 150000 wei!");

    ret = await c.sendETH( accounts[0], 144, {from:accounts[5]});
    assert.equal(ret.logs[0].args.amount, 100000, "accounts[0] should have withdrawn 100000 wei!");

    await c.swapRegistration(accounts[4], {from:accounts[2]});
    const numRegistered = await c.getNumRegistered.call();
    const isRegistered = await c.getIsRegistered.call(accounts[4]);
    const isntRegistered = await c.getIsRegistered.call(accounts[2]);
    var hasWithdrawn = await c.getHasWithdrawn.call(accounts[4]);

    assert.equal(numRegistered.valueOf(),4,"there should still be 4 addresses registered!");
    assert.equal(isRegistered.valueOf(), true, "accounts[4] should now be registered!");
    assert.equal(isntRegistered.valueOf(),false, "accounts[2] should not be registered anymore!");
    assert.equal(hasWithdrawn.valueOf(),150000, "After the swap, accounts[4] should have \"withdrawn\" 150000 wei!");

    ret = await c.sendETH( accounts[4], 155, {from:accounts[5]});
    hasWithdrawn = await c.getHasWithdrawn.call(accounts[4]);
    assert.equal(ret.logs[0].args.amount, 100000, "accounts[4] should have withdrawn 100000 wei!");

    assert.equal(hasWithdrawn.valueOf(),250000, "accounts[4] should have withdrawn all 250000 ETH!");

    hasWithdrawn = await c.getHasWithdrawn.call(accounts[3]);
    assert.equal(hasWithdrawn.valueOf(),0, "accounts[3] should have no ETH withdrawn!");
    ret = await c.withdrawETH(156, {from:accounts[3]});
    hasWithdrawn = await c.getHasWithdrawn.call(accounts[3]);
    assert.equal(ret.logs[0].args.amount, 333333, "accounts[3] should have withdrawn 333333 wei!");
  
    ret = await c.ownerWithdrawExtraETH({from:accounts[5]});
    assert.equal(ret.logs[0].args.amount, 450000, "owner should have withdrawn all the extra ETH!");
  
  });
});