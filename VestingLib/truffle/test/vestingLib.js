/* global artifacts, contract, context, before, it, assert */
import { increaseTimeTo, duration } from './helpers/increaseTime'
import latestTime from './helpers/latestTime'

const VestingLibTokenTestContract = artifacts.require("VestingLibTokenTestContract");
const CrowdsaleToken = artifacts.require("CrowdsaleToken");

contract('VestingLibTokenTestContract', function (accounts) {
  let c,startTime, endTime, afterStartTime, afterFirstVest, afterSecondVest, afterThirdVest, afterFourthVest, afterFifthVest, afterEndTime, t

  context('Token Vesting Testing', async () => { 
    before(async function () { 
        startTime = latestTime() + duration.weeks(10) + duration.hours(4)
        afterStartTime = startTime + duration.hours(4)
        afterFirstVest = startTime + duration.weeks(1) + duration.hours(4)
        afterSecondVest = startTime + duration.weeks(2) + duration.hours(4)
        afterThirdVest = startTime + duration.weeks(3) + duration.hours(4)
        afterFourthVest = startTime + duration.weeks(4) + duration.hours(4)
        afterFifthVest = startTime + duration.weeks(5) + duration.hours(4)
        endTime = startTime + duration.weeks(5)
        afterEndTime = endTime + duration.seconds(1)

        c = await VestingLibTokenTestContract.new(accounts[5],true,startTime,endTime,5);

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
        assert.equal(isToken.valueOf(), true, "isToken should be set to true!");
        assert.equal(numRegistered.valueOf(),0, "numRegistered should be 0!");
        assert.equal(timeInterval.valueOf(), 604800, "interval between vestings should be 6!");
        assert.equal(percentPerInterval.valueOf(), 20000, "Percentage of Tokens to be released every vesting period should be 20000!");
    });

    it("should initialize the token balance", async () => {
        const t = await CrowdsaleToken.deployed();

        await t.transfer(c.contract.address,1100000,{from:accounts[5]});

        await c.initializeTokenBalance(t.address, 1100000, {from:accounts[5]});

        const totalSupply = await c.getTotalSupply.call();

        assert.equal(totalSupply.valueOf(), 1100000, "Total supply should be 1100000.");
    });

    it("should accept group user registrations", async () => {

        var regevent = await c.registerUsers([accounts[0],accounts[1],accounts[2],accounts[3]], 200000, 0, {from:accounts[5]});
        // var receipt2 = await web3.eth.getTransactionReceipt(regevent.receipt.transactionHash);

        // console.log("Register "+receipt2.logs[0].topics[0]);

        const numRegistered = await c.getNumRegistered.call();
        const contractBalance = await c.getContractBalance.call();

        assert.equal(numRegistered.valueOf(),4, "numRegistered should be 4!");
        assert.equal(contractBalance.valueOf(), 300000, "contract balance should be 300000");
    });

    it("should deny invalid registrations", async () => {

        const alreadyRegistered = await c.registerUser(accounts[0], 2000, 200, {from:accounts[5]});

        const bigBonus = await c.registerUser(accounts[4],2000,200000, {from:accounts[5]});

        // var receipt1 = await web3.eth.getTransactionReceipt(alreadyRegistered.receipt.transactionHash);

        // console.log("Error "+receipt1.logs[0].topics[0]);

        assert.equal(alreadyRegistered.logs[0].args.Msg,"Registrant address is already registered for the vesting!", "should fail because accounts[0] is already registered");
        assert.equal(bigBonus.logs[0].args.Msg,"Bonus is larger than vest amount, please reduce bonus!","should fail because bonus is larger than vest amount");
    });

    it("should deny invalid un-registrations", async () => {

        const notRegistered = await c.unregisterUser(accounts[4],{from:accounts[5]});

        assert.equal(notRegistered.logs[0].args.Msg,"Registrant address not registered for the vesting!", "should fail because the address is not registered");
    });

    it("should accept group user un-registrations", async () => {

        var unreg = await c.unregisterUsers([accounts[0],accounts[1],accounts[2],accounts[3]],{from:accounts[5]});
        // var receipt3 = await web3.eth.getTransactionReceipt(unreg.receipt.transactionHash);

        // console.log("Unreg "+receipt3.logs[0].topics[0]);

        const numRegisteredbefore = await c.getNumRegistered.call();
        const contractBalancebefore = await c.getContractBalance.call();

        assert.equal(numRegisteredbefore.valueOf(),0, "numRegistered should be 0!");
        assert.equal(contractBalancebefore.valueOf(), 1100000, "contract balance should be 1100000");

        await c.registerUsers([accounts[0],accounts[1],accounts[2],accounts[3],accounts[6]], 200000, 20000, {from:accounts[5]});

        const bonusamt = await c.getBonusAmount.call(accounts[1], {from:accounts[1]});
        assert.equal(bonusamt.valueOf(),20000, "accounts[1] bonus should be 20000!");

        const numRegisteredafter = await c.getNumRegistered.call();
        const contractBalanceafter = await c.getContractBalance.call();

        assert.equal(numRegisteredafter.valueOf(),5, "numRegistered should be 4!");
        assert.equal(contractBalanceafter.valueOf(), 0, "contract balance should be 0");
    });

    it("should allow participants to withdraw vested tokens and for the owner to send tokens", async () => {
        const t = await CrowdsaleToken.deployed();

        await increaseTimeTo(afterFirstVest);

        const badRegistrationTiming = await c.registerUser(accounts[4],20000,200, {from:accounts[5]});
        assert.equal(badRegistrationTiming.logs[0].args.Msg,"Can only register users before the vesting starts!","should fail because vesting has started");

        const badUnregistrationTiming = await c.unregisterUser(accounts[0],{from:accounts[5]});
        assert.equal(badUnregistrationTiming.logs[0].args.Msg,"Can only register and unregister users before the vesting starts!","should fail because vesting has started");

        var percentReleased = await c.getPercentReleased.call();
        assert.equal(percentReleased.valueOf(),20, "percentReleased should be 20!");

        // withdraw tokens after first vest
        var withdraw = await c.withdrawTokens(t.address, {from:accounts[0]});
        // var receipt4 = await web3.eth.getTransactionReceipt(withdraw.receipt.transactionHash);

        // console.log("tokenwithdraw "+receipt4.logs[0].topics[0]);
        var tokenBalance = await t.balanceOf.call(accounts[0]);
        assert.equal(tokenBalance.valueOf(),40000, "accounts[0] token balance should be 40000!");

        const bonusamt = await c.getBonusAmount.call(accounts[1], {from:accounts[1]});
        assert.equal(bonusamt.valueOf(),20000, "accounts[1] bonus should be 20000!");

        await c.sendTokens(t.address, accounts[2], {from:accounts[5]});
        tokenBalance = await t.balanceOf.call(accounts[2]);
        assert.equal(tokenBalance.valueOf(),40000, "accounts[2] token balance should be 40000!");

        await increaseTimeTo(afterSecondVest);

        percentReleased = await c.getPercentReleased.call();
        assert.equal(percentReleased.valueOf(),40, "percentReleased should be 40!");

        await c.sendTokens(t.address, accounts[0], {from:accounts[5]});
        tokenBalance = await t.balanceOf.call(accounts[0]);
        assert.equal(tokenBalance.valueOf(),80000, "accounts[0] token balance should be 80000!");

    });

    it("should allow registrations to be swapped without affecting vested tokens", async () => {
        const t = await CrowdsaleToken.deployed();

        var swap = await c.swapRegistration(accounts[4], {from:accounts[2]});
        // var receipt5 = await web3.eth.getTransactionReceipt(swap.receipt.transactionHash);

        // console.log("SWAP "+receipt5.logs[0].topics[0]);
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

        await c.sendTokens(t.address, accounts[4], {from:accounts[5]});
        hasWithdrawn = await c.getHasWithdrawn.call(accounts[4]);
        var tokenBalance = await t.balanceOf.call(accounts[4]);

        assert.equal(hasWithdrawn.valueOf(),120000, "accounts[4] should have withdrawn 120000 tokens!");
        assert.equal(tokenBalance.valueOf(),80000, "accounts[4] token balance should be 80000!");

    });

    it("should allow token withdrawals near the end of vesting", async () => {
        const t = await CrowdsaleToken.deployed();

        await increaseTimeTo(afterFourthVest)

        const hasWithdrawn = await c.getHasWithdrawn.call(accounts[3]);
        assert.equal(hasWithdrawn.valueOf(),0, "accounts[3] should have no tokens withdrawn!");

        await c.withdrawTokens(t.address, {from:accounts[3]});
        var tokenBalance = await t.balanceOf.call(accounts[3]);

        assert.equal(tokenBalance.valueOf(),160000, "accounts[3] token balance should be 160000!");

        await c.withdrawTokens(t.address, {from:accounts[0]});
        tokenBalance = await t.balanceOf.call(accounts[0]);

        assert.equal(tokenBalance.valueOf(),160000, "accounts[0] token balance should be 160000!");

    });

    it("should allow full bonus withdrawals after the vesting is over", async () => {
        const t = await CrowdsaleToken.deployed();

        //move time two hours
        await increaseTimeTo(afterEndTime);

        await c.withdrawTokens(t.address,{from:accounts[6]});
        var tokenBalance = await t.balanceOf.call(accounts[6]);
        assert.equal(tokenBalance.valueOf(),220000, "accounts[6] token balance should be 220000!");

        await c.sendTokens(t.address,accounts[1], {from:accounts[5]});
        tokenBalance = await t.balanceOf.call(accounts[1]);

        assert.equal(tokenBalance.valueOf(),220000, "accounts[1] token balance should be 220000!");

    });

    it("should allow the owner to withdraw all the extra tokens", async () => {
        const t = await CrowdsaleToken.deployed();

        await c.ownerWithdrawExtraTokens(t.address, {from:accounts[5]});
        var tokenBalance = await t.balanceOf.call(accounts[5]);
        assert.equal(tokenBalance.valueOf(), 1999999040000, "owner should have withdrawn all the extra tokens!");
    });
  });
});


