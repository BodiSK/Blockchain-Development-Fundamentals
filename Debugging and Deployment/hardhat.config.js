require("@nomicfoundation/hardhat-toolbox");
require("./tasks/index.js")
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version : "0.8.28",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
        }
      }
  },
  networks: {
    sepolia: {
      url: process.env.TESTNET_WEB3_PROVIDER_URL,
      accounts: [process.env.PRIVATE_KEY]
      }
    }    
};
