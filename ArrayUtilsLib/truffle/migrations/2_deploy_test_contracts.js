var Array256Lib = artifacts.require("./Array256Lib.sol");
var Array128Lib = artifacts.require("./Array128Lib.sol");
var Array64Lib = artifacts.require("./Array64Lib.sol");
var Array32Lib = artifacts.require("./Array32Lib.sol");
var Array16Lib = artifacts.require("./Array16Lib.sol");
var Array8Lib = artifacts.require("./Array8Lib.sol");
var ArrayUtilsTestContract = artifacts.require("./ArrayUtilsTestContract.sol");
var ArrayUtilsTestContractTwo = artifacts.require("./ArrayUtilsTestContractTwo.sol");
var ArrayUtilsTestContractThree = artifacts.require("./ArrayUtilsTestContractThree.sol");

module.exports = function(deployer, network) {
  deployer.deploy(Array256Lib, {overwrite: false});
  deployer.deploy(Array128Lib, {overwrite: false});
  deployer.deploy(Array64Lib, {overwrite: false});
  deployer.deploy(Array32Lib, {overwrite: false});
  deployer.deploy(Array16Lib, {overwrite: false});
  deployer.deploy(Array8Lib, {overwrite: false});

  if(network === "development" || network === "coverage"){
    deployer.link(Array256Lib, ArrayUtilsTestContract);
    deployer.link(Array128Lib, ArrayUtilsTestContract);
    deployer.link(Array64Lib, ArrayUtilsTestContract);
    deployer.link(Array32Lib, ArrayUtilsTestContract);
    deployer.link(Array16Lib, ArrayUtilsTestContract);
    deployer.link(Array8Lib, ArrayUtilsTestContract);
    deployer.deploy(ArrayUtilsTestContract);

    deployer.link(Array256Lib, ArrayUtilsTestContractTwo);
    deployer.link(Array128Lib, ArrayUtilsTestContractTwo);
    deployer.link(Array64Lib, ArrayUtilsTestContractTwo);
    deployer.link(Array32Lib, ArrayUtilsTestContractTwo);
    deployer.link(Array16Lib, ArrayUtilsTestContractTwo);
    deployer.link(Array8Lib, ArrayUtilsTestContractTwo);
    deployer.deploy(ArrayUtilsTestContractTwo);

    deployer.link(Array256Lib, ArrayUtilsTestContractThree);
    deployer.link(Array128Lib, ArrayUtilsTestContractThree);
    deployer.link(Array64Lib, ArrayUtilsTestContractThree);
    deployer.link(Array32Lib, ArrayUtilsTestContractThree);
    deployer.link(Array16Lib, ArrayUtilsTestContractThree);
    deployer.link(Array8Lib, ArrayUtilsTestContractThree);
    deployer.deploy(ArrayUtilsTestContractThree);
  }
};
