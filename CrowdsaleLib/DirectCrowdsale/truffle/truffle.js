module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*"
    },
    coverage: {
      host: "localhost",
      port: 8555,
      from: "0x40333d950b4c682e8aad143c216af52877d828bf",
      network_id: "*",
      gas: 0xfffffffffff,
      gasPrice: 0x01
    },
  }
};
