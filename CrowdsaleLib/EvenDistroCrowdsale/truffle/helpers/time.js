// Taken from wingsDAO/contracts
// copyright WINGS foundation

const Promise = require('bluebird')

const moveTime = (web3, value) => {
  return new Promise((resolve, reject) => {
    web3.currentProvider.sendAsync({
      jsonrpc: "2.0",
      method: "evm_increaseTime",
      params: [value],
      id: new Date().getTime()
    }, (err, result) => {
      err? reject(err) : resolve()
    })
  })
}

const currentTime = () => {
  return Math.floor(new Date().getTime() / 1000);
}

const toSeconds = (seconds) => {
  return Math.floor(seconds / 1000)
}

const blockchainTime = (web3) => {
  return new Promise((resolve, reject) => {
    const block = web3.eth.getBlock(web3.eth.blockNumber)
    return resolve(block.timestamp)
  })
}

module.exports = {
  move: moveTime,
  now: currentTime,
  toSeconds: toSeconds,
  blockchainTime: blockchainTime
}
