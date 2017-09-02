var BasicMathLib = artifacts.require("./BasicMathLib.sol");
var Array256Lib = artifacts.require("./Array256Lib.sol");
var WalletMainLib = artifacts.require("./WalletMainLib.sol");
var WalletAdminLib = artifacts.require("./WalletAdminLib.sol");
var WalletGetterLib = artifacts.require("./WalletGetterLib.sol");
var TokenLib = artifacts.require("./TokenLib.sol");
var CrowdsaleToken = artifacts.require("./CrowdsaleToken.sol")
var CrowdsaleLib = artifacts.require("./CrowdsaleLib.sol");
var DirectCrowdsaleLib = artifacts.require("./DirectCrowdsaleLib.sol");
var DirectCrowdsaleTestContract = artifacts.require("./DirectCrowdsaleTestContract.sol");
var WalletLibTestContract = artifacts.require("./WalletLibTestContract.sol");

module.exports = function(deployer, network) {
  deployer.deploy(BasicMathLib,{overwrite: false});
  deployer.deploy(Array256Lib, {overwrite: false});
  deployer.link(BasicMathLib, WalletMainLib);
  deployer.link(Array256Lib, WalletMainLib);
  deployer.deploy(WalletMainLib,{overwrite: false});
  deployer.link(WalletMainLib,WalletAdminLib);
  deployer.link(WalletMainLib,WalletGetterLib);
  deployer.deploy(WalletAdminLib,{overwrite: false});
  deployer.deploy(WalletGetterLib,{overwrite: false});
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
  	deployer.link(WalletMainLib, WalletLibTestContract);
    deployer.link(WalletAdminLib, WalletLibTestContract);
    deployer.link(WalletGetterLib, WalletLibTestContract);
    deployer.deploy(WalletLibTestContract);
  	deployer.link(TokenLib,CrowdsaleToken);
  	deployer.deploy(CrowdsaleToken, "0xb4e205cd196bbe4b1b3767a5e32e15f50eb79623", "Tester Token", "TST", 18, 1000000, true);
  	//deployer.deploy(CrowdsaleToken, WalletLibTestContract.address(), "Tester Token", "TST", 18, 1000000, true);
    deployer.link(DirectCrowdsaleLib, DirectCrowdsaleTestContract);
    deployer.deploy(DirectCrowdsaleTestContract, WalletLibTestContract.address, 0,0,false,CrowdsaleToken.address());
    
  }
};
