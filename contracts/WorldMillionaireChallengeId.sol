// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "./utils/MillionaireId.sol";
import "./interfaces/IRefTree.sol";
import "./interfaces/INftDescriptor.sol";

/**
 * @dev Millionaire ID on World Millionaire Challenge as ERC721 token. Referral tree.
 */
contract WorldMillionaireChallengeId is
    Initializable,
    Ownable2StepUpgradeable,
    MillionaireId,
    IRefTree
{
    using StringsUpgradeable for uint256;

    // Metadata
    INftDescriptor public nftDescriptor;
    string private _contractURI;
    string private _baseURI;
    string private _ext;
    bool private _revealed = false;
    string private _notRevealedURI;

    /**
     * @param id - participant ID.
     * @param referrerId - referrer ID.
     * @param referrerWallet - referrer Wallet.
     */
    struct ParticipantData {
        uint256 id;
        address referrerWallet;
        uint256 referrerId;
    }
    mapping(address => ParticipantData) private _participantData;
    mapping(address => address[]) private _referrals;

    mapping(address => bool) public isAdmin;

    // Events
    event NftDescriptorChanged(address oldValue, address newValue);
    event AdminChanged(address indexed wallet, bool status);
    event NewParticipant(
        address indexed participantWallet,
        uint256 indexed participantId,
        uint256 indexed referrerId
    );

    function initialize() public initializer {
        __Ownable2Step_init();
        __MillionaireId_init("World Millionaire Challenge ID", "MILLIONAIRE");
    }

    function version() external view returns (uint8) {
        return _getInitializedVersion();
    }

    function addParticipant(
        address wallet,
        uint256 referrerIdIn
    )
        external
        override
        onlyAdmin
        returns (
            uint256 participantId,
            address referrerWallet,
            uint256 referrerId
        )
    {
        require(
            getParticipantId(wallet) == 0,
            "Participant was added previously"
        );
        participantId = _mint(wallet);
        _participantData[wallet].id = participantId;

        // Checking the existence of an referrer record.
        // If doesn't exist then: address(0), 0.
        referrerWallet = rawOwnerOf(referrerIdIn);
        referrerId = _participantData[referrerWallet].id;

        // Save link to referrer.
        _participantData[wallet].referrerWallet = referrerWallet;
        _participantData[wallet].referrerId = referrerId;

        // Add referral.
        _referrals[referrerWallet].push(wallet);

        emit NewParticipant(wallet, participantId, referrerId);
    }

    modifier onlyAdmin() {
        require(isAdmin[_msgSender()], "Caller is not the admin");
        _;
    }

    function setAdmin(address wallet, bool status) external onlyOwner {
        emit AdminChanged(wallet, status);
        isAdmin[wallet] = status;
    }

    function getParticipant(
        address wallet
    )
        external
        view
        override
        returns (
            uint256 participantId,
            address referrerWallet,
            uint256 referrerId,
            uint256 referrals
        )
    {
        return (
            _participantData[wallet].id,
            _participantData[wallet].referrerWallet,
            _participantData[wallet].referrerId,
            _referrals[referrerWallet].length
        );
    }

    function getParticipantId(
        address wallet
    ) public view override returns (uint256 participantId) {
        return _participantData[wallet].id;
    }

    function getParticipantWallet(
        uint256 participantId
    ) external view override returns (address wallet) {
        return rawOwnerOf(participantId);
    }

    function getParticipants(
        uint256 offset,
        uint256 limit
    ) external view returns (uint256 total, address[] memory list) {
        total = totalSupply();
        limit = _getListLimit(total, offset, limit);

        list = new address[](limit);
        for (uint256 i = 0; i < limit; i++) {
            list[i] = _ownerByIndex(offset + i);
        }
        return (total, list);
    }

    function getReferrals(
        address wallet,
        uint256 offset,
        uint256 limit
    ) external view returns (uint256 total, address[] memory list) {
        total = _referrals[wallet].length;
        limit = _getListLimit(total, offset, limit);

        list = new address[](limit);
        for (uint256 i = 0; i < limit; i++) {
            list[i] = _referrals[wallet][offset + i];
        }
        return (total, list);
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

    // ERC721
    function tokenOfOwnerByIndex(
        address owner,
        uint256 index
    ) public view override returns (uint256 tokenId) {
        tokenId = getParticipantId(owner);
        require(
            tokenId == 0 || index > 0,
            "ERC721Enumerable: owner index out of bounds"
        );
    }

    function balanceOf(address owner) public view override returns (uint256) {
        require(
            owner != address(0),
            "ERC721: address zero is not a valid owner"
        );
        if (getParticipantId(owner) == 0) {
            return 0;
        }
        return 1;
    }

    // ERC721 Metadata
    function reveal() external onlyOwner {
        _revealed = true;
    }

    function setNotRevealedURI(string memory uri_) external onlyOwner {
        _notRevealedURI = uri_;
    }

    function contractURI() external view returns (string memory) {
        if (address(nftDescriptor) != address(0)) {
            return nftDescriptor.contractURI();
        }

        return _contractURI;
    }

    function setContractURI(string memory uri_) external onlyOwner {
        _contractURI = uri_;
    }

    function tokenURI(
        uint256 tokenId
    ) external view override returns (string memory) {
        _requireMinted(tokenId);

        if (!_revealed) {
            return _notRevealedURI;
        }

        if (address(nftDescriptor) != address(0)) {
            return nftDescriptor.tokenURI(tokenId);
        }

        return
            bytes(_baseURI).length > 0
                ? string(abi.encodePacked(_baseURI, tokenId.toString(), _ext))
                : "";
    }

    function setBaseURI(string memory uri_) external onlyOwner {
        _baseURI = uri_;
    }

    function setFileExtension(string memory ext_) external onlyOwner {
        _ext = ext_;
    }

    function setNftDescriptor(address nftDescriptor_) external onlyOwner {
        emit NftDescriptorChanged(address(nftDescriptor), nftDescriptor_);
        nftDescriptor = INftDescriptor(nftDescriptor_);
    }

    function setTokenMetadata(
        string memory name_,
        string memory symbol_
    ) external onlyOwner {
        _setTokenMetadata(name_, symbol_);
    }
}
