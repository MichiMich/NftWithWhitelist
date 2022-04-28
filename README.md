

# Nft with whitelist

<img src="./gifs/AsciiFaces.gif" width="142" height="142" />

<img src="./img/OpenseaAsciiFAce.png" width="490" height="301" />

## Short description
Creating two contracts.

1. A **nft contract** including the ERC721 standard which will create different AsciiFaces fully onchain
2. An **AccessControl contract** which defines which adddress can mint what number of elements of the nft contract given in 1.


## Details
### fully onchain
Creating fully onchain generated AsciiFaces using base64 encoding and svg creation - no need for storing the picture/image/svg on any decentralized/centralized storage.

### random and all mint combinations
Defining all possible mint combinations during deployment of the contract.
Combination of a choosen number at mint and the clearing of the used mint combinations to generate one of its kind nfts only - all "random" created - no duplicates.
**its no full randomness, if you want a true unbiased randomness you should go for <a href="https://docs.chain.link/docs/chainlink-vrf/">chainlink VRF</a>**

### Realization of a whitelist

The whitelist is realized by linking the nft contract with the AccessControl contract and vice versa. This ensures that the mint function of the nft contract can only be accessed by addresses which are granted access
from the AccessControl access during non-public mint.


## Prerequisites
<ul  dir="auto">
<li><a  href="https://nodejs.org/en/download/"  rel="nofollow">Nodejs and npm</a>
You'll know you've installed nodejs right if you can run:
<code>node --version</code> and get an ouput like: <code>vx.x.x</code>
</ul>
<ul  dir="auto">
<li><a  href="https://hardhat.org/getting-started/"  rel="nofollow">hardhat</a>
You'll know you've installed hardhat right if you can run:
<code>npx hardhat --version</code> and get an ouput like: <code>2.9.3</code>
</ul>
<ul  dir="auto">
A webbrowser, since you can read this here I should not have to  mention it^^
</ul>
<ul  dir="auto">
Basic understand of js, hardhat and solidity. If you want to get basic understanding up to expert I highly recommend
the man, the myth, the legend: <a href="https://www.youtube.com/watch?v=M576WGiDBdQ&t=10s">Patrick Collins</a>
</ul>
<ul  dir="auto">
Some rinkeby eth if you deploying to rinkeby testnet, you could grap some <a href="https://faucets.chain.link/rinkeby">here</a>
</ul>



## dependencies
### openzeppelin
    ´npm install --save-dev @openzeppelin/contracts´


## For the fast runners
## clone repository
fire up the git clone command: <code>https://github.com/MichiMich/NftWithWhitelist</code>
## cd into it
<code>cd NftWithWhitelist</code>

## and deploy/mint it:
a) to local hardhat: <code>npx hardhat run scripts/deploy_NftWithWhitelist.js</code> or

b) rinkeby: 
**never share your private keys with anyone! I highly recommend you to create a new wallet only for testing contracts, dont use your wallets with actual money on it!! Please friend be save, better save than sorry! If you want to push your data on github, add the <code>secrets.json</code> at the .gitignore file**

I used 3 wallets for the deploy script, so you can add the private keys at secrets.json or adapt the scripts/deploy_NftWithWhitelist.js file to only use one account, then you would only need one private key

fill in your <a href="https://www.alchemy.com/">alchemy url</a> and private keys from your wallet at the secrets.json file and deploy it on rinkeby with <code>npx hardhat run scripts/deploy_NftWithWhitelist.js --network rinkeby</code>

    

