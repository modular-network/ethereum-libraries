var BasicMathLib = artifacts.require("./BasicMathLib.sol");
var TokenLib = artifacts.require("./TokenLib.sol");
var TokenLibTestContract = artifacts.require("./TokenLibTestContract");

module.exports = function(deployer, network, accounts) {
  deployer.deploy(BasicMathLib,{overwrite: false});
  deployer.link(BasicMathLib, TokenLib);
  deployer.deploy(TokenLib, {overwrite: false});

  if(network === "development" || network === "coverage"){
    deployer.link(TokenLib, TokenLibTestContract);
    deployer.deploy(TokenLibTestContract, "0xb4e205cd196bbe4b1b3767a5e32e15f50eb79623", "Tester Token", "TST", 18, 100, true);
  }
};
