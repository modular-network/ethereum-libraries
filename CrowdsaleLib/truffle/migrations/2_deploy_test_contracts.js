var BasicMathLib = artifacts.require("./BasicMathLib.sol");
var Array256Lib = artifacts.require("./Array256Lib.sol");
var WalletMainLib = artifacts.require("./WalletMainLib.sol");
var WalletAdminLib = artifacts.require("./WalletAdminLib.sol");
var WalletGetterLib = artifacts.require("./WalletGetterLib.sol");
var TokenLib = artifacts.require("./TokenLib.sol");
var CrowdsaleToken = artifacts.require("./CrowdsaleToken.sol");
var CrowdsaleLib = artifacts.require("./TestCrowdsaleLib.sol");   // ./TestCrowdsaleLib for testrpc testing, ./CrowdsaleLib for network testing
var DirectCrowdsaleLib = artifacts.require("./TestDirectCrowdsaleLib.sol");  //  ./TestDirectCrowdsaleLib for testrpc testing, ./DirectCrowdsaleLib for network testing
var TimeDirectCrowdsaleTestContract = artifacts.require("./TimeDirectCrowdsaleTestContract.sol");
var WalletLibTestContract = artifacts.require("./WalletLibTestContract.sol");
var walletAddress;

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
    deployer.link(TokenLib,CrowdsaleToken);
    deployer.link(CrowdsaleLib,TimeDirectCrowdsaleTestContract);
    deployer.link(DirectCrowdsaleLib, TimeDirectCrowdsaleTestContract);
    deployer.deploy(WalletLibTestContract).then(function() {
      walletAddress = WalletLibTestContract.address;
   		return deployer.deploy(CrowdsaleToken, "0x36994c7cff11859ba8b9715120a68aa9499329ee", "Tester Token", "TST", 18, 1000000, true);
	  }).then(function() {
      // right now it is configured to use accounts[5] as the owner and for the token price to increase periodically by 50 cents
      return deployer.deploy(TimeDirectCrowdsaleTestContract, "0x36994c7cff11859ba8b9715120a68aa9499329ee", 100, 50, 20000000000000000000000, 105, 120, [75,100], 5, CrowdsaleToken.address);
 	  });   
  }
};
