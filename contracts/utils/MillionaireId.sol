// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/IERC721MetadataUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/IERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC2981Upgradeable.sol";

/**
 * @dev Millionaire ID on World Millionaire Challenge as ERC721 token.
 */
abstract contract MillionaireId is
    Initializable,
    IERC165Upgradeable,
    IERC721Upgradeable,
    IERC721MetadataUpgradeable,
    IERC721EnumerableUpgradeable,
    IERC2981Upgradeable
{
    // Metadata
    string private _name;
    string private _symbol;

    uint256 private constant _offset = 1;
    string private constant _error = "This function is not used";

    address[] private _owners;

    event TokenMetadataChanged(string name, string symbol);

    function __MillionaireId_init(
        string memory name_,
        string memory symbol_
    ) internal onlyInitializing {
        __MillionaireId_init_unchained(name_, symbol_);
    }

    function __MillionaireId_init_unchained(
        string memory name_,
        string memory symbol_
    ) internal onlyInitializing {
        _setTokenMetadata(name_, symbol_);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) external pure override returns (bool) {
        return
            interfaceId == type(IERC721Upgradeable).interfaceId ||
            interfaceId == type(IERC721MetadataUpgradeable).interfaceId ||
            interfaceId == type(IERC721EnumerableUpgradeable).interfaceId ||
            interfaceId == type(IERC2981Upgradeable).interfaceId ||
            interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    ) external view returns (address receiver, uint256 royaltyAmount) {}

    function totalSupply() public view returns (uint256) {
        return _owners.length;
    }

    function tokenOfOwnerByIndex(
        address,
        uint256
    ) public view virtual returns (uint256) {}

    function tokensOfOwner(
        address owner
    ) external view returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(owner);
        require(tokenCount > 0, "ERC721Enumerable: owner index out of bounds");
        uint256[] memory tokenIds = new uint256[](tokenCount);
        for (uint256 i = 0; i < tokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(owner, i);
        }
        return tokenIds;
    }

    function tokenByIndex(uint256 index) external view returns (uint256) {
        require(
            index < totalSupply(),
            "ERC721Enumerable: global index out of bounds"
        );
        return index + _offset;
    }

    function balanceOf(
        address
    ) public view virtual override returns (uint256) {}

    function ownerOf(uint256 tokenId) external view override returns (address) {
        _requireMinted(tokenId);
        return _ownerOf(tokenId);
    }

    function rawOwnerOf(uint256 tokenId) public view returns (address) {
        if (_exists(tokenId)) {
            return _ownerOf(tokenId);
        }
        return address(0);
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function tokenURI(
        uint256
    ) external view virtual override returns (string memory) {}

    /**
     * @dev This function is not used.
     */
    function approve(address, uint256) external pure override {
        _makeError();
    }

    /**
     * @dev This function is not used.
     */
    function getApproved(
        uint256 tokenId
    ) external view override returns (address) {
        _requireMinted(tokenId);
        return address(0);
    }

    /**
     * @dev This function is not used.
     */
    function setApprovalForAll(address, bool) external pure override {
        _makeError();
    }

    /**
     * @dev This function is not used.
     */
    function isApprovedForAll(
        address,
        address
    ) external pure override returns (bool) {
        return false;
    }

    /**
     * @dev This function is not used.
     */
    function transferFrom(address, address, uint256) external pure override {
        _makeError();
    }

    /**
     * @dev This function is not used.
     */
    function safeTransferFrom(
        address,
        address,
        uint256
    ) external pure override {
        _makeError();
    }

    /**
     * @dev This function is not used.
     */
    function safeTransferFrom(
        address,
        address,
        uint256,
        bytes memory
    ) external pure override {
        _makeError();
    }

    function _ownerOf(uint256 tokenId) internal view returns (address) {
        return _owners[tokenId - _offset];
    }

    function _ownerByIndex(uint256 index) internal view returns (address) {
        return _owners[index];
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        return tokenId > 0 && tokenId <= totalSupply();
    }

    function _mint(address to) internal returns (uint256 tokenId) {
        _owners.push(to);
        tokenId = totalSupply();
        emit Transfer(address(0), to, tokenId);
    }

    function _requireMinted(uint256 tokenId) internal view {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    function _makeError() private pure {
        revert(_error);
    }

    function _setTokenMetadata(
        string memory name_,
        string memory symbol_
    ) internal {
        _name = name_;
        _symbol = symbol_;
        emit TokenMetadataChanged(name_, symbol_);
    }
}
