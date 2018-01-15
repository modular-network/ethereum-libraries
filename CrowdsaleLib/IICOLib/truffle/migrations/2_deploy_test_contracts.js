const BasicMathLib = artifacts.require("./BasicMathLib.sol");
const Array256Lib = artifacts.require("./Array256Lib.sol");
const TokenLib = artifacts.require("./TokenLib.sol");
const CrowdsaleToken = artifacts.require("./CrowdsaleToken.sol");
const CrowdsaleLib = artifacts.require("./CrowdsaleLib.sol");
const InteractiveCrowdsaleLib = artifacts.require("./InteractiveCrowdsaleLib.sol");
const InteractiveCrowdsaleTestContract = artifacts.require("./InteractiveCrowdsaleTestContract.sol");

module.exports = function(deployer, network, accounts) {
  deployer.deploy(BasicMathLib,{overwrite: false});
  deployer.deploy(Array256Lib, {overwrite: false});
  deployer.link(BasicMathLib, TokenLib);
  deployer.deploy(TokenLib, {overwrite: false});
  deployer.link(BasicMathLib,CrowdsaleLib);
  deployer.link(TokenLib,CrowdsaleLib);
  deployer.deploy(CrowdsaleLib, {overwrite: false});
  deployer.link(BasicMathLib,InteractiveCrowdsaleLib);
  deployer.link(TokenLib,InteractiveCrowdsaleLib);
  deployer.link(CrowdsaleLib, InteractiveCrowdsaleLib);
  deployer.deploy(InteractiveCrowdsaleLib, {overwrite:false});
  deployer.link(TokenLib,CrowdsaleToken);
  //deployer.deploy(CrowdsaleToken, accounts[5], "Tester Token", "TST", 18, 20000000000000000000000000, false, {from:accounts[5]});


  if(network == "development" || network == "coverage"){
    deployer.link(BasicMathLib,InteractiveCrowdsaleTestContract);
    deployer.link(CrowdsaleLib,InteractiveCrowdsaleTestContract);
    deployer.link(InteractiveCrowdsaleLib, InteractiveCrowdsaleTestContract);
      // configured to set the token price to $1.41, with a periodic increase in the address cap by 250%
      // var purchaseData =[1654998799,141,100,
      //                    1655000000,200,100];
      // return deployer.deploy(InteractiveCrowdsaleTestContract, accounts[5], purchaseData, 29000, 10000000, 1700000000, 1660000000, 175696000, 50, CrowdsaleToken.address,{from:accounts[5]});
  }
};
