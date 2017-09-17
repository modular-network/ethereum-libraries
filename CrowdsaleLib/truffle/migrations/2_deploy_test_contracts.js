var BasicMathLib = artifacts.require("./BasicMathLib.sol");
var Array256Lib = artifacts.require("./Array256Lib.sol");
//var WalletMainLib = artifacts.require("./WalletMainLib.sol");
//var WalletAdminLib = artifacts.require("./WalletAdminLib.sol");
//var WalletGetterLib = artifacts.require("./WalletGetterLib.sol");
var TokenLib = artifacts.require("./TokenLib.sol");
var CrowdsaleToken = artifacts.require("./CrowdsaleToken.sol");
var CrowdsaleLib = artifacts.require("./CrowdsaleLib.sol");   // ./TestCrowdsaleLib for testrpc testing, ./CrowdsaleLib for network testing
var DirectCrowdsaleLib = artifacts.require("./DirectCrowdsaleLib.sol");  //  ./TestDirectCrowdsaleLib for testrpc testing, ./DirectCrowdsaleLib for network testing
var DirectCrowdsaleTestContract = artifacts.require("./DirectCrowdsaleTestContract.sol");
//var WalletLibTestContract = artifacts.require("./WalletLibTestContract.sol");
//var walletAddress;

module.exports = function(deployer, network, accounts) {
  deployer.deploy(BasicMathLib,{overwrite: false});
  deployer.deploy(Array256Lib, {overwrite: false});
  //deployer.link(BasicMathLib, WalletMainLib);
  //deployer.link(Array256Lib, WalletMainLib);
  //deployer.deploy(WalletMainLib,{overwrite: false});
  //deployer.link(WalletMainLib,WalletAdminLib);
  //deployer.link(WalletMainLib,WalletGetterLib);
  //deployer.deploy(WalletAdminLib,{overwrite: false});
  //deployer.deploy(WalletGetterLib,{overwrite: false});
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
  	//deployer.link(WalletMainLib, WalletLibTestContract);
    //deployer.link(WalletAdminLib, WalletLibTestContract);
    //deployer.link(WalletGetterLib, WalletLibTestContract);
    deployer.link(TokenLib,CrowdsaleToken);
    deployer.link(CrowdsaleLib,DirectCrowdsaleTestContract);
    deployer.link(DirectCrowdsaleLib, DirectCrowdsaleTestContract);
    //deployer.deploy(WalletLibTestContract).then(function() {
      //walletAddress = WalletLibTestContract.address;
    deployer.deploy(CrowdsaleToken, accounts[5], "Tester Token", "TST", 18, 1000000, true,{from:accounts[5]}).then(function() {
      // right now it is configured to use accounts[5] as the owner and for the token price to increase periodically by 50 cents
      //return deployer.deploy(DirectCrowdsaleTestContract, "0x36994c7cff11859ba8b9715120a68aa9499329ee", 20000000000000000000000, 1505203200, 1505462400, [50,75,100], 86400, CrowdsaleToken.address);
 	    return deployer.deploy(TimeDirectCrowdsaleTestContract, accounts[5], 100, 20000000000000000000000, 105, 125, [50,75,100], 29000, 5, CrowdsaleToken.address,{from:accounts[5]});
    });   
  }

  if(network == "rinkeby") {
    deployer.link(TokenLib,CrowdsaleToken);
    deployer.link(CrowdsaleLib,DirectCrowdsaleTestContract);
    deployer.link(DirectCrowdsaleLib, DirectCrowdsaleTestContract);
    //deployer.deploy(WalletLibTestContract).then(function() {
      //walletAddress = WalletLibTestContract.address;
    deployer.deploy(CrowdsaleToken, "0x3f33c3d3ae37fdd0e1227a424add8b67f49232c0", "Tester Token", "TST", 18, 1000000, true,{from:"0x3f33c3d3ae37fdd0e1227a424add8b67f49232c0"}).then(function() {
      // right now it is configured to use accounts[5] as the owner and for the token price to increase periodically by 50 cents
      //return deployer.deploy(DirectCrowdsaleTestContract, "0x36994c7cff11859ba8b9715120a68aa9499329ee", 20000000000000000000000, 1505203200, 1505462400, [50,75,100], 86400, CrowdsaleToken.address);
      return deployer.deploy(DirectCrowdsaleTestContract, "0x3f33c3d3ae37fdd0e1227a424add8b67f49232c0", 20000000000000000000000, 1505664000, 1505923200, [50,75,100], 29000, 86400, CrowdsaleToken.address,{from:"0x3f33c3d3ae37fdd0e1227a424add8b67f49232c0"});
    });
  }
};
