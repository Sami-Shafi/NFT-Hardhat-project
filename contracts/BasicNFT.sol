// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

pragma solidity ^0.8.7;

contract BasicNFT is ERC721 {
    uint256 private s_tokenId;
    string public constant TOKEN_URI =
        "https://ipfs.io/ipfs/QmdizgF4GJnPYj7BNPcXgV7U63USNjHdikwjTPKuLz2Q6E?filename=sea-submarine-nft.json";

    constructor() ERC721("AbstractSea", "ASM") {
        s_tokenId = 0;
    }

    function mintNFT() public returns (uint256) {
        _safeMint(msg.sender, s_tokenId);
        s_tokenId = s_tokenId + 1;

        return s_tokenId;
    }

    function tokenURI(
        uint256 /* tokenId */
    ) public view override returns (string memory) {
        return TOKEN_URI;
    }

    function getTokenId() public view returns (uint256) {
        return s_tokenId;
    }
}
