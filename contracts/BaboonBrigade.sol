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

    string private tokenBaseURI =
        "https://ipfs.io/ipfs/QmZ2M1bcmsi18n7pY4XR5c2FEyBgMbNFgMJyuYR39kH8a6/";

    uint256 public totalMintedAmount;

	event PreSale(uint256 tokenId, address sender, uint amount);
	event PrivatePreSale(uint256 tokenId, address sender, uint amount);

    constructor() ERC721("BaboonBrigade", "BBG") {}

	/**
     * @notice Results a finished mint
     * @dev Only admin or smart contract
     * @dev Token Id can only be resulted if there has been a bidder and reserve met.
     * @param tokenQuantity token ID which need to be finished
    */
    function preSale(uint256 tokenQuantity)
        external
        payable
    {
        require(totalSupply() < BBG_MAX, "OUT_OF_STOCK");
        require(tokenQuantity <= BBG_PER_MINT, "EXCEED_PER_MINT");
		require(BBG_PRICE * tokenQuantity <= msg.value, "Not Enough payments");

        for (uint256 i = 0; i < tokenQuantity; i++) {
			totalMintedAmount++;
            _safeMint(msg.sender, totalSupply() + 1);
			companyAddress.transfer(msg.value);
			emit PreSale(totalMintedAmount, msg.sender, msg.value);
        }
    }

	/**
     * @notice Results a finished private mint
     * @dev Only admin
     * @dev Token Id can only be resulted if there has been a bidder and reserve met.
     * @param tokenQuantity token ID which need to be finished
    */
	function privatePreSale(uint256 tokenQuantity)
        external
        payable
		onlyOwner
    {
        require(totalSupply() < BBG_MAX, "OUT_OF_STOCK");
		require(BBG_PRICE * tokenQuantity <= msg.value, "Not Enough payments");

        for (uint256 i = 0; i < tokenQuantity; i++) {
			totalMintedAmount++;
            _safeMint(msg.sender, totalSupply() + 1);
			companyAddress.transfer(msg.value);
			emit PrivatePreSale(totalMintedAmount, msg.sender, msg.value);
        }
    }

    /**
     * @notice Results a Remaining amount
     * @dev Total amount - minted amount
    */
    function getAmount() external view returns (uint256) {
        return (BBG_MAX - totalMintedAmount);
    }

    /**
     * @notice Results a price per NFT
	 * @dev Only admin
     * @dev Set price per NFT
    */
    function setPrice(uint256 _price) external onlyOwner {
        BBG_PRICE = _price;
    }

	/**
     * @notice Results a metadata URI
	 * @param tokenId token URI per token ID
    */
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721)
        returns (string memory)
    {
        require(_exists(tokenId), "Cannot query non-existent token");

        return string(abi.encodePacked(tokenBaseURI, tokenId.toString()));
    }

	/**
     * @notice Results a metadata uri
     * @param _tokenBaseURI token ID which need to be finished
    */
	function setTokenBaseUri(string memory _tokenBaseURI) public {
		tokenBaseURI = _tokenBaseURI;
	}

	/**
     * @notice Results a company wallet address
     * @param addr change another wallet address from wallet address
    */
	function setCompanyAddress(address payable addr) public onlyOwner {
		companyAddress = addr;
	}

	/**
     * @notice Results a max value can buy
    */
	function getMaxValue() public view returns (uint256) {
		return BBG_PER_MINT;
	}
}
