// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract BaboonBrigade is ERC721Enumerable, Ownable {
    using Strings for uint256;
    using ECDSA for bytes32;
    using SafeMath for uint256;

    uint256 public constant BBG_MAX = 7777; // total amount
	uint256 public BBG_PER_PRICE; // per price
    uint256 public constant BBG_PER_MINT = 10; // limit mint
	uint256 public publicAmountMinted;
    uint256 public privateAmountMinted;
	uint256 public presalePurchaseLimit = 2;

    bool public presaleLive;

	address payable public companyAddress = payable(0x2d2DA12fFb23e1025d2490657e96289C37FC28B3); // company address

    string private tokenBaseURI =
        "https://ipfs.io/ipfs/QmZ2M1bcmsi18n7pY4XR5c2FEyBgMbNFgMJyuYR39kH8a6/";

	mapping(address => bool) public presalerListFirst;
	mapping(address => bool) public presalerListSecond;
    mapping(address => uint256) public presalerListPurchases;

	/// @notice status enum for nft
    enum State {
        PrivatePreSaleFirst,
        PrivatePreSaleSecond,
		PublicSale
    }

	/// @dev internal factory status
    State private _state;

	event PreSale(uint256 tokenId, address sender, uint amount);
	event PrivateSale(uint256 tokenId, address sender, uint amount);

    constructor() ERC721("BaboonBrigade", "BBG") {}

	/**
     * @notice Results a decided owners to add first presale
     * @dev Only admin
     * @param entries owners address which need to be decided
    */
	function addToPresaleListFirst(address[] calldata entries) external onlyOwner {
        for (uint256 i = 0; i < entries.length; i++) {
            address entry = entries[i];
            require(entry != address(0), "NULL_ADDRESS");
            require(!presalerListFirst[entry], "DUPLICATE_ENTRY");

            presalerListFirst[entry] = true;
        }
    }

	/**
     * @notice Results a decided owners to add second presale
     * @dev Only admin
     * @param entries owners address which need to be decided
    */
	function addToPresaleListSecond(address[] calldata entries) external onlyOwner {
        for (uint256 i = 0; i < entries.length; i++) {
            address entry = entries[i];
            require(entry != address(0), "NULL_ADDRESS");
            require(!presalerListSecond[entry], "DUPLICATE_ENTRY");

            presalerListSecond[entry] = true;
        }
    }

	/**
     * @notice Results a decided owners to remove first presale
     * @dev Only admin
     * @param entries owners address which need to be delete
    */
	function removeFromPresaleListFirst(address[] calldata entries)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < entries.length; i++) {
            address entry = entries[i];
            require(entry != address(0), "NULL_ADDRESS");

            presalerListFirst[entry] = false;
        }
    }

	/**
     * @notice Results a decided owners to remove second presale
     * @dev Only admin
     * @param entries owners address which need to be delete
    */
	function removeFromPresaleListSecond(address[] calldata entries)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < entries.length; i++) {
            address entry = entries[i];
            require(entry != address(0), "NULL_ADDRESS");

            presalerListSecond[entry] = false;
        }
    }

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
		require(!presaleLive, "ONLY_PRESALE");
        require(totalSupply() < BBG_MAX, "OUT_OF_STOCK");
        require(tokenQuantity <= BBG_PER_MINT, "EXCEED_PER_MINT");

		require(
            totalSupply().add(tokenQuantity) <= BBG_MAX,
            "Sorry, there's not that many BBG left."
        );

		uint256 remainingAmount = getAmount();

		if (remainingAmount == 150) {
			_state = State.PrivatePreSaleFirst;
		} else if (remainingAmount == 400) {
			_state = State.PrivatePreSaleSecond;
		} else if (remainingAmount == 550) {
			_state = State.PublicSale;
		}

		uint256 BBG_PRICE = 0.05 ether;

		if (_state == State.PrivatePreSaleFirst) {
			require(presalerListFirst[msg.sender], "Not Authorize presale");
			require(BBG_PRICE * tokenQuantity <= msg.value, "Not Enough payments");

		} else if (_state == State.PrivatePreSaleSecond) {
			BBG_PRICE = 0.06 ether;
			require(presalerListSecond[msg.sender], "Not Authorize presale");
			require(BBG_PRICE * tokenQuantity <= msg.value, "Not Enough payments");

		} else {
			BBG_PRICE = 0.07 ether;
			require(BBG_PRICE * tokenQuantity <= msg.value, "Not Enough payments");
		}

        for (uint256 i = 0; i < tokenQuantity; i++) {
			publicAmountMinted++;
            _safeMint(msg.sender, totalSupply() + 1);
			companyAddress.transfer(msg.value);
			emit PreSale(publicAmountMinted, msg.sender, msg.value);
        }
    }

	/**
     * @notice Results a finished private mint
     * @dev Only admin
     * @dev Token Id can only be resulted if there has been a bidder and reserve met.
     * @param tokenQuantity token ID which need to be finished
    */
	function privateSale(address[] calldata _toAddresses, uint256[] calldata tokenQuantity)
        external
		onlyOwner
    {
        require(totalSupply() < BBG_MAX, "OUT_OF_STOCK");

        for (uint256 i = 0; i < tokenQuantity.length; i++) {
			for (uint256 j = 0; j < _toAddresses.length; j++) {
				privateAmountMinted++;
				_safeMint(_toAddresses[j], totalSupply() + 1);
				emit PrivateSale(privateAmountMinted, msg.sender, 0);
			}
		}
    }

    /**
     * @notice Results a Remaining amount
     * @dev Total amount - minted amount
    */
    function getAmount() internal view returns (uint256) {
        return (BBG_MAX - publicAmountMinted - privateAmountMinted);
    }

    /**
     * @notice Results a price per NFT
	 * @dev Only admin
     * @dev Set price per NFT
    */
    function setPrice(uint256 _price) external onlyOwner {
        BBG_PER_PRICE = _price;
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
     * @notice Results a first presaler
     * @param addr address to check presaler
    */
	function isFirstPresaler(address addr) external view returns (bool) {
        return presalerListFirst[addr];
    }

	/**
     * @notice Results a second presaler
     * @param addr address to check presaler
    */
	function isSecondPresaler(address addr) external view returns (bool) {
        return presalerListSecond[addr];
    }

	/**
     * @notice Results a counter per presaler
     * @param addr limit counter per presaler
    */
    function presalePurchasedCount(address addr)
        external
        view
        returns (uint256)
    {
        return presalerListPurchases[addr];
    }

	/**
     * @notice Results a boolean for about presale
     * @dev enable to add presaler list
    */
	function togglePresaleStatus() external onlyOwner {
        presaleLive = true;
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
	function getMaxValue() public pure returns (uint256) {
		return BBG_PER_MINT;
	}

	/**
     * @notice getter method of current contract status
     * @return current contract status
     */
    function state() public view virtual returns (State) {
        return _state;
    }

	/**
     * @notice update contract status for presale
     */
    function startPrivateSaleFirst() public onlyOwner {
		_state = State.PrivatePreSaleFirst;
    }

	/**
     * @notice update contract status for presale
     */
    function startPrivateSaleSecond() public onlyOwner {
        require(_state == State.PrivatePreSaleFirst);
        _state = State.PrivatePreSaleSecond;
    }

	/**
     * @notice update contract status to party
     */
    function setPublicSale() public onlyOwner {
        _state = State.PublicSale;
    }
}
