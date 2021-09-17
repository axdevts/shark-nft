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

describe("CarbonCreatures", function () {
	before(async function() {
		let wallets = await ethers.getSigners()
		owner = wallets[0]
		account1 = wallets[1]
		reserveAddress = wallets[2]
		carbonCreatures = await ethers.getContractFactory('CarbonCreatures')
	});
	beforeEach(async () => {
		nft = await carbonCreatures.deploy();
	})
	describe('set starting index and reserve', async () => {
		it('should fail the starting index after setting initial one', async () => {
			await nft.setStartingIndexAndMintReserve(reserveAddress.address)
			expectRevert(
				nft.setStartingIndexAndMintReserve(reserveAddress.address),
				'Starting index is already set.'
			)
		})
	})
	describe('set contract uri', async () => {
		it('should get correct uri after setting', async () => {
			expect(await nft.contractURI()).to.be.equal('');
			await nft.setContractURL(testuri);
			expect(await nft.contractURI()).to.be.equal(testuri);
		})
	})
	describe('set token uri', async () => {
		it('should get correct uri after setting', async () => {
			expect(await nft.tokenBaseUri()).to.be.equal('');

			await nft.setTokenURI(testuri);
			expect(await nft.tokenBaseUri()).to.be.equal(testuri);
		})
	})

	describe('mint nft', async () => {
		it('should mint nft', async () => {
			await nft.authoriseCo2c(owner.address, 10);
			await nft.startPreParty();
			await nft.mintCo2c(1, {
				from: owner.address,
				value: ethers.utils.parseEther("0.08")
			});
			expect(await nft.ownerOf(1)).to.be.equal(owner.address);
		})
		it('should fail if I am not on authorized list on presale stage', async () => {
			await nft.startPreParty();
			await expectRevert(
				nft.mintCo2c(1, {
					from: owner.address,
					value: ethers.utils.parseEther("0.08")
				}),
				"Hey, you're not allowed to buy this many CO2Cs during the pre-party."
			);
		})
	})
})