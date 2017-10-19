var BasicMathLib = artifacts.require("./BasicMathLib.sol");
var Array256Lib = artifacts.require("./Array256Lib.sol");
var TokenLib = artifacts.require("./TokenLib.sol");
var VestingLib = artifacts.require("./VestingLib.sol");

// testrpc contracts
var CrowdsaleToken = artifacts.require("./CrowdsaleToken.sol");
var TestVestingLib = artifacts.require("./TestVestingLib.sol");
var TimeVestingLibTokenTestContract = artifacts.require("./TimeVestingLibTokenTestContract");
var TimeVestingLibETHTestContract = artifacts.require("./TimeVestingLibETHTestContract.sol");

module.exports = function(deployer, network, accounts) {
  deployer.deploy(BasicMathLib,{overwrite: false});
  deployer.deploy(Array256Lib, {overwrite: false});
  deployer.link(BasicMathLib, TokenLib);
  deployer.deploy(TokenLib, {overwrite: false});
  deployer.link(BasicMathLib,VestingLib);
  deployer.link(TokenLib, VestingLib);
  deployer.deploy(VestingLib, {overwrite: false});

  if(network == "development"){
    deployer.link(BasicMathLib,TestVestingLib);
    deployer.link(TokenLib,TestVestingLib);
    deployer.deploy(TestVestingLib, {overwrite:false});

    deployer.link(TokenLib,CrowdsaleToken);
    deployer.link(BasicMathLib,TimeVestingLibTokenTestContract);
    deployer.link(TestVestingLib,TimeVestingLibTokenTestContract);

    deployer.link(BasicMathLib,TimeVestingLibETHTestContract);
    deployer.link(TestVestingLib,TimeVestingLibETHTestContract);

    deployer.deploy(CrowdsaleToken, accounts[5], "Tester Token", "TST", 18, 20000000000000000000000000, false, {from:accounts[5]});

    deployer.deploy(TimeVestingLibTokenTestContract,accounts[5],true,105,150,5);

    deployer.deploy(TimeVestingLibETHTestContract,accounts[5],false,105,150,5);
  }
};
