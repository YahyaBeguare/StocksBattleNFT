const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("XAUPriceNFT Contract", function () {
  let XAUPriceNFT, xauPriceNFT, owner, addr1;

  beforeEach(async function () {
    XAUPriceNFT = await ethers.getContractFactory("XAUPriceNFT");
    [owner, addr1] = await ethers.getSigners();
    xauPriceNFT = await XAUPriceNFT.deploy();
    await xauPriceNFT.deployed();
  });

  it("Should deploy and mint an NFT to the owner", async function () {
    const ownerBalance = await xauPriceNFT.balanceOf(owner.address);
    expect(ownerBalance).to.equal(1);
  });

  it("Should mint an NFT to a specified address", async function () {
    await xauPriceNFT.mintFrom(addr1.address, 1);
    const addr1Balance = await xauPriceNFT.balanceOf(addr1.address);
    expect(addr1Balance).to.equal(1);
  });

  it("Should update metadata upon minting", async function () {
    await xauPriceNFT.mintFrom(addr1.address, 1);
    const tokenId = await xauPriceNFT.tokenIdCounter() - 1;
    const tokenURI = await xauPriceNFT.tokenURI(tokenId);
    expect(tokenURI).to.include("data:application/json;base64,");
  });

  it("Should compare price and return the correct indicator", async function () {
    const indicator = await xauPriceNFT.comparePrice();
    expect(["😀", "😔", "😑"]).to.include(indicator);
  });

  it("Should retrieve the latest price from Chainlink data feed", async function () {
    const price = await xauPriceNFT.getChainlinkDataFeedLatestAnswer();
    expect(price).to.be.a("number");
  });
});
