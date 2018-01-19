var BasicMathLib = artifacts.require("./BasicMathLib.sol");
var Array256Lib = artifacts.require("./Array256Lib.sol");
var TokenLib = artifacts.require("./TokenLib.sol");
var VestingLib = artifacts.require("./VestingLib.sol");
var VestingLibTokenTestContract = artifacts.require("./VestingLibTokenTestContract");
var VestingLibETHTestContract = artifacts.require("./VestingLibETHTestContract");

// testrpc contracts
var CrowdsaleToken = artifacts.require("./CrowdsaleToken.sol");

module.exports = function(deployer, network, accounts) {
  deployer.deploy(BasicMathLib,{overwrite: false});
  deployer.deploy(Array256Lib, {overwrite: false});
  deployer.link(BasicMathLib, TokenLib);
  deployer.deploy(TokenLib, {overwrite: false});
  deployer.link(BasicMathLib,VestingLib);
  deployer.link(TokenLib, VestingLib);
  deployer.deploy(VestingLib, {overwrite: false});

  if(network == "development" || network === "coverage"){

    deployer.link(TokenLib,CrowdsaleToken);
    deployer.link(BasicMathLib,VestingLibTokenTestContract);
    deployer.link(VestingLib,VestingLibTokenTestContract);

    deployer.link(BasicMathLib,VestingLibETHTestContract);
    deployer.link(VestingLib,VestingLibETHTestContract);

    deployer.deploy(CrowdsaleToken, accounts[5], "Tester Token", "TST", 18, 2000000000000, false, {from:accounts[5]});
  }
};
