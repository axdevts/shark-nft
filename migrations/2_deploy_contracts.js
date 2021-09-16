const SharkNFT = artifacts.require("./SharkNFT.sol");
const SRKFactory = artifacts.require("./SRKFactory.sol");
const SharkAccessControls = artifacts.require("./SharkAccessControls.sol");
const Presale = artifacts.require("./Presale.sol")

module.exports = async (deployer, network, addresses) => {
  // OpenSea proxy registry addresses for rinkeby and mainnet.

  await deployer.deploy(SharkAccessControls);
  const accessControl = await SharkAccessControls.deployed();

  let proxyRegistryAddress = "";
  if (network === 'rinkeby') {
    proxyRegistryAddress = "0xf57b2c51ded3a29e6891aba85459d600256cf317";
  } else {
    proxyRegistryAddress = "0xa5409ec958c83c3f309868babaca7c86dcb077c1";
  }

    await deployer.deploy(SharkNFT, proxyRegistryAddress, {gas: 5000000});
	const nft = SharkNFT.deployed();

	await deployer.deploy(SRKFactory, proxyRegistryAddress, SharkNFT.address, {gas: 7000000});
	const sharkNFT = await SharkNFT.deployed();
	await sharkNFT.transferOwnership(SRKFactory.address);

	await deployer.deploy(Presale, accessControl.address, nft.address, 0.08e18, '0xD387098B3CA4C6D592Be0cE0B69E83BE86011c50');
	await Presale.deployed();
};
