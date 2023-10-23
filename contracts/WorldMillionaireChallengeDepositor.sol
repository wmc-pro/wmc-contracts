// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./utils/RecoverableErc20.sol";
import "./interfaces/IChallenge.sol";

contract WorldMillionaireChallengeDepositor is
    Ownable2Step,
    RecoverableErc20,
    Pausable
{
    using SafeERC20 for IERC20;

    IERC20 immutable tokenUsdt;
    IChallenge immutable challenge;
    address public teamWallet;

    // Signature
    uint256 immutable chainId;
    address public signer;
    mapping(address => uint256) public walletNonce;

    // Fees
    uint256 public immutable seasonDays;
    uint256 public seasonFees;
    bool public autoWithdrawal;

    // Events
    event ChallengeChanged(address oldValue, address newValue);
    event TeamWalletChanged(address oldValue, address newValue);
    event AutoWithdrawalChanged(bool oldValue, bool newValue);
    event SignerChanged(address oldValue, address newValue);
    event SeasonFeesChanged(uint256 oldValue, uint256 newValue);
    event Fees(address indexed from, address indexed to, uint256 amount);

    constructor(
        address tokenUsdt_,
        address challenge_,
        address teamWallet_,
        address signer_,
        bool autoWithdrawal_
    ) {
        chainId = block.chainid;
        seasonDays = 3; // TODO 90
        seasonFees = 3 * 10 ** 18;

        tokenUsdt = IERC20(tokenUsdt_);
        challenge = IChallenge(challenge_);

        emit AutoWithdrawalChanged(autoWithdrawal, autoWithdrawal_);
        autoWithdrawal = autoWithdrawal_;

        emit TeamWalletChanged(teamWallet, teamWallet_);
        teamWallet = teamWallet_;

        signer = signer_;
        emit SignerChanged(signer, signer_);
    }

    function getDepositDaysAmountFees(
        address wallet,
        uint256 numSeasons
    )
        public
        view
        returns (uint256 numDays, uint256 usdtAmount, uint256 usdtFees)
    {
        (numDays, usdtAmount) = challenge.getDepositDaysAmount(
            wallet,
            numSeasons
        );
        usdtFees =
            ((numDays / seasonDays) * seasonFees) +
            (((numDays % seasonDays) * seasonFees) / seasonDays);
    }

    function deposit(
        uint256 nonce,
        uint256 numSeasons,
        uint256 referrerId,
        bytes memory signature
    ) external whenNotPaused {
        // Check signature
        if (signer != address(0)) {
            _checkSignature(
                _msgSender(),
                nonce,
                numSeasons,
                referrerId,
                signature
            );
        }

        // Collect USDT
        (, uint256 usdtAmount, uint256 usdtFees) = getDepositDaysAmountFees(
            _msgSender(),
            numSeasons
        );
        tokenUsdt.safeTransferFrom(
            _msgSender(),
            address(this),
            usdtAmount + usdtFees
        );

        // Make deposit
        tokenUsdt.safeApprove(address(challenge), usdtAmount);
        challenge.deposit(_msgSender(), numSeasons, referrerId);

        // Send fees
        emit Fees(_msgSender(), address(this), usdtFees);
        if (autoWithdrawal) {
            tokenUsdt.safeTransfer(
                teamWallet,
                tokenUsdt.balanceOf(address(this))
            );
        }
    }

    function pause(bool status) external onlyOwner {
        if (status) _pause();
        else _unpause();
    }

    function setSeasonFees(uint256 newSeasonFees) external onlyOwner {
        emit SeasonFeesChanged(seasonFees, newSeasonFees);
        seasonFees = newSeasonFees;
    }

    function setTeamWallet(address newTeamWallet) external onlyOwner {
        require(newTeamWallet != address(0), "Zero address");
        emit TeamWalletChanged(teamWallet, newTeamWallet);
        teamWallet = newTeamWallet;
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
        uint256 numSeasons,
        uint256 referrerId,
        bytes memory signature
    ) private {
        require(walletNonce[wallet] < nonce, "Wallet nonce was used");
        require(
            _getSigner(wallet, nonce, numSeasons, referrerId, signature) ==
                signer,
            "Not authorized"
        );
        walletNonce[wallet] = nonce;
    }

    function _getSigner(
        address wallet,
        uint256 nonce,
        uint256 numSeasons,
        uint256 referrerId,
        bytes memory signature
    ) private view returns (address) {
        return
            ECDSA.recover(
                keccak256(
                    abi.encode(chainId, wallet, nonce, numSeasons, referrerId)
                ),
                signature
            );
    }
}
