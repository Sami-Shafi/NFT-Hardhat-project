const networkConfig = {
	31337: {
		name: "localhost",
		ethUsdPriceFeed: "0x9326BFA02ADD2366b30bacB125260Af641031331",
		keyHash:
			"0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc", // 30 gwei
		mintFee: "10000000000000000", // 0.01 ETH
		callbackGasLimit: "500000", // 500,000 gas
	},
	// Price Feed Address, values can be obtained at https://docs.chain.link/docs/reference-contracts
	5: {
		name: "goerli",
		ethUsdPriceFeed: "0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e",
		vrfCoordinatorV2: "0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D",
		keyHash:
			"0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15",
		callbackGasLimit: "500000", // 500,000 gas
		mintFee: "10000000000000000", // 0.01 ETH
		subId: "8309", // add your ID here!
	},
};

const DECIMALS = "18";
const INITIAL_PRICE = "200000000000000000000";
const BASE_FEE = ethers.utils.parseEther("0.25");
const GAS_PRICE_LINK = 1e9;
const devChains = ["hardhat", "localhost"];

module.exports = {
	networkConfig,
	devChains,
	DECIMALS,
	INITIAL_PRICE,
	BASE_FEE,
	GAS_PRICE_LINK,
};
