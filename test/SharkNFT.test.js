const { expect } = require("chai")
const hre = require("hardhat")
const { ethers } = require("hardhat")
const { BigNumber } = require("ethers")
const {
	expectRevert
} = require('@openzeppelin/test-helpers');

let carbonCreatures;
let nft;
let owner;
let account1;
let reserveAddress;
const testuri = 'testuri';

describe("BaboonBrigade", () => {
	before(async () => {
		let wallets = await ethers.getSigners()
		owner = wallets[0]
		account1 = wallets[1]
		reserveAddress = wallets[2]
		BaboonBrigadeInstance = await ethers.getContractFactory('BaboonBrigade')
	})
	beforeEach(async () => {
		nft = await BaboonBrigadeInstance.deploy();
	})
	// describe("presale mint feature", async () => {
	// 	it('should success on presale mint', async () => {
	// 		await nft.togglePresaleStatus();
	// 		await nft.addToPresaleList([owner.address]);

	// 		await nft.presaleBuy(1, { value: ethers.utils.parseEther('0.07') });
	// 		expect(await nft.ownerOf(1)).to.be.equal(owner.address);
	// 	})
	// 	it('should fail if address is not on presaler list', async () => {
	// 		await nft.togglePresaleStatus();
	// 		expectRevert(
	// 			nft.presaleBuy(1, { value: ethers.utils.parseEther('0.07') }),
	// 			'NOT_QUALIFIED'
	// 		);
	// 	})
	// })
	describe("mint feature", async () => {
		it('should success on mint', async () => {
			await nft.toggleSaleStatus();
			await nft.addToPresaleList([owner.address]);

			await nft.buy(1, { value: ethers.utils.parseEther('0.07') });
			expect(await nft.ownerOf(1)).to.be.equal(owner.address);
		})
		it('should fail if address is not on presaler list', async () => {
			await nft.toggleSaleStatus();
			expectRevert(
				nft.buy(1, { value: ethers.utils.parseEther('0.07') }),
				'NOT_QUALIFIED'
			);
		})
	})
});