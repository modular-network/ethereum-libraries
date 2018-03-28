const WalletLibTestContract = artifacts.require("WalletLibTestContract");
const TestToken = artifacts.require("TestToken");

contract('WalletLibTestContract', (accounts) => {
  it("should properly initialize wallet data", async () => {


    const contract = await WalletLibTestContract.deployed();
    const maxOwners = await contract.maxOwners.call({from:accounts[0]});
    const ownerCount = await contract.ownerCount.call({from:accounts[0]});
    const requiredAdmin = await contract.requiredAdmin.call({from:accounts[0]});
    const requiredMinor = await contract.requiredMinor.call({from:accounts[0]});
    const requiredMajor = await contract.requiredMajor.call({from:accounts[0]});
    await contract.owners.call();
    const majorThreshold = await contract.majorThreshold.call(0,{from:accounts[0]});

    assert.equal(maxOwners.valueOf(), 50, "Max owners should be set to 50.");
    assert.equal(ownerCount.valueOf(), 5, "Owner count should reflect 5.");
    assert.equal(requiredAdmin.valueOf(), 4, "Required sigs for admin should reflect 4.");
    assert.equal(requiredMinor.valueOf(), 1, "Required sigs for minor tx should show 1.");
    assert.equal(requiredMajor.valueOf(), 3, "Required sigs for major tx should show 3.");
    assert.equal(majorThreshold.valueOf(), 100000000000000000000, "Max threshold should reflect 100 ether.");

  });

  it("should change owner after requiredAdmin number of confirmations and deny illegal requests", async () => {

    const contract = await WalletLibTestContract.deployed();
    const ownerIndex = await contract.ownerIndex("0x36994c7cff11859ba8b9715120a68aa9499329ee");

    const changeOwnerAccount0 = await contract.changeOwner("0x36994c7cff11859ba8b9715120a68aa9499329ee",
                           "0x0deef860f84a5298ccbc8a56f32f6ce49a236c8e",
                           true, { from: accounts[0] });
    const changeOwnerAccount0Id = ""+changeOwnerAccount0.logs[0].args.txid+"";
    const revokeConfirm = await contract.revokeConfirm(changeOwnerAccount0Id, {from:accounts[1]});

    const firstTransactionLength = await contract.transactionLength(changeOwnerAccount0Id);
    const checkNotConfirmed = await contract.checkNotConfirmed("0x741c8986816d4c662739c411feb37b739f5f3dbd78850ee68032682a5912ba57", firstTransactionLength.valueOf() - 1, {from:accounts[1]});
    // var receipt1 = await web3.eth.getTransactionReceipt(checkNotConfirmed.receipt.transactionHash);

    // console.log("transaction fail "+receipt1.logs[1].topics[0]);

    const transactionConfirmCount = await contract.transactionConfirmCount(changeOwnerAccount0Id, firstTransactionLength.valueOf() - 1);

    await contract.changeOwner("0x36994c7cff11859ba8b9715120a68aa9499329ee",
                           "0x0deef860f84a5298ccbc8a56f32f6ce49a236c8e",
                           true, {from: accounts[2]});
    await contract.revokeConfirm(changeOwnerAccount0Id, {from:accounts[2]});
    const secondTransactionLenght = await contract.transactionLength(changeOwnerAccount0Id);
    const secondTransactionConfirmCount = await contract.transactionConfirmCount(changeOwnerAccount0Id, secondTransactionLenght - 1);

    const badFromChangeOwner = await contract.changeOwner("0x36994c7cff11859ba8b9715120a68aa9499329e7",
                           "0x0deef860f84a5298ccbc8a56f32f6ce49a236c8e",
                           true, {from: accounts[2]});

    const badToChangeOwner = await contract.changeOwner("0x36994c7cff11859ba8b9715120a68aa9499329ee",
                           "0x79b63228ff63659248b7c688870de388bdcf0c14",
                           true, {from: accounts[2]});

    await contract.changeOwner("0x36994c7cff11859ba8b9715120a68aa9499329ee",
                           "0x0deef860f84a5298ccbc8a56f32f6ce49a236c8e",
                           true, {from: accounts[2]});

    const thirdTransactionConfirmCount = await contract.transactionConfirmCount(changeOwnerAccount0Id, secondTransactionLenght - 1);

    await contract.changeOwner("0x36994c7cff11859ba8b9715120a68aa9499329ee",
                           "0x0deef860f84a5298ccbc8a56f32f6ce49a236c8e",
                           false, {from: accounts[2]});

    const fourthTransactionConfirmCount = await contract.transactionConfirmCount(changeOwnerAccount0Id, secondTransactionLenght - 1);

    await contract.changeOwner("0x36994c7cff11859ba8b9715120a68aa9499329ee",
                           "0x0deef860f84a5298ccbc8a56f32f6ce49a236c8e",
                           true, {from: accounts[2]});


    var ret = await contract.changeOwner("0x36994c7cff11859ba8b9715120a68aa9499329ee",
                           "0x0deef860f84a5298ccbc8a56f32f6ce49a236c8e",
                           true, {from: accounts[1]});
    // var receipt1 = await web3.eth.getTransactionReceipt(ret.receipt.transactionHash);

    // console.log("TransactionConfirmed "+receipt1.logs[0].topics[0]);

    const changeOwnerSecondAccount = await contract.changeOwner("0x36994c7cff11859ba8b9715120a68aa9499329ee",
                           "0x0deef860f84a5298ccbc8a56f32f6ce49a236c8e",
                           true, {from: accounts[1]});

    const firstAccountTransactionLenght = await contract.transactionLength(changeOwnerAccount0Id);
    const firstAccountCheckNotConfirmed = await contract.checkNotConfirmed(changeOwnerAccount0Id,  firstAccountTransactionLenght.valueOf() - 1, {from:accounts[1]});
    const firstAccountTransactionConfirmCount = await contract.transactionConfirmCount(changeOwnerAccount0Id,  firstAccountTransactionLenght.valueOf() - 1);

    ret = await contract.confirmTx(changeOwnerAccount0Id, {from:accounts[3]});
    // var receipt2 = await web3.eth.getTransactionReceipt(ret.receipt.transactionHash);

    // console.log("Owner change "+receipt2.logs[0].topics[0]);
    const checkNotConfirmedFail = await contract.checkNotConfirmed(changeOwnerAccount0Id, firstTransactionLength.valueOf() - 1, {from:accounts[1]});
    const revokeConfirmFail = await contract.revokeConfirm(changeOwnerAccount0Id, {from:accounts[1]});

    const newOwnerIndex = await contract.ownerIndex("0x0deef860f84a5298ccbc8a56f32f6ce49a236c8e");
    const oldOwnerIndex = await contract.ownerIndex("0x36994c7cff11859ba8b9715120a68aa9499329ee");

    assert.equal(revokeConfirm.logs[0].args.msg, 'Owner has not confirmed tx', "should give message that the owner hasn't confirmed the transaction yet");
    assert.equal(firstTransactionLength.valueOf(), 1, 'Should have 1 transaction with this ID');
    assert.equal(badFromChangeOwner.logs[0].args.msg, 'Change from address is not an owner', "Should give a message that the from owner is invalid");
    assert.equal(badToChangeOwner.logs[0].args.msg, 'Change to address is an owner', "Should give a message that the to owner is invalid");
    assert.equal(checkNotConfirmed.logs[0].args.msg,'Tx not initiated', "should return msg that the tx hasn't been initiated");
    assert.equal(checkNotConfirmedFail.logs[0].args.msg, 'Transaction already complete', "should state tx is already complete");
    assert.equal(revokeConfirmFail.logs[0].args.msg, 'Transaction already complete', "should state tx is already complete");

    assert.equal(transactionConfirmCount.valueOf(), 1, "Confirmation count should still be one b/c accounts[1] has not confirmed");
    assert.equal(secondTransactionConfirmCount.valueOf(), 1, "Confirmation count should still be one b/c accounts[2] has revoked");
    assert.equal(thirdTransactionConfirmCount.valueOf(), 2, "Confirmation count should be two b/c accounts[2] has confirmed");
    assert.equal(fourthTransactionConfirmCount.valueOf(), 1, "Confirmation count should still be one b/c accounts[2] has revoked");
    assert.equal(changeOwnerSecondAccount.logs[0].args.msg,'Owner already confirmed', "should return msg that the owner has already confirmed");
    assert.equal(firstAccountCheckNotConfirmed.logs[0].args.msg,'Owner already confirmed', "should return msg that the owner has already confirmed");
    assert.equal(firstAccountTransactionConfirmCount.valueOf(), 3, "Confirmation count should still be three b/c accounts[1] has already confirmed");
    assert.equal(newOwnerIndex.valueOf(), ownerIndex, "The index for the new owner should be the same as the old owner");
    assert.equal(oldOwnerIndex.valueOf(), 0, "The index of the old owner should be 0");

  });

  it("should add owner after requiredAdmin number of confirmations and deny illegal requests", async () => {

    const contract = await WalletLibTestContract.deployed();
    await contract.addOwner("0x0deef860f84a5298ccbc8a56f32f6ce49a236c8e",
                         true, {from: accounts[0]});
    const addOwner = await contract.addOwner("0x36994c7cff11859ba8b9715120a68aa9499329ee",
                         true, {from: accounts[0]});
    const addOwnerAlreadyConfirmed = await contract.addOwner("0x36994c7cff11859ba8b9715120a68aa9499329ee",
                         true, {from: accounts[0]});
    // var receipt3 = await web3.eth.getTransactionReceipt(addOwnerAlreadyConfirmed.receipt.transactionHash);

    // console.log("Error "+receipt3.logs[0].topics[0]);
    const id = ""+addOwner.logs[0].args.txid+"";
    await contract.revokeConfirm(id, {from:accounts[0]});
    const firstTransactionLength = await contract.transactionLength(id);

    await contract.addOwner("0x36994c7cff11859ba8b9715120a68aa9499329ee",
                         true, {from: accounts[0]});
    await contract.revokeConfirm(id, {from:accounts[2]});
    const secondTransactionLenght = await contract.transactionLength(id);
    const secondTransactionConfirmCount = await contract.transactionConfirmCount(id, secondTransactionLenght.valueOf() - 1);

    await contract.confirmTx(id, {from:accounts[2]});
    await contract.confirmTx(id, {from:accounts[1]});
    await contract.addOwner("0x36994c7cff11859ba8b9715120a68aa9499329ee",
                         false, {from: accounts[0]});
    const thirdTransactionLenght = await contract.transactionLength(id);
    const thirdTransactionConfirmCount = await contract.transactionConfirmCount(id, thirdTransactionLenght.valueOf() - 1);

    await contract.confirmTx(id, {from:accounts[0]});
    var ret = await contract.confirmTx(id, {from:accounts[3]});
    // var receipt4 = await web3.eth.getTransactionReceipt(ret.receipt.transactionHash);

    // console.log("Owner added "+receipt4.logs[0].topics[0]);
    const newOwnerIndex = await contract.ownerIndex("0x36994c7cff11859ba8b9715120a68aa9499329ee");

    assert.equal(addOwnerAlreadyConfirmed.logs[0].args.msg,'Owner already confirmed', "Should fail because accounts[0] has already confirmed the tx");
    assert.equal(firstTransactionLength.valueOf(), 0, "Revocation of only confirmation should delete tx");
    assert.equal(secondTransactionConfirmCount.valueOf(), 1, "Confirmation count should still be one b/c accounts[2] has not confirmed");
    assert.equal(thirdTransactionConfirmCount.valueOf(), 2, "Confirmation count should be two b/c accounts[0] revoked");
    assert.equal(newOwnerIndex.valueOf(), 6, "The index for the new owner should be six");
  });

  it("should remove owner after requiredAdmin number of confirmations and deny illegal requests", async () => {

    const contract = await WalletLibTestContract.deployed();
    await contract.removeOwner("0x0deef860f84a5298ccbc8a56f32f6ce49a236c8e",
                         true, {from: accounts[1]});
    const badRemoveOwnerFirstAccount = await contract.removeOwner("0x36994c7cff11859ba8b9715120a68aa9499329e7",
                         true, {from: accounts[0]});
    const removeOwnerFirstAccount = await contract.removeOwner("0x36994c7cff11859ba8b9715120a68aa9499329ee",
                         true, {from: accounts[0]});
    const removeOwnerFirstAccountId = ""+removeOwnerFirstAccount.logs[0].args.txid+"";
    await contract.revokeConfirm(removeOwnerFirstAccountId, {from:accounts[0]});
    const firstAccountTransactionLenght = await contract.transactionLength(removeOwnerFirstAccountId);

    const removeSecondOwnerFirstAccount = await contract.removeOwner("0x0deef860f84a5298ccbc8a56f32f6ce49a236c8e",
                         true, {from: accounts[0]});

    const removeSecondOwnerFirstAccountId = ""+removeSecondOwnerFirstAccount.logs[0].args.txid+"";
    await contract.removeOwner("0x0deef860f84a5298ccbc8a56f32f6ce49a236c8e",
                         false, {from: accounts[2]});
    const secondTransactionLenght = await contract.transactionLength(removeSecondOwnerFirstAccountId);
    const secondTransactionConfirmCount = await contract.transactionConfirmCount(removeSecondOwnerFirstAccountId, secondTransactionLenght.valueOf() - 1);

    await contract.confirmTx(removeSecondOwnerFirstAccountId, {from:accounts[2]});
    var ret = await contract.confirmTx(removeSecondOwnerFirstAccountId, {from:accounts[3]});
    // var receipt1 = await web3.eth.getTransactionReceipt(ret.receipt.transactionHash);

    // console.log("Remove owner "+receipt1.logs[0].topics[0]);

    const lastOwnerIndex = await contract.ownerIndex("0x36994c7cff11859ba8b9715120a68aa9499329ee");
    const removedOwnerIndex = await contract.ownerIndex("0x0deef860f84a5298ccbc8a56f32f6ce49a236c8e");

    await contract.removeOwner("0x79b63228ff63659248b7c688870de388bdcf0c14", true, {from: accounts[0]});
    await contract.removeOwner("0x79b63228ff63659248b7c688870de388bdcf0c14", true, {from: accounts[0]});
    await contract.removeOwner("0x79b63228ff63659248b7c688870de388bdcf0c14", true, {from: accounts[1]});
    await contract.removeOwner("0x79b63228ff63659248b7c688870de388bdcf0c14", true, {from: accounts[2]});
    await contract.removeOwner("0x79b63228ff63659248b7c688870de388bdcf0c14", true, {from: accounts[5]});

    const badRemoveOwnerTooManyAdmin = await contract.removeOwner(accounts[0], true, {from:accounts[1]});

    await contract.addOwner("0x79b63228ff63659248b7c688870de388bdcf0c14", true, {from: accounts[0]});
    await contract.addOwner("0x79b63228ff63659248b7c688870de388bdcf0c14", true, {from: accounts[1]});
    await contract.addOwner("0x79b63228ff63659248b7c688870de388bdcf0c14", true, {from: accounts[2]});
    await contract.addOwner("0x79b63228ff63659248b7c688870de388bdcf0c14", true, {from: accounts[5]});

    await contract.owners.call();

    assert.equal(badRemoveOwnerFirstAccount.logs[0].args.msg,'Owner removing not an owner', "Should fail because removing owner is not an owner");
    assert.equal(firstAccountTransactionLenght.valueOf(), 0, "Revocation of only confirmation should delete tx");
    assert.equal(secondTransactionConfirmCount.valueOf(), 2, "Confirmation count should still be two b/c accounts[2] has not confirmed");
    assert.equal(lastOwnerIndex.valueOf(), 5, "The index of the last owner should be moved to removed owner");
    assert.equal(removedOwnerIndex.valueOf(), 0, "The index of the removed owner should be 0");
    assert.equal(badRemoveOwnerTooManyAdmin.logs[0].args.msg,'Must reduce requiredAdmin first', "Should give error that admin sigs need to be less than number of owners");
  });

  it("should advise when too many owners are added", async () => {
    const contract = await WalletLibTestContract.deployed();
    let baseAddr = "79b63228ff63659248b7c688870de388bdcf0c15";
    let begin = baseAddr.substr(0,baseAddr.length - 5);
    let end = baseAddr.substr(baseAddr.length - 5);
    let newEnd = (parseInt(end, 16) + 1);
    let newAddr;
    for(var i = 0; i < 45; i++){
      newEnd = (parseInt(newEnd, 16) + 1).toString(16);
      newAddr = '0x'+ begin + newEnd;
      await contract.addOwner(newAddr, true, {from: accounts[0]});
      await contract.addOwner(newAddr, true, {from: accounts[1]});
      await contract.addOwner(newAddr, true, {from: accounts[2]});
      await contract.addOwner(newAddr, true, {from: accounts[5]});
    }
    newEnd = (parseInt(newEnd, 16) + 1).toString(16);
    newAddr = '0x'+ begin + newEnd;
    const badNewOwner = await contract.addOwner(newAddr, true, {from: accounts[0]});
    assert.equal(badNewOwner.logs[0].args.msg,'Too many owners', "Should give error that too many owners added");
  });

  it("should change requiredAdmin after requiredAdmin number of confirmations and deny illegal requests", async () => {

    const contract = await WalletLibTestContract.deployed();

    await contract.changeRequiredAdmin(6, true, {from: accounts[1]});
    const changeFirstRequiredAdmin = await contract.changeRequiredAdmin(2, true, {from: accounts[1]});
    const changeFirstRequiredAdminId = ""+changeFirstRequiredAdmin.logs[0].args.txid+"";
    await contract.changeRequiredAdmin(2, false, {from: accounts[1]});
    const firstTransactionLength = await contract.transactionLength(changeFirstRequiredAdminId);

    const changeSecondRequiredAdmin = await contract.changeRequiredAdmin(2, true, {from: accounts[1]});
    const changeSecondRequiredAdminId = ""+changeSecondRequiredAdmin.logs[0].args.txid+"";
    await contract.confirmTx(changeSecondRequiredAdminId, {from:accounts[2]});
    await contract.revokeConfirm(changeSecondRequiredAdminId, {from:accounts[3]});
    const failChangeAdmin = await contract.revokeConfirm(1742, {from:accounts[3]});
    const secondTransactionLenght = await contract.transactionLength(changeSecondRequiredAdminId);
    const secondTransactionConfirmCount = await contract.transactionConfirmCount(changeSecondRequiredAdminId, secondTransactionLenght.valueOf() - 1);

    const failConformTxNotInitiated = await contract.confirmTx(1742, {from:accounts[3]});
    await contract.confirmTx(changeSecondRequiredAdminId, {from:accounts[3]});
    await contract.confirmTx(changeSecondRequiredAdminId, {from:accounts[0]});
    const firstRequiredAdmin = await contract.requiredAdmin.call();

    await contract.changeRequiredAdmin(0, true, {from: accounts[1]});
    await contract.changeRequiredAdmin(3, true, {from: accounts[1]});
    await contract.changeRequiredAdmin(3, true, {from: accounts[1]});
    var ret = await contract.changeRequiredAdmin(3, true, {from: accounts[0]});
    // var receipt1 = await web3.eth.getTransactionReceipt(ret.receipt.transactionHash);

    // console.log("change admin "+receipt1.logs[0].topics[0]);
    const secondRequiredAdmin = await contract.requiredAdmin.call();

    assert.equal(failChangeAdmin.logs[0].args.msg, "Tx not initiated","Should give error that the tx id has not been initiated");
    assert.equal(firstTransactionLength.valueOf(), 0, "Revocation of only confirmation should delete tx");
    assert.equal(secondTransactionConfirmCount.valueOf(), 2, "Confirmation count should still be two b/c accounts[3] has not confirmed");
    assert.equal(firstRequiredAdmin.valueOf(), 2, "New sig requirement for administrative tasks should be 2");
    assert.equal(secondRequiredAdmin.valueOf(), 3, "New sig requirement for administrative tasks should be 3 after two sigs");
  });

  it("should change requiredMajor after requiredAdmin number of confirmations and deny illegal requests", async () => {

    const contract = await WalletLibTestContract.deployed();

    await contract.changeRequiredMajor(6, true, {from: accounts[2]});
    const changeSecondRequiredMajor = await contract.changeRequiredMajor(4, true, {from: accounts[1]});
    const changeSecondRequiredMajorId = ""+changeSecondRequiredMajor.logs[0].args.txid+"";
    await contract.changeRequiredMajor(4, false, {from: accounts[1]});
    const transactionLength = await contract.transactionLength(changeSecondRequiredMajorId);

    const changeThirdRequiredMajor = await contract.changeRequiredMajor(4, true, {from: accounts[1]});
    const changeThirdRequiredMajorFail = await contract.changeRequiredMajor(4, true, {from: accounts[1]});
    const changeThirdRequiredMajorId = ""+changeThirdRequiredMajor.logs[0].args.txid+"";
    await contract.confirmTx(changeThirdRequiredMajorId, {from:accounts[2]});
    await contract.revokeConfirm(changeThirdRequiredMajorId, {from:accounts[3]});
    const secondTransactionLenght = await contract.transactionLength(changeThirdRequiredMajorId);
    const transactionConfirmCount = await contract.transactionConfirmCount(changeThirdRequiredMajorId, secondTransactionLenght.valueOf() - 1);

    const badMajor = await contract.changeRequiredMajor(51, true, {from: accounts[1]});
    var ret = await contract.confirmTx(changeThirdRequiredMajorId, {from:accounts[3]});
    const requiredMajor = await contract.requiredMajor.call();

    assert.equal(changeThirdRequiredMajorFail.logs[0].args.msg,"Owner already confirmed", "Should fail because accounts[1] already confirmed!");
    assert.equal(transactionLength.valueOf(), 0, "Revocation of only confirmation should delete tx");
    assert.equal(transactionConfirmCount.valueOf(), 2, "Confirmation count should still be two b/c accounts[3] has not confirmed");
    assert.equal(requiredMajor.valueOf(), 4, "New sig requirement for major tx should be 4");
    assert.equal(badMajor.logs[0].args.msg,"Making requirement too high", "Should fail because the requirement is too high!");
  });

  it("should change requiredMinor after requiredAdmin number of confirmations and deny illegal requests", async () => {
    let id;

    const contract = await WalletLibTestContract.deployed();
    await contract.changeRequiredMinor(6, true, {from: accounts[2]});
    const changeSecondRequiredMinor = await contract.changeRequiredMinor(2, true, {from: accounts[1]});
    const changeSecondRequiredMinorId = ""+changeSecondRequiredMinor.logs[0].args.txid+"";
    await contract.revokeConfirm(changeSecondRequiredMinorId, {from:accounts[1]});
    const transactionLength = await contract.transactionLength(changeSecondRequiredMinorId);


    const changeThirdRequiredMinor = await contract.changeRequiredMinor(2, true, {from: accounts[1]});
    const changeThirdRequiredMinorFail = await contract.changeRequiredMinor(2, true, {from: accounts[1]});

    const changeThirdRequiredMinorId = ""+changeThirdRequiredMinor.logs[0].args.txid+"";
    await contract.confirmTx(changeThirdRequiredMinorId, {from:accounts[2]});
    await contract.changeRequiredMinor(2, false, {from: accounts[3]});
    const secondTransactionLength = await contract.transactionLength(changeThirdRequiredMinorId);
    const transactionConfirmCount = await contract.transactionConfirmCount(changeThirdRequiredMinorId, secondTransactionLength - 1);

    const badMinor = await contract.changeRequiredMinor(51, true, {from: accounts[1]});
    await contract.confirmTx(changeThirdRequiredMinorId, {from:accounts[3]});
    const requiredMinor = await contract.requiredMinor.call();

    assert.equal(changeThirdRequiredMinorFail.logs[0].args.msg,"Owner already confirmed", "Should fail because accounts[1] already confirmed!");
    assert.equal(transactionLength.valueOf(), 0, "Revocation of only confirmation should delete tx");
    assert.equal(transactionConfirmCount.valueOf(), 2, "Confirmation count should still be two b/c accounts[3] has not confirmed");
    assert.equal(requiredMinor.valueOf(), 2, "New sig requirement for minor tx should be 2");
    assert.equal(badMinor.logs[0].args.msg,"Making requirement too high", "Should fail because the requirement is too high!");

  });

  it("should change majorThreshold after requiredAdmin number of confirmations and deny illegal requests", async () => {
    let id;

    const c = await WalletLibTestContract.deployed();
    const tc = await TestToken.deployed();
    const tcAdd = ""+tc.address+"";

    const ret = await c.changeMajorThreshold(tcAdd, 3, true, {from: accounts[0]});
    id = ""+ret.logs[0].args.txid+"";
    await c.confirmTx(id, {from:accounts[1]});
    await c.revokeConfirm(id, {from:accounts[1]});
    const len = await c.transactionLength(id);
    const count = await c.transactionConfirmCount(id, len.valueOf() - 1);

    await c.changeMajorThreshold(tcAdd, 3, true, {from: accounts[0]});
    const len2 = await c.transactionLength(id);
    const count2 = await c.transactionConfirmCount(id, len2.valueOf() - 1);

    await c.changeMajorThreshold(tcAdd, 3, true, {from: accounts[1]});
    await c.changeMajorThreshold(tcAdd, 3, false, {from: accounts[1]});
    const countAfterRevoke = await c.transactionConfirmCount(id, len.valueOf() - 1);
    await c.confirmTx(id, {from:accounts[1]});
    const countAfterReConfirm = await c.transactionConfirmCount(id, len.valueOf() - 1);
    await c.confirmTx(id, {from:accounts[2]});
    const mt = await c.majorThreshold.call(tcAdd);

    const ret2 = await c.changeMajorThreshold(0, 50000000000000000000, true, {from: accounts[0]});
    id = ""+ret2.logs[0].args.txid+"";
    await c.confirmTx(id, {from:accounts[1]});
    var ret3 = await c.confirmTx(id, {from:accounts[2]});
    // var receipt1 = await web3.eth.getTransactionReceipt(ret3.receipt.transactionHash);

    // console.log("threshold "+receipt1.logs[0].topics[0]);
    const mt2 = await c.majorThreshold.call(0);

    assert.equal(countAfterRevoke.valueOf(),1,"Confirmation count should be 0 because accounts[1] revoked!");
    assert.equal(countAfterReConfirm.valueOf(),2,"confirmation count should be 1 becuase accounts[1] reconfirmed");
    assert.equal(count.valueOf(), 1, "Confirmation count should be one b/c accounts[1] revoked");
    assert.equal(count2.valueOf(), 1, "Confirmation count should still be one b/c accounts[0] already confirmed");
    assert.equal(mt.valueOf(), 3, "Major tx threshold for test token should be 3");
    assert.equal(mt2.valueOf(), 50000000000000000000, "Major tx threshold for ether should be 50");

  });
  it("should execute minor tx after requiredMinor number of confirmations and deny illegal requests", async () => {

    const contract  = await WalletLibTestContract.deployed();
    const testToken = await TestToken.deployed();
    const testTokenAddress = ""+testToken.address+"";
    await testToken.transfer(contract.address, 10, {from:accounts[1]});
    const accountsBalance = await web3.eth.getBalance(accounts[5]);
    const initialBalance = Math.floor(accountsBalance.valueOf()/10**18);
    await contract.sendTransaction({value: 100000000000000000000, from: accounts[5]});
    const addressBalance = await web3.eth.getBalance(contract.address);
    const balance = Math.floor(addressBalance.valueOf()/10**18);

    const accountServeTx = await contract.serveTx(accounts[5], 10000000000000000000, 0, true, {from: accounts[0]});
    const accountServeTxId = ""+accountServeTx.logs[0].args.txid+"";
    const accountConfirmTx = await contract.confirmTx(accountServeTxId, {from:accounts[2]});
    await contract.confirmTx(accountServeTxId, {from:accounts[2]});

    const testTokenTransferRequest = await testToken.transfer.request(accounts[5], 2);
    const testTokenTransferRequestData = testTokenTransferRequest.params[0].data;
    const testTokenServeTx = await contract.serveTx(testTokenAddress, 0, ""+testTokenTransferRequestData+"", true, {from: accounts[0]});
    const testTokenServeTxId = ""+testTokenServeTx.logs[0].args.txid+"";
    var ret = await contract.revokeConfirm(testTokenServeTxId, {from:accounts[2]});
    // var receipt1 = await web3.eth.getTransactionReceipt(ret.receipt.transactionHash);

    // console.log("revoke not "+receipt1.logs[0].topics[0]);
    const testTokenServeTxTransactionLenght = await contract.transactionLength(testTokenServeTxId);
    const testTokenTransactionConfirmCount = await contract.transactionConfirmCount(testTokenServeTxId, testTokenServeTxTransactionLenght.valueOf() - 1);

    await contract.serveTx(testTokenAddress, 0, ""+testTokenTransferRequestData+"", true, {from: accounts[0]});
    const secondTestTokenServeTxTransactionLenght = await contract.transactionLength(testTokenServeTxId);
    const secondTestTokenServeTxtransactionConfirmCount = await contract.transactionConfirmCount(testTokenServeTxId, secondTestTokenServeTxTransactionLenght.valueOf() - 1);

    var transactionConfirms = await contract.transactionConfirms(testTokenServeTxId, secondTestTokenServeTxTransactionLenght-1);

    var transactionSuccessBefore = await contract.transactionSuccess(testTokenServeTxId, secondTestTokenServeTxTransactionLenght-1);

    var ret = await contract.serveTx(testTokenAddress, 0, ""+testTokenTransferRequestData+"", true, {from: accounts[2]});
    // var receipt1 = await web3.eth.getTransactionReceipt(ret.receipt.transactionHash);

    // console.log("transaction complete "+receipt1.logs[0].topics[0]);
    const testTokenBalance = await testToken.balanceOf(""+contract.address+"");

    const receiverBalance = await testToken.balanceOf(accounts[5]);

    await testToken.approve.request(contract.address,2,{from:accounts[5]});
    const testTokenTransferFrom = await testToken.transferFrom.request(accounts[5],contract.address,2);
    const testTokenTFRequestData = testTokenTransferFrom.params[0].data;
    const testTokenServerTFTx = await contract.serveTx(testTokenAddress, 0, ""+testTokenTFRequestData+"", true, {from: accounts[0]});

    const receiverBalanceTwo = await testToken.balanceOf(accounts[5]);
    var currentDaySpend = await contract.currentSpend(testTokenAddress);

    var transactionSuccessAfter = await contract.transactionSuccess(testTokenServeTxId, secondTestTokenServeTxTransactionLenght-1);

    assert.equal(balance, 100, "100 ether should be transferred to the wallet from accounts[5]");
    assert.equal(accountConfirmTx.logs[0].args.value.valueOf(), 10000000000000000000, "10 ether should be transferred to accounts[5] from the wallet with 2 sigs");
    assert.equal(testTokenTransactionConfirmCount.valueOf(), 1, "Confirmation count should be one b/c accounts[2] has not confirmed");
    assert.equal(secondTestTokenServeTxtransactionConfirmCount.valueOf(), 1, "Confirmation count should be one b/c accounts[0] has already confirmed");
    assert.equal(testTokenBalance.valueOf(), 8, "2 tokens should be transferred to accounts[5] after 2 sigs");
    assert.equal(receiverBalance.valueOf(), 2, "accounts[5] should have received 2 tokens");
    assert.equal(receiverBalanceTwo.valueOf(), 2, "accounts[5] should have no tokens again b/c they were transferred")
    assert.equal(currentDaySpend[1],2,"Current day spend should be 2");
    assert.equal(transactionSuccessBefore,false, "Transaction success should be false before last confirm");
    assert.equal(transactionSuccessAfter,true, "Transaction success should be true after last confirm");
  });

  it("should execute major tx after requiredMajor number of confirmations and deny illegal requests", async () => {

    const contract = await WalletLibTestContract.deployed();
    const testToken = await TestToken.deployed();

    const testTokenAddress = ""+testToken.address+"";
    const accountsBalance = await web3.eth.getBalance(accounts[5]);
    const initialBalance = Math.floor(accountsBalance.valueOf()/10**18);
    await contract.sendTransaction({value: 100000000000000000000, from: accounts[5]});
    const secondAccountsBalance = await web3.eth.getBalance(accounts[5]);
    const firstRealBalance = initialBalance - Math.floor(secondAccountsBalance.valueOf()/10**18);

    const accountServeTx = await contract.serveTx(accounts[5], 60000000000000000000, 0, true, {from: accounts[0]});
    const accountServeTxId = ""+accountServeTx.logs[0].args.txid+"";
    const accountServeTxIdLength = await contract.transactionLength(accountServeTxId);

    await contract.confirmTx(accountServeTxId, {from:accounts[2]});
    await contract.serveTx(accounts[5], 60000000000000000000, 0, false, {from: accounts[2]});
    const serveConfirms = await contract.transactionConfirmCount(accountServeTxId, accountServeTxIdLength.valueOf() - 1);
    await contract.serveTx(accounts[5], 60000000000000000000, 0, true, {from: accounts[2]});
    const serveConfirmsAfterReConfirm = await contract.transactionConfirmCount(accountServeTxId, accountServeTxIdLength.valueOf() - 1);

    const thirdAccountsBalance = await web3.eth.getBalance(accounts[5]);
    const thirdRealBalance = initialBalance - Math.floor(thirdAccountsBalance.valueOf()/10**18);

    await contract.confirmTx(accountServeTxId, {from:accounts[3]});
    await contract.confirmTx(accountServeTxId, {from:accounts[1]});
    const fourthAccountsBalance = await web3.eth.getBalance(accounts[5]);
    const fourthRealBalance = initialBalance - Math.floor(fourthAccountsBalance.valueOf()/10**18);

    const testTokenTransferRequest = await testToken.transfer.request(accounts[5], 5);
    const testTokenTransferRequestData = testTokenTransferRequest.params[0].data;
    const testTokenServeTx = await contract.serveTx(testTokenAddress, 0, ""+testTokenTransferRequestData+"", true, {from: accounts[0]});
    const testTokenServeTxId = ""+testTokenServeTx.logs[0].args.txid+"";
    await contract.revokeConfirm(testTokenServeTxId, {from:accounts[2]});
    const testTokenServeTxTransactionLenght = await contract.transactionLength(testTokenServeTxId);
    const testTokenTransactionConfirmCount = await contract.transactionConfirmCount(testTokenServeTxId, testTokenServeTxTransactionLenght.valueOf() - 1);

    await contract.serveTx(testTokenAddress, 0, ""+testTokenTransferRequestData+"", true, {from: accounts[0]});
    const secondTestTokenServeTxtransactionLenght = await contract.transactionLength(testTokenServeTxId);
    const secondTestTokenServeTxtransactionConfirmCount = await contract.transactionConfirmCount(testTokenServeTxId, secondTestTokenServeTxtransactionLenght.valueOf() - 1);

    await contract.confirmTx(testTokenServeTxId, {from:accounts[2]});
    await contract.confirmTx(testTokenServeTxId, {from:accounts[3]});
    await contract.confirmTx(testTokenServeTxId, {from:accounts[1]});
    const addressBalance = await testToken.balanceOf(""+contract.address+"");

    assert.equal(serveConfirms.valueOf(),1,"should be 0 confirms since accounts[2] revoked!");
    assert.equal(serveConfirmsAfterReConfirm.valueOf(),2,"Should be 1 confirms since accounts[2] reconfirmed!");
    assert.equal(firstRealBalance, 100, "100 ether should be transferred to the wallet from accounts[5]");
    assert.equal(thirdRealBalance, 100, "No ether should be sent until 4 confirms");
    assert.equal(fourthRealBalance, 40, "60 ether should be transferred to accounts[5] from the wallet with 4 sigs");
    assert.equal(testTokenTransactionConfirmCount.valueOf(), 1, "Confirmation count should be one b/c accounts[2] has not confirmed");
    assert.equal(secondTestTokenServeTxtransactionConfirmCount.valueOf(), 1, "Confirmation count should be one b/c accounts[0] has already confirmed");
    assert.equal(addressBalance.valueOf(), 3, "3 tokens should be transferred to accounts[5] after 4 sigs");

  });
  it("should create contract after appropriate number of sigs, no target, and proper data", async () => {
    const data  = "0x6060604052341561000f57600080fd5b5b6103108061001f6000396000f300606060405263ffffffff60e060020a6000350416631d3b9edf811461004557806366098d4f1461006d578063e39bbf6814610095578063f4f3bdc1146100bd575b600080fd5b6100536004356024356100e5565b604051911515825260208201526040908101905180910390f35b610053600435602435610159565b604051911515825260208201526040908101905180910390f35b6100536004356024356101cd565b604051911515825260208201526040908101905180910390f35b610053600435602435610247565b604051911515825260208201526040908101905180910390f35b600082820282158382048514176100fe57506001905060005b8115610151576000805160206102c58339815191526040516020808252601390820152606860020a7274696d65732066756e63206f766572666c6f77026040808301919091526060909101905180910390a15b5b9250929050565b600082820182810384148382111661017357506001905060005b8115610151576000805160206102c58339815191526040516020808252601290820152607060020a71706c75732066756e63206f766572666c6f77026040808301919091526060909101905180910390a15b5b9250929050565b60008082156101e85750818304806020604051015260408051f35b6000805160206102c58339815191526040516020808252601790820152604860020a76747269656420746f20646976696465206279207a65726f026040808301919091526060909101905180910390a1506001905060005b9250929050565b60008183038083018414848210828614171660011461026857506001905060005b8115610151576000805160206102c58339815191526040516020808252601490820152606060020a736d696e75732066756e6320756e646572666c6f77026040808301919091526060909101905180910390a15b5b925092905056004eb9487277c052fc38bc53c91e4af51b26a1e7600aa1761ef9d2973180cf72a7a165627a7a72305820816921a222288d2b0efcc39a7dfdda6552de32e026d6a7f8b9e335dab1871dcb0029";

    const contract = await WalletLibTestContract.deployed();
    const serveTx = await contract.serveTx(0, 0, data, true, {from: accounts[0]});
    const id = ""+serveTx.logs[0].args.txid+"";
    await contract.confirmTx(id, {from:accounts[2]});
    await contract.confirmTx(id, {from:accounts[1]});
    const confirmTx = await contract.confirmTx(id, {from:accounts[3]});
    // var receipt1 = await web3.eth.getTransactionReceipt(confirmTx.receipt.transactionHash);

    // console.log("contract create "+receipt1.logs[0].topics[0]);

    assert.isDefined(confirmTx.logs[0].args.newContract, "New contract should be created if no target and proper data");
  });
});
