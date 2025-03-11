require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-toolbox");
require("hardhat-gas-reporter");
require("dotenv").config();

const INFURA_RPC_URL = process.env.INFURA_RPC_URL;
const ACCOUNT_PRIVATE_KEY = process.env.ACCOUNT_PRIVATE_KEY;
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;
const COINMARKETCAP = process.env.COINMARKETCAP_API_KEY;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.24",
  defaultNetwork: "sepolia",
  gasReporter: {
    enabled: true,           
    currency: "USD",           // Currency in which to report costs
    coinmarketcap: COINMARKETCAP,  
    outputFile: "gas-report.txt",  // The File where to save the report
    noColors: false, 
    // gasPrice: 20, 
   offline: true,           
  },
  networks: {
    hardhat: {},
    sepolia: {
      url: `${INFURA_RPC_URL}`,
      accounts: [ACCOUNT_PRIVATE_KEY],
      chainId: 11155111,
    },	
    
  },
  etherscan: {
    apiKey: {
      sepolia: ETHERSCAN_API_KEY,
    },
  },
  sourcify: {
    enabled: true
  },
  // paths: {
  //   artifacts: "./src/artifacts",
  // },
};
