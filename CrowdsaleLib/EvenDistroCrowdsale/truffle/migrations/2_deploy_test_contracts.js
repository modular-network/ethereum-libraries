var BasicMathLib = artifacts.require("./BasicMathLib.sol");
var Array256Lib = artifacts.require("./Array256Lib.sol");
var TokenLib = artifacts.require("./TokenLib.sol");
var CrowdsaleToken = artifacts.require("./CrowdsaleToken.sol");
var CrowdsaleLib = artifacts.require("./CrowdsaleLib.sol");
var EvenDistroCrowdsaleLib = artifacts.require("./EvenDistroCrowdsaleLib.sol");
var EvenDistroCrowdsaleTestContract = artifacts.require("./EvenDistroCrowdsaleTestContract.sol");

//testrpc contracts
//var CrowdsaleToken2 = artifacts.require("./CrowdsaleToken.sol");
var TestCrowdsaleLib = artifacts.require("./TestCrowdsaleLib.sol");
var TestEvenDistroCrowdsaleLib = artifacts.require("./TestEvenDistroCrowdsaleLib.sol");
var TimeEvenDistroCrowdsaleTestContract = artifacts.require("./TimeEvenDistroCrowdsaleTestContract.sol");
//var TimeEvenDistroCTCnoChangeFullRegistration = artifacts.require("./TimeEvenDistroCrowdsaleTestContract.sol");

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
    // deployer.link(TokenLib,CrowdsaleToken2);
    deployer.link(TestCrowdsaleLib,TimeEvenDistroCrowdsaleTestContract);
    deployer.link(TestEvenDistroCrowdsaleLib, TimeEvenDistroCrowdsaleTestContract);
    // deployer.link(TestCrowdsaleLib,TimeEvenDistroCTCnoChangeFullRegistration);
    // deployer.link(TestEvenDistroCrowdsaleLib, TimeEvenDistroCTCnoChangeFullRegistration);
    deployer.deploy(CrowdsaleToken, accounts[5], "Tester Token", "TST", 18, 20000000000000000000000000, false, {from:accounts[5]}).then(function() {
      // configured to set the token price to $1.41, with a periodic increase in the address cap by 250%
 	    return deployer.deploy(TimeEvenDistroCrowdsaleTestContract, accounts[5], 1700000000, 105, 125, 141, 29000, 250, 100000000000000000000, 5, 50, CrowdsaleToken.address,{from:accounts[5]});
      //return deployer.deploy(TimeEvenDistroCrowdsaleTestContract, accounts[5], 1700000000, 105, 125, 141, 29000, 100, 1.465525e+22, 0, 50, CrowdsaleToken.address,{from:accounts[5]});
    });
    // deployer.deploy(CrowdsaleToken2, accounts[5], "Tester Toke", "TST", 18, 20000000000000000000000000, false, {from:accounts[5]}).then(function() {
    //   // configured to set the token price to $1.41, which a static address cap for the entire sale
    //   return deployer.deploy(TimeEvenDistroCTCnoChangeFullRegistration, accounts[5], 1700000000, 105, 125, 141, 29000, 0, 100000000000000000000, 0, 50, CrowdsaleToken2.address,{from:accounts[5]});
    // });
  }
};
