// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "base64-sol/base64.sol";

pragma solidity ^0.8.7;

contract DynamicSvgNFT is ERC721 {
    // state variable
    AggregatorV3Interface internal immutable i_priceFeed;
    uint256 private s_tokenCounter;
    string private s_lowSvgUri;
    string private s_highSvgUri;
    string private constant BASE_64_SVG_PREFIX = "data:image/svg+xml;base64,";

    // events
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
        s_lowSvgUri = svgToImageUri(lowSvg);
        s_highSvgUri = svgToImageUri(highSvg);
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
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter = s_tokenCounter + 1;

        emit NFTMinted(s_tokenCounter, highValue);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        require(_exists(tokenId), "URI Query for nonexistent token");

        // answer = 1200$
        (, int price, , , ) = i_priceFeed.latestRoundData();
        string memory imageURI = s_lowSvgUri;

        if (price >= s_tokenIdToHighValue[tokenId]) {
            imageURI = s_highSvgUri;
        }

        return
            string(
                abi.encodePacked(
                    _baseURI(),
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                name(), // You can add whatever name here
                                '", "description":"An NFT that changes based on the Chainlink Feed", ',
                                '"attributes": [{"trait_type": "coolness", "value": 100}], "image":"',
                                imageURI,
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    function getLowSvg() public view returns (string memory) {
        return s_lowSvgUri;
    }

    function getHighSvg() public view returns (string memory) {
        return s_highSvgUri;
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return i_priceFeed;
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }
}
