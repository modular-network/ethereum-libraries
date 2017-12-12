module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*",
      gas: 0xfffffffffff,
      gasPrice: 0x01
    },
    coverage: {
      host: "localhost",
      port: 8555,
      network_id: "*",
      gas: 0xfffffffffff,
      gasPrice: 0x01
    },
  }
};
