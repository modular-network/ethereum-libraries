var BasicMathLib = artifacts.require("./BasicMathLib.sol");
var CrowdsaleLib = artifacts.require("./CrowdsaleLib.sol");
//var CrowdsaleLibTestContract = artifacts.require("./CrowdsaleLibTestContract");

module.exports = function(deployer, network) {
  deployer.deploy(BasicMathLib,{overwrite: false});
  deployer.link(BasicMathLib, TokenLib);
  //deployer.deploy(TokenLib, {overwrite: false});
  deployer.deploy(CrowdsaleLib, {overwrite: false});

  if(network == "development"){
    //deployer.link(CrowdsaleLib, CrowdsaleLibTestContract);
    //deployer.deploy(TokenLibTestContract, "0xb4e205cd196bbe4b1b3767a5e32e15f50eb79623", "Tester Token", "TST", 18, 100, true);
  }
};
