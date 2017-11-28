var BasicMathLib = artifacts.require("./BasicMathLib.sol");
var BasicMathTestContract = artifacts.require("./BasicMathTestContract.sol");

module.exports = function(deployer, network) {
  deployer.deploy(BasicMathLib,{overwrite: false});

  if(network === "development" || network === "coverage"){
    deployer.link(BasicMathLib, BasicMathTestContract);
    deployer.deploy(BasicMathTestContract);
  }
};
