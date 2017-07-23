var HDWalletProvider = require("truffle-hdwallet-provider");

var mnemonic = "refuse blade over muscle crime flat merge fluid comfort faint recycle lobster";
//var provider = new HDWalletProvider(mnemonic, "https://ropsten.infura.io/");
//console.log(provider.getAddress());

module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*"
    }
  }
};
