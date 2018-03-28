var TokenLibTestContract = artifacts.require("TokenLibTestContract");
var Web3 = require('web3');
var web3 = new Web3(Web3.givenProvider || "ws://localhost:8545");

contract('TokenLibTestContract', function(accounts) {
  it("should properly initialize token data", function() {
    var returnObj = {};
    var c;

    return TokenLibTestContract.deployed().then(function(instance) {
      c = instance;
      return c.name.call();
    }).then(function(n){
      returnObj.name = n;
      return c.symbol.call();
    }).then(function(s){
      returnObj.symbol = s;
      return c.decimals.call();
    }).then(function(d){
      returnObj.decimals = d;
      return c.totalSupply.call();
    }).then(function(ts){
      returnObj.totalSupply = ts;
      return c.initialSupply.call();
    }).then(function(is){
      returnObj.initialSupply = is;
      assert.equal(returnObj.name.valueOf(), 'Tester Token', "Name should be set to Tester Token.");
      assert.equal(returnObj.symbol.valueOf(), 'TST', "Symbol should be set to TST.");
      assert.equal(returnObj.decimals.valueOf(), 18, "Decimals should be set to 18.");
      assert.equal(returnObj.totalSupply.valueOf(), 100, "Total supply should reflect 10.");
      assert.equal(returnObj.initialSupply.valueOf(), 100, "Initial supply should reflect 10.");
    });
  });

  it('gets log hashes for all events', async () => {
    token = await TokenLibTestContract.deployed();

    // transfer event
    var ret = await token.transfer(accounts[1],20,{from:accounts[0]});
    var receipt1 = await web3.eth.getTransactionReceipt(ret.receipt.transactionHash);

    console.log(receipt1.logs[0].topics[0]);

    // event Approval(address indexed owner, address indexed spender, uint256 value);
    var ret = await token.approve(accounts[3],20,{from:accounts[0]});
    var receipt2 = await web3.eth.getTransactionReceipt(ret.receipt.transactionHash);

    console.log(receipt2.logs[0].topics[0]);

    // event OwnerChange(address from, address to);
    var ret = await token.changeOwner(accounts[1],{from:accounts[0]});
    var receipt3 = await web3.eth.getTransactionReceipt(ret.receipt.transactionHash);

    console.log(receipt3.logs[0].topics[0]);

    // event Burn(address indexed burner, uint256 value);
    var ret = await token.burnToken(20,{from:accounts[1]});
    var receipt4 = await web3.eth.getTransactionReceipt(ret.receipt.transactionHash);

    console.log(receipt4.logs[0].topics[0]);

    // event MintingClosed(bool mintingClosed);
    var ret = await token.closeMint({from:accounts[1]});
    var receipt5 = await web3.eth.getTransactionReceipt(ret.receipt.transactionHash);

    console.log(receipt5.logs[0].topics[0]);
  });
});
