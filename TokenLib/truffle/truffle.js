module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 7545,
      network_id: "*"
    },
    coverage: {
      host: "localhost",
      port: 8555,
      network_id: "*",
      gas: 0xfffffffffff,
      gasPrice: 0x01
    },
    ropsten: {
      host: "localhost",
      port: 8545,
      network_id: "3",
      from: "0x21c1c99bea83d5d35d3d1cac38e2591e0dee854d",
      gas: 4500000,
      gasPrice: 21000000000
    },
    rinkeby: {
      host: "localhost",
      port: 8545,
      network_id: "4",
      from: "0x4e31a4c6233ffeb5cb4806c04acd7bb4324eaaf4",
      gas: 4500000,
      gasPrice: 21000000000
    },
    live: {
      host: "localhost",
      port: 8545,
      network_id: "1",
      from: "0x475ded3e48d0182fd684e3f78a1ee17659482c3b",
      gas: 2500000,
      gasPrice: 11000000000
    }
  },
};
