// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

interface IRefTree {
    function getParticipantId(
        address wallet
    ) external view returns (uint256 participantId);

    function getParticipantWallet(
        uint256 participantId
    ) external view returns (address wallet);

    function getParticipant(
        address wallet
    )
        external
        view
        returns (
            uint256 participantId,
            address referrerWallet,
            uint256 referrerId,
            uint256 referrals
        );

    function addParticipant(
        address wallet,
        uint256 referrerIdIn
    )
        external
        returns (
            uint256 participantId,
            address referrerWallet,
            uint256 referrerId
        );
}
