var BasicMathLib = artifacts.require("./BasicMathLib.sol");
var Array256Lib = artifacts.require("./Array256Lib.sol");
var TokenLib = artifacts.require("./TokenLib.sol");
var CrowdsaleLib = artifacts.require("./CrowdsaleLib.sol");
var EvenDistroCrowdsaleLib = artifacts.require("./EvenDistroCrowdsaleLib.sol");
var EvenDistroCrowdsaleTestContract = artifacts.require("./EvenDistroCrowdsaleTestContract.sol");

//testrpc contracts
var TestCrowdsaleLib = artifacts.require("./TestCrowdsaleLib.sol");
var TestEvenDistroCrowdsaleLib = artifacts.require("./TestEvenDistroCrowdsaleLib.sol");

var CrowdsaleToken = artifacts.require("./CrowdsaleToken.sol");
var TimeEvenDistroCrowdsaleTestContract = artifacts.require("./TimeEvenDistroCrowdsaleTestContract.sol");

var CrowdsaleToken2 = artifacts.require("./CrowdsaleToken2.sol");
var TimeEvenDistroCrowdsaleTestContract2 = artifacts.require("./TimeEvenDistroCrowdsaleTestContract2.sol");

module.exports = function(deployer, network, accounts) {
  deployer.deploy(BasicMathLib,{overwrite: false});
  deployer.deploy(Array256Lib, {overwrite: false});
  deployer.link(BasicMathLib, TokenLib);
  deployer.deploy(TokenLib, {overwrite: false});
  deployer.link(BasicMathLib,CrowdsaleLib);
  deployer.link(TokenLib,CrowdsaleLib);
  deployer.deploy(CrowdsaleLib, {overwrite: false});
  deployer.link(BasicMathLib,EvenDistroCrowdsaleLib);
  deployer.link(TokenLib,EvenDistroCrowdsaleLib);
  deployer.link(CrowdsaleLib,EvenDistroCrowdsaleLib);
  deployer.deploy(EvenDistroCrowdsaleLib, {overwrite:false});

  if(network == "development"){
    deployer.link(BasicMathLib,TestCrowdsaleLib);
    deployer.link(TokenLib,TestCrowdsaleLib);
    deployer.deploy(TestCrowdsaleLib);
    deployer.link(BasicMathLib,TestEvenDistroCrowdsaleLib);
    deployer.link(TokenLib,TestEvenDistroCrowdsaleLib);
    deployer.link(TestCrowdsaleLib,TestEvenDistroCrowdsaleLib);
    deployer.deploy(TestEvenDistroCrowdsaleLib);
    deployer.link(TokenLib,CrowdsaleToken);
    deployer.link(TestCrowdsaleLib,TimeEvenDistroCrowdsaleTestContract);
    deployer.link(TestEvenDistroCrowdsaleLib, TimeEvenDistroCrowdsaleTestContract);
    deployer.link(TokenLib,CrowdsaleToken2);
    deployer.link(TestCrowdsaleLib,TimeEvenDistroCrowdsaleTestContract2);
    deployer.link(TestEvenDistroCrowdsaleLib, TimeEvenDistroCrowdsaleTestContract2);
    deployer.deploy(CrowdsaleToken, accounts[5], "Tester Token", "TST", 18, 20000000000000000000000000, false, {from:accounts[5]}).then(function() {
      // configured to set the token price to $1.41, with a periodic increase in the address cap by 250%
      var purchaseData =[105,141,100,
                         110,141,250,
                         115,141,625];
      return deployer.deploy(TimeEvenDistroCrowdsaleTestContract, accounts[5], 100, purchaseData, 29000, 1700000000, 125, 50, 50000, false, CrowdsaleToken.address,{from:accounts[5]});
    });
    deployer.deploy(CrowdsaleToken2, accounts[5], "Tester Token", "TST", 0, 500000000, false, {from:accounts[5]}).then(function() {
      // configured to set the token price to $1.41, with a periodic increase in the address cap by 250%
      var purchaseData2 =[105,50,50000,
                         135,75,50000];
      return deployer.deploy(TimeEvenDistroCrowdsaleTestContract2, accounts[5], 100, purchaseData2, 29000, 40000000000, 165, 100, 50000, true, CrowdsaleToken2.address,{from:accounts[5]});
    });
  }
};
