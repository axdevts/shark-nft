// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract BaboonBrigade is ERC721Enumerable, Ownable {
    using Strings for uint256;
    using ECDSA for bytes32;

    uint256 public constant BBG_MAX = 7777; // total amount
    uint256 public BBG_PRICE = 0.07 ether; // price per nft
    uint256 public constant BBG_PER_MINT = 5; // limit mint
	address payable public companyAddress = payable(0x2d2DA12fFb23e1025d2490657e96289C37FC28B3); // company address
    mapping(uint256 => string) public metadataUris;

    string private _tokenBaseURI =
        "https://ipfs.io/ipfs/";

    uint256 public tokenIdAmount;

    constructor() ERC721("BaboonBrigade", "BBG") {}

    // mining with metadata uri
    function mint(uint256 tokenQuantity, string[] calldata uris)
        external
        payable
    {
        require(totalSupply() < BBG_MAX, "OUT_OF_STOCK");
        require(tokenQuantity <= BBG_PER_MINT, "EXCEED_PER_MINT");

        for (uint256 i = 0; i < tokenQuantity; i++) {
			tokenIdAmount++;
            metadataUris[tokenIdAmount] = uris[i];
            _safeMint(msg.sender, totalSupply() + 1);
			companyAddress.transfer(msg.value);
			emit mint(tokenIdAmount, uris[i], msg.sender, companyAddress, msg.value);
        }
    }

    // get total amount
    function getAmount() external view returns (uint256) {
        return (BBG_MAX - tokenIdAmount);
    }

    // set nft price
    function setPrice(uint256 _price) external onlyOwner {
        BBG_PRICE = _price;
    }

    // update metadata uri
    function updateMetadatauri(uint256 tokenId, string calldata uri)
        external
        onlyOwner
    {
        metadataUris[tokenId] = uri;
    }
}
