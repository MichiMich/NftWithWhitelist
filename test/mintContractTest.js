const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("OnChainNftMint", function () {

  it("try mint with low send amount", async function () {
    // We get the contract to deploy
    const NftContract = await hre.ethers.getContractFactory("OnChainNftMintContract");
    const nftContract = await NftContract.deploy(false, ethers.utils.parseUnits("1", 15)); //mint price set to 1e15 = 1 finney = 0.001 eth
    await nftContract.deployed();
    let ethTransmitValueInWei = 0.5e15;
    await expect(nftContract.mint({ value: ethTransmitValueInWei })).to.be.reverted;
  });


  it("check balance during mint and try minting more than available", async function () {
    // We get the contract to deploy
    const NftContract = await hre.ethers.getContractFactory("OnChainNftMintContract");
    const nftContract = await NftContract.deploy(false, ethers.utils.parseUnits("1", 15)); //mint price set to 1e15 = 1 finney = 0.001 eth
    await nftContract.deployed();
    let ethTransmitValueInWei = ethers.utils.parseUnits("1", 15);
    let availableMintCombinations = await nftContract.totalSupply();

    let contractBalance;
    for (let i = 0; i < availableMintCombinations; i++) {
      await nftContract.mint({ value: ethTransmitValueInWei });
      contractBalance = await nftContract.getBalance();
      expect(contractBalance).to.equal(JSON.stringify((i + 1) * ethTransmitValueInWei));
    }

    //they should now be minted out and the following wanted mint should be reverted
    await expect(nftContract.mint({ value: ethTransmitValueInWei })).to.be.reverted;

  });


  it("diff accounts mint, ownership check", async function () {
    //get all accounts
    accounts = await hre.ethers.getSigners();

    // We get the contract to deploy
    const NftContract = await hre.ethers.getContractFactory("OnChainNftMintContract");
    const nftContract = await NftContract.deploy(false, ethers.utils.parseUnits("1", 15)); //mint price set to 1e15 = 1 finney = 0.001 eth
    await nftContract.deployed();
    let ethTransmitValueInWei = ethers.utils.parseUnits("1", 15);

    //let owner mint 2
    await nftContract.mint({ value: ethTransmitValueInWei });
    await nftContract.mint({ value: ethTransmitValueInWei });

    //let next account mint 1
    await nftContract.connect(accounts[1]).mint({ value: ethTransmitValueInWei });
    await nftContract.connect(accounts[2]).mint({ value: ethTransmitValueInWei });

    //the following lines prove simply the functionality implemented by ERC721Enumerable

    //check balances
    let nftBalanceOfGivenAccount;
    //account[0] did mint 2
    nftBalanceOfGivenAccount = await (nftContract.balanceOf(accounts[0].address));
    expect(nftBalanceOfGivenAccount).to.equal(2);

    //account[1] did mint 1
    nftBalanceOfGivenAccount = await (nftContract.balanceOf(accounts[1].address));
    expect(nftBalanceOfGivenAccount).to.equal(1);

    //account[2] did mint 1
    nftBalanceOfGivenAccount = await (nftContract.balanceOf(accounts[2].address));
    expect(nftBalanceOfGivenAccount).to.equal(1);

    //check ownership
    let ownerOfNft;
    //account[0] owns nfts with id 0 and 1
    ownerOfNft = await nftContract.ownerOf(0);
    expect(ownerOfNft).to.equal(accounts[0].address);
    ownerOfNft = await nftContract.ownerOf(1);
    expect(ownerOfNft).to.equal(accounts[0].address);
    //account[1] owns nft with id 2
    ownerOfNft = await nftContract.ownerOf(2);
    expect(ownerOfNft).to.equal(accounts[1].address);

    //account[2] owns nft with id 3
    ownerOfNft = await nftContract.ownerOf(3);
    expect(ownerOfNft).to.equal(accounts[2].address);

  });

});
