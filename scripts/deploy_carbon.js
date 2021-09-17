const { ethers } = require("hardhat");

async function main() {
	let wallets = await ethers.getSigners()
	const Instance = await ethers.getContractFactory("Baboons");
	const contract = await Instance.deploy();
	await contract.togglePresaleStatus();
	await contract.toggleSaleStatus();
	await contract.addToPresaleList([wallet[0].address]);

	console.log("Box deployed to:", contract.address);
	await contract.startPreParty();
}

main();