pragma solidity ^0.4.18;

/**
 * Direct Crowdsale Contract
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

import "./DirectCrowdsaleLib.sol";
import "./CrowdsaleTestTokenZeroD.sol";

contract DirectCrowdsaleTestZeroD {
  using DirectCrowdsaleLib for DirectCrowdsaleLib.DirectCrowdsaleStorage;

  DirectCrowdsaleLib.DirectCrowdsaleStorage sale;

  function DirectCrowdsaleTestZeroD(
                address owner,
                uint256[] saleData,
                uint256 endTime,
                uint8 percentBurn,
                CrowdsaleToken token)
                public
  {
  	sale.init(owner, saleData, endTime, percentBurn, token);
  }

  // fallback function can be used to buy tokens
  function () payable public {
    sendPurchase();
  }

  function sendPurchase() payable public returns (bool) {
  	return sale.receivePurchase(msg.value);
  }

  function withdrawTokens() public returns (bool) {
  	return sale.withdrawTokens();
  }

  function withdrawLeftoverWei() public returns (bool) {
    return sale.withdrawLeftoverWei();
  }

  function withdrawOwnerEth() public returns (bool) {
    return sale.withdrawOwnerEth();
  }

  function crowdsaleActive() public view returns (bool) {
    return sale.crowdsaleActive();
  }

  function crowdsaleEnded() public view returns (bool) {
    return sale.crowdsaleEnded();
  }

  function setTokens() public returns (bool) {
    return sale.setTokens();
  }

  function getOwner() public view returns (address) {
    return sale.base.owner;
  }

  function getTokensPerEth() public view returns (uint256) {
    return sale.base.tokensPerEth;
  }

  function getStartTime() public view returns (uint256) {
    return sale.base.startTime;
  }

  function getEndTime() public view returns (uint256) {
    return sale.base.endTime;
  }

  function getEthRaised() public view returns (uint256) {
    return sale.base.ownerBalance;
  }

  function getContribution(address _buyer) public view returns (uint256) {
  	return sale.base.hasContributed[_buyer];
  }

  function getTokenPurchase(address _buyer) public view returns (uint256) {
  	return sale.base.withdrawTokensMap[_buyer];
  }

  function getLeftoverWei(address _buyer) public view returns (uint256) {
    return sale.base.leftoverWei[_buyer];
  }

  function getSaleData(uint256 timestamp) public view returns (uint256[3]) {
    return sale.getSaleData(timestamp);
  }

  function getTokensSold() public view returns (uint256) {
    return sale.getTokensSold();
  }

  function getPercentBurn() public view returns (uint256) {
    return sale.base.percentBurn;
  }
}
