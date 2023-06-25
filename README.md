# PROTOTYPE

A platform powered by smart contracts that allows anyone to fundraise or collect donations

What technologies we use:
- Solidity
- React
- [Sismo Factory](https://github.com/sismo-core/sismo-hub)
- [Sismo Connect](https://github.com/sismo-core/sismo-connect-onchain-verifier)
- [Worldcoin ID](https://github.com/worldcoin/world-id-poap)
- Linea for smart contract deployment

### The main idea
Prototype provides a place where users can create their fundraising or donation projects. Prototype is fully decentralized, open source, and can be used without a UI. Sismo data is implemented as a smart contract. 

To use the platform, users need to verify their onchain and offchain activity. Prototype uses `Sismo Factory Group` for this. According to this activity each user gets a level of access.

1. Level 1 > raise no more than $100 > Gitcoin Passport 10
2. Level 2 > raise no more than $1.000 > Gitcoin Passport 15, ENS
3. Level 3 > raise no more than $10.000 > Gitcoin Passport 21, ENS, Degenscore 800
4. Level 4 > raise no more than $50.000 > Gitcoin Passport 32, ENS, Degenscore 1200, `Worldcoin ID POAP`
5. Level 5 > no limits > Users have to sign a legal agreement, pass KYC and be approved by us

Worldcoin ID POAP links user identity and EVM address. It works like a KYC. We apply this POAP in Sismo Group Level 4.

### The process
Users create their projects using Prototype platform by logging in through Sismo Connect. There are a few settings:
- term of deposit
- the sum according access level
- type of project: fundraise or donate
- title
- description
- social links
- frontpage image
- hidden project or not

People who make deposits can see all neceserary data about the fundraise creator like: EVM address, contract address, level access, social links.

**Prototype has a fee - 3% for all projects.** Prototype can reduce fees to 0 for donations in case if users have a special POAP.

Users can claim their funds only when the amount is reached or the time is over. Users claim the funds and pay the gas fee for Prototype fees. 
