const Market = artifacts.require("Market");
const NFT = artifacts.require("NFT");

contract("Market", () => {
  let market;
  let token;

  before(() => {
    market = Market.deployed();
  });

  describe("list token", () => {});
});
