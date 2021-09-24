const { ethers } = require("hardhat");

async function main() {
	let wallets = await ethers.getSigners()
	console.log('owner address-------', wallets[0].address)
	const walletAddress = "0x61Ca191FBBD213aFFD2a897D9BbB30547474849F";
	const Instance = await ethers.getContractFactory("SharkNFT");
	const contract = await Instance.deploy();
	await contract.toggleSaleStatus();
	await contract.addToPresaleList([walletAddress]);

	console.log("Box deployed to:", contract.address);
}

main();