var BasicMathLib = artifacts.require("./BasicMathLib.sol");
var ERC20Lib = artifacts.require("./ERC20Lib.sol");
var ERC20LibTestContract = artifacts.require("./ERC20LibTestContract");

module.exports = function(deployer, network) {
  deployer.deploy(BasicMathLib,{overwrite: false});
  deployer.link(BasicMathLib, ERC20Lib);
  deployer.deploy(ERC20Lib, {overwrite: false});

  if(network == "development"){
    deployer.link(ERC20Lib, ERC20LibTestContract);
    deployer.deploy(ERC20LibTestContract);
  }
};
