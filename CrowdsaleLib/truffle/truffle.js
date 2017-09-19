//var HDWalletProvider = require("truffle-hdwallet-provider");

var mnemonic = "refuse blade over muscle crime flat merge fluid comfort faint recycle lobster";
//var provider = new HDWalletProvider(mnemonic, "https://ropsten.infura.io/");
//console.log(provider.getAddress());

module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      gas: 47000000,
      network_id: "*", // Match any network id
    },
    rinkeby: {
      host: "localhost",
      port: 8545,
      network_id: "4",
      from: "0x3f33c3d3ae37fdd0e1227a424add8b67f49232c0",
      //from: "0x7095e54a0745fa737abefc85cb162ee03851e98b",
      gas: 4700000,
      gasPrice: 21000000000
    },
    live: {
      host: "localhost",
      port: 8545,
      network_id: "1",
      from: "0x3f33c3d3ae37fdd0e1227a424add8b67f49232c0",
      gas: 500000,
      gasPrice: 21000000000
    },
    ropsten: {
      //provider: new HDWalletProvider(mnemonic, "https://ropsten.infura.io/"),
      network_id: 3, // official id of the ropsten network
      gas: 500000,
      gasPrice: 21000000000
    }
  }
};
