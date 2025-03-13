const hre = require("hardhat");
const fs = require("fs").promises;
const path = require("path");


const addressFile = require("../address.json");

let ContractAddress;
let baseURI;

async function deploy() {
  
  try {
    console.log("Deploying XAUPriceNFT...");
    const deployer = (await hre.ethers.getSigners())[0];
    // Deploy XAUPriceNFT contract
    const xauPriceNFT = await hre.ethers.deployContract("XAUPriceNFT",[baseURI]);
    await xauPriceNFT.waitForDeployment();
    ContractAddress = BasContract.target;
    console.log("xauPriceNFT deployed at: ", xauPriceNFT.target);
  } catch (err) {
    console.error("Error deploying xauPriceNFT: ", err.message || err);
  }
  //   Update the address.json file
  try {
    addressFile["xauPriceNFT"][
      "ContractAddress"
    ] = ContractAddress;
    fs.writeFile("./address.json", JSON.stringify(addressFile, null, 2));
  } catch (err) {
    console.error("Error: ", err);
  }
}

deploy().catch((error) => {
  console.error("Deployment script error:", error.message || error);
  process.exit(1);
}); 