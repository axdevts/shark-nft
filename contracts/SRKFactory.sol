// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "openzeppelin-solidity/contracts/utils/Strings.sol";
import "./interface/IFactoryERC721.sol";
import "./SharkNFT.sol";

contract SRKFactory is FactoryERC721, Ownable {
    using Strings for string;

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    address public proxyRegistryAddress;
    address public nftAddress;
    string public baseURI = "https://creatures-api.opensea.io/api/factory/";

    /*
     * Enforce the existence of only 100 OpenSea creatures.
     */
    uint256 SHARK_SUPPLY = 100;

    constructor(address _proxyRegistryAddress, address _nftAddress) {
        proxyRegistryAddress = _proxyRegistryAddress;
        nftAddress = _nftAddress;
    }

    function name() external pure override returns (string memory) {
        return "SharkNFT";
    }

    function symbol() external pure override returns (string memory) {
        return "SRK";
    }

    function supportsFactoryInterface() public pure override returns (bool) {
        return true;
    }

    function transferOwnership(address newOwner) public override onlyOwner {
        // address _prevOwner = owner();
        super.transferOwnership(newOwner);
    }

    function mint(uint256 _optionId, address _toAddress) public override {
        // Must be sent from the owner proxy or owner.
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        assert(
            address(proxyRegistry.proxies(owner())) == _msgSender() ||
                owner() == _msgSender()
        );
        require(canMint(_optionId));

        SharkNFT srkNFT = SharkNFT(nftAddress);
        srkNFT.mintTo(_toAddress);
    }

    function canMint() public view returns (uint256 _optionId, bool) {
        SharkNFT srkNFT = SharkNFT(nftAddress);
        uint256 creatureSupply = srkNFT.totalSupply();

        return creatureSupply == 0;
    }

    function tokenURI(uint256 _optionId)
        external
        view
        override
        returns (string memory)
    {
        return string(abi.encodePacked(baseURI, Strings.toString(_optionId)));
    }

    /**
     * Hack to get things to work automatically on OpenSea.
     * Use transferFrom so the frontend doesn't have to worry about different method names.
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public {
        mint(_tokenId, _to);
    }

    /**
     * Hack to get things to work automatically on OpenSea.
     * Use isApprovedForAll so the frontend doesn't have to worry about different method names.
     */
    function isApprovedForAll(address _owner, address _operator)
        public
        view
        returns (bool)
    {
        if (owner() == _owner && _owner == _operator) {
            return true;
        }

        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (
            owner() == _owner &&
            address(proxyRegistry.proxies(_owner)) == _operator
        ) {
            return true;
        }

        return false;
    }

    /**
     * Hack to get things to work automatically on OpenSea.
     * Use isApprovedForAll so the frontend doesn't have to worry about different method names.
     */
    function ownerOf()
        public
        view
        returns (
            // uint256 _tokenId
            address _owner
        )
    {
        return owner();
    }
}
