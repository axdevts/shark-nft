const { ethers } = require("hardhat");

async function main() {
	let wallets = await ethers.getSigners()
	console.log('owner address-------', wallets[0].address)
	const walletAddress = "0xAF15e909a4ea5e6f3B0D19de03Ec15E823215012";
	const Instance = await ethers.getContractFactory("BaboonBrigade");
	const contract = await Instance.deploy();
	await contract.togglePresaleStatus();
	await contract.addToPresaleList([walletAddress]);

	console.log("Box deployed to:", contract.address);
}

main();