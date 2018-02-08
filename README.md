Modular Libraries
=========================

[![Build Status](https://travis-ci.org/Modular-Network/ethereum-libraries.svg?branch=master)](https://travis-ci.org/Modular-Network/ethereum-libraries)
[![codecov](https://codecov.io/gh/Modular-Network/ethereum-libraries/branch/master/graph/badge.svg)](https://codecov.io/gh/Modular-Network/ethereum-libraries)
[![Join the chat at https://gitter.im/Modular-Network/Lobby](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/Modular-Network/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Discord](https://img.shields.io/discord/102860784329052160.svg)](https://discord.gg/crxYSF2)   
[![Waffle.io - Columns and their card count](https://badge.waffle.io/Modular-Network/ethereum-libraries.svg?columns=all)](https://waffle.io/Modular-Network/ethereum-libraries)


Modular Libraries is a group of packages built for use on blockchains utilizing the Ethereum Virtual Machine (EVM). All libraries are deployed and linkable in your smart contracts on both Rinkeby, Ropsten, and Ethereum Mainnet. [We also have an ethereum-contracts repository that currently holds ICO contracts](https://github.com/Modular-Network/ethereum-contracts "Github link").  

Libraries and contracts are currently written in Solidity and Solidity Assembly. If you are not familiar with the workings of Ethereum, smart contracts, or Solidity [please educate yourself by clicking here before proceeding](https://solidity.readthedocs.io/en/develop/introduction-to-smart-contracts.html "Solidity link").

If you want to contribute to the libraries or just join the discussion on smart contract development and security, please join our Discord at https://discordapp.com/invite/crxYSF2

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [About Us](#about-us)
- [Why Modular Libraries?](#why-modular-libraries)
- [How to use](#how-to-use)
- [How to Contribute](#how-to-contribute)
  - [Feedback and Bug Reports](#feedback-and-bug-reports)
  - [Collaborations](#collaborations)
  - [Code Contributions](#code-contributions)
  - [Code Quality](#code-quality)
- [Why Libraries?](#why-libraries)
- [In Conclusion](#in-conclusion)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## About Us

Modular is hitting the ground running in becoming a valuable partner in the Ethereum community. Our new website is going up shortly because we just went through an identity crisis. [To learn more about Modular on our website, our mission, as well as contributing please click here](https://modular.network "Modular website").

## Why Modular Libraries?

Modular Libraries aims to supplement current projects such as [Open-Zeppelin](https://github.com/OpenZeppelin/ "Zeppelin github") and others by utilizing the facilities Ethereum has in place to provide reusable source code on-chain. Our library code has been tested, documented, and deployed with the purpose of being used in Ethereum smart contracts. Be sure to familiarize yourself with libraries as well as the benefits and drawbacks to ensure you pick solutions that best fits your needs.  

**DISCLAIMER**  

While we make every effort to write, review, secure, test, and document professional grade code, all code is released open source under the MIT license and "without warranty of any kind." We shall not be held liable for any damages or lost funds so please be careful and prudent with your implementation. Please review and familiarize yourself with the entire license and accompanying disclaimers.  

**DISCLAIMER**  

## How to use

Modular Libraries has been packaged such that each library is available independently from any other library. You can browse each folder and pick the library or libraries that you need for your smart contracts.  

The README in each library contains the Rinkeby, Ropsten, and Mainnet address of the deployed library to link in your contract. You will find documentation for the functions and installation instructions for development and deployment use as well. Additionally, each library has as an ENS domain which is not of much use now but will provide a better experience as development proceeds. All deployed source code has been verified on etherscan.io for your viewing pleasure.   

## How to Monitor Events Emmitted by Modular Libraries

In docs/LibraryLogHashes.csv, you can find a listing of all of the zero-topic hashes for the events that our libraries emit.  You can use these in your web app to monitor events that contracts that use our libraries emit.  

## How to Contribute

Feedback, bug reports, library submissions, collaborations, and contributions are all welcome! We will be rewarding contributions so please do not hesitate to reach out to us.

### Feedback and Bug Reports
If you have feedback about our libraries or questions about our documentation, or find a bug in our code, please contact us as soon as possible at contact@modular.network or reach out to us on on Gitter or Discord channel.  Significant contributions will be rewarded.

### Collaborations
As part of the global Ethereum/Blockchain community, we at Modular want to do our part in supporting fellow projects and enthusiasts in the community.  If you need an audit, advice, help building a secure ICO or Ethereum Dapp, or any other type of collaboration, please get in touch at contact@modular.network where we can discuss the collaboration.

### Code Contributions
If you see an issue in our repo or a piece of code in our Libraries you want to improve, please don't hesitate to dive in.  We welcome help in any form and are more than willing to offer our assistance to developers who want to contribute to documentation, code fixes, or even new libraries or functionality!  We ask that you follow a few guidelines when making changes to the repo:

1. Create a branch separate from master for any changes.
2. Create separate branches and submissions for unrelated changes.
3. Please adhere to [Ethereum Natural Specification Format Guidelines](https://github.com/ethereum/wiki/wiki/Ethereum-Natural-Specification-Format) for function documentation.  Also, leave comments on functional blocks in the code so that any functionality is easy to understand by any moderately competent developer reading the code.
5. If you are making significant changes, include a README with function signatures, inputs, outputs, and a detailed description of the functionality.
6. Include the description of the changes on the Pull Request.
7. When creating a pull request on the main repo, do not submit it to master.  Either submit it to an existing branch that was allocated for the changes, or submit it to a new branch you create with the PR.

### Code Quality

We strive to maintain high standards at Modular. To accomplish this, we have included unit tests and a coverage report tool. We are using the [solitidy-coverage](https://github.com/sc-forks/solidity-coverage) tool and [Codecov](https://codecov.io/gh/Modular-Network/ethereum-libraries) to host our reports and analysis. Let's keep growing our coverage percentage as much as we can!

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

As always you should stay informed and determine what works best for you and your project. We look forward to working with everyone and we welcome anyone that wants to collaborate. [Please visit modular.network](https://modular.network"Modular website") to see more information about us and opportunities.
