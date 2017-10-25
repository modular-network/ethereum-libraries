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
      gas: 270000000000000,
      from: "0x40333d950b4c682e8aad143c216af52877d828bf",
      network_id: "*",
      gas: 0xfffffffffff,
      gasPrice: 0x01
    },
  }
};
