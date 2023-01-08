const { network, ethers } = require("hardhat");
const fs = require("fs");
const { devChains, networkConfig } = require("../helper-hardhat-config");
const { verify } = require("../utils/verify");
const { storeNFTs } = require("../utils/uploadToNftStorage");

module.exports = async ({ getNamedAccounts, deployments }) => {
	const { deploy, log } = deployments;
	const { deployer } = await getNamedAccounts();
	const chainId = network.config.chainId;

	let priceFeedAddress, MockV3Aggregator;

	if (devChains.includes(network.name)) {
		MockV3Aggregator = await ethers.getContract("MockV3Aggregator");
		priceFeedAddress = MockV3Aggregator.address;
	} else {
		priceFeedAddress = networkConfig[chainId].ethUsdPriceFeed;
	}

	const lowSvg = await fs.readFileSync(
		"./images/dynamicNft/frown.svg",
		"utf8"
	);
	const highSvg = await fs.readFileSync(
		"./images/dynamicNft/happy.svg",
		"utf8"
	);

	// deploy
	log("-------------------------------------------------------");
	const arguments = [priceFeedAddress, lowSvg, highSvg];
	const dynamicSvgNft = await deploy("DynamicSvgNFT", {
		from: deployer,
		log: true,
		args: arguments,
		waitConfirmations: network.config.blockConfirmations || 1,
	});
	log("Dynamic SVG Deployed");
	log("-------------------------------------------------------");

	// Verify the deployment
	if (!devChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
		log("Verifying...");
		await verify(dynamicSvgNft.address, arguments);
	}
};

module.exports.tags = ["all", "dynamicsvg", "main"];
