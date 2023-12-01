// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./utils/Challenge.sol";
import "./utils/RecoverableErc20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract WorldMillionaireChallenge is
    Ownable2Step,
    RecoverableErc20,
    Challenge
{
    using SafeERC20 for IERC20;

    IERC20 public immutable tokenUsdt;
    address public teamWallet;
    mapping(address => bool) public isDepositor;
    mapping(address => bool) public isDrawMaker;

    struct AccountingData {
        uint256 deposited;
        uint256 withdrawn;
    }
    AccountingData public accounting;

    /**
     * @param day - Draw day number
     */
    struct ProofRecord {
        uint256 day;
        uint256 blkNumber;
        uint256 blkTime;
        bytes32 blkHash;
        uint256 count;
        uint256 amount;
        uint256 index;
        uint256 winnerId;
        address winnerWallet;
        uint256 winRewards;
    }
    // day => proof
    mapping(uint256 => ProofRecord) public proof;

    // RefRewards
    bool public autoClaim;
    uint256 private constant _denominator = 10_000;
    uint256 private _refRewardTotal;
    uint256[] private _refRewards;

    event DepositorChanged(address indexed wallet, bool status);
    event DrawMakerChanged(address indexed wallet, bool status);
    event TeamWalletChanged(address oldValue, address newValue);
    event RefRewardsChanged(uint256 total, uint256 lines, uint256[] refRewards);
    event Deposit(
        address indexed participantWallet,
        uint256 indexed participantId,
        uint256 amount
    );
    event WinRewardsAwarded(
        address indexed participantWallet,
        uint256 indexed participantId,
        uint256 indexed day,
        uint256 amount
    );
    event RefRewardsAwarded(
        address indexed participantWallet,
        uint256 indexed participantId,
        uint256 indexed day,
        uint256 fromId,
        uint256 line,
        uint256 amount
    );
    event RefRewardsMissed(
        address indexed participantWallet,
        uint256 indexed participantId,
        uint256 indexed day,
        uint256 fromId,
        uint256 line,
        uint256 amount
    );
    event WinRewardsClaimed(
        address indexed participantWallet,
        uint256 indexed participantId,
        uint256 amount
    );
    event RefRewardsClaimed(
        address indexed participantWallet,
        uint256 indexed participantId,
        uint256 amount
    );

    constructor(
        address tokenUsdt_,
        address refTree_,
        address teamWallet_
    )
        Challenge(
            refTree_,
            "WMC.PRO Remaining Challenge Days",
            "WMC-DAYS",
            1,
            4,
            85500,
            100_000,
            90,
            1 * 10 ** 18
        )
    {
        tokenUsdt = IERC20(tokenUsdt_);

        emit TeamWalletChanged(teamWallet, teamWallet_);
        teamWallet = teamWallet_;

        _refRewardTotal = 1_000; // 10%
        _refRewards = [500, 250, 250]; // 5%, 2.5%, 2.5%
    }

    modifier onlyDepositor() {
        require(isDepositor[_msgSender()], "Caller is not the depositor");
        _;
    }

    function deposit(
        address wallet,
        uint256 numSeasons,
        uint256 referrerIdIn
    ) external onlyDepositor returns (bool) {
        uint256 participantId = _getOrAddParticipant(wallet, referrerIdIn);

        // Collect USDT
        (uint256 numDays, uint256 usdtAmount) = getDepositDaysAmount(
            wallet,
            numSeasons
        );
        tokenUsdt.safeTransferFrom(_msgSender(), address(this), usdtAmount);
        _incDepositedUsdt(usdtAmount);
        emit Deposit(wallet, participantId, usdtAmount);

        // Add a participant to seasons
        _addParticipantToSeasons(wallet, participantId, numSeasons);

        // Mint DaysToken
        _mint(wallet, numDays);

        return true;
    }

    function claim() external {
        _claim(_msgSender());
    }

    function _claim(address wallet) private {
        uint256 participantId = _getParticipantId(wallet);
        uint256 winRew = _getParticipantWinRewards(wallet) -
            _getParticipantWinRewardsClaimed(wallet);
        if (winRew > 0) {
            _sendWinRewards(wallet, participantId, winRew);
        }

        uint256 refRew = _getParticipantRefRewards(wallet) -
            _getParticipantRefRewardsClaimed(wallet);
        if (refRew > 0) {
            _sendRefRewards(wallet, participantId, refRew);
        }
    }

    modifier onlyDrawMaker() {
        require(isDrawMaker[_msgSender()], "Caller is not the draw maker");
        _;
    }

    function makeDraw(uint256 day) external onlyDrawMaker {
        require(data.isStarted, "Challenge has not started");

        (
            uint256 currentDay,
            uint256 currentSeason,

        ) = getCurrentDaySeasonSeasonday();
        require(day == currentDay, "Wrong day");

        // The process was not started.
        if (block.number - proof[day].blkNumber > 255) {
            if (day != 0) {
                require(
                    (block.timestamp - proof[day - 1].blkTime) >=
                        data.minInterval,
                    "Too often"
                );
            }
            proof[day].day = day;
            proof[day].blkNumber = block.number;
            proof[day].blkTime = block.timestamp;
            return;
        }

        proof[day].blkHash = blockhash(proof[day].blkNumber);
        uint256 participantsCount = _getSeasonParticipantsCount(currentSeason);
        proof[day].count = participantsCount;
        uint256 amountUsdt = participantsCount * data.dayPrice;
        proof[day].amount = amountUsdt;

        // Determining the index in the list of participantIds in the current season.
        uint256 index = uint256(
            keccak256(
                abi.encodePacked(
                    proof[day].day,
                    proof[day].blkNumber,
                    proof[day].blkTime,
                    proof[day].blkHash,
                    proof[day].count,
                    proof[day].amount
                )
            )
        ) % participantsCount;
        proof[day].index = index;

        address winWallet = _getSeasonParticipant(currentSeason, index);
        uint256 winId = _getParticipantId(winWallet);
        proof[day].winnerId = winId;
        proof[day].winnerWallet = winWallet;
        _addToWinners(winWallet);

        uint256 totalRefRewards;
        address refWallet = _getParticipantReferrerWallet(winWallet);
        for (uint256 i = 0; i < _refRewards.length; i++) {
            uint256 refId = _getParticipantId(refWallet);
            uint256 refRew = (amountUsdt * _refRewards[i]) / _denominator;
            totalRefRewards += refRew;

            // Check if the subscription is active.
            if (_isSeasonJoined(currentSeason, refWallet)) {
                _incParticipantRefRewards(refWallet, refRew);
                emit RefRewardsAwarded(refWallet, refId, day, winId, i, refRew);

                if (autoClaim) {
                    _sendRefRewards(refWallet, refId, refRew);
                }
            } else {
                /**
                 * If the referrer’s subscription is not active,
                 * then the rewards goes to the team’s wallet.
                 */
                emit RefRewardsMissed(refWallet, refId, day, winId, i, refRew);

                _incParticipantRefRewards(address(0), refRew);
                emit RefRewardsAwarded(address(0), 0, day, winId, i, refRew);

                _sendMissedRefRewards(refRew);
            }
            refWallet = _getParticipantReferrerWallet(refWallet);
        }

        uint256 winRew = amountUsdt - totalRefRewards;
        proof[day].winRewards = winRew;
        _incParticipantWinRewards(winWallet, winRew);
        emit WinRewardsAwarded(winWallet, winId, day, winRew);

        if (autoClaim) {
            _sendWinRewards(winWallet, winId, winRew);
        }
    }

    function _sendWinRewards(
        address wallet,
        uint256 participantId,
        uint256 amount
    ) private {
        tokenUsdt.safeTransfer(wallet, amount);
        _incParticipantWinRewardsClaimed(wallet, amount);
        _incWthdrawnUsdt(amount);
        emit WinRewardsClaimed(wallet, participantId, amount);
    }

    function _sendRefRewards(
        address wallet,
        uint256 participantId,
        uint256 amount
    ) private {
        tokenUsdt.safeTransfer(wallet, amount);
        _incParticipantRefRewardsClaimed(wallet, amount);
        _incWthdrawnUsdt(amount);
        emit RefRewardsClaimed(wallet, participantId, amount);
    }

    function _sendMissedRefRewards(uint256 amount) private {
        tokenUsdt.safeTransfer(teamWallet, amount);
        _incParticipantRefRewardsClaimed(address(0), amount);
        _incWthdrawnUsdt(amount);
        emit RefRewardsClaimed(address(0), 0, amount);
    }

    function _incDepositedUsdt(uint256 usdtAmount) private {
        accounting.deposited += usdtAmount;
    }

    function _incWthdrawnUsdt(uint256 usdtAmount) private {
        accounting.withdrawn += usdtAmount;
    }

    function _getRecoverableAmount(
        address token
    ) internal view override returns (uint256 recoverableAmount) {
        recoverableAmount = IERC20(token).balanceOf(address(this));
        if (token == address(tokenUsdt)) {
            return
                recoverableAmount -
                (accounting.deposited - accounting.withdrawn);
        }
    }

    function getRefRewards()
        external
        view
        returns (
            uint256 refRewardsTotal,
            uint256 refRewardsLines,
            uint256[] memory refRewards
        )
    {
        refRewardsTotal = _refRewardTotal;
        refRewardsLines = _refRewards.length;
        refRewards = _refRewards;
    }

    function setRefRewards(uint256[] memory newRefRewards) external onlyOwner {
        uint256 total;
        for (uint256 i; i < newRefRewards.length; i++) {
            total += newRefRewards[i];
        }
        require(total <= 1_000, "RefRewards too high");

        _refRewardTotal = total;
        _refRewards = newRefRewards;
        emit RefRewardsChanged(total, _refRewards.length, _refRewards);
    }

    function setDepositor(address depositor, bool status) external onlyOwner {
        emit DepositorChanged(depositor, status);
        isDepositor[depositor] = status;
    }

    function setDrawMaker(address drawMaker, bool status) external onlyOwner {
        emit DrawMakerChanged(drawMaker, status);
        isDrawMaker[drawMaker] = status;
    }

    function setTeamWallet(address newTeamWallet_) external onlyOwner {
        require(newTeamWallet_ != address(0), "Zero address");
        emit TeamWalletChanged(teamWallet, newTeamWallet_);
        teamWallet = newTeamWallet_;
    }

    function setAutoClaim(bool status) external onlyOwner {
        autoClaim = status;
    }
}
