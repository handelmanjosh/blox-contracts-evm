import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Game", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployFixture() {


    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const Game = await ethers.getContractFactory("Game");
    const game = await Game.deploy(owner);

    return { game, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      const { game, owner } = await loadFixture(deployFixture);

      expect(await game.owner()).to.equal(owner.address);
    });
  });
  describe("Game creation", function () {
    it("Should create a game successfully", async function() {
      const { game, owner } = await loadFixture(deployFixture);
      const tokens = [
        { name: "Token1", symbol: "TK1", description: "First Token", supply: 1000 },
        { name: "Token2", symbol: "TK2", description: "Second Token", supply: 2000 }
      ];
  
      const nfts = [
        { name: "NFT1", symbol: "NF1", description: "First NFT" },
        { name: "NFT2", symbol: "NF2", description: "Second NFT" }
      ];
  
      // Define Shop (assuming structure) and prizes
      const shop = {
        items: [/* addresses */],
        prices: [100, 200],
        priceTokens: [/* token addresses */],
        userListable: true
      };
  
      const prizes = [100, 200];
  
      // Call createGame
      await game.createGame("console.log('hello world')", tokens, nfts, shop, prizes);
      const g = await game.viewGame(1);
      const t = await game.viewGameTokens(1);
      const b = await game.viewOwnerBalance();
      console.log(g);
      console.log(t);
      console.log(b);
    }) 
  })
});
