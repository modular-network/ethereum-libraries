//var BasicMathLib = artifacts.require("./BasicMathLib.sol");
var LinkedListLib = artifacts.require("./LinkedListLib.sol");
var LinkedListTestContract = artifacts.require("./LinkedListTestContract.sol");

module.exports = function(deployer, network) {
  //deployer.deploy(BasicMathLib,{overwrite: false});
  //deployer.link(BasicMathLib,LinkedListLib);
  deployer.deploy(LinkedListLib,{overwrite: false});

  if(network == "development"){
    //deployer.link(BasicMathLib, LinkedListTestContract);
    deployer.link(LinkedListLib, LinkedListTestContract);
    deployer.deploy(LinkedListTestContract);
  }
};
