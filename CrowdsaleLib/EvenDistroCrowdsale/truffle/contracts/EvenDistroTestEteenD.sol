pragma solidity ^0.4.18;

/**
 * Even Distro Contract
 *
 * Majoolr provides smart contract services and security reviews for contract
 * deployments in addition to working on open source projects in the Ethereum
 * community. Our purpose is to test, document, and deploy reusable code onto the
 * blockchain and improve both security and usability. We also educate non-profits,
 * schools, and other community members about the application of blockchain
 * technology.
 * For further information: majoolr.io
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import "./EvenDistroCrowdsaleLib.sol";
import "./CrowdsaleTestTokenEteenD.sol";

contract EvenDistroTestEteenD {
  using EvenDistroCrowdsaleLib for EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage;

  EvenDistroCrowdsaleLib.EvenDistroCrowdsaleStorage sale;

  function EvenDistroTestEteenD(
    address owner,
    uint256[] saleData,
    uint256 endTime,
    uint8 percentBurn,
    uint256 initialAddressTokenCap,
    bool staticCap,
    CrowdsaleToken token)
  {
  	sale.init(owner, saleData, endTime, percentBurn, initialAddressTokenCap, staticCap, token);
  }

  event LogTokensBought(address buyer, uint256 amount);
  event LogUserRegistered(address registrant);
  event LogUserUnRegistered(address registrant);
  event LogErrorMsg(uint256 amount, string Msg);
  event LogRegError(address user, string Msg);
  event LogAddressTokenCapChange(uint256 amount, string Msg);
  event LogTokenPriceChange(uint256 amount, string Msg);
  event LogAddressTokenCapCalculated(uint256 numRegistered, uint256 cap, string Msg);
  event LogTokensWithdrawn(address indexed _bidder, uint256 Amount);
  event LogWeiWithdrawn(address indexed _bidder, uint256 Amount);
  event LogOwnerEthWithdrawn(address indexed owner, uint256 amount, string Msg);
  event LogNoticeMsg(address _buyer, uint256 value, string Msg);

  // fallback function can be used to buy tokens
  function () payable {
    sendPurchase();
  }

  function sendPurchase() payable returns (bool) {
  	return sale.receivePurchase(msg.value);
  }

  function registerUser(address _registrant) returns (bool) {
    return sale.registerUser(_registrant);
  }

  function registerUsers(address[] _registrants) returns (bool) {
    return sale.registerUsers(_registrants);
  }

  function unregisterUser(address _registrant) returns (bool) {
    return sale.unregisterUser(_registrant);
  }

  function unregisterUsers(address[] _registrants) returns (bool) {
    return sale.unregisterUsers(_registrants);
  }

  function isRegistered(address _registrant) constant returns (bool) {
    return sale.isRegistered[_registrant];
  }

  function withdrawTokens() returns (bool) {
    return sale.withdrawTokens();
  }

  function withdrawLeftoverWei() returns (bool) {
    return sale.withdrawLeftoverWei();
  }

  function withdrawOwnerEth() returns (bool) {
  	return sale.withdrawOwnerEth();
  }

  function crowdsaleActive() constant returns (bool) {
  	return sale.crowdsaleActive();
  }

  function crowdsaleEnded() constant returns (bool) {
  	return sale.crowdsaleEnded();
  }

  function setTokens() returns (bool) {
    return sale.setTokens();
  }

  function getOwner() constant returns (address) {
    return sale.base.owner;
  }

  function getTokensPerEth() constant returns (uint256) {
    return sale.base.tokensPerEth;
  }

  function getStartTime() constant returns (uint256) {
    return sale.base.startTime;
  }

  function getEndTime() constant returns (uint256) {
    return sale.base.endTime;
  }

  function getEthRaised() constant returns (uint256) {
    return sale.base.ownerBalance;
  }

  function getContribution(address _buyer) constant returns (uint256) {
    return sale.base.hasContributed[_buyer];
  }

  function getTokenPurchase(address _buyer) constant returns (uint256) {
    return sale.base.withdrawTokensMap[_buyer];
  }

  function getLeftoverWei(address _buyer) constant returns (uint256) {
    return sale.base.leftoverWei[_buyer];
  }

  function getSaleData(uint256 timestamp) constant returns (uint256[3]) {
    return sale.getSaleData(timestamp);
  }

  function getTokensSold() constant returns (uint256) {
    return sale.getTokensSold();
  }

  function getPercentBurn() constant returns (uint256) {
    return sale.base.percentBurn;
  }

  function getAddressTokenCap() constant returns (uint256) {
    return sale.addressTokenCap;
  }

  function getNumRegistered() constant returns (uint256) {
    return sale.numRegistered;
  }
}
