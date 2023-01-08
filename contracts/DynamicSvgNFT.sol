// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "base64-sol/base64.sol";

pragma solidity ^0.8.7;

error RandomIpfsNFT_RangeOutOfBounds();
error RandomIpfsNFT_NeedMoreETHSent();
error RandomIpfsNFT_TransferFailed();

contract DynamicSvgNFT is ERC721 {
    // state variable
    AggregatorV3Interface internal immutable i_priceFeed;
    uint256 private s_tokenCounter;
    string private i_lowSvgUri;
    string private i_highSvgUri;
    string private constant BASE_64_SVG_PREFIX = "data:image/svg+xml;base64";

    // eventsq
    event NFTMinted(uint256 indexed tokenId, int256 highValue);

    // mapping
    mapping(uint256 => int256) public s_tokenIdToHighValue;

    // constructor
    constructor(
        address priceFeedAddress,
        string memory lowSvg,
        string memory highSvg
    ) ERC721("Dynamic Svg NFT", "DSN") {
        s_tokenCounter = 0;
        i_lowSvgUri = svgToImageUri(lowSvg);
        i_highSvgUri = svgToImageUri(highSvg);
        i_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    function svgToImageUri(
        string memory svg
    ) public pure returns (string memory) {
        // coded svg to data uri
        string memory svgBase64Encoded = Base64.encode(
            bytes(string(abi.encodePacked(svg)))
        );
        return string(abi.encodePacked(BASE_64_SVG_PREFIX, svgBase64Encoded));
    }

    function mintNft(int256 highValue) public {
        s_tokenIdToHighValue[s_tokenCounter] = highValue;
        s_tokenCounter = s_tokenCounter + 1;
        _safeMint(msg.sender, s_tokenCounter);

        emit NFTMinted(s_tokenCounter, highValue);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        require(_exists(tokenId), "URI Query for nonexistent token");

        (, int price, , , ) = i_priceFeed.latestRoundData();
        string memory imageURI = i_lowSvgUri;
        if (price >= s_tokenIdToHighValue[s_tokenCounter]) {
            imageURI = i_highSvgUri;
        }
        return
            string(
                abi.encodePacked(
                    _baseURI(),
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                name(),
                                '"',
                                '"description":"An NFT that changes based on the chainlink feed."',
                                '"attributes": [{"trait_type": "coolness", "value": 100}]',
                                '"image":"',
                                imageURI,
                                '"'
                            )
                        )
                    )
                )
            );
    }
}
