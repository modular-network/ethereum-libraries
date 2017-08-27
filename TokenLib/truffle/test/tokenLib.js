var TokenLibTestContract = artifacts.require("TokenLibTestContract");

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
});
