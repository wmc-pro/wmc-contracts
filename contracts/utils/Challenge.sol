// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "./ParticipantsStorage.sol";
import "./DaysToken.sol";

abstract contract Challenge is Ownable2Step, DaysToken, ParticipantsStorage {
    /**
     * @param isStarted - The true when the challenge is launched.
     * @param lastSeasonId - Last joined season ID.
     * @param requirement - Number of participants to launch the challenge.
     * @param dayPrice - Price for one day.
     * @param seasonDays - Number of days in the season.
     * @param seasonsMinLimit - Minimum number of seasons to join.
     * @param seasonsMaxLimit - Maximum number of seasons to join.
     */
    struct ChallengeData {
        bool isStarted;
        uint256 lastSeasonId;
        uint256 requirement;
        uint256 dayPrice;
        uint256 seasonDays;
        uint256 seasonsMinLimit;
        uint256 seasonsMaxLimit;
    }
    ChallengeData public data;

    // Season participants
    // seasonId => [wallet1, wallet2, ...]
    mapping(uint256 => address[]) private _seasonParticipants;
    // seasonId => participanWallet => isJoined
    mapping(uint256 => mapping(address => bool)) private _seasonJoined;
    // dayId => participanWallet
    address[] private _winners;

    // Events
    event SeasonsMinLimitChanged(uint256 oldValue, uint256 newValue);
    event SeasonsMaxLimitChanged(uint256 oldValue, uint256 newValue);
    event RequirementChanged(uint256 oldValue, uint256 newValue);
    event ParticipantJoinedtoSeason(
        address indexed participantWallet,
        uint256 indexed participantId,
        uint256 indexed seasonId
    );
    event ChallengeStarted();

    constructor(
        address refTree_,
        string memory name_,
        string memory symbol_,
        uint256 seasonsMinLimit_,
        uint256 seasonsMaxLimit_,
        uint256 requirement_,
        uint256 seasonDays_,
        uint256 dayPrice_
    ) ParticipantsStorage(refTree_) DaysToken(name_, symbol_) {
        emit SeasonsMaxLimitChanged(data.seasonsMinLimit, seasonsMinLimit_);
        data.seasonsMinLimit = seasonsMinLimit_;

        emit SeasonsMaxLimitChanged(data.seasonsMaxLimit, seasonsMaxLimit_);
        data.seasonsMaxLimit = seasonsMaxLimit_;

        emit RequirementChanged(data.requirement, requirement_);
        data.requirement = requirement_;

        data.seasonDays = seasonDays_;
        data.dayPrice = dayPrice_;
    }

    function getSeasonParticipants(
        uint256 seasonId,
        uint256 offset,
        uint256 limit
    ) external view returns (uint256 total, address[] memory list) {
        total = _seasonParticipants[seasonId].length;
        limit = _getListLimit(total, offset, limit);

        list = new address[](limit);
        for (uint256 i = 0; i < limit; i++) {
            list[i] = _seasonParticipants[seasonId][offset + i];
        }
        return (total, list);
    }

    function getWinners(
        uint256 offset,
        uint256 limit
    ) external view returns (uint256 total, address[] memory list) {
        total = _getCurrentDay();
        limit = _getListLimit(total, offset, limit);

        list = new address[](limit);
        for (uint256 i = 0; i < limit; i++) {
            list[i] = _winners[offset + i];
        }
        return (total, list);
    }

    function _addToWinners(address wallet) internal {
        _winners.push(wallet);
        _incParticipantWins(wallet);
    }

    function _getCurrentDay() private view returns (uint256 currentDay) {
        return _winners.length;
    }

    function _isSeasonJoined(
        uint256 seasonId,
        address wallet
    ) internal view returns (bool) {
        return _seasonJoined[seasonId][wallet];
    }

    function _getSeasonParticipantsCount(
        uint256 seasonId
    ) internal view returns (uint256) {
        return _seasonParticipants[seasonId].length;
    }

    function _getSeasonParticipant(
        uint256 seasonId,
        uint256 index
    ) internal view returns (address) {
        return _seasonParticipants[seasonId][index];
    }

    function _addAdnJoinToSeason(uint256 seasonId, address wallet) private {
        _seasonParticipants[seasonId].push(wallet);
        _seasonJoined[seasonId][wallet] = true;
    }

    /**
     * @param currentDay - A current day that is not yet closed.
     * @param currentSeason - A current season.
     * @param currentSeasonDay - A current season day.
     */
    function getCurrentDaySeasonSeasonday()
        public
        view
        returns (
            uint256 currentDay,
            uint256 currentSeason,
            uint256 currentSeasonDay
        )
    {
        currentDay = _getCurrentDay();
        currentSeason = currentDay / data.seasonDays;
        currentSeasonDay = currentDay % data.seasonDays;
    }

    function getSeasonsMaxLimit(
        address wallet
    ) external view returns (uint256) {
        (
            ,
            uint256 currentSeason,
            uint256 currentSeasonDay
        ) = getCurrentDaySeasonSeasonday();
        return
            _getSeasonsMaxLimit(
                _getParticipantLastSeasonId(wallet),
                _isSeasonJoined(currentSeason, wallet),
                currentSeason,
                currentSeasonDay
            );
    }

    function _getSeasonsMaxLimit(
        uint256 lastSeasonId,
        bool isCurrentSeasonJoined,
        uint256 currentSeason,
        uint256 currentSeasonDay
    ) private view returns (uint256 seasonsMax) {
        /**
         * If a participant has not joined the current season,
         * then the usual limit applies.
         */
        if (!isCurrentSeasonJoined) {
            return data.seasonsMaxLimit;
        }

        seasonsMax = ((currentSeason + data.seasonsMaxLimit) - lastSeasonId);
        /**
         * The participant joined in the current season
         * and the current season is not started (all 90/90 days).
         */
        if (currentSeasonDay == 0) {
            if (seasonsMax > 0) {
                return seasonsMax - 1;
            } else {
                return 0;
            }
        }
    }

    function getDepositDaysAmount(
        address wallet,
        uint256 numSeasons
    ) public view returns (uint256 numDays, uint256 usdtAmount) {
        (
            ,
            uint256 currentSeason,
            uint256 currentSeasonDay
        ) = getCurrentDaySeasonSeasonday();
        bool isCurrentSeasonJoined = _isSeasonJoined(currentSeason, wallet);
        uint256 seasonsMax = _getSeasonsMaxLimit(
            _getParticipantLastSeasonId(wallet),
            isCurrentSeasonJoined,
            currentSeason,
            currentSeasonDay
        );
        require(
            numSeasons >= data.seasonsMinLimit && numSeasons <= seasonsMax,
            "Seasons limit"
        );

        numDays = numSeasons * data.seasonDays;

        /**
         * If the current season has already started
         * and the participant has not joined the current season,
         * then the current season is added (above numSeasons).
         */
        if (currentSeasonDay != 0 && !isCurrentSeasonJoined) {
            // Add the remaining days of the current season.
            numDays += data.seasonDays - currentSeasonDay;
        }
        usdtAmount = data.dayPrice * numDays;
    }

    /**
     * @param wallet - Participant wallet.
     * @param participantId - Participant ID.
     * @param numSeasons - Number of new seasons not including the current season.
     */
    function _addParticipantToSeasons(
        address wallet,
        uint256 participantId,
        uint256 numSeasons
    ) internal {
        /**
         * lastSeasonId - Last joined season.
         * For a new participant this is equal to 0.
         * We add 1 to shift the pointer to the next not joined season.
         */
        uint256 nextSeasonId = _getParticipantLastSeasonId(wallet) + 1;

        (
            ,
            uint256 currentSeason,
            uint256 currentSeasonDay
        ) = getCurrentDaySeasonSeasonday();
        // If the participant has not joined the current season.
        if (!_isSeasonJoined(currentSeason, wallet)) {
            /**
             * If the current season has already started (closed 1 or more days),
             * then the current season is added (above numSeasons).
             */
            if (currentSeasonDay != 0) {
                _addAdnJoinToSeason(currentSeason, wallet);
                emit ParticipantJoinedtoSeason(
                    wallet,
                    participantId,
                    currentSeason
                );

                // Next season after current season.
                nextSeasonId = currentSeason + 1;
            }
            /**
             * This means currentSeasonDay is equal to 0.
             * This may be the case when the participant
             * entered at the start of the season (not a single day is closed).
             * This may be before the requirements are met
             * or the day after the previous season closes.
             */
            else {
                nextSeasonId = currentSeason;
            }
        }

        // Add a participant to seasons
        for (uint256 i = 0; i < numSeasons; i++) {
            uint256 seasonId = nextSeasonId + i;
            _addAdnJoinToSeason(seasonId, wallet);
            emit ParticipantJoinedtoSeason(wallet, participantId, seasonId);
        }
        _setParticipantLastSeasonId(wallet, nextSeasonId + numSeasons - 1);

        // Update the last joined season
        if (_getParticipantLastSeasonId(wallet) > data.lastSeasonId) {
            data.lastSeasonId = _getParticipantLastSeasonId(wallet);
        }

        // Checking that the requirement for launching the game are met.
        if (!data.isStarted) {
            _checkRequirementForStart();
        }
    }

    function _checkRequirementForStart() private {
        if (_getSeasonParticipantsCount(0) == data.requirement) {
            data.isStarted = true;
            emit ChallengeStarted();
        }
    }

    function setSeasonsLimits(
        uint256 newSeasonsMinLimit,
        uint256 newSeasonsMaxLimit
    ) external onlyOwner {
        require(newSeasonsMinLimit <= newSeasonsMaxLimit, "Wrong limits");
        emit SeasonsMinLimitChanged(data.seasonsMinLimit, newSeasonsMinLimit);
        data.seasonsMinLimit = newSeasonsMinLimit;

        emit SeasonsMaxLimitChanged(data.seasonsMaxLimit, newSeasonsMaxLimit);
        data.seasonsMaxLimit = newSeasonsMaxLimit;
    }

    function setRequirement(uint256 newRequirement) external onlyOwner {
        require(
            newRequirement >= _getSeasonParticipantsCount(0),
            "It must be more than the number of participants"
        );
        emit RequirementChanged(data.requirement, newRequirement);
        data.requirement = newRequirement;

        // Checking that the requirement for launching the game are met.
        if (!data.isStarted) {
            _checkRequirementForStart();
        }
    }

    function _getListLimit(
        uint256 total,
        uint256 offset,
        uint256 limit
    ) private pure returns (uint256) {
        if ((offset + limit) > total) {
            return total - offset;
        }
        return limit;
    }

    // START OF ERC20
    /**
     * @dev Number of challenge days left.
     */
    function totalSupply() external view override returns (uint256) {
        return (data.lastSeasonId + 1) * data.seasonDays - _getCurrentDay();
    }

    /**
     * @dev Number of challenge days left for this participant.
     */
    function balanceOf(
        address account
    ) external view override returns (uint256) {
        (
            uint256 currentDay,
            uint256 currentSeason,

        ) = getCurrentDaySeasonSeasonday();
        if (_isSeasonJoined(currentSeason, account)) {
            return
                (_getParticipantLastSeasonId(account) + 1) *
                data.seasonDays -
                currentDay;
        }
        return 0;
    }

    // END ERC20
}
