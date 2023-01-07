const { assert } = require("chai");
const { network, deployments, ethers } = require("hardhat");
const { devChains } = require("../../helper-hardhat-config");

!devChains.includes(network.name)
	? describe.skip
	: describe("BasicNFT", () => {
			let basicNFT, deployer;

			beforeEach(async () => {
				const accounts = await ethers.getSigners();
				deployer = accounts[0];
				await deployments.fixture(["basicnft"]);

				// connect contracts
				basicNFT = await ethers.getContract("BasicNFT");
			});

			describe("Constructor", () => {
				it("Initializes The NFT Correctly", async () => {
					const name = await basicNFT.name();
					const symbol = await basicNFT.symbol();
					const tokenId = await basicNFT.getTokenId();

					assert.equal(name, "AbstractSea");
					assert.equal(symbol, "ASM");
					assert.equal(tokenId.toString(), "0");
				});
			});

			describe("Minting", () => {
				beforeEach(async () => {
					// before running test here we need to mint the nft first
					const txRes = await basicNFT.mintNFT();
					await txRes.wait(1);
				});

				it("TokenId should update", async () => {
					const tokenId = basicNFT.getTokenId();
					assert(tokenId.toString(), "1");
				});

				it("Token URL should always be same", async () => {
					const getTokenURI = await basicNFT.tokenURI(0);
					const getTokenURI1 = await basicNFT.tokenURI(1);

					assert(getTokenURI, basicNFT.TOKEN_URI);
					assert(getTokenURI1, basicNFT.TOKEN_URI);
				});

				it("Handle the owner balance and address properly", async () => {
					const ownerBalance = await basicNFT.balanceOf(
						deployer.address
					);
					const owner = await basicNFT.ownerOf("0");

					assert.equal(ownerBalance.toString(), "1");
					assert.equal(owner, deployer.address);
				});
			});
	  });
