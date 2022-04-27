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
        const NftMintContract = await hre.ethers.getContractFactory("OnChainNftMintContract");
        nftContract = await NftMintContract.deploy(useSeedWithTestnet, mintPrice); //mint price set to 1e15 = 1 finney = 0.001 eth
        await nftContract.deployed();
        console.log("nftMintContract deployed to:", nftContract.address);
    })


    it("MintAndAccess, try adding address while not the owner", async function () {
        //add address, not by owner
        await expect(accessControl.connect(accounts[2]).addAddressToAccessAllowed(accounts[3].address, 1)).to.be.reverted;
    });

    it("MintAndAccess, link, add address, check access", async function () {
        await accessControl.linkNftContractAddress(nftContract.address);
        //add address, by owner
        await accessControl.addAddressToAccessAllowed(accounts[1].address, 1);
        //check if address is allowed to access
        expect(await accessControl.isAccessGranted(accounts[1].address)).to.be.true;

        expect(await accessControl.getNrOfAllowedElementsPerAddress(accounts[1].address)).to.be.equal(1);

    });


    it("MintAndAccess, add multiple, mint, check nr and access again", async function () {
        const allowedNrOfMints = 3;

        await accessControl.linkNftContractAddress(nftContract.address);
        //add address, by owner
        await accessControl.addAddressToAccessAllowed(accounts[2].address, allowedNrOfMints);
        //check if address is allowed to access
        expect(await accessControl.isAccessGranted(accounts[2].address)).to.be.true;

        expect(await accessControl.getNrOfAllowedElementsPerAddress(accounts[2].address)).to.be.equal(allowedNrOfMints);

        //mint two more
        for (let i = 1; i <= allowedNrOfMints; i++) {
            //mint one, pay needed amount
            await (nftContract.connect(accounts[2]).mint({ value: mintPrice }));

            console.log("nft balance of account2", await nftContract.balanceOf(accounts[2].address))
            if (i != allowedNrOfMints) {
                //max allowed not reached yet
                expect(await accessControl.isAccessGranted(accounts[2].address)).to.be.true;
            }
            else {
                //zero left, not allowed anymore
                expect(await accessControl.isAccessGranted(accounts[2].address)).to.be.false;
            }
            //check if nr of left is correct
            console.log("nr of remaining nfts: ", await accessControl.getRemainingNrOfElementsPerAddress(accounts[2].address));
            //nr of left ones
            expect(await accessControl.getRemainingNrOfElementsPerAddress(accounts[2].address)).to.be.equal(allowedNrOfMints - i);
        }

    });





});