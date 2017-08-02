var BasicMathLib = artifacts.require("./BasicMathLib.sol");
var ArrayUtilsLib = artifacts.require("./ArrayUtilsLib.sol");
var WalletLib = artifacts.require("./WalletLib.sol");
var WalletLibTestContract = artifacts.require("./WalletLibTestContract.sol");
var ERC20Lib = artifacts.require("./ERC20Lib.sol");
var TestToken = artifacts.require("./TestToken.sol");

module.exports = function(deployer, network) {
  deployer.deploy(BasicMathLib,{overwrite: false});
  deployer.deploy(ArrayUtilsLib, {overwrite: false});
  deployer.link(BasicMathLib, WalletLib);
  deployer.link(ArrayUtilsLib, WalletLib);
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
