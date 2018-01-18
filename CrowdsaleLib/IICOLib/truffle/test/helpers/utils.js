/* global assert */
function isException (error) {
  let strError = error.toString()
  return strError.includes('invalid opcode') || strError.includes('invalid JUMP')
}

function ensuresException (error) {
  assert(isException(error), error.toString())
}

/** Returns last block's timestamp */
function getBlockNow () {
  return web3.eth.getBlock(web3.eth.blockNumber).timestamp // base timestamp off the blockchain
}

const BigNumber = web3.BigNumber
const should = require('chai')
    .use(require('chai-as-promised'))
    .use(require('chai-bignumber')(BigNumber))
    .should()

module.exports = {
  isException,
  ensuresException,
  getBlockNow,
  should
}
