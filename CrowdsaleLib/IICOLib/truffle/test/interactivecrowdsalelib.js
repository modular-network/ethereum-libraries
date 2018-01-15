/* global artifacts, contract, context, before, it, assert */
import { increaseTimeTo, duration } from './helpers/increaseTime'
import { simulate } from './helpers/pointerUtils'
import latestTime from './helpers/latestTime'
import BN from 'bn.js'
// const { should } = require('./helpers/utils')
const CrowdsaleToken = artifacts.require('CrowdsaleToken')
const InteractiveCrowdsaleTestContract = artifacts.require('InteractiveCrowdsaleTestContract')

// can also set sale as a global up here and carry it throughout
// var sale;
contract('InteractiveCrowdsaleTestContract', function (accounts) {
  let sale, startTime, endWithdrawlTime, endTime, afterEndTime, token, simulation, purchaseData

  context('Moving pointer', async () => {
    before(async function () {
      startTime = latestTime() + duration.weeks(1) + duration.hours(4)
      endWithdrawlTime = startTime + duration.weeks(100)
      endTime = startTime + duration.years(2)
      afterEndTime = endTime + duration.seconds(1)

      purchaseData = [startTime, 1000000000000000000000, 0]

      sale = await InteractiveCrowdsaleTestContract.new(accounts[5],
                                                       purchaseData,
                                                       20,
                                                       40000000000000000000, // minimum in terms of wei
                                                       endWithdrawlTime,
                                                       endTime,
                                                       50,
                                                       'Jason Token',
                                                       'TBT',
                                                       18,
                                                       false)
    })

    it('calculates the pointer correctly', async () => {
      await increaseTimeTo(startTime)
      simulation = await simulate(accounts, sale)
      // console.log('fetched Pointers: ', simulation.fetchedValuationPointer);
      // console.log('calculated pointers', simulation.calculatedValuationPointer);
      for (var i = 0; i < simulation.fetchedValuationPointer.length; i++) {
        assert.equal(simulation.fetchedValuationPointer[i],
                     simulation.calculatedValuationPointer[i],
                     'Results from fetched value differ from calculated value')
      }
    })

    it('gives correct ETH refunds during the sale', async () => {
      var ethBalance

      for (var i = 1; i < accounts.length; i++) {
        ethBalance = await sale.getLeftoverWei.call(accounts[i])
        // console.log(accounts[i]+': '+ethBalance)
        if (simulation.addressWithdrew[i] === false) {
          // console.log('no withdrawal')
          assert.equal(ethBalance.valueOf(), 0,
                       'Addresses that didn\'t withdraw should have a leftover wei balance of zero!')
        } else {
          // console.log('withdrawal')
          assert.isAbove(ethBalance.valueOf(), 0,
                         'Addresses that did manual withdraws should have a nonzero leftover wei balance!')
        }
      }
    })

    it('denies token withdrawals if owner has not withdrawn ETH yet', async () => {
      await increaseTimeTo(afterEndTime)

      let error = false
      try {
        await sale.retreiveFinalResult({ from:accounts[2] })
      } catch (e) {
        error = true
      }

      assert.isTrue(error, 'Token withdraw should throw an error if the owner has not finalized the sale')
    })

    it('initializes token correctly', async () => {
      await sale.finalizeSale()

      const tokenAddress = await sale.getTokenAddress.call()
      token = CrowdsaleToken.at(tokenAddress)
      const tokenName = await token.name.call()
      assert.equal(tokenName, 'Jason Token', 'Tokens should be created after the sale is finalized')
    })

    it('allows correct ETH withdrawals', async () => {
      // let totalValuation = await sale.getTotalValuation();
      // let minimumRaise = await sale.getMinimumRaise();

      // console.log(totalValuation.valueOf());
      // console.log(minimumRaise.valueOf());

      for (var i = 1; i < accounts.length; i++) {
        // console.log('cap: '+simulation.personalCaps[i])
        if ((simulation.personalCaps[i] < simulation.totalValuation) && (i !== 5)) {
          // console.log('account number '+i)
          let initialContribution = await sale.getContribution.call(accounts[i])

          let initialLeftover = await sale.getLeftoverWei.call(accounts[i])

          let totalAfterWithdraw = initialContribution.add(initialLeftover)

          let denyToken = await sale.retreiveFinalResult({ from:accounts[i] })

          let newBalance = await sale.getContribution.call(accounts[i])

          let leftoverWei = await sale.getLeftoverWei.call(accounts[i])

          // console.log('contribution: '+initialContribution.valueOf());
          // console.log('leftover: '+initialLeftover.valueOf());
          // console.log('totalAfterWithdraw: '+totalAfterWithdraw.valueOf());

          newBalance.should.be.bignumber.equal(0)
          leftoverWei.should.be.bignumber.equal(0)
          assert.equal(denyToken.logs[0].args.Amount.valueOf(), totalAfterWithdraw.valueOf(),
            'amount of wei withdrawn should be the sum of of the initial withdrawal refund plus finalized refund!')
        }
      }
    })

    it('gives full token purchases to bidders above the total valuation', async () => {
      for (var i = 1; i < accounts.length; i++) {
        // console.log('cap: '+simulation.personalCaps[i])
        if ((simulation.personalCaps[i] > simulation.totalValuation) && (i !== 5)) {
          // console.log('account number: '+i)
          let price = await sale.getPrice.call(accounts[i])
          let hasContributed = await sale.getContribution.call(accounts[i])
          // console.log('price: '+price.toString());
          // console.log('contribute: '+hasContributed.toString());

          let tokenPurchase = price.mul(hasContributed)
          let divisor = new BN('1000000000000000000', 10)

          tokenPurchase = tokenPurchase.div(divisor).toString()
          if (tokenPurchase.split('e').length === 1) {
            tokenPurchase = tokenPurchase.split('.')[0]
          } else if (tokenPurchase.split('e')[0].length > 23) {
            let firstPart = tokenPurchase.substring(0, 23)
            while (firstPart.charAt(firstPart.length - 1) === '0') {
              firstPart = firstPart.slice(0, -1)
            }
            tokenPurchase = firstPart + 'e' + tokenPurchase.split('e')[1]
          }
          // console.log('tokenPurchase: ' + tokenPurchase)

          await sale.retreiveFinalResult({ from:accounts[i] })

          let balance = await token.balanceOf.call(accounts[i])
          // let contractBalance = await token.balanceOf.call(sale.address)
          // console.log(contractBalance.valueOf())

          let leftoverWei = await sale.getLeftoverWei.call(accounts[i])
          hasContributed = await sale.getContribution.call(accounts[i])

          tokenPurchase.should.be.bignumber.equal(balance.valueOf())
          leftoverWei.should.be.bignumber.equal(0)
          hasContributed.should.be.bignumber.equal(0)
        }
      }
    })

    it('correctly splits the token/eth distro for users at the valuation', async () => {
      for (var i = 1; i < accounts.length; i++) {
        // console.log('cap: '+simulation.personalCaps[i])
        if ((simulation.personalCaps[i] === simulation.totalValuation) && (i !== 5)) {
          // console.log('account number: '+i)
          let price = await sale.getPrice.call(accounts[i])
          let valuation = await sale.getTotalValuation.call()
          let committed = await sale.getCommittedCapital.call()
          let overage = committed.sub(valuation)
          let valueCommitment = await sale.getValueCommitement.call(valuation.toString())
          let hasContributed = await sale.getContribution.call(accounts[i])
          let percentageOfThePie = overage.div(valueCommitment)
          percentageOfThePie = 1 - percentageOfThePie.toNumber()
          percentageOfThePie = (percentageOfThePie * 100).toString().split('.')[0]
          percentageOfThePie = parseInt(percentageOfThePie) / 100
          // console.log('price: '+price.toString())
          // console.log('contribute: '+hasContributed.toString())
          // console.log('percentage: '+percentageOfThePie)

          let tokenPurchase = price.mul(hasContributed.mul(percentageOfThePie))
          let divisor = new BN('1000000000000000000', 10)

          tokenPurchase = tokenPurchase.div(divisor).toString()
          if (tokenPurchase.split('e').length === 1) {
            tokenPurchase = tokenPurchase.split('.')[0]
          } else if (tokenPurchase.split('e')[0].length > 23) {
            let firstPart = tokenPurchase.substring(0, 23)
            while (firstPart.charAt(firstPart.length - 1) === '0') {
              firstPart = firstPart.slice(0, -1)
            }
            tokenPurchase = firstPart + 'e' + tokenPurchase.split('e')[1]
          }
          // console.log('tp: '+tokenPurchase)

          await sale.retreiveFinalResult({ from:accounts[i] })

          let balance = await token.balanceOf.call(accounts[i])

          let leftoverWei = await sale.getLeftoverWei.call(accounts[i])
          hasContributed = await sale.getContribution.call(accounts[i])

          tokenPurchase.should.be.bignumber.equal(balance.valueOf())
          leftoverWei.should.be.bignumber.equal(0)
          hasContributed.should.be.bignumber.equal(0)
        }
      }
    })
  })

  context('Intializing the contract', async () => {
    before(async function () {
      startTime = latestTime() + duration.weeks(100) + duration.hours(4)
      endWithdrawlTime = startTime + duration.weeks(100)
      endTime = startTime + duration.years(2)
      afterEndTime = endTime + duration.seconds(1)

      purchaseData = [startTime, 1000000000000000000000, 0]

      sale = await InteractiveCrowdsaleTestContract.new(accounts[5],
                                                       purchaseData,
                                                       20,
                                                       1000000000000000000, // minimum in terms of wei
                                                       endWithdrawlTime,
                                                       endTime,
                                                       50,
                                                       'Jason Token',
                                                       'TBT',
                                                       18,
                                                       false)
    })

    it('has the correct owner', async () => {
      const owner = await sale.getOwner.call()
      owner.should.be.equal(accounts[5])
    })

    it('has the correct minimum raise', async () => {
      const raise = await sale.getMinimumRaise.call()
      raise.should.be.bignumber.equal(1000000000000000000)
    })

    it('has the correct start time', async () => {
      const start = await sale.getStartTime.call()

      start.should.be.bignumber.equal(startTime)
    })

    it('has the correct endWithdrawalTime', async () => {
      const gran = await sale.getEndWithdrawlTime.call()
      gran.should.be.bignumber.equal(endWithdrawlTime)
    })

    it('has the correct endTime', async () => {
      const gran = await sale.getEndTime.call()
      gran.should.be.bignumber.equal(endTime)
    })

    it('initializes with zeroed valuation', async () => {
      const valuation = await sale.getTotalValuation.call()
      assert.equal(valuation, 0)
    })

    it('initializes with no tokens sold', async () => {
      const sold = await sale.getTokensSold.call()
      assert.equal(sold, 0)
    })

    it('has the correct burn percentage', async () => {
      const percentSold = await sale.getPercentBeingSold.call()
      assert.equal(percentSold.toNumber(), 50)
    })

    it('has the correct tokens per Eth calculated', async () => {
      const tokensPerEth = await sale.getTokensPerEth.call()
      tokensPerEth.should.be.bignumber.equal(1000000000000000000000)
    })

    it('has the correct active status', async () => {
      const active = await sale.crowdsaleActive.call()
      assert.isFalse(active, 'current sale is starting with past time')
    })
  })

  context('Testing bid submission', async() => {
    before(async function () {
      startTime = latestTime() + duration.weeks(100) + duration.hours(4)
      endWithdrawlTime = startTime + duration.weeks(100)
      endTime = startTime + duration.years(2)
      afterEndTime = endTime + duration.seconds(1)

      purchaseData = [startTime, 1000000000000000000000, 0]

      sale = await InteractiveCrowdsaleTestContract.new(accounts[5],
                                                       purchaseData,
                                                       20,
                                                       1000000000000000000, // minimum in terms of wei
                                                       endWithdrawlTime,
                                                       endTime,
                                                       50,
                                                       'Jason Token',
                                                       'TBT',
                                                       18,
                                                       false)
    })

    it('disallows bid submission if sale hasn\'t started', async () => {
      let err = false
      try {
        await sale.submitBid(100000000, 0, { from:accounts[2], value:1000000 })
      } catch (e) {
        err = true
      }
      assert.isTrue(err, 'should give an error message since sale has not started')
    })

    it('should accept a bid if the sale has started', async () => {
      await increaseTimeTo(startTime)
      await sale.submitBid(100000000, 0, { from:accounts[0], value:1000000 })
      const cont = await sale.getContribution.call(accounts[0])
      cont.should.be.bignumber.equal(1000000)
    })

    it('disallows bid submission if bidder previously bid', async () => {
      let err = false
      try {
        await sale.submitBid(200000000, 0, { from:accounts[0], value:2000000 })
      } catch (e) {
        err = true
      }
      assert.isTrue(err, 'should give an error message since bidder already submited')
    })

    it('should show the correct personal cap for the bidder', async () => {
      const cap = await sale.getPersonalCap.call(accounts[0])
      cap.should.be.bignumber.equal(100000000)
    })

    it('should not accept payment in the fallback function', async () => {
      let err = false
      try {
        await sale.nonExistent(200000000, 0, { from:accounts[7], value:2000000 })
      } catch (e) {
        err = true
      }
      assert.isTrue(err, 'should give an error message when sending ether to the fallback')
    })

    it('should set the valuation to the appropriate bucket', async () => {
      await sale.submitBid(110000000, 100000000, { from:accounts[1], value: 100000000 })
      const value = await sale.getTotalValuation.call()
      value.should.be.bignumber.equal(100000000)
    })

    it('should include a bid with a personal cap equal to valuation prior to withdrawal lock', async () => {
      await sale.submitBid(100000000, 100000000, { from:accounts[3], value: 90000000 })
      const value = await sale.getTotalValuation.call()
      const committed = await sale.getCommittedCapital.call()
      value.should.be.bignumber.equal(100000000)
      committed.should.be.bignumber.equal(191000000)
    })

    it('should not include a bid with a personal cap equal to valuation after withdrawal lock', async () => {
      let err = false
      await increaseTimeTo(endWithdrawlTime)
      try {
        await sale.submitBid(1000000, 0, { from:accounts[4], value: 10 })
      } catch (e) {
        err = true
      }
      assert.isTrue(err, 'should give an error message since cap is too low')
    })
  })

  context('Withdrawing ETH', async () => {
    before(async function () {
      startTime = latestTime() + duration.weeks(200)
      endWithdrawlTime = startTime + duration.weeks(1)
      endTime = startTime + duration.weeks(4)
      afterEndTime = endTime + duration.seconds(1)

      purchaseData = [startTime, 1000000000000000000000, 0]

      sale = await InteractiveCrowdsaleTestContract.new(accounts[0],
                                                       purchaseData,
                                                       20,
                                                       1000000000000000000, // minimum in terms of wei
                                                       endWithdrawlTime,
                                                       endTime,
                                                       50,
                                                       'Jason Token',
                                                       'TBT',
                                                       18,
                                                       false)
    })

    it('calculates withdraw amount correctly', async () => {
      const contrib = 1000000000000000000
      await increaseTimeTo(startTime)
      await sale.submitBid(100000000000000000000, 0, { from: accounts[1], value: contrib })

      const firstPrice = await sale.getPrice.call(accounts[1])
      assert.equal(firstPrice.toNumber(), 1200000000000000000000, 'Accounts[1] should receive a 20% bonus')

      await increaseTimeTo(latestTime() + duration.days(4))
      const percentMultiplier = Math.ceil(((latestTime() - startTime) / (endWithdrawlTime - startTime) * 100))

      await sale.withdrawBid({ from:accounts[1] })
      const newContrib = await sale.getContribution.call(accounts[1])
      assert.equal(Math.ceil((newContrib.toNumber() / contrib) * 100), percentMultiplier,
        'The new contribution is calculated properly.')

      const leftover = await sale.getLeftoverWei.call(accounts[1])
      assert.equal(contrib - newContrib.toNumber(), leftover.toNumber(),
        'LeftoverWei should equal the original contribution minus the amount committed')
    })

    it('accepts a bid with a low cap prior to withdrawal lock', async () => {
      const contrib = 1000
      await sale.submitBid(100000, 0, { from: accounts[4], value: contrib })

      const balance = await sale.getContribution.call(accounts[4])
      balance.should.be.bignumber.equal(contrib)
    })

    it('adjusts the purchase price after withdrawal penalty correctly', async () => {
      const contrib = 50000000000
      await sale.submitBid(150000000000000000000, 100000000000000000000, { from: accounts[2], value: contrib })

      const firstPrice = await sale.getPrice.call(accounts[2])
      assert.equal(firstPrice.toNumber(), 1090000000000000000000, 'Price paid by accounts[2] should be 9% bonus')

      await increaseTimeTo(latestTime() + duration.days(1))
      await sale.withdrawBid({ from: accounts[2] })

      const secondPrice = await sale.getPrice.call(accounts[2])
      assert.equal(secondPrice.toNumber(), 1060000000000000000000, 'Bonus should be reduced by 1/3 to 6% bonus')
    })

    it('denies eth withdrawal after a previous withdrawal', async () => {
      let error = false
      try {
        await sale.withdrawBid({ from:accounts[2] })
      } catch (e) {
        error = true
      }

      assert.isTrue(error, 'Bid withdraw should throw an error if the sender has already manually withdrawn')
    })

    it('denies eth withdrawal after withdrawal lock if the cap is at or above valuation', async () => {
      let error = false
      await sale.submitBid(150000000000000000000, 150000000000000000000, { from: accounts[3], value: 1000 })
      await increaseTimeTo(latestTime() + duration.days(4))

      try {
        await sale.withdrawBid({ from: accounts[3] })
      } catch (e) {
        error = true
      }

      assert.isTrue(error, 'Bid withdraw should throw an error after withdrawal lock')
    })

    it('allows a full withdrawal after the lock if the cap is too low', async () => {
      await sale.withdrawBid({ from:accounts[4] })

      const leftover = await sale.getLeftoverWei.call(accounts[4])
      leftover.should.be.bignumber.equal(1000)
    })

    it('allows a bidder to withdraw their wei', async () => {
      await sale.withdrawLeftoverWei({ from:accounts[4] })

      const leftover = await sale.getLeftoverWei.call(accounts[4])
      leftover.should.be.bignumber.equal(0)
    })
  })

  context('Launching the token', async () => {
    before(async function () {
      startTime = latestTime() + duration.weeks(225)
      endWithdrawlTime = startTime + duration.weeks(1)
      endTime = startTime + duration.weeks(4)
      afterEndTime = endTime + duration.seconds(1)

      purchaseData = [startTime, 1000000000000000000000, 0]

      sale = await InteractiveCrowdsaleTestContract.new(accounts[0],
                                                       purchaseData,
                                                       20,
                                                       1000000000000000000, // minimum in terms of wei
                                                       endWithdrawlTime,
                                                       endTime,
                                                       50,
                                                       'Jason Token',
                                                       'TBT',
                                                       18,
                                                       false)
    })

    it('accepts 100 ETH', async () => {
      const contrib = 10000000000000000000
      await increaseTimeTo(startTime)
      await sale.submitBid(200000000000000000000, 0, { from: accounts[1], value: contrib })

      for (var i = 2; i < 11; i++) {
        await sale.submitBid(200000000000000000000, 200000000000000000000, { from: accounts[i], value: contrib })
      }

      const committed = await sale.getTotalValuation.call()
      committed.should.be.bignumber.equal(100000000000000000000)
    })

    it('should not have a token before finalization', async () => {
      const tokenAddress = await sale.getTokenAddress.call()
      assert.equal(tokenAddress, '0x0000000000000000000000000000000000000000',
        'Token should have address 0 before finalizing the sale.')
    })

    it('moves to after the end time', async () => {
      await increaseTimeTo(afterEndTime)
      const ended = await sale.crowdsaleEnded.call()

      assert.isTrue(ended, 'Crowdsale should show as ended')
    })

    it('launches the new token when finalized', async () => {
      await sale.finalizeSale()

      const tokenAddress = await sale.getTokenAddress.call()
      token = CrowdsaleToken.at(tokenAddress)
      const tokenName = await token.name.call()
      assert.equal(tokenName, 'Jason Token', 'Tokens should be created after the sale is finalized')
    })

    it('launches the correct amount of tokens', async () => {
      // 100 ETH sale value divided by 50% of total tokens sold + bonus tokens
      const calculatedTokens = '220000000000000000000000'

      const initSupply = await token.initialSupply.call()
      initSupply.should.be.bignumber.equal(calculatedTokens)
    })

    it('gives the correct amount of tokens to the owner', async () => {
      const calcOwnerBalance = '100000000000000000000000'
      const ownerBalance = await token.balanceOf.call(accounts[0])
      ownerBalance.should.be.bignumber.equal(calcOwnerBalance)
    })

    it('gives the correct amount of tokens to the contract', async () => {
      const calcContractBalance = '120000000000000000000000'
      const contractBalance = await token.balanceOf.call(sale.address)
      contractBalance.should.be.bignumber.equal(calcContractBalance)
    })

    it('allows owner to withdraw eth from the sale', async () => {
      await sale.withdrawOwnerEth({ from:accounts[0] })
      const bal = await sale.getOwnerBalance.call()
      assert.equal(bal.toNumber(), 0, 'Owner balance should be zero')
    })
  })

  context('Handling a canceled sale', async() => {
    before(async function () {
      startTime = latestTime() + duration.weeks(235)
      endWithdrawlTime = startTime + duration.weeks(2)
      endTime = startTime + duration.weeks(4)
      afterEndTime = endTime + duration.seconds(1)

      purchaseData = [startTime, 1000000000000000000000, 0]

      sale = await InteractiveCrowdsaleTestContract.new(accounts[5],
                                                       purchaseData,
                                                       20,
                                                       1000000000000000000, // minimum in terms of wei
                                                       endWithdrawlTime,
                                                       endTime,
                                                       50,
                                                       'John M Token',
                                                       'JMT',
                                                       18,
                                                       false)
    })

    it('should accept a bid', async () => {
      await increaseTimeTo(startTime)
      await sale.submitBid(10000000000000000000, 0, { from:accounts[0], value:1000000000000000000 })
      const cont = await sale.getContribution.call(accounts[0])
      cont.should.be.bignumber.equal(1000000000000000000)
    })

    it('should deny a withdrawal if the sale is not finalized before 30 days', async () => {
      let err = false
      await increaseTimeTo(afterEndTime)

      try {
        await sale.retreiveFinalResult({ from:accounts[0] })
      } catch (e) {
        err = true
      }

      assert.isTrue(err, 'Retrieval should be denied if the owner hasn\'t finalized the sale')
    })

    it('should give all tokens to the owner after if canceled', async () => {
      await increaseTimeTo(afterEndTime + duration.days(31))
      await sale.finalizeSale({ from:accounts[5] })

      const tokenAddress = await sale.getTokenAddress.call()
      let token = CrowdsaleToken.at(tokenAddress)
      const ownerBalance = await token.balanceOf.call(accounts[5])

      ownerBalance.should.be.bignumber.equal(2000000000000000000000)
    })

    it('should give a full refund to the bidder if canceled', async () => {
      await sale.retreiveFinalResult({ from:accounts[0] })

      const leftover = await sale.getLeftoverWei.call(accounts[0])
      leftover.should.be.bignumber.equal(1000000000000000000)
    })
  })
})
