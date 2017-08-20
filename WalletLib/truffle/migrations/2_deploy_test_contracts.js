var BasicMathLib = artifacts.require("./BasicMathLib.sol");
var Array256Lib = artifacts.require("./Array256Lib.sol");
var WalletLib = artifacts.require("./WalletLib.sol");
var WalletLibTestContract = artifacts.require("./WalletLibTestContract.sol");
var ERC20Lib = artifacts.require("./ERC20Lib.sol");
var TestToken = artifacts.require("./TestToken.sol");

module.exports = function(deployer, network) {
  deployer.deploy(BasicMathLib,{overwrite: false});
  deployer.deploy(Array256Lib, {overwrite: false});
  deployer.link(BasicMathLib, WalletLib);
  deployer.link(Array256Lib, WalletLib);
  deployer.deploy(WalletLib,{overwrite: false});
  deployer.link(BasicMathLib, ERC20Lib);
  deployer.deploy(ERC20Lib, {overwrite: false});

  if(network == "development"){
    deployer.link(WalletLib, WalletLibTestContract);
    deployer.deploy(WalletLibTestContract);
    deployer.link(ERC20Lib, TestToken);
    deployer.deploy(TestToken);
  }
};
