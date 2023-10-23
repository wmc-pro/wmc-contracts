// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./utils/RecoverableErc20.sol";

contract WorldMillionaireChallengeTokenSale is
    Ownable2Step,
    RecoverableErc20,
    Pausable
{
    using SafeERC20 for IERC20;

    IERC20 public immutable tokenUsdt;
    IERC20 public immutable tokenWmc;
    address public teamWallet;
    uint256 public price;
    bool public autoWithdrawal;

    // Signature
    uint256 immutable chainId;
    address public signer;
    mapping(address => uint256) public walletNonce;

    // Events
    event TokenSale(address indexed wallet, uint256 amount, uint256 price);
    event TeamWalletChanged(address oldValue, address newValue);
    event PriceChanged(uint256 oldPrice, uint256 newPrice);
    event AutoWithdrawalChanged(bool oldValue, bool newValue);
    event SignerChanged(address oldValue, address newValue);

    constructor(
        address tokenUsdt_,
        address tokenWmc_,
        address teamWallet_,
        address signer_,
        bool autoWithdrawal_
    ) {
        tokenUsdt = IERC20(tokenUsdt_);
        tokenWmc = IERC20(tokenWmc_);
        chainId = block.chainid;

        price = 1 * 10 ** 18;
        emit PriceChanged(0, price);

        emit AutoWithdrawalChanged(autoWithdrawal, autoWithdrawal_);
        autoWithdrawal = autoWithdrawal_;

        emit TeamWalletChanged(teamWallet, teamWallet_);
        teamWallet = teamWallet_;

        emit SignerChanged(signer, signer_);
        signer = signer_;
    }

    function reserveWmc() public view returns (uint256) {
        return tokenWmc.balanceOf(address(this));
    }

    function buy(
        uint256 nonce,
        uint256 amountUsdt,
        bytes memory signature
    ) external whenNotPaused {
        uint256 amountWmc = (amountUsdt * 10 ** 18) / price;
        require(amountWmc <= reserveWmc(), "Insufficient WMC");

        // Check signature
        if (signer != address(0)) {
            _checkSignature(_msgSender(), nonce, amountUsdt, signature);
        }

        tokenUsdt.safeTransferFrom(_msgSender(), address(this), amountUsdt);
        tokenWmc.safeTransfer(_msgSender(), amountWmc);
        emit TokenSale(_msgSender(), amountWmc, price);

        if (autoWithdrawal) {
            tokenUsdt.safeTransfer(
                teamWallet,
                tokenUsdt.balanceOf(address(this))
            );
        }
    }

    function pause(bool paused_) external onlyOwner {
        if (paused_) _pause();
        else _unpause();
    }

    function setPrice(uint256 price_) external onlyOwner {
        require(price_ != 0, "Zero price");
        emit PriceChanged(price, price_);
        price = price_;
    }

    function setTeamWallet(address newTeamWallet_) external onlyOwner {
        require(newTeamWallet_ != address(0), "Zero address");
        emit TeamWalletChanged(teamWallet, newTeamWallet_);
        teamWallet = newTeamWallet_;
    }

    function setAutoWithdrawal(bool autoWithdrawal_) external onlyOwner {
        emit AutoWithdrawalChanged(autoWithdrawal, autoWithdrawal_);
        autoWithdrawal = autoWithdrawal_;
    }

    // Signature
    function setSigner(address newSigner) external onlyOwner {
        emit SignerChanged(signer, newSigner);
        signer = newSigner;
    }

    function _checkSignature(
        address wallet,
        uint256 nonce,
        uint256 amountUsdt,
        bytes memory signature
    ) private {
        require(walletNonce[wallet] < nonce, "Wallet nonce was used");
        require(
            _getSigner(wallet, nonce, amountUsdt, signature) == signer,
            "Not authorized"
        );
        walletNonce[wallet] = nonce;
    }

    function _getSigner(
        address wallet,
        uint256 nonce,
        uint256 amountUsdt,
        bytes memory signature
    ) private view returns (address) {
        return
            ECDSA.recover(
                keccak256(abi.encode(chainId, wallet, nonce, amountUsdt)),
                signature
            );
    }
}
