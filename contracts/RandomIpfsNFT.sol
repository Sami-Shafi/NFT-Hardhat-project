// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

pragma solidity ^0.8.7;

error RandomIpfsNFT_RangeOutOfBounds();
error RandomIpfsNFT_NeedMoreETHSent();
error RandomIpfsNFT_TransferFailed();

contract RandomIpfsNFT is VRFConsumerBaseV2, ERC721URIStorage, Ownable {
    // Types
    enum Breed {
        PUG,
        SHIBA_INU,
        DESHI_KUTTA
    }

    // state variables and vrf
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    uint64 private immutable i_subId;
    bytes32 private immutable i_keyHash;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIMATIONS = 3;
    uint16 private constant NUM_WORDS = 1;

    mapping(uint256 => address) private s_requestIdToSender;

    // NFT Variables
    uint256 private s_tokenCounter;
    uint256 internal constant MAX_CHANCE_VAL = 100;
    string[] internal s_dogTokenUris;
    uint256 private immutable i_mintFee;

    // events
    event NFTRequested(uint256 indexed requestId, address requester);
    event NFTMinted(Breed dogBreed, address minter);

    // constructor
    constructor(
        address vrfCoordinatorV2,
        bytes32 keyHash,
        uint64 subId,
        uint32 callbackGasLimit,
        string[3] memory dogTokenUris,
        uint256 mintFee
    ) VRFConsumerBaseV2(vrfCoordinatorV2) ERC721("Random IPFS NFT", "RIN") {
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_keyHash = keyHash;
        i_subId = subId;
        i_callbackGasLimit = callbackGasLimit;
        s_dogTokenUris = dogTokenUris;
        i_mintFee = mintFee;
    }

    function requestNft() public payable returns (uint256 requestId) {
        if (msg.value < i_mintFee) revert RandomIpfsNFT_NeedMoreETHSent();
        requestId = i_vrfCoordinator.requestRandomWords(
            i_keyHash,
            i_subId,
            REQUEST_CONFIMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );

        // save the msg.sender address and use it on fulfillRandomWords
        // because if you call msg.sender in fulfillRandomWords, you will get the Oracle's address or something like that
        s_requestIdToSender[requestId] = msg.sender;
        emit NFTRequested(requestId, msg.sender);
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        address nftOwner = s_requestIdToSender[requestId];
        uint256 tokenCounter = s_tokenCounter;

        // get random from modulus
        uint256 moddedRng = randomWords[0] % MAX_CHANCE_VAL;

        Breed dogBreed = getBreed(moddedRng);
        _safeMint(nftOwner, tokenCounter);
        _setTokenURI(tokenCounter, s_dogTokenUris[uint256(dogBreed)]);

        emit NFTMinted(dogBreed, nftOwner);
    }

    function getBreed(uint256 moddedRng) public pure returns (Breed) {
        uint256 calculativeSum = 0;
        uint256[3] memory chanceArray = getChanceArray();
        for (uint256 i = 0; i < chanceArray.length; i++) {
            if (
                moddedRng >= calculativeSum &&
                moddedRng < calculativeSum + chanceArray[i]
            ) {
                return Breed(i);
            }
            calculativeSum += chanceArray[i];
        }

        revert RandomIpfsNFT_RangeOutOfBounds();
    }

    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if (!success) revert RandomIpfsNFT_TransferFailed();
    }

    function getChanceArray() public pure returns (uint256[3] memory) {
        return [10, 30, MAX_CHANCE_VAL];
    }

    // we don't need getTokenURI if we use the openZeppelin _setTokenURI
    function getMintFee() public view returns (uint256) {
        return i_mintFee;
    }

    function getDogTokenUris(
        uint256 index
    ) public view returns (string memory) {
        return s_dogTokenUris[index];
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }
}
