const { network, ethers } = require("hardhat");
const { devChains, networkConfig } = require("../helper-hardhat-config");
const { verify } = require("../utils/verify");

module.exports = async ({ getNamedAccounts, deployments }) => {
	const { deploy, log } = deployments;
	const { deployer } = await getNamedAccounts();
	const chainId = network.config.chainId;

	let VRFCoordinatorV2Address, subId;

	if (devChains.includes(network.name)) {
		const VRFCoordinatorV2Mock = await ethers.getContract(
			"VRFCoordinatorV2Mock"
		);
		VRFCoordinatorV2Address = VRFCoordinatorV2Mock.address;

		const tx = await VRFCoordinatorV2Mock.createSubscription();
		const txReceipt = await tx.wait(1);

		subId = txReceipt.events[0].args.subId;
	} else {
		VRFCoordinatorV2Address = networkConfig[chainId].vrfCoordinatorV2;
		subId = networkConfig[chainId].subId;
	}

	const { keyHash, callbackGasLimit, mintFee } = networkConfig[chainId];
	const arguements = [
		VRFCoordinatorV2Address,
		keyHash,
		subId,
		callbackGasLimit,
		"hey" /*dog token uris*/,
		mintFee,
	];
};

module.exports.tags = ["all", "mock"];
