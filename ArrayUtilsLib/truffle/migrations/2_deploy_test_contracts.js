var ArrayUtilsLib = artifacts.require("./ArrayUtilsLib.sol");
var ArrayUtilsTestContract = artifacts.require("./ArrayUtilsTestContract.sol");

module.exports = function(deployer, network) {
  deployer.deploy(ArrayUtilsLib);

  if(network == "development"){
    deployer.link(ArrayUtilsLib, ArrayUtilsTestContract);
    deployer.deploy(ArrayUtilsTestContract);
  }
};
