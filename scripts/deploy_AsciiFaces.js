const hre = require("hardhat");
const { ethers } = require("hardhat");

async function main() {


    // We get the contract to deploy
    const NftContract = await hre.ethers.getContractFactory("OnChainNftMintContract");
    const nftContract = await NftContract.deploy(false, ethers.utils.parseUnits("1", 15)); //mint price set to 1e15 = 1 finney = 0.001 eth

    await nftContract.deployed();

    console.log("nftContract deployed to:", nftContract.address);

    //Check how much mint combinations are available
    let availableMintCombinations = await nftContract.totalSupply();
    console.log("total nft supply: ", availableMintCombinations);

    //now lets mint out
    let ethTransmitValueInWei = 1e15;
    console.log("contract balance before mint: ", await nftContract.getBalance());
    for (let i = 0; i < availableMintCombinations; i++) {
        createdNft = await nftContract.mint({ value: ethTransmitValueInWei });
        console.log("created nft: ", createdNft);


        //tokenUri
        let tokenUri = await nftContract.tokenURI(i);
        console.log("created AsciiFace: ", tokenUri);

    }

    console.log("contract balance after mint: ", await nftContract.getBalance());




}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
