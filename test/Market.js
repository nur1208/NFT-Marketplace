const {
  expectRevert,
  expectEvent,
  BN,
} = require("@openzeppelin/test-helpers");
const {
  assertion,
} = require("@openzeppelin/test-helpers/src/expectRevert");

const Market = artifacts.require("Market");
const NFT = artifacts.require("NFT");

contract("Market", (accounts) => {
  let market;
  let token;

  const minter = accounts[1];
  const tokenId = "1";
  let listingId = new BN(1);
  const price = "1000";
  const seller = accounts[0];

  describe("List token", () => {
    before(async () => {
      market = await Market.new();
      token = await NFT.new();

      await token.mint();
    });

    it("should prevent listing - contract not approved", async () => {
      await expectRevert(
        market.listToken(token.address, tokenId, price, {
          from: minter,
        }),
        "ERC721: transfer caller is not owner nor approved"
      );
    });

    it("should execute listing", async () => {
      await token.approve(market.address, tokenId);
      const tx = await market.listToken(
        token.address,
        tokenId,
        price
      );

      expectEvent(tx, "Listed", {
        listingId,
        seller,
        token: token.address,
        tokenId,
        price,
      });

      const ownerAddress = await token.ownerOf(tokenId);

      assert.equal(ownerAddress, market.address);
    });
  });
});
