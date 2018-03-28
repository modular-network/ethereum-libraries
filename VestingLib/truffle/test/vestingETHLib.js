/* global artifacts, contract, context, before, it, assert */
import { increaseTimeTo, duration } from './helpers/increaseTime'
import latestTime from './helpers/latestTime'

const VestingLibETHTestContract = artifacts.require("VestingLibETHTestContract");

/*================================================================
  ETH CONTRACT
=================================================================*/

contract('VestingLibETHTestContract', function (accounts) {
  let c,startTime, endTime, afterStartTime, afterFirstVest, afterSecondVest, afterThirdVest, afterFourthVest, afterFifthVest, afterEndTime

  context('ETH Vesting Testing', async () => { 
    
    before(async function () { 
        startTime = latestTime() + duration.weeks(1) + duration.hours(4)
        afterStartTime = startTime + duration.hours(4)
        afterFirstVest = startTime + duration.weeks(1) + duration.hours(4)
        afterSecondVest = startTime + duration.weeks(2) + duration.hours(4)
        afterThirdVest = startTime + duration.weeks(3) + duration.hours(4)
        afterFourthVest = startTime + duration.weeks(4) + duration.hours(4)
        afterFifthVest = startTime + duration.weeks(5) + duration.hours(4)
        endTime = startTime + duration.weeks(5)
        afterEndTime = endTime + duration.seconds(1)

        c = await VestingLibETHTestContract.new(accounts[5],false,startTime,endTime,5);

    });


    it("should initialize the vesting contract data correctly", async () => {
        const owner = await c.getOwner.call();
        const totalSupply = await c.getTotalSupply.call();
        const contractBalance = await c.getContractBalance.call();
        const isToken = await c.getIsToken.call();
        const sTime = await c.getStartTime.call();
        const eTime = await c.getEndTime.call();
        const numRegistered = await c.getNumRegistered.call();
        const timeInterval = await c.getTimeInterval.call();
        const percentPerInterval = await c.getPercentPerInterval.call();
        console.log('Time  now  is ' + (new Date().valueOf())/1000);
        console.log('Start time is ' + sTime.valueOf());
        console.log('End   time is ' + eTime.valueOf());

        assert.equal(owner.valueOf(), accounts[5], "Owner should be set to accounts[5].");
        assert.equal(totalSupply.valueOf(), 0, "Total supply should be 0.");
        assert.equal(contractBalance.valueOf(), 0, "contract balance should be 0");
        assert.equal(isToken.valueOf(), false, "isToken should be set to false!");
        assert.equal(numRegistered.valueOf(),0, "numRegistered should be 0!");
        assert.equal(timeInterval.valueOf(), 604800, "interval between vestings should be 6!");
        assert.equal(percentPerInterval.valueOf(), 20000, "Percentage of ETH to be released every vesting period should be 20000!");
    });

    it("should initialize the wei balance and accept registrations before the vesting starts", async () => {

        await c.initializeETHBalance({from:accounts[5], value: 1120000});

        await c.registerUsers([accounts[0],accounts[1],accounts[2],accounts[3],accounts[6]], 200000, 20000, {from:accounts[5]});

        const totalSupply = await c.getTotalSupply.call();
        const contractBalance = await c.getContractBalance.call();
        const numRegistered = await c.getNumRegistered.call();

        assert.equal(totalSupply.valueOf(), 1120000, "Total supply should be 1000000.");
        assert.equal(contractBalance.valueOf(), 20000, "contract balance should be 20000");
        assert.equal(numRegistered.valueOf(),5, "numRegistered should be 5!");

    });

    it("should allow participants to withdraw vested ETH and swap registrations", async () => {

        await increaseTimeTo(afterFirstVest);
        // withdraw ETH after first vest
        let ret = await c.withdrawETH({from:accounts[0]});
        assert.equal(ret.logs[0].args.amount, 40000, "accounts[0] should have withdrawn 40000 wei!");
        // var receipt1 = await web3.eth.getTransactionReceipt(ret.receipt.transactionHash);

        // console.log("ETHwithdraw "+receipt1.logs[0].topics[0]);

        ret = await c.sendETH(accounts[2], {from:accounts[5]});
        assert.equal(ret.logs[0].args.amount, 40000, "accounts[2] should have withdrawn 40000 wei!");

        await increaseTimeTo(afterSecondVest);

        ret = await c.sendETH(accounts[0], {from:accounts[5]});
        assert.equal(ret.logs[0].args.amount, 40000, "accounts[0] should have withdrawn 40000 wei!");

        await c.swapRegistration(accounts[4], {from:accounts[2]});
        const numRegistered = await c.getNumRegistered.call();
        const vestingAmount = await c.getVestingAmount.call(accounts[4]);
        let hasWithdrawn = await c.getHasWithdrawn.call(accounts[4]);
        const noVestingAmount = await c.getVestingAmount.call(accounts[2]);
        const noHasWithdrawn = await c.getHasWithdrawn.call(accounts[2]);

        assert.equal(numRegistered.valueOf(),5,"there should still be 4 addresses registered!");
        assert.equal(vestingAmount.valueOf(), 200000, "accounts[4] should now have the vested amount!");
        assert.equal(hasWithdrawn.valueOf(),40000, "accounts[4] should have the withdrawn amount!");
        assert.equal(noVestingAmount.valueOf(), 0, "accounts[2] should not have the vested amount!");
        assert.equal(noHasWithdrawn.valueOf(),0, "accounts[2] should not have the withdrawn amount!");

        await increaseTimeTo(afterThirdVest);

        ret = await c.sendETH(accounts[4], {from:accounts[5]});
        hasWithdrawn = await c.getHasWithdrawn.call(accounts[4]);

        assert.equal(hasWithdrawn.valueOf(),120000, "accounts[4] should have withdrawn 120000 wei!");
        assert.equal(ret.logs[0].args.amount, 80000, "accounts[4] should have withdrawn 80000 wei!");

        await increaseTimeTo(afterFourthVest);

        hasWithdrawn = await c.getHasWithdrawn.call(accounts[3]);
        assert.equal(hasWithdrawn.valueOf(),0, "accounts[3] should have no tokens withdrawn!");

        ret = await c.withdrawETH({from:accounts[3]});
        assert.equal(ret.logs[0].args.amount, 160000, "accounts[3] should have withdrawn 160000 wei!");

        ret = await c.withdrawETH({from:accounts[0]});
        assert.equal(ret.logs[0].args.amount, 80000, "accounts[0] should have withdrawn 80000 wei!");

        await increaseTimeTo(afterEndTime);

        ret = await c.withdrawETH({from:accounts[6]});
        assert.equal(ret.logs[0].args.amount,220000, "accounts[6] should have gotten 220000 wei!");

        ret = await c.sendETH(accounts[1], {from:accounts[5]});

        assert.equal(ret.logs[0].args.amount,220000, "accounts[1] should have gotten 220000 wei!");

        ret = await c.ownerWithdrawExtraETH({from:accounts[5]});
        assert.equal(ret.logs[0].args.amount, 240000, "owner should have withdrawn all the extra ETH!");
    });
  });
});