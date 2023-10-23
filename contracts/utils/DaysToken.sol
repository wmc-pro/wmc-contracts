// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

/**
 * @dev Remaining Challenge days on World Millionaire Challenge as ERC20 token.
 */
abstract contract DaysToken is Ownable2Step, IERC20, IERC20Metadata {
    // Metadata
    string private _name;
    string private _symbol;

    string private constant _error = "This function is not used";

    event TokenMetadataChanged(string name, string symbol);

    constructor(string memory name_, string memory symbol_) {
        _setTokenMetadata(name_, symbol_);
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function decimals() external pure override returns (uint8) {
        return 0;
    }

    function totalSupply() external view virtual override returns (uint256) {}

    function balanceOf(
        address
    ) external view virtual override returns (uint256) {}

    /**
     * @dev This function is not used.
     */
    function allowance(
        address,
        address
    ) external pure override returns (uint256) {
        return 0;
    }

    /**
     * @dev This function is not used.
     */
    function approve(address, uint256) external pure override returns (bool) {
        _makeError();
    }

    /**
     * @dev This function is not used.
     */
    function transfer(address, uint256) external pure override returns (bool) {
        _makeError();
    }

    /**
     * @dev This function is not used.
     */
    function transferFrom(
        address,
        address,
        uint256
    ) external pure override returns (bool) {
        _makeError();
    }

    function _mint(address account, uint256 amount) internal {
        emit Transfer(address(0), account, amount);
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

    function setTokenMetadata(
        string memory name_,
        string memory symbol_
    ) external onlyOwner {
        _setTokenMetadata(name_, symbol_);
    }
}
