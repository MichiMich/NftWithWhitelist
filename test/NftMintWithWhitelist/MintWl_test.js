const { expect } = require("chai");
const { ethers } = require("hardhat");


describe("MintWl test", function () {

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


    it("MintWl, try minting without wl access", async function () {

        //minting without wl access
        await expect(nftContract.mint({ value: mintPrice })).to.be.reverted; //accounts[0] is used by default and not whitelisted
        await expect(nftContract.connect(accounts[1]).mint({ value: mintPrice })).to.be.reverted; //accounts[1] is not whitelisted as well
    });


    it("MintWl, link nft contract, mint with wl, enable public mint", async function () {
        await accessControl.linkNftContractAddress(nftContract.address);
        //add address, by owner
        await accessControl.addAddressToAccessAllowed(accounts[1].address, 1);
        await accessControl.addAddressToAccessAllowed(accounts[2].address, 1);
        // //check if address is allowed to access
        // expect(await accessControl.isAccessGranted(accounts[1].address)).to.be.true;
        // expect(await accessControl.getNrOfAllowedElementsPerAddress(accounts[1].address)).to.be.equal(1);

        //lets mint with allowed adress
        await nftContract.connect(accounts[1]).mint({ value: mintPrice }); //accounts[1] is whitelisted

        await nftContract.connect(accounts[2]).mint({ value: mintPrice }); //accounts[2] is whitelisted as well

        //check if others can mint
        await expect(nftContract.connect(accounts[3]).mint({ value: mintPrice })).to.be.reverted; //accounts[1] is not whitelisted as well


        //open bublic mint
        await nftContract.enablePublicMint();
        console.log("public mint enabled");
        //lets mint
        await nftContract.connect(accounts[3]).mint({ value: mintPrice });
        //now even accounts which have already minted, can mint again
        await nftContract.connect(accounts[2]).mint({ value: mintPrice })

        //minted out, expect others to get reverted
        await expect(nftContract.connect(accounts[4]).mint({ value: mintPrice })).to.be.reverted;

    });






});