var LinkedListTestContract = artifacts.require("./LinkedListTestContract.sol");

module.exports = function(deployer, network) {
  deployer.deploy(LinkedListTestContract);
};
