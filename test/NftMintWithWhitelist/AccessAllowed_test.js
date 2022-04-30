const { expect } = require("chai");
const { ethers } = require("hardhat");


describe("AccessControl test", function () {


    let accessControl;


    //Deploying contract before running tests
    beforeEach(async function () {
        //get available accounts from hardhat
        accounts = await hre.ethers.getSigners();
        //deploy contract
        const AccessControl = await hre.ethers.getContractFactory("AccessControl");
        accessControl = await AccessControl.deploy(); //mint price set to 1e15 = 1 finney = 0.001 eth
        await accessControl.deployed();
        console.log("AccessControl deployed to:", accessControl.address);

    })


    it("AccessControl, unlinked nft contract", async function () {
        //add address, by owner
        await accessControl.addAddressToAccessAllowed(accounts[1].address, 2);
        //this should be reverted, because we did not link the nft contract -> see AccessControl.sol line 
        await expect(accessControl.isAccessGranted(accounts[1].address)).to.be.reverted;
    });

    it("AccessControl, add addresses, check values", async function () {
        await accessControl.addAddressToAccessAllowed(accounts[1].address, 1);
        expect(await accessControl.getNrOfAllowedElementsPerAddress(accounts[1].address)).to.be.equal(1);

        await accessControl.addAddressToAccessAllowed(accounts[2].address, 2);
        expect(await accessControl.getNrOfAllowedElementsPerAddress(accounts[2].address)).to.be.equal(2);

    });


    it("AccessControl, double adding", async function () {
        accessControl.addAddressToAccessAllowed(accounts[1].address, 1);
        expect(await accessControl.getNrOfAllowedElementsPerAddress(accounts[1].address)).to.be.equal(1);

        //double adding
        await expect(accessControl.addAddressToAccessAllowed(accounts[1].address, 1)).to.be.reverted;

    });

    it("AccessControl, add and update nr of allowed", async function () {
        accessControl.addAddressToAccessAllowed(accounts[1].address, 1);
        expect(await accessControl.getNrOfAllowedElementsPerAddress(accounts[1].address)).to.be.equal(1);

        accessControl.addAddressToAccessAllowed(accounts[1].address, 3);
        expect(await accessControl.getNrOfAllowedElementsPerAddress(accounts[1].address)).to.be.equal(3);
    });

});