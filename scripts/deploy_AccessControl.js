const hre = require("hardhat");
const { ethers } = require("hardhat");


async function main() {


    //get available accounts from hardhat
    accounts = await hre.ethers.getSigners();
    //deploy contract
    const AccessControl = await hre.ethers.getContractFactory("AccessControl");
    const accessControl = await AccessControl.deploy(); //mint price set to 1e15 = 1 finney = 0.001 eth
    await accessControl.deployed();

    console.log("AccessControl deployed to:", accessControl.address);

    //add address, by owner
    await accessControl.addAddressToAccessAllowed(accounts[1].address, 1);

    //link nft contract

    //check if address is allowed to access



}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
