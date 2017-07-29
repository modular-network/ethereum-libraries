var StringUtilsLib = artifacts.require("./StringUtilsLib.sol");
var StringUtilsTestContract = artifacts.require("./StringUtilsTestContract.sol");

module.exports = function(deployer, network) {
  deployer.deploy(StringUtilsLib,{overwrite: false});

  if(network == "development"){
    deployer.link(StringUtilsLib, StringUtilsTestContract);
    deployer.deploy(StringUtilsTestContract);
  }

};
