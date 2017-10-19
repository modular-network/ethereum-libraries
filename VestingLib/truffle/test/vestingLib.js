const TimeVestingLibTokenTestContract = artifacts.require("TimeVestingLibTokenTestContract");
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
    assert.equal(totalSupply.valueOf(), 20000000000000000000000000, "Total supply should reflect 20000000000000000000.");
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

    t.transfer(c.contract.address,1333333,{from:accounts[5]});

    c.initializeTokenBalance(t.contract, 1333333,333333, {from:accounts[5]});

    const totalSupply = await c.getTotalSupply.call();
    const contractBalance = await c.getContractBalance.call();
    const bonus = await c.getBonus.call();
    const numRegistered = await c.getNumRegistered.call();

    assert.equal(totalSupply.valueOf(), 1000000, "Total supply should be 1000000.");
    assert.equal(contractBalance.valueOf(), 1000000, "contract balance should be 1000000");
    assert.equal(bonus.valueOf(), 333333, "The bonus tokens should be 333333");
    assert.equal(numRegistered.valueOf(),0, "numRegistered should be 0!");
    
  });
});