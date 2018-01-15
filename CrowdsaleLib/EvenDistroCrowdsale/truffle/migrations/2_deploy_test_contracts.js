var BasicMathLib = artifacts.require("./BasicMathLib.sol");
var Array256Lib = artifacts.require("./Array256Lib.sol");
var TokenLib = artifacts.require("./TokenLib.sol");
var CrowdsaleLib = artifacts.require("./CrowdsaleLib.sol");
var EvenDistroCrowdsaleLib = artifacts.require("./EvenDistroCrowdsaleLib.sol");

var CrowdsaleTestTokenEteenD = artifacts.require("./CrowdsaleTestTokenEteenD");
var EvenDistroTestEteenD = artifacts.require("./EvenDistroTestEteenD.sol");
var CrowdsaleTestTokenTenD = artifacts.require("./CrowdsaleTestTokenTenD");
var EvenDistroTestTenD = artifacts.require("./EvenDistroTestTenD.sol");

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

  if(network === "development" || network === "coverage"){
    deployer.link(TokenLib,CrowdsaleTestTokenEteenD);
    deployer.link(CrowdsaleLib,EvenDistroTestEteenD);
    deployer.link(EvenDistroCrowdsaleLib, EvenDistroTestEteenD);

    deployer.link(TokenLib,CrowdsaleTestTokenTenD);
    deployer.link(CrowdsaleLib,EvenDistroTestTenD);
    deployer.link(EvenDistroCrowdsaleLib, EvenDistroTestTenD);

    // startTime 3 days + 1 hour in the future
    var startTime = (Math.floor((new Date().valueOf()/1000))) + 262800;
    // first price step in 7 days
    var stepOne = startTime + 604800;
    // second price step in 14 days
    var stepTwo = stepOne + 604800;
    // endTime in 30 days
    var endTime = startTime + 2592000;
    deployer.deploy(CrowdsaleTestTokenEteenD,
                    accounts[0],
                    "Eighteen Decimals",
                    "ETEEN",
                    18,
                    50000000000000000000000000,
                    false,
                    {from:accounts[5]})
    .then(function() {
      var purchaseData =[startTime,600000000000000000000,100,
                         stepOne,600000000000000000000,100,
                         stepTwo,300000000000000000000,0];
 	    return deployer.deploy(EvenDistroTestEteenD,
                             accounts[5],
                             purchaseData,
                             endTime,
                             100,
                             10000000000000000000000,
                             false,
                             CrowdsaleTestTokenEteenD.address,
                             {from:accounts[5]})
    })
    .then(function(){
      return deployer.deploy(CrowdsaleTestTokenTenD,
                             accounts[0],
                             "Ten Decimals",
                             "TEN",
                             10,
                             1000000000000000,
                             false,
                             {from:accounts[5]})
    })
    .then(function() {
      // start next sale in 7 days
      startTime = endTime + 604800;
      stepOne = startTime + 604800;
      stepTwo = stepOne + 604800;
      endTime = startTime + 2592000;

      purchaseData =[startTime,4000000000000,0,
                     stepOne,8000000000000,20000000000000,
                     stepTwo,16000000000000,0];
 	    return deployer.deploy(EvenDistroTestTenD,
                             accounts[0],
                             purchaseData,
                             endTime,
                             25,
                             0,
                             true,
                             CrowdsaleTestTokenTenD.address,
                             {from:accounts[5]})
    });
  }
};
