// Dependency file: @openzeppelin/contracts/utils/Context.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

// pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


// Dependency file: @openzeppelin/contracts/access/Ownable.sol

// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// Dependency file: @openzeppelin/contracts/access/Ownable2Step.sol

// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable2Step.sol)

// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @dev Contract module which provides access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership} and {acceptOwnership}.
 *
 * This module is used through inheritance. It will make available all functions
 * from parent (Ownable).
 */
abstract contract Ownable2Step is Ownable {
    address private _pendingOwner;

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    /**
     * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner(), newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`) and deletes any pending owner.
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual override {
        delete _pendingOwner;
        super._transferOwnership(newOwner);
    }

    /**
     * @dev The new owner accepts the ownership transfer.
     */
    function acceptOwnership() public virtual {
        address sender = _msgSender();
        require(pendingOwner() == sender, "Ownable2Step: caller is not the new owner");
        _transferOwnership(sender);
    }
}


// Dependency file: contracts/interfaces/IRefTree.sol

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


// Dependency file: contracts/utils/ParticipantsStorage.sol

// pragma solidity 0.8.21;

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


// Dependency file: @openzeppelin/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

// pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}


// Dependency file: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}


// Dependency file: contracts/utils/DaysToken.sol

// pragma solidity 0.8.21;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
// import "@openzeppelin/contracts/access/Ownable2Step.sol";

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


// Root file: contracts/utils/Challenge.sol

pragma solidity 0.8.21;

// import "@openzeppelin/contracts/access/Ownable2Step.sol";
// import "contracts/utils/ParticipantsStorage.sol";
// import "contracts/utils/DaysToken.sol";

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
