module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      gas: 270000000000000,
      from: "0x40333d950b4c682e8aad143c216af52877d828bf",
      network_id: "*"
    },
    rinkeby: {
      host: "localhost",
      port: 8545,
      gas: 6000000,
      gasPrice: 21000000000,
      from: "0x3f33c3d3ae37fdd0e1227a424add8b67f49232c0",
      network_id: "4"
    }
  }
};
