var DirectCrowdsaleTestContract = artifacts.require("DirectCrowdsaleTestContract");

contract('DirectCrowdsaleTestContract', function(accounts) {
  it("should properly initialize token data", function() {
    var returnObj = {};
    var c;

    return DirectCrowdsaleTestContract.deployed().then(function(instance) {
      c = instance;
      return c.getOwner.call();
    }).then(function(n){
      console.log(n)
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
      assert.equal(returnObj.name.valueOf(), 'Tester Token', "Name should be set to Tester Token.");
      assert.equal(returnObj.symbol.valueOf(), 'TST', "Symbol should be set to TST.");
      assert.equal(returnObj.decimals.valueOf(), 18, "Decimals should be set to 18.");
      assert.equal(returnObj.totalSupply.valueOf(), 20000000000000000000000000, "Total supply should reflect 20000000000000000000.");
    });
  });
});