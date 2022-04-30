require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");

let secrets = require("./secrets");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      loggingEnabled: true,
    },
    rinkeby: {
      url: secrets.url,
      accounts: [secrets.key1, secrets.key2, secrets.key3],
      gas: 2100000,
      gasPrice: 8000000000
    },
    ropsten: {
      url: secrets.url_ropsten,
      accounts: [secrets.key1, secrets.key2, secrets.key3],
      gas: 2100000,
      gasPrice: 8000000000
    }
  },
  etherscan: {
    apiKey: "N88FMJSQKXBBWPWCH7RBF3SWJB7NQ2XQTE"
  },
  solidity: "0.8.4",
};
