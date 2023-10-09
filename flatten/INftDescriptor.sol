// Root file: contracts/interfaces/INftDescriptor.sol

// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

interface INftDescriptor {
    function contractURI() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}
