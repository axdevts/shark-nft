const { expect } = require("chai")
const hre = require("hardhat")
const { ethers } = require("hardhat")
const { BigNumber } = require("ethers")
const {
	expectRevert
} = require('@openzeppelin/test-helpers');

let baboonBrigade;
let nft;
let owner;
let account1;
let reserveAddress;
const testuri = 'testuri';

describe("BaboonBrigade", function () {
	before(async function () {
		let wallets = await ethers.getSigners();
		console.log('wallets', wallets);
		owner = wallets[0]
		account1 = wallets[1]
		reserveAddress = wallets[2]
		baboonBrigade = await ethers.getContractFactory("BaboonBrigade")
	});
	beforeEach(async () => {
		nft = await carbonCreatures.deploy();
	})
	// describe('set starting index and reserve', async () => {
	// 	it('should fail the starting index after setting initial one', async () => {
	// 		await nft.setStartingIndexAndMintReserve(reserveAddress.address)
	// 		expectRevert(
	// 			nft.setStartingIndexAndMintReserve(reserveAddress.address),
	// 			'Starting index is already set.'
	// 		)
	// 	})
	// })
	// describe('set contract uri', async () => {
	// 	it('should get correct uri after setting', async () => {
	// 		expect(await nft.contractURI()).to.be.equal('');
	// 		await nft.setContractURL(testuri);
	// 		expect(await nft.contractURI()).to.be.equal(testuri);
	// 	})
	// })
	// describe('set token uri', async () => {
	// 	it('should get correct uri after setting', async () => {
	// 		expect(await nft.tokenBaseUri()).to.be.equal('');

	// 		await nft.setTokenURI(testuri);
	// 		expect(await nft.tokenBaseUri()).to.be.equal(testuri);
	// 	})
	// })
	// // describe('get co2cs price', async () => {
	// // 	it('should get co2cs price', async () => {
	// // 		let result = await nft.CO2C_PRICE();
	// // 		console.log('CO2C_PRICE ----------- ', result);
	// // 	})
	// // })
	// // describe('set co2cs price', async () => {
	// // 	it('should set co2cs price', async () => {
	// // 		let result = await nft.setCo2cPrice(ethers.utils.parseEther("0.08"));
	// // 	})
	// // })
	// describe('mint nft for private sale by owner', async () => {
	// 	it('should mint by owner', async () => {
	// 		let uris = generateFakeURLs(2);
	// 		await nft.mintPrivateSale(account1.address, 2, uris, {
	// 			from: owner.address,
	// 		});
	// 		expect(await nft.ownerOf(1)).to.be.equal(account1.address);
	// 		expect(await nft.ownerOf(2)).to.be.equal(account1.address);

	// 		expect(await nft.tokenURI(1)).to.be.equal(uris[0]);
	// 		expect(await nft.tokenURI(2)).to.be.equal(uris[1]);
	// 	});
	// 	it('should fail if sender is not owner', async () => {
	// 		let uris = generateFakeURLs(2);
	// 		await expectRevert(
	// 			nft.connect(account1).mintPrivateSale(account1.address, 2, uris),
	// 			"Ownable: caller is not the owner"
	// 		);
	// 	});
	// });

	// describe('mint nft (Pre mode)', async () => {
	// 	it('should mint nft', async () => {
	// 		await nft.authoriseCo2c(owner.address, 10);
	// 		await nft.startPreParty();
	// 		await nft.mintCo2c(1, generateFakeURLs(1), {
	// 			from: owner.address,
	// 			value: ethers.utils.parseEther("0.08")
	// 		});
	// 		expect(await nft.ownerOf(1)).to.be.equal(owner.address);
	// 	})
	// 	it('should fail if current stage is just on setup', async () => {
	// 		await expectRevert(
	// 			nft.mintCo2c(1, generateFakeURLs(1), {
	// 				from: owner.address,
	// 				value: ethers.utils.parseEther("0.08")
	// 			}),
	// 			"CO2Cs aren't ready yet!"
	// 		);
	// 	});
	// 	it('should fail if user trying to buy more than max purchase', async () => {
	// 		await nft.authoriseCo2c(owner.address, 10);
	// 		await nft.startPreParty();
	// 		await expectRevert(
	// 			nft.mintCo2c(100, generateFakeURLs(100), {
	// 				from: owner.address,
	// 				value: ethers.utils.parseEther("0.08")
	// 			}),
	// 			"Hey, that's too many CO2Cs. Save some for the rest of us!"
	// 		);
	// 	});
	// 	// it('should fail if mint all of the nfts', async () => {
	// 	// 	await nft.authoriseCo2c(owner.address, 10000);
	// 	// 	await nft.startPreParty();
	// 	// 	for(let i=0; i<2000; i++) {
	// 	// 		await nft.mintCo2c(5, {
	// 	// 			from: owner.address,
	// 	// 			value: ethers.utils.parseEther("0.4")
	// 	// 		});
	// 	// 	}
	// 	// 	await expectRevert(
	// 	// 		nft.mintCo2c(1, {
	// 	// 			from: owner.address,
	// 	// 			value: ethers.utils.parseEther("0.08")
	// 	// 		}),
	// 	// 		"Sorry, there's not that many CO2Cs left."
	// 	// 	);
	// 	// });
	// 	it('should fail if proper ether not sent', async () => {
	// 		await nft.authoriseCo2c(owner.address, 10);
	// 		await nft.startPreParty();
	// 		await expectRevert(
	// 			nft.mintCo2c(1, generateFakeURLs(1), {
	// 				from: owner.address,
	// 				value: ethers.utils.parseEther("0.05")
	// 			}),
	// 			"Hey, that's not the right price."
	// 		);
	// 	});
	// 	it('should fail if not authorized amount on presale', async () => {
	// 		await nft.authoriseCo2c(owner.address, 1);
	// 		await nft.startPreParty();
	// 		await expectRevert(
	// 			nft.mintCo2c(5, generateFakeURLs(5), {
	// 				from: owner.address,
	// 				value: ethers.utils.parseEther("0.4")
	// 			}),
	// 			"Hey, you're not allowed to buy this many CO2Cs during the pre-party."
	// 		);
	// 	});
	// 	it('should fail if I am not on authorized list on presale stage', async () => {
	// 		await nft.startPreParty();
	// 		await expectRevert(
	// 			nft.mintCo2c(1, generateFakeURLs(1), {
	// 				from: owner.address,
	// 				value: ethers.utils.parseEther("0.08")
	// 			}),
	// 			"Hey, you're not allowed to buy this many CO2Cs during the pre-party."
	// 		);
	// 	})
	// })
	// describe('create sale', async () => {
	// 	it('should fail if no owner', async () => {
	// 		await expectRevert(
	// 			nft.createSale(1, ethers.utils.parseEther("0.003")),
	// 			'ERC721: owner query for nonexistent token'
	// 		);
	// 	})
	// 	it('should fail if the sale price for create is great than minOfferPrice', async () => {
	// 		// should mint at least one nft for owner
	// 		await nft.authoriseCo2c(owner.address, 1);
	// 		await nft.startPreParty();
	// 		const mintResult = await nft.mintCo2c(1, generateFakeURLs(1), {
	// 			from: owner.address,
	// 			value: ethers.utils.parseEther("0.08")
	// 		});

	// 		// try to create a sale after minting but should fail if _price < minOfferPrice
	// 		await expectRevert(
	// 			nft.createSale(1, ethers.utils.parseEther("0.001")),
	// 			"require minPrice to be higher than minOfferPrice"
	// 		);
	// 	})
	// 	it('should create one sale', async () => {
	// 		// should mint at least one nft for owner
	// 		await nft.authoriseCo2c(owner.address, 1);
	// 		await nft.startPreParty();
	// 		const mintResult = await nft.mintCo2c(1, generateFakeURLs(1), {
	// 			from: owner.address,
	// 			value: ethers.utils.parseEther("0.08")
	// 		});
	// 		// try to create a sale with the right condition(_price >= minOfferPrice) after minting
	// 		expect(await nft.createSale(1, ethers.utils.parseEther('0.008')));
	// 	});
	// });
	// describe('buy sale', async () => {
	// 	it('should fail if no enough payment to buy', async () => {
	// 		// should mint at least one nft for owner
	// 		await nft.authoriseCo2c(owner.address, 1);
	// 		await nft.startPreParty();
	// 		const mintResult = await nft.mintCo2c(1, {
	// 			from: owner.address,
	// 			value: ethers.utils.parseEther("0.08")
	// 		});

	// 		// try to create a sale with the right condition(_price >= minOfferPrice) after minting
	// 		const createSale = await nft.createSale(1, ethers.utils.parseEther("0.008"));

	// 		await expectRevert(
	// 			nft.buySale(1, {
	// 				from: owner.address,
	// 				value: ethers.utils.parseEther("0.005")
	// 			}),
	// 			"Not enough payment"
	// 		);
	// 	})
	// })
})