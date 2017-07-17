var HDWalletProvider = require("truffle-hdwallet-provider");

var mnemonic = "refuse blade over muscle crime flat merge fluid comfort faint recycle lobster";
//var provider = new HDWalletProvider(mnemonic, "https://ropsten.infura.io/");
//console.log(provider.getAddress());

module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*", // Match any network id
    },
    rinkeby: {
      host: "localhost",
      port: 8545,
      network_id: "4",
      from: "0xc7f2b103e3cdad693ffa37ddec657fc46e8d8633",
      gas: 500000,
      gasPrice: 21000000000
    },
    live: {
      host: "localhost",
      port: 8545,
      network_id: "1",
      from: "0x475ded3e48d0182fd684e3f78a1ee17659482c3b",
      gas: 500000,
      gasPrice: 21000000000
    },
    ropsten: {
      provider: new HDWalletProvider(mnemonic, "https://ropsten.infura.io/"),
      network_id: 3, // official id of the ropsten network
      gas: 500000,
      gasPrice: 21000000000
    }
  }
};
