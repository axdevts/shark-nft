// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract SharkNFT is ERC721Enumerable, Ownable {
    using Strings for uint256;
    using ECDSA for bytes32;

    // uint256 public constant SVS_GIFT = 88;
    // uint256 public constant SVS_PRIVATE = 800;
    // uint256 public constant SVS_PUBLIC = 8000;
    uint256 public constant SVS_MAX = 7777;
    uint256 public SVS_PRICE = 0.07 ether;
    uint256 public constant SVS_PER_MINT = 5;

    mapping(address => bool) public presalerList;
    mapping(address => uint256) public presalerListPurchases;
    mapping(string => bool) private _usedNonces;
    mapping(uint256 => string) public metadataUris;

    string private _contractURI;
    string private _tokenBaseURI =
        "https://opensea-creatures-api.herokuapp.com/api/";
    // string private _tokenBaseURI = "https://SharkNFT.gg/api/metadata/";
    // address private _artistAddress = 0xea68212b0450A929B14726b90550933bC12fF813;
    // address private _signerAddress = 0x7e3999B106E4Ef472E569b772bF7F7647D8F26Ba;

    string public proof;
    uint256 public giftedAmount;
    uint256 public publicAmountMinted;
    uint256 public privateAmountMinted;
    uint256 public presalePurchaseLimit = 2;
    bool public presaleLive;
    bool public saleLive;
    bool public locked;

    constructor() ERC721("SharkNFT", "BNS") {}

    modifier notLocked() {
        require(!locked, "Contract metadata methods are locked");
        _;
    }

    function addToPresaleList(address[] calldata entries) external onlyOwner {
        for (uint256 i = 0; i < entries.length; i++) {
            address entry = entries[i];
            require(entry != address(0), "NULL_ADDRESS");
            require(!presalerList[entry], "DUPLICATE_ENTRY");

            presalerList[entry] = true;
        }
    }

    function removeFromPresaleList(address[] calldata entries)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < entries.length; i++) {
            address entry = entries[i];
            require(entry != address(0), "NULL_ADDRESS");

            presalerList[entry] = false;
        }
    }

    function hashTransaction(
        address sender,
        uint256 qty,
        string memory nonce
    ) private pure returns (bytes32) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                keccak256(abi.encodePacked(sender, qty, nonce))
            )
        );

        return hash;
    }

    function buy(
        // bytes32 hash,
        // bytes memory signature,
        // string memory nonce,
        uint256 tokenQuantity,
        bytes memory _data
    ) external payable {
        require(saleLive, "SALE_CLOSED");
        require(!presaleLive, "ONLY_PRESALE");
        // require(matchAddresSigner(hash, signature), "DIRECT_MINT_DISALLOWED");
        // require(!_usedNonces[nonce], "HASH_USED");
        // require(
        //     hashTransaction(msg.sender, tokenQuantity, nonce) == hash,
        //     "HASH_FAIL"
        // );
        require(totalSupply() < SVS_MAX, "OUT_OF_STOCK");
        // require(
        // publicAmountMinted + tokenQuantity <= SVS_PUBLIC,
        // "EXCEED_PUBLIC"
        // );
        require(tokenQuantity <= SVS_PER_MINT, "EXCEED_SVS_PER_MINT");
        // require(SVS_PRICE * tokenQuantity <= msg.value, "INSUFFICIENT_ETH");

        for (uint256 i = 0; i < tokenQuantity; i++) {
            publicAmountMinted++;
            _safeMint(msg.sender, totalSupply() + 1, _data);
        }

        // _usedNonces[nonce] = true;
    }

    function presaleBuy(uint256 tokenQuantity) external payable {
        require(!saleLive && presaleLive, "PRESALE_CLOSED");
        require(presalerList[msg.sender], "NOT_QUALIFIED");
        require(totalSupply() < SVS_MAX, "OUT_OF_STOCK");
        // require(
        // privateAmountMinted + tokenQuantity <= SVS_PRIVATE,
        // "EXCEED_PRIVATE"
        // );
        require(
            presalerListPurchases[msg.sender] + tokenQuantity <=
                presalePurchaseLimit,
            "EXCEED_ALLOC"
        );
        require(SVS_PRICE * tokenQuantity <= msg.value, "INSUFFICIENT_ETH");

        for (uint256 i = 0; i < tokenQuantity; i++) {
            privateAmountMinted++;
            presalerListPurchases[msg.sender]++;
            _safeMint(msg.sender, totalSupply() + 1);
        }
    }

    function getAmount() external view onlyOwner returns (uint256) {
        return (SVS_MAX - publicAmountMinted - privateAmountMinted);
    }

    function setPrice(uint256 _price) external onlyOwner {
        SVS_PRICE = _price;
    }

    function updateMetadatauri(uint256 tokenId, string calldata uri)
        external
        onlyOwner
    {
        metadataUris[tokenId] = uri;
    }

    function gift(address[] calldata receivers) external onlyOwner {
        require(totalSupply() + receivers.length <= SVS_MAX, "MAX_MINT");
        // require(giftedAmount + receivers.length <= SVS_GIFT, "GIFTS_EMPTY");

        for (uint256 i = 0; i < receivers.length; i++) {
            giftedAmount++;
            _safeMint(receivers[i], totalSupply() + 1);
        }
    }

    // function withdraw() external onlyOwner {
    // payable(_artistAddress).transfer((address(this).balance * 2) / 5);
    // payable(msg.sender).transfer(address(this).balance);
    // }

    function isPresaler(address addr) external view returns (bool) {
        return presalerList[addr];
    }

    function presalePurchasedCount(address addr)
        external
        view
        returns (uint256)
    {
        return presalerListPurchases[addr];
    }

    // Owner functions for enabling presale, sale, revealing and setting the provenance hash
    function lockMetadata() external onlyOwner {
        locked = true;
    }

    function togglePresaleStatus() external onlyOwner {
        presaleLive = !presaleLive;
    }

    function toggleSaleStatus() external onlyOwner {
        saleLive = !saleLive;
    }

    // function setSignerAddress(address addr) external onlyOwner {
    // _signerAddress = addr;
    // }

    function setProvenanceHash(string calldata hash)
        external
        onlyOwner
        notLocked
    {
        proof = hash;
    }

    function setContractURI(string calldata URI) external onlyOwner notLocked {
        _contractURI = URI;
    }

    function setBaseURI(string calldata URI) external onlyOwner notLocked {
        _tokenBaseURI = URI;
    }

    // aWYgeW91IHJlYWQgdGhpcywgc2VuZCBGcmVkZXJpayMwMDAxLCAiZnJlZGR5IGlzIGJpZyI=
    function contractURI() public view returns (string memory) {
        return _contractURI;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721)
        returns (string memory)
    {
        require(_exists(tokenId), "Cannot query non-existent token");

        return string(abi.encodePacked(_tokenBaseURI, tokenId.toString()));
    }
}
