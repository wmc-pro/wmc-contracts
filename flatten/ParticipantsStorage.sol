// Dependency file: contracts/interfaces/IRefTree.sol

// SPDX-License-Identifier: MIT
// pragma solidity 0.8.21;

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


// Root file: contracts/utils/ParticipantsStorage.sol

pragma solidity 0.8.21;

// import "contracts/interfaces/IRefTree.sol";

abstract contract ParticipantsStorage {
    IRefTree public immutable refTree;

    /**
     * @param id - 1, 2, 3, ..., n. default=0. 0 does not exist by logic.
     * 0 it is team wallet.
     * @param lastSeasonId - default=0.
     * @param wins - Number of wins.
     * @param winRewards - Amount of USDT that has not been claimed.
     * @param refRewards - Amount of USDT that has not been claimed.
     */
    struct ParticipantData {
        uint256 id;
        address referrerWallet;
        uint256 referrerId;
        uint256 lastSeasonId;
        uint256 wins;
        uint256 winRewards;
        uint256 winRewardsClaimed;
        uint256 refRewards;
        uint256 refRewardsClaimed;
    }
    mapping(address => ParticipantData) private _participantData;

    // Events
    event NewParticipant(
        address indexed participantWallet,
        uint256 indexed participantId,
        uint256 indexed referrerId
    );

    constructor(address refTree_) {
        refTree = IRefTree(refTree_);
    }

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
        )
    {
        participantId = _getParticipantId(wallet);
        referrerWallet = _getParticipantReferrerWallet(wallet);
        referrerId = _participantData[wallet].referrerId;
        lastSeasonId = _getParticipantLastSeasonId(wallet);
        wins = _participantData[wallet].wins;
        winRewards = _getParticipantWinRewards(wallet);
        winRewardsClaimed = _getParticipantWinRewardsClaimed(wallet);
        refRewards = _getParticipantRefRewards(wallet);
        refRewardsClaimed = _getParticipantRefRewardsClaimed(wallet);
    }

    function _getParticipantId(address wallet) internal view returns (uint256) {
        return _participantData[wallet].id;
    }

    function _getParticipantReferrerWallet(
        address wallet
    ) internal view returns (address) {
        return _participantData[wallet].referrerWallet;
    }

    function _getParticipantLastSeasonId(
        address wallet
    ) internal view returns (uint256) {
        return _participantData[wallet].lastSeasonId;
    }

    function _setParticipantLastSeasonId(
        address wallet,
        uint256 lastSeasonId
    ) internal {
        _participantData[wallet].lastSeasonId = lastSeasonId;
    }

    function _incParticipantWins(address wallet) internal {
        _participantData[wallet].wins++;
    }

    function _getParticipantWinRewards(
        address wallet
    ) internal view returns (uint256) {
        return _participantData[wallet].winRewards;
    }

    function _getParticipantWinRewardsClaimed(
        address wallet
    ) internal view returns (uint256) {
        return _participantData[wallet].winRewardsClaimed;
    }

    function _getParticipantRefRewards(
        address wallet
    ) internal view returns (uint256) {
        return _participantData[wallet].refRewards;
    }

    function _getParticipantRefRewardsClaimed(
        address wallet
    ) internal view returns (uint256) {
        return _participantData[wallet].refRewardsClaimed;
    }

    function _incParticipantWinRewards(address wallet, uint256 inc) internal {
        _participantData[wallet].winRewards += inc;
    }

    function _incParticipantWinRewardsClaimed(
        address wallet,
        uint256 inc
    ) internal {
        _participantData[wallet].winRewardsClaimed += inc;
    }

    function _incParticipantRefRewards(address wallet, uint256 inc) internal {
        _participantData[wallet].refRewards += inc;
    }

    function _incParticipantRefRewardsClaimed(
        address wallet,
        uint256 inc
    ) internal {
        _participantData[wallet].refRewardsClaimed += inc;
    }

    function _getOrAddParticipant(
        address wallet,
        uint256 referrerIdIn
    ) internal returns (uint256 participantId) {
        // Record found.
        if (_getParticipantId(wallet) != 0) {
            return _getParticipantId(wallet);
        }

        // Record not found.
        // So we try to get it from the referral tree, or create a new entry.
        address referrerWallet;
        uint256 referrerId;
        (participantId, referrerWallet, referrerId, ) = refTree.getParticipant(
            wallet
        );
        // The entry in the referral tree was not found.
        // Create a new record.
        if (participantId == 0) {
            (participantId, referrerWallet, referrerId) = refTree
                .addParticipant(wallet, referrerIdIn);
        }

        _participantData[wallet].id = participantId;
        _participantData[wallet].referrerWallet = referrerWallet;
        _participantData[wallet].referrerId = referrerId;
        emit NewParticipant(wallet, participantId, referrerId);
    }
}
