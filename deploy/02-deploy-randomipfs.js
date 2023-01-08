const { network, ethers } = require("hardhat");
const { devChains, networkConfig } = require("../helper-hardhat-config");
const { verify } = require("../utils/verify");
const { storeNFTs } = require("../utils/uploadToNftStorage");

const imagesLocation = "./images/randomNft";
const FUND_AMOUNT = "10000000000000000000";

module.exports = async ({ getNamedAccounts, deployments }) => {
	const { deploy, log } = deployments;
	const { deployer } = await getNamedAccounts();
	const chainId = network.config.chainId;

	// this one stores NFTS on nft.storage
	let tokenUris = [
		"ipfs://bafyreia7j22huzkteukef5eebwnmhjbwh2fupbvgqsurpy2s2pqtndcijm/metadata.json",
		"ipfs://bafyreiflh4wjd2shgk2kguff5gl5uv6ifpdszfgfep2itve3tdzqugx7mu/metadata.json",
		"ipfs://bafyreifto6b6mnmdldfgjdnl7s4xtqiy2y3sxdzeofto4t7kabirethnqa/metadata.json",
	];

	if (process.env.UPLOAD_TO_NFT_STORAGE == "true" && tokenUris == undefined) {
		tokenUris = await handleTokenUris();
	} else {
		console.log("NFT Upload on IPFS Not Required.");
	}

	let VRFCoordinatorV2Address, subId, VRFCoordinatorV2Mock;

	if (devChains.includes(network.name)) {
		VRFCoordinatorV2Mock = await ethers.getContract("VRFCoordinatorV2Mock");
		VRFCoordinatorV2Address = VRFCoordinatorV2Mock.address;

		const tx = await VRFCoordinatorV2Mock.createSubscription();
		const txReceipt = await tx.wait(1);

		subId = txReceipt.events[0].args.subId;
		await VRFCoordinatorV2Mock.fundSubscription(subId, FUND_AMOUNT);
	} else {
		VRFCoordinatorV2Address = networkConfig[chainId].vrfCoordinatorV2;
		subId = networkConfig[chainId].subId;
	}

	// deploy
	const { keyHash, callbackGasLimit, mintFee } = networkConfig[chainId];
	const arguments = [
		VRFCoordinatorV2Address,
		keyHash,
		subId,
		callbackGasLimit,
		tokenUris,
		mintFee,
	];

	log("-------------------------------------------------------");
	const randomIpfsNft = await deploy("RandomIpfsNFT", {
		from: deployer,
		args: arguments,
		log: true,
		waitConfirmations: network.config.blockConfirmations || 1,
	});
	log("Mocks Deployed!");
	log("-------------------------------------------------------");

	if (chainId == 31337) {
		await VRFCoordinatorV2Mock.addConsumer(subId, randomIpfsNft.address);
	}

	// Verify the deployment
	if (!devChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
		log("Verifying...");
		await verify(randomIpfsNft.address, arguments);
	}
};

const handleTokenUris = async () => {
	tokenUris = [];

	// responses example
	// [
	//     Token {
	//       ipnft: 'bafyreia7j22huzkteukef5eebwnmhjbwh2fupbvgqsurpy2s2pqtndcijm',
	//       'ipfs://bafyreia7j22huzkteukef5eebwnmhjbwh2fupbvgqsurpy2s2pqtndcijm/metadata.json'
	//     },
	//     Token {
	//       ipnft: 'bafyreiflh4wjd2shgk2kguff5gl5uv6ifpdszfgfep2itve3tdzqugx7mu',
	//       'ipfs://bafyreiflh4wjd2shgk2kguff5gl5uv6ifpdszfgfep2itve3tdzqugx7mu/metadata.json'
	//     },
	//     Token {
	//       ipnft: 'bafyreifto6b6mnmdldfgjdnl7s4xtqiy2y3sxdzeofto4t7kabirethnqa',
	//       'ipfs://bafyreifto6b6mnmdldfgjdnl7s4xtqiy2y3sxdzeofto4t7kabirethnqa/metadata.json'
	//     }
	// ]
	const { responses: imageUploadResponses } = await storeNFTs(imagesLocation);
	for (imageIndex in imageUploadResponses) {
		const tokenUri = imageUploadResponses[imageIndex].url;
		tokenUris.push(tokenUri);
	}

	return tokenUris;
};

module.exports.tags = ["all", "randomipfs", "main"];
