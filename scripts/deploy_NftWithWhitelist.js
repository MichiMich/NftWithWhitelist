

const hre = require("hardhat");
const { ethers } = require("hardhat");


async function main() {

    let accessControl;
    let nftContract;
    const mintPrice = ethers.utils.parseUnits("1", 15);

    //get available accounts from hardhat
    accounts = await hre.ethers.getSigners();
    //console.log("accounts: ", accounts);
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
    const NftMintContract = await hre.ethers.getContractFactory("OnChainNftWithAccessControl");
    nftContract = await NftMintContract.deploy(useSeedWithTestnet, mintPrice, accessControl.address); //mint price set to 1e15 = 1 finney = 0.001 eth
    await nftContract.deployed();
    console.log("nftMintContract deployed to:", nftContract.address);


    //add 2 addresses to whitelist, let them mint, open public mint, mint another one
    await accessControl.linkNftContractAddress(nftContract.address);

    //check chain and use wallet from mm or hardhat

    //add address, by owner
    await accessControl.addAddressToAccessAllowed(accounts[1].address, 1);
    await accessControl.addAddressToAccessAllowed(accounts[2].address, 1);
    //let them mint
    await (nftContract.connect(accounts[1]).mint({ value: mintPrice }));
    await (nftContract.connect(accounts[2]).mint({ value: mintPrice }));

    //open public mint
    await nftContract.enablePublicMint();
    //lets mint
    await nftContract.connect(accounts[2]).mint({ value: mintPrice });
    //now even accounts which have already minted, can mint again
    await nftContract.connect(accounts[2]).mint({ value: mintPrice })

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
