Majoolr Libraries
=========================

[![Build Status](https://travis-ci.org/Majoolr/ethereum-libraries.svg?branch=master)](https://travis-ci.org/Majoolr/ethereum-libraries)
[![Join the chat at https://gitter.im/Majoolr/EthereumLibraries](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/Majoolr/EthereumLibraries?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Discord](https://img.shields.io/discord/102860784329052160.svg)](https://discord.gg/crxYSF2)   

Majoolr Libraries is a group of packages built for use on blockchains utilizing the Ethereum Virtual Machine (EVM). All libraries are deployed and linkable in your smart contracts on both Rinkeby, Ropsten, and Ethereum Mainnet. [We also have an ethereum-contracts repository that currently holds ICO contracts](https://github.com/Majoolr/ethereum-contracts "Github link").  

Libraries and contracts are currently written in Solidity and Solidity Assembly. If you are not familiar with the workings of Ethereum, smart contracts, or Solidity [please educate yourself by clicking here before proceeding](https://solidity.readthedocs.io/en/develop/introduction-to-smart-contracts.html "Solidity link").

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [About Us](#about-us)
- [Why Majoolr Libraries?](#why-majoolr-libraries)
- [How to use](#how-to-use)
- [Why Libraries?](#why-libraries)
- [In Conclusion](#in-conclusion)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## About Us

Majoolr is hitting the ground running in becoming a valuable partner in the Ethereum community. We are not currently open for business but we are open for collaboration and seeking opportunities. [To learn more about Majoolr, our mission, as well as contributing please click here](https://majoolr.io "Majoolr website").

## Why Majoolr Libraries?

Majoolr Libraries aims to supplement current projects such as [Open-Zeppelin](https://github.com/OpenZeppelin/ "Zeppelin github") and others by utilizing the facilities Ethereum has in place to provide reusable source code on-chain. Our library code has been tested, documented, and deployed with the purpose of being used in Ethereum smart contracts. Be sure to familiarize yourself with libraries as well as the benefits and drawbacks to ensure you pick solutions that best fits your needs.  

**DISCLAIMER**  

While we make every effort to write, review, secure, test, and document professional grade code, all code is released open source under the MIT license and "without warranty of any kind." We shall not be held liable for any damages or lost funds so please be careful and prudent with your implementation. Please review and familiarize yourself with the entire license and accompanying disclaimers.  

**DISCLAIMER**  

## How to use

Majoolr Libraries has been packaged such that each library is available independently from any other library. You can browse each folder and pick the library or libraries that you need for your smart contracts.  

The README in each library contains the Rinkeby, Ropsten, and Mainnet address of the deployed library to link in your contract. You will find documentation for the functions and installation instructions for development and deployment use as well. Additionally, each library has as an ENS domain which is not of much use now but will provide a better experience as development proceeds. All deployed source code has been verified on etherscan.io for your viewing pleasure.   

If you do not find what you are looking for here please let us know and be sure check out more mature libraries such as [Open-Zeppelin](https://github.com/OpenZeppelin/ "Zeppelin github") and see what they have.

Feedback, bug reports, library submissions, collaborations, and contributions are all welcome! We will be rewarding contributions and please do not hesitate to reach out to us.  

## Why Libraries?

Utilizing libraries has some of the following benefits:   

* Reduce deployment costs

   The overall bytecode load you deploy for your own contracts is reduced because your contract will not contain the function used from a linked library's external function. Your contract will make external calls to a linked library.

* Provide reliability

   Common libraries and reusable source code naturally receive higher visibility and scrutiny. This provides better code for developers as well as a known location to report and review bugs after many use cases.

* Improve security

   Libraries help to improve the security of your code because of the same circumstances that provide reliability. With that said **please review the license and disclaimer before use**.

Utilizing libraries has some of the following drawbacks:   

* Increase execution costs

   Using external calls to library functions on-chain causes some overhead that does not exist when using internal functions. So, while contract deployments are less expensive, contract gas usage increases with execution. If this is a concern and you have a higher need to reduce gas usage upon execution than to reduce gas usage upon deployment, you can modify the contract function with an internal modifier. This will pull the function into your contract when you deploy. [Please review the Solidity docs on libraries if you are not familiar with this](http://solidity.readthedocs.io/en/develop/contracts.html#libraries "Solidity Libraries").

* Deployed libraries are immutable

   This is a concern more for our approach rather than the approach other repositories use. Since our focus is on deployed libraries, the code at this address is as permanent as the blockchain. Don't hold your breath for changes. There are some upsides in that immutable code is guaranteed to never have a breaking change so you can rely on it for as long as it is relevant. There are initiatives we've seen, particularly with Aragon and OpenZepplein, that plan on making library code upgradable to a certain extent. We will keep an eye on these developments as well as continue our plans to help develop a versioning system on-chain.

* Understanding someone else's code

   For the same reason libraries give us the benefit of reusable community code, it requires us to understand someone else's logic. Again, we strive for excellence, but sometimes it may not be the best implementation. Such as when we have used Solidity Assembly to improve our own competence in the language, the same thing could be done just as efficiently in basic Solidity. Our approach to this downside is to ensure we verify the deployed code and provide adequate documentation.

## In Conclusion

As always you should stay informed and determine what works best for you and your project. We look forward to working with everyone and we welcome anyone that wants to collaborate. [Please visit Majoolr.io](https://majoolr.io "Majoolr website") to see more information about us and opportunities.
