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


// Dependency file: @openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/extensions/IERC20Permit.sol)

// pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}


// Dependency file: @openzeppelin/contracts/utils/Address.sol

// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

// pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}


// Dependency file: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/utils/SafeERC20.sol)

// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";
// import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance + value));
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance - value));
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Compatible with tokens that require the approval to be set to
     * 0 before setting it to a non-zero value.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeWithSelector(token.approve.selector, spender, value);

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Use a ERC-2612 signature to set the `owner` approval toward `spender` on `token`.
     * Revert on invalid signature.
     */
    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        require(returndata.length == 0 || abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return
            success && (returndata.length == 0 || abi.decode(returndata, (bool))) && Address.isContract(address(token));
    }
}


// Dependency file: contracts/interfaces/IRefTree.sol

// pragma solidity 0.8.19;

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

// pragma solidity 0.8.19;

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

// pragma solidity 0.8.19;

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


// Dependency file: contracts/utils/Challenge.sol

// pragma solidity 0.8.19;

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
        uint256 minInterval;
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
    event MinIntervalChanged(uint256 oldValue, uint256 newValue);
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
        uint256 minInterval_,
        uint256 requirement_,
        uint256 seasonDays_,
        uint256 dayPrice_
    ) ParticipantsStorage(refTree_) DaysToken(name_, symbol_) {
        emit SeasonsMaxLimitChanged(data.seasonsMinLimit, seasonsMinLimit_);
        data.seasonsMinLimit = seasonsMinLimit_;

        emit SeasonsMaxLimitChanged(data.seasonsMaxLimit, seasonsMaxLimit_);
        data.seasonsMaxLimit = seasonsMaxLimit_;

        emit MinIntervalChanged(data.minInterval, minInterval_);
        data.minInterval = minInterval_;

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

    function setMinInterval(uint256 newMinInterval) external onlyOwner {
        require(newMinInterval < 24 * 60 * 60, "Wrong interval");

        emit MinIntervalChanged(data.minInterval, newMinInterval);
        data.minInterval = newMinInterval;
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


// Dependency file: contracts/utils/RecoverableErc20.sol

// pragma solidity 0.8.19;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/access/Ownable2Step.sol";

/**
 * @dev The contract is intendent to help recovering arbitrary ERC20 tokens and
 * ETH accidentally transferred to the contract address
 */
abstract contract RecoverableErc20 is Ownable2Step {
    event RecoveredFunds(
        address indexed token,
        uint256 amount,
        address indexed recipient
    );

    function _getRecoverableAmount(
        address token
    ) internal view virtual returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    /**
     * @param token - ERC20 token's address to recover
     * @param amount - to recover from contract's address
     * @param recipient - address to receive tokens from the contract
     */
    function recoverFunds(
        address token,
        uint256 amount,
        address recipient
    ) external onlyOwner returns (bool) {
        require(token != address(0), "Recoverable: token is zero");
        uint256 recoverableAmount = _getRecoverableAmount(token);
        require(
            amount <= recoverableAmount,
            "Recoverable: RECOVERABLE_AMOUNT_NOT_ENOUGH"
        );
        _transferErc20(token, amount, recipient);
        emit RecoveredFunds(token, amount, recipient);
        return true;
    }

    function _transferErc20(
        address token,
        uint256 amount,
        address recipient
    ) private {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, recipient, amount)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "Recoverable: TRANSFER_FAILED"
        );
    }
}


// Root file: contracts/WorldMillionaireChallenge.sol

pragma solidity 0.8.19;

// import "@openzeppelin/contracts/access/Ownable2Step.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
// import "contracts/utils/Challenge.sol";
// import "contracts/utils/RecoverableErc20.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

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

    /*
    Challenge(
        refTree_,
        "WMC.PRO Remaining Challenge Days",
        "WMC-DAYS",
        1,
        4,
        85500, // TODO 23:45 = 24*60*60-15*60 = 85500
        100_000, // TODO
        90, // TODO
        1 * 10 ** 18
    )*/
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
            10,
            60,
            3,
            3,
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
