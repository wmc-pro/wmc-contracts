// Root file: contracts/interfaces/IChallenge.sol

// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IChallenge {
    function deposit(
        address wallet,
        uint256 numSeasons,
        uint256 referrerId
    ) external returns (bool success);

    function getDepositDaysAmount(
        address wallet,
        uint256 numSeasons
    ) external view returns (uint256 numDays, uint256 usdtAmount);

    function getParticipantData(
        address wallet
    )
        external
        view
        returns (
            uint256 participantId,
            address referrerWallet,
            uint256 referrerId,
            uint256 lastSeasonId,
            uint256 wins,
            uint256 winRewards,
            uint256 winRewardsClaimed,
            uint256 refRewards,
            uint256 refRewardsClaimed
        );
}
