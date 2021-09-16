// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC721/ERC721Tradeable.sol";

/**
 * @title Creature
 * Creature - a contract for my non-fungible creatures.
 */
contract SharkNFT is ERC721Tradable {
    constructor(address _proxyRegistryAddress)
        ERC721Tradable("SharkNFT", "SRK", _proxyRegistryAddress)
    {}

    function baseTokenURI() override public pure returns (string memory) {
        return "https://creatures-api.opensea.io/api/creature/";
    }

    function contractURI() public pure returns (string memory) {
        return "https://creatures-api.opensea.io/contract/opensea-creatures";
    }
}
