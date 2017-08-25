var WalletLibTestContract = artifacts.require("WalletLibTestContract");
var TestToken = artifacts.require("TestToken");

contract('WalletLibTestContract', function(accounts) {
  it("should properly initialize wallet data", function() {
    var returnObj = {};
    var c;

    return WalletLibTestContract.deployed().then(function(instance) {
      c = instance;
      return c.maxOwners.call();
    }).then(function(mo){
      returnObj.mo = mo;
      return c.ownerCount.call();
    }).then(function(oc){
      returnObj.oc = oc;
      return c.requiredAdmin.call();
    }).then(function(ra){
      returnObj.ra = ra;
      return c.requiredMinor.call();
    }).then(function(rmi){
      returnObj.rmi = rmi;
      return c.requiredMajor.call();
    }).then(function(rma){
      returnObj.rma = rma;
      return c.owners.call();
    }).then(function(o){
      returnObj.o = o;
      console.log(returnObj.o);
      return c.majorThreshold.call(0);
    }).then(function(mt){
      returnObj.mt = mt;
      assert.equal(returnObj.mo.valueOf(), 50, "Max owners should be set to 50.");
      assert.equal(returnObj.oc.valueOf(), 5, "Owner count should reflect 5.");
      assert.equal(returnObj.ra.valueOf(), 4, "Required sigs for admin should reflect 4.");
      assert.equal(returnObj.rmi.valueOf(), 1, "Required sigs for minor tx should show 1.");
      assert.equal(returnObj.rma.valueOf(), 3, "Required sigs for major tx should show 3.");
      assert.equal(returnObj.mt.valueOf(), 100000000000000000000, "Max threshold should reflect 100 ether.");
    });
  });
  it("should change owner after requiredAdmin number of confirmations and deny illegal requests", function() {
    var c;
    var id;
    var ownerIndex;

    return WalletLibTestContract.deployed().then(function(instance){
      c = instance;
      return c.ownerIndex("0x36994c7cff11859ba8b9715120a68aa9499329ee");
    }).then(function(oi){
      ownerIndex = oi;
      return c.changeOwner("0x36994c7cff11859ba8b9715120a68aa9499329ee",
                           "0x0deef860f84a5298ccbc8a56f32f6ce49a236c8e",
                           true, {from: accounts[0]});
    }).then(function(ret){
      id = ""+ret.logs[0].args.txid+"";
      return c.revokeConfirm(id, {from:accounts[1]});
    }).then(function(ret){
      assert.equal(ret.logs[0].args.msg, 'Owner has not confirmed tx', "should give message that the owner hasn't confirmed the transaction yet");
      return c.transactionLength(id);
    }).then(function(len){
      length = len.valueOf();
      assert.equal(length, 1, 'Should have 1 transaction with this ID');
      return c.checkNotConfirmed('0x741c8986816d4c662739c411feb37b739f5f3dbd78850ee68032682a5912ba57', length - 1, {from:accounts[1]});
    }).then(function(ret){
      assert.equal(ret.logs[0].args.msg,'Tx not initiated', "should return msg that the tx hasn't been initiated");

      return c.transactionConfirmCount(id, length - 1);
    }).then(function(count){
      count = count.valueOf();
      assert.equal(count, 1, "Confirmation count should still be one b/c accounts[1] has not confirmed");
    }).then(function(){
      return c.changeOwner("0x36994c7cff11859ba8b9715120a68aa9499329ee",
                           "0x0deef860f84a5298ccbc8a56f32f6ce49a236c8e",
                           true, {from: accounts[2]});
    }).then(function(ret){
      return c.revokeConfirm(id, {from:accounts[2]});
    }).then(function(ret){
      return c.transactionLength(id);
    }).then(function(len){
      len = len.valueOf();
      return c.transactionConfirmCount(id, len - 1);
    }).then(function(count){
      count = count.valueOf();
      assert.equal(count, 1, "Confirmation count should still be one b/c accounts[2] has revoked");
    }).then(function(){
      return c.changeOwner("0x36994c7cff11859ba8b9715120a68aa9499329ee",
                           "0x0deef860f84a5298ccbc8a56f32f6ce49a236c8e",
                           true, {from: accounts[2]});
    }).then(function(ret){
      console.log(ret.logs[0].args);
      return c.changeOwner("0x36994c7cff11859ba8b9715120a68aa9499329ee",
                           "0x0deef860f84a5298ccbc8a56f32f6ce49a236c8e",
                           true, {from: accounts[1]});
    }).then(function(ret){
      console.log(ret.logs[0].args);
      return c.changeOwner("0x36994c7cff11859ba8b9715120a68aa9499329ee",
                           "0x0deef860f84a5298ccbc8a56f32f6ce49a236c8e",
                           true, {from: accounts[1]});
    }).then(function(ret){
      assert.equal(ret.logs[0].args.msg,'Owner already confirmed', "should return msg that the owner has already confirmed");
      return c.transactionLength(id);
    }).then(function(len){
      length = len.valueOf();
      return c.checkNotConfirmed(id, length - 1, {from:accounts[1]});
    }).then(function(ret){
      assert.equal(ret.logs[0].args.msg,'Owner already confirmed', "should return msg that the owner has already confirmed");
      return c.transactionConfirmCount(id, length - 1);
    }).then(function(count){
      count = count.valueOf();
      assert.equal(count, 3, "Confirmation count should still be three b/c accounts[1] has already confirmed");
    }).then(function(ret){
      return c.confirmTx(id, {from:accounts[3]});
    }).then(function(ret){
      return c.ownerIndex("0x0deef860f84a5298ccbc8a56f32f6ce49a236c8e");
    }).then(function(oi){
      assert.equal(oi.valueOf(), ownerIndex, "The index for the new owner should be the same as the old owner");
      return c.ownerIndex("0x36994c7cff11859ba8b9715120a68aa9499329ee");
    }).then(function(oi){
      assert.equal(oi.valueOf(), 0, "The index of the old owner should be 0");
    });
  });
  it("should add owner after requiredAdmin number of confirmations and deny illegal requests", function() {
    var c;
    var id;
    var ownerIndex;

    return WalletLibTestContract.deployed().then(function(instance){
      c = instance;
      return c.addOwner("0x0deef860f84a5298ccbc8a56f32f6ce49a236c8e",
                         true, {from: accounts[0]});
    }).then(function(ret){
      console.log(ret.logs[0].args);
      return c.addOwner("0x36994c7cff11859ba8b9715120a68aa9499329ee",
                         true, {from: accounts[0]});
    }).then(function(ret){
      console.log(ret.logs[0].args);
      id = ""+ret.logs[0].args.txid+"";
      return c.revokeConfirm(id, {from:accounts[0]});
    }).then(function(ret){
      return c.transactionLength(id);
    }).then(function(len){
      len = len.valueOf();
      assert.equal(len, 0, "Revocation of only confirmation should delete tx");
    }).then(function(){
      return c.addOwner("0x36994c7cff11859ba8b9715120a68aa9499329ee",
                         true, {from: accounts[0]});
    }).then(function(ret){
      return c.revokeConfirm(id, {from:accounts[2]});
    }).then(function(ret){
      return c.transactionLength(id);
    }).then(function(len){
      len = len.valueOf();
      return c.transactionConfirmCount(id, len - 1);
    }).then(function(count){
      count = count.valueOf();
      assert.equal(count, 1, "Confirmation count should still be one b/c accounts[2] has not confirmed");
    }).then(function(){
      return c.confirmTx(id, {from:accounts[2]});
    }).then(function(ret){
      console.log(ret.logs[0].args);
      return c.confirmTx(id, {from:accounts[1]});
    }).then(function(ret){
      console.log(ret.logs[0].args);
      return c.addOwner("0x36994c7cff11859ba8b9715120a68aa9499329ee",
                         false, {from: accounts[0]});
    }).then(function(ret){
      return c.transactionLength(id);
    }).then(function(len){
      len = len.valueOf();
      return c.transactionConfirmCount(id, len - 1);
    }).then(function(count){
      count = count.valueOf();
      assert.equal(count, 2, "Confirmation count should be two b/c accounts[0] revoked");
    }).then(function(){
      return c.confirmTx(id, {from:accounts[0]});
    }).then(function(ret){
      console.log(ret.logs[0].args);
      return c.confirmTx(id, {from:accounts[3]});
    }).then(function(ret){
      console.log(ret.logs[0].args);
      return c.ownerIndex("0x36994c7cff11859ba8b9715120a68aa9499329ee");
    }).then(function(oi){
      assert.equal(oi.valueOf(), 6, "The index for the new owner should be six");
    });
  });
  it("should remove owner after requiredAdmin number of confirmations and deny illegal requests", function() {
    var c;
    var id;
    var ownerIndex;

    return WalletLibTestContract.deployed().then(function(instance){
      c = instance;
      return c.removeOwner("0x0deef860f84a5298ccbc8a56f32f6ce49a236c8e",
                         true, {from: accounts[1]});
    }).then(function(ret){
      console.log(ret.logs[0].args);
      return c.removeOwner("0x36994c7cff11859ba8b9715120a68aa9499329ee",
                         true, {from: accounts[0]});
    }).then(function(ret){
      console.log(ret.logs[0].args);
      id = ""+ret.logs[0].args.txid+"";
      return c.revokeConfirm(id, {from:accounts[0]});
    }).then(function(ret){
      return c.transactionLength(id);
    }).then(function(len){
      len = len.valueOf();
      assert.equal(len, 0, "Revocation of only confirmation should delete tx");
    }).then(function(){
      return c.removeOwner("0x0deef860f84a5298ccbc8a56f32f6ce49a236c8e",
                         true, {from: accounts[0]});
    }).then(function(ret){
      console.log(ret.logs[0].args);
      id = ""+ret.logs[0].args.txid+"";
      return c.removeOwner("0x0deef860f84a5298ccbc8a56f32f6ce49a236c8e",
                         false, {from: accounts[2]});
    }).then(function(ret){
      return c.transactionLength(id);
    }).then(function(len){
      len = len.valueOf();
      return c.transactionConfirmCount(id, len - 1);
    }).then(function(count){
      count = count.valueOf();
      assert.equal(count, 2, "Confirmation count should still be two b/c accounts[2] has not confirmed");
    }).then(function(){
      return c.confirmTx(id, {from:accounts[2]});
    }).then(function(ret){
      console.log(ret.logs[0].args);
      return c.confirmTx(id, {from:accounts[3]});
    }).then(function(ret){
      console.log(ret.logs[0].args);
      return c.ownerIndex("0x36994c7cff11859ba8b9715120a68aa9499329ee");
    }).then(function(oi){
      assert.equal(oi.valueOf(), 5, "The index of the last owner should be moved to removed owner");
      return c.ownerIndex("0x0deef860f84a5298ccbc8a56f32f6ce49a236c8e");
    }).then(function(oi){
      assert.equal(oi.valueOf(), 0, "The index of the removed owner should be 0");
      return c.owners.call();
    });
  });
  it("should change requiredAdmin after requiredAdmin number of confirmations and deny illegal requests", function() {
    var c;
    var id;

    return WalletLibTestContract.deployed().then(function(instance){
      c = instance;
      return c.changeRequiredAdmin(6, true, {from: accounts[1]});
    }).then(function(ret){
      console.log(ret.logs[0].args);
      return c.changeRequiredAdmin(2, true, {from: accounts[1]});
    }).then(function(ret){
      console.log(ret.logs[0].args);
      id = ""+ret.logs[0].args.txid+"";
      return c.changeRequiredAdmin(2, false, {from: accounts[1]});
    }).then(function(ret){
      return c.transactionLength(id);
    }).then(function(len){
      len = len.valueOf();
      assert.equal(len, 0, "Revocation of only confirmation should delete tx");
    }).then(function(){
      return c.changeRequiredAdmin(2, true, {from: accounts[1]});
    }).then(function(ret){
      console.log(ret.logs[0].args);
      id = ""+ret.logs[0].args.txid+"";
      return c.confirmTx(id, {from:accounts[2]});
    }).then(function(ret){
      console.log(ret.logs[0].args);
      return c.revokeConfirm(id, {from:accounts[3]});
    }).then(function(ret){
      return c.transactionLength(id);
    }).then(function(len){
      len = len.valueOf();
      return c.transactionConfirmCount(id, len - 1);
    }).then(function(count){
      count = count.valueOf();
      assert.equal(count, 2, "Confirmation count should still be two b/c accounts[3] has not confirmed");
    }).then(function(){
      return c.confirmTx(id, {from:accounts[3]});
    }).then(function(ret){
      console.log(ret.logs[0].args);
      return c.confirmTx(id, {from:accounts[0]});
    }).then(function(ret){
      console.log(ret.logs[0].args);
      return c.requiredAdmin.call();
    }).then(function(ra){
      assert.equal(ra.valueOf(), 2, "New sig requirement for administrative tasks should be 2");
    }).then(function(ret){
      return c.changeRequiredAdmin(0, true, {from: accounts[1]});
    }).then(function(ret){
      console.log(ret.logs[0].args);
      return c.changeRequiredAdmin(3, true, {from: accounts[1]});
    }).then(function(ret){
      console.log(ret.logs[0].args);
      return c.changeRequiredAdmin(3, true, {from: accounts[0]});
    }).then(function(ret){
      console.log(ret.logs[0].args);
      return c.requiredAdmin.call();
    }).then(function(ra){
      assert.equal(ra.valueOf(), 3, "New sig requirement for administrative tasks should be 3 after two sigs");
    });
  });
  it("should change requiredMajor after requiredAdmin number of confirmations and deny illegal requests", function() {
    var c;
    var id;

    return WalletLibTestContract.deployed().then(function(instance){
      c = instance;
      return c.changeRequiredMajor(6, true, {from: accounts[2]});
    }).then(function(ret){
      console.log(ret.logs[0].args);
      return c.changeRequiredMajor(4, true, {from: accounts[1]});
    }).then(function(ret){
      console.log(ret.logs[0].args);
      id = ""+ret.logs[0].args.txid+"";
      return c.changeRequiredMajor(4, false, {from: accounts[1]});
    }).then(function(ret){
      return c.transactionLength(id);
    }).then(function(len){
      len = len.valueOf();
      assert.equal(len, 0, "Revocation of only confirmation should delete tx");
    }).then(function(){
      return c.changeRequiredMajor(4, true, {from: accounts[1]});
    }).then(function(ret){
      console.log(ret.logs[0].args);
      id = ""+ret.logs[0].args.txid+"";
      return c.confirmTx(id, {from:accounts[2]});
    }).then(function(ret){
      console.log(ret.logs[0].args);
      return c.revokeConfirm(id, {from:accounts[3]});
    }).then(function(ret){
      return c.transactionLength(id);
    }).then(function(len){
      len = len.valueOf();
      return c.transactionConfirmCount(id, len - 1);
    }).then(function(count){
      count = count.valueOf();
      assert.equal(count, 2, "Confirmation count should still be two b/c accounts[3] has not confirmed");
    }).then(function(){
      return c.confirmTx(id, {from:accounts[3]});
    }).then(function(ret){
      console.log(ret.logs[0].args);
      return c.requiredMajor.call();
    }).then(function(rma){
      assert.equal(rma.valueOf(), 4, "New sig requirement for major tx should be 4");
    });
  });
  it("should change requiredMinor after requiredAdmin number of confirmations and deny illegal requests", function() {
    var c;
    var id;

    return WalletLibTestContract.deployed().then(function(instance){
      c = instance;
      return c.changeRequiredMinor(6, true, {from: accounts[2]});
    }).then(function(ret){
      console.log(ret.logs[0].args);
      return c.changeRequiredMinor(2, true, {from: accounts[1]});
    }).then(function(ret){
      console.log(ret.logs[0].args);
      id = ""+ret.logs[0].args.txid+"";
      return c.revokeConfirm(id, {from:accounts[1]});
    }).then(function(ret){
      return c.transactionLength(id);
    }).then(function(len){
      len = len.valueOf();
      assert.equal(len, 0, "Revocation of only confirmation should delete tx");
    }).then(function(){
      return c.changeRequiredMinor(2, true, {from: accounts[1]});
    }).then(function(ret){
      console.log(ret.logs[0].args);
      id = ""+ret.logs[0].args.txid+"";
      return c.confirmTx(id, {from:accounts[2]});
    }).then(function(ret){
      console.log(ret.logs[0].args);
      return c.changeRequiredMinor(2, false, {from: accounts[3]});
    }).then(function(ret){
      return c.transactionLength(id);
    }).then(function(len){
      len = len.valueOf();
      return c.transactionConfirmCount(id, len - 1);
    }).then(function(count){
      count = count.valueOf();
      assert.equal(count, 2, "Confirmation count should still be two b/c accounts[3] has not confirmed");
    }).then(function(){
      return c.confirmTx(id, {from:accounts[3]});
    }).then(function(ret){
      console.log(ret.logs[0].args);
      return c.requiredMinor.call();
    }).then(function(rmi){
      assert.equal(rmi.valueOf(), 2, "New sig requirement for minor tx should be 2");
    });
  });
  it("should change majorThreshold after requiredAdmin number of confirmations and deny illegal requests", function() {
    var c;
    var tc;
    var tcAdd;
    var id;

    return WalletLibTestContract.deployed().then(function(instance){
      c = instance;
      return TestToken.deployed().then(function(tokInstance){
        tc = tokInstance;
        tcAdd = ""+tc.address+"";
        console.log(tcAdd);
        return c.changeMajorThreshold(tcAdd, 3, true, {from: accounts[0]});
      }).then(function(ret){
        console.log(ret.logs[0].args);
        id = ""+ret.logs[0].args.txid+"";
        return c.confirmTx(id, {from:accounts[1]});
      }).then(function(ret){
        console.log(ret.logs[0].args);
        return c.revokeConfirm(id, {from:accounts[1]});
      }).then(function(ret){
        return c.transactionLength(id);
      }).then(function(len){
        len = len.valueOf();
        return c.transactionConfirmCount(id, len - 1);
      }).then(function(count){
        count = count.valueOf();
        assert.equal(count, 1, "Confirmation count should be one b/c accounts[1] revoked");
      }).then(function(){
        return c.changeMajorThreshold(tcAdd, 3, true, {from: accounts[0]});
      }).then(function(ret){
        console.log(ret.logs[0].args);
        return c.transactionLength(id);
      }).then(function(len){
        len = len.valueOf();
        return c.transactionConfirmCount(id, len - 1);
      }).then(function(count){
        count = count.valueOf();
        assert.equal(count, 1, "Confirmation count should still be one b/c accounts[0] already confirmed");
      }).then(function(){
        return c.changeMajorThreshold(tcAdd, 3, true, {from: accounts[1]});
      }).then(function(ret){
        console.log(ret.logs[0].args);
        return c.confirmTx(id, {from:accounts[2]});
      }).then(function(ret){
        console.log(ret.logs[0].args);
        return c.majorThreshold.call(tcAdd);
      }).then(function(mt){
        assert.equal(mt.valueOf(), 3, "Major tx threshold for test token should be 3");
      }).then(function(){
        return c.changeMajorThreshold(0, 50000000000000000000, true, {from: accounts[0]});
      }).then(function(ret){
        console.log(ret.logs[0].args);
        id = ""+ret.logs[0].args.txid+"";
        return c.confirmTx(id, {from:accounts[1]});
      }).then(function(ret){
        console.log(ret.logs[0].args);
        return c.confirmTx(id, {from:accounts[2]});
      }).then(function(ret){
        console.log(ret.logs[0].args);
        return c.majorThreshold.call(0);
      }).then(function(mt){
        assert.equal(mt.valueOf(), 50000000000000000000, "Major tx threshold for ether should be 50");
      });
    });
  });
  it("should execute minor tx after requiredMinor number of confirmations and deny illegal requests", function() {
    var c;
    var tc;
    var tcAdd;
    var id;
    var initialBalance;
    var data;

    return WalletLibTestContract.deployed().then(function(instance){
      c = instance;
      return TestToken.deployed().then(function(tokInstance){
        tc = tokInstance;
        tcAdd = ""+tc.address+"";
        return tc.transfer(c.address, 10, {from:accounts[1]});
      }).then(function(ret){
        return web3.eth.getBalance(accounts[5]);
      }).then(function(bal){
        initialBalance = Math.floor(bal.valueOf()/10**18);
        return c.sendTransaction({value: 100000000000000000000, from: accounts[5]});
      }).then(function(ret){
        return web3.eth.getBalance(c.address);
      }).then(function(bal){
        bal = Math.floor(bal.valueOf()/10**18);
        assert.equal(bal, 100, "100 ether should be transferred to the wallet from accounts[5]");
        return c.serveTx(accounts[5], 10000000000000000000, 0, true, {from: accounts[0]});
      }).then(function(ret){
        console.log(ret.logs[0].args);
        id = ""+ret.logs[0].args.txid+"";
        return c.confirmTx(id, {from:accounts[2]});
      }).then(function(ret){
        console.log(ret.logs[0].args);
        assert.equal(ret.logs[0].args.value.valueOf(), 10000000000000000000, "10 ether should be transferred to accounts[5] from the wallet with 2 sigs");
      }).then(function(){
        return tc.transfer.request(accounts[5], 2);
      }).then(function(ret){
        data = ret.params[0].data;
        return c.serveTx(tcAdd, 0, ""+data+"", true, {from: accounts[0]});
      }).then(function(ret){
        console.log(ret.logs[0].args);
        id = ""+ret.logs[0].args.txid+"";
        return c.revokeConfirm(id, {from:accounts[2]});
      }).then(function(ret){
        return c.transactionLength(id);
      }).then(function(len){
        len = len.valueOf();
        return c.transactionConfirmCount(id, len - 1);
      }).then(function(count){
        count = count.valueOf();
        assert.equal(count, 1, "Confirmation count should be one b/c accounts[2] has not confirmed");
      }).then(function(){
        return c.serveTx(tcAdd, 0, ""+data+"", true, {from: accounts[0]});
      }).then(function(ret){
        console.log(ret.logs[0].args);
        return c.transactionLength(id);
      }).then(function(len){
        len = len.valueOf();
        return c.transactionConfirmCount(id, len - 1);
      }).then(function(count){
        count = count.valueOf();
        assert.equal(count, 1, "Confirmation count should be one b/c accounts[0] has already confirmed");
      }).then(function(){
        return c.serveTx(tcAdd, 0, ""+data+"", true, {from: accounts[2]});
      }).then(function(ret){
        console.log(ret.logs[0].args);
        return tc.balanceOf(""+c.address+"");
      }).then(function(b){
        assert.equal(b.valueOf(), 8, "2 tokens should be transferred to accounts[5] after 2 sigs");
      });
    });
  });
  it("should execute major tx after requiredMajor number of confirmations and deny illegal requests", function() {
    var c;
    var tc;
    var tcAdd;
    var id;
    var initialBalance;
    var data;

    return WalletLibTestContract.deployed().then(function(instance){
      c = instance;
      return TestToken.deployed().then(function(tokInstance){
        tc = tokInstance;
        tcAdd = ""+tc.address+"";
        return web3.eth.getBalance(accounts[5]);
      }).then(function(bal){
        initialBalance = Math.floor(bal.valueOf()/10**18);
        return c.sendTransaction({value: 100000000000000000000, from: accounts[5]});
      }).then(function(ret){
        return web3.eth.getBalance(accounts[5]);
      }).then(function(bal){
        bal = initialBalance - Math.floor(bal.valueOf()/10**18);
        assert.equal(bal, 100, "100 ether should be transferred to the wallet from accounts[5]");
        return c.serveTx(accounts[5], 60000000000000000000, 0, true, {from: accounts[0]});
      }).then(function(ret){
        console.log(ret.logs[0].args);
        id = ""+ret.logs[0].args.txid+"";
        return c.confirmTx(id, {from:accounts[2]});
      }).then(function(){
        return web3.eth.getBalance(accounts[5]);
      }).then(function(bal){
        bal= initialBalance - Math.floor(bal.valueOf()/10**18);
        assert.equal(bal, 100, "No ether should be sent until 4 confirms");
        return c.confirmTx(id, {from:accounts[3]});
      }).then(function(bal){
        return c.confirmTx(id, {from:accounts[1]});
      }).then(function(ret){
        console.log(ret.logs[0].args);
        return web3.eth.getBalance(accounts[5]);
      }).then(function(bal){
        bal = initialBalance - Math.floor(bal.valueOf()/10**18);
        assert.equal(bal, 40, "60 ether should be transferred to accounts[5] from the wallet with 4 sigs");
      }).then(function(){
        return tc.transfer.request(accounts[5], 5);
      }).then(function(ret){
        data = ret.params[0].data;
        return c.serveTx(tcAdd, 0, ""+data+"", true, {from: accounts[0]});
      }).then(function(ret){
        console.log(ret.logs[0].args);
        id = ""+ret.logs[0].args.txid+"";
        return c.revokeConfirm(id, {from:accounts[2]});
      }).then(function(ret){
        return c.transactionLength(id);
      }).then(function(len){
        len = len.valueOf();
        return c.transactionConfirmCount(id, len - 1);
      }).then(function(count){
        count = count.valueOf();
        assert.equal(count, 1, "Confirmation count should be one b/c accounts[2] has not confirmed");
      }).then(function(){
        return c.serveTx(tcAdd, 0, ""+data+"", true, {from: accounts[0]});
      }).then(function(ret){
        return c.transactionLength(id);
      }).then(function(len){
        len = len.valueOf();
        return c.transactionConfirmCount(id, len - 1);
      }).then(function(count){
        count = count.valueOf();
        assert.equal(count, 1, "Confirmation count should be one b/c accounts[0] has already confirmed");
      }).then(function(){
        return c.confirmTx(id, {from:accounts[2]});
      }).then(function(){
        return c.confirmTx(id, {from:accounts[3]});
      }).then(function(){
        return c.confirmTx(id, {from:accounts[1]});
      }).then(function(ret){
        console.log(ret.logs[0].args);
        return tc.balanceOf(""+c.address+"");
      }).then(function(b){
        assert.equal(b.valueOf(), 3, "3 tokens should be transferred to accounts[5] after 4 sigs");
      });
    });
  });
  it("should create contract after appropriate number of sigs, no target, and proper data", function() {
    var c;
    var id;
    var data  = "0x6060604052341561000f57600080fd5b5b6103108061001f6000396000f300606060405263ffffffff60e060020a6000350416631d3b9edf811461004557806366098d4f1461006d578063e39bbf6814610095578063f4f3bdc1146100bd575b600080fd5b6100536004356024356100e5565b604051911515825260208201526040908101905180910390f35b610053600435602435610159565b604051911515825260208201526040908101905180910390f35b6100536004356024356101cd565b604051911515825260208201526040908101905180910390f35b610053600435602435610247565b604051911515825260208201526040908101905180910390f35b600082820282158382048514176100fe57506001905060005b8115610151576000805160206102c58339815191526040516020808252601390820152606860020a7274696d65732066756e63206f766572666c6f77026040808301919091526060909101905180910390a15b5b9250929050565b600082820182810384148382111661017357506001905060005b8115610151576000805160206102c58339815191526040516020808252601290820152607060020a71706c75732066756e63206f766572666c6f77026040808301919091526060909101905180910390a15b5b9250929050565b60008082156101e85750818304806020604051015260408051f35b6000805160206102c58339815191526040516020808252601790820152604860020a76747269656420746f20646976696465206279207a65726f026040808301919091526060909101905180910390a1506001905060005b9250929050565b60008183038083018414848210828614171660011461026857506001905060005b8115610151576000805160206102c58339815191526040516020808252601490820152606060020a736d696e75732066756e6320756e646572666c6f77026040808301919091526060909101905180910390a15b5b925092905056004eb9487277c052fc38bc53c91e4af51b26a1e7600aa1761ef9d2973180cf72a7a165627a7a72305820816921a222288d2b0efcc39a7dfdda6552de32e026d6a7f8b9e335dab1871dcb0029";

    return WalletLibTestContract.deployed().then(function(instance){
      c = instance;

      return c.serveTx(0, 0, data, true, {from: accounts[0]});
    }).then(function(ret){
      console.log(ret.logs[0].args);
      id = ""+ret.logs[0].args.txid+"";
      return c.confirmTx(id, {from:accounts[2]});
    }).then(function(ret){
      console.log(ret.logs[0].args);
      return c.confirmTx(id, {from:accounts[1]});
    }).then(function(ret){
      console.log(ret.logs[0].args);
      return c.confirmTx(id, {from:accounts[3]});
    }).then(function(ret){
      console.log(ret.logs[0].args);
      assert.isDefined(ret.logs[0].args.newContract, "New contract should be created if no target and proper data");
    });
  });
});
