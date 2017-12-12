module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      gas: 900000000,
      network_id: "*"
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
