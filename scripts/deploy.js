const { ethers } = require("hardhat");

async function main() {
	let wallets = await ethers.getSigners()
	console.log('owner address-------', wallets[0].address)
	const Instance = await ethers.getContractFactory("SharkNFT");
	const contract = await Instance.deploy();
	await contract.toggleSaleStatus();
	await contract.addToPresaleList([wallets[0].address]);

	console.log("Box deployed to:", contract.address);
}

main();