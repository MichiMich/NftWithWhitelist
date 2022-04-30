const { expect } = require("chai");
const { ethers } = require("hardhat");


describe("Mint and accessControl test", function () {


    let accessControl;
    let nftContract;
    const mintPrice = ethers.utils.parseUnits("1", 15);

    //Deploying contract before running tests
    beforeEach(async function () {
        //get available accounts from hardhat
        accounts = await hre.ethers.getSigners();
        //deploy contract
        const AccessControl = await hre.ethers.getContractFactory("AccessControl");
        accessControl = await AccessControl.deploy();
        await accessControl.deployed();
        console.log("AccessControl deployed to:", accessControl.address);


        //nft mint contract specific
        const networkName = hre.network.name
        const chainId = hre.network.config.chainId
        console.log("chainId: ", chainId);
        let useSeedWithTestnet;
        if (chainId == "4" || networkName === "rinkeby") {
            //rinkeby
            console.log("seed with testnet used");
            useSeedWithTestnet = true;
        }
        const NftMintContract = await hre.ethers.getContractFactory("NftMintWithWhitelist");
        nftContract = await NftMintContract.deploy(useSeedWithTestnet, mintPrice, accessControl.address); //mint price set to 1e15 = 1 finney = 0.001 eth
        await nftContract.deployed();
        console.log("nftMintContract deployed to:", nftContract.address);
    })

    it("getTokenURI_NftMintWithWhitelist, mint and request created token URI", async function () {
        const nrOfAvailableNfts = 4;

        //we just want to check generated token URIs so we will public mint all nfts
        await nftContract.enablePublicMint();
        console.log("public mint enabled");

        //mint two more
        let tokenURI;
        for (let i = 0; i < nrOfAvailableNfts; i++) {
            //mint one, pay needed amount
            await (nftContract.mint({ value: mintPrice }));
            console.log("nft balance of account0", await nftContract.balanceOf(accounts[0].address))
            tokenURI = await nftContract.tokenURI(i);
            console.log("tokenURI of id: ", i, "\n\n", tokenURI);
        }

    });






});