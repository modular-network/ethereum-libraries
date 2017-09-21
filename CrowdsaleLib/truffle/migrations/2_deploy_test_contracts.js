var BasicMathLib = artifacts.require("./BasicMathLib.sol");
var Array256Lib = artifacts.require("./Array256Lib.sol");
var TokenLib = artifacts.require("./TokenLib.sol");
var CrowdsaleToken = artifacts.require("./CrowdsaleToken.sol");
var CrowdsaleLib = artifacts.require("./CrowdsaleLib.sol");
var DirectCrowdsaleLib = artifacts.require("./DirectCrowdsaleLib.sol");
var DirectCrowdsaleTestContract = artifacts.require("./DirectCrowdsaleTestContract.sol");

//testrpc contracts
var TestCrowdsaleLib = artifacts.require("./TestCrowdsaleLib.sol");
var TestDirectCrowdsaleLib = artifacts.require("./TestDirectCrowdsaleLib.sol");
var TimeDirectCrowdsaleTestContract = artifacts.require("./TimeDirectCrowdsaleTestContract.sol");

module.exports = function(deployer, network, accounts) {
  deployer.deploy(BasicMathLib,{overwrite: false});
  deployer.deploy(Array256Lib, {overwrite: false});
  deployer.link(BasicMathLib, TokenLib);
  deployer.deploy(TokenLib, {overwrite: false});
  deployer.link(BasicMathLib,CrowdsaleLib);
  deployer.link(TokenLib,CrowdsaleLib);
  deployer.deploy(CrowdsaleLib, {overwrite: false});
  deployer.link(BasicMathLib,DirectCrowdsaleLib);
  deployer.link(TokenLib,DirectCrowdsaleLib);
  deployer.link(CrowdsaleLib,DirectCrowdsaleLib);
  deployer.deploy(DirectCrowdsaleLib, {overwrite:false});

  if(network == "development"){
    deployer.link(BasicMathLib,TestCrowdsaleLib);
    deployer.link(TokenLib,TestCrowdsaleLib);
    deployer.deploy(TestCrowdsaleLib);
    deployer.link(BasicMathLib,TestDirectCrowdsaleLib);
    deployer.link(TokenLib,TestDirectCrowdsaleLib);
    deployer.link(TestCrowdsaleLib,TestDirectCrowdsaleLib);
    deployer.deploy(TestDirectCrowdsaleLib);
    deployer.link(TokenLib,CrowdsaleToken);
    deployer.link(TestCrowdsaleLib,TimeDirectCrowdsaleTestContract);
    deployer.link(TestDirectCrowdsaleLib, TimeDirectCrowdsaleTestContract);
    deployer.deploy(CrowdsaleToken, accounts[5], "Tester Token", "TST", 18, 20000000000000000000000000, false, {from:accounts[5]}).then(function() {
      // right now it is configured to use accounts[5] as the owner and for the token price to increase periodically by 50 cents
 	    return deployer.deploy(TimeDirectCrowdsaleTestContract, accounts[5], 100, 1700000000, 105, 125, [141,155,165], 29000, 5, 50, CrowdsaleToken.address,{from:accounts[5]});
    });
  }

  if(network == "rinkeby") {
    deployer.link(TokenLib,CrowdsaleToken);
    deployer.link(CrowdsaleLib,DirectCrowdsaleTestContract);
    deployer.link(DirectCrowdsaleLib, DirectCrowdsaleTestContract);
    /*deployer.deploy(CrowdsaleToken, "0x3f33c3d3ae37fdd0e1227a424add8b67f49232c0", "Tester Token", "TST", 18, 1000000, true,{from:"0x3f33c3d3ae37fdd0e1227a424add8b67f49232c0"}).then(function() {
      // right now it is configured to use accounts[5] as the owner and for the token price to increase periodically by 50 cents
      //return deployer.deploy(DirectCrowdsaleTestContract, "0x36994c7cff11859ba8b9715120a68aa9499329ee", 20000000000000000000000, 1505203200, 1505462400, [50,75,100], 86400, CrowdsaleToken.address);
      return deployer.deploy(DirectCrowdsaleTestContract, "0x3f33c3d3ae37fdd0e1227a424add8b67f49232c0", 20000000000000000000000, 1505664000, 1505923200, [50,75,100], 29000, 86400, CrowdsaleToken.address,{from:"0x3f33c3d3ae37fdd0e1227a424add8b67f49232c0"});
    });*/
  }
};
