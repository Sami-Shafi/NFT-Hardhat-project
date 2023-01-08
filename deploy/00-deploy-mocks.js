const { network, ethers } = require("hardhat");
const {
	devChains,
	DECIMALS,
	INITIAL_PRICE,
	BASE_FEE,
	GAS_PRICE_LINK,
} = require("../helper-hardhat-config");

module.exports = async ({ getNamedAccounts, deployments }) => {
	const { deploy, log } = deployments;
	const { deployer } = await getNamedAccounts();
	const args = [BASE_FEE, GAS_PRICE_LINK];

	if (devChains.includes(network.name)) {
		log("Local Network! Deploying Mocks...");

		// deploy vrfcoordinator
		await deploy("VRFCoordinatorV2Mock", {
			from: deployer,
			log: true,
			args: args,
		});

        log("-------------------------------------------------------");
		await deploy("MockV3Aggregator", {
			from: deployer,
			log: true,
			args: [DECIMALS, INITIAL_PRICE],
		});
		log("Mocks Deployed!");
		log("-------------------------------------------------------");
	}
};

module.exports.tags = ["all", "randipfs", "mocks"];
