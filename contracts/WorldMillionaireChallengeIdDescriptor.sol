// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "./interfaces/IChallenge.sol";
import "./interfaces/INftDescriptor.sol";

interface IWmcId {
    function ownerOf(uint256 tokenId) external view returns (address);

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
}

contract WorldMillionaireChallengeIdDescriptor is
    Initializable,
    Ownable2StepUpgradeable,
    INftDescriptor
{
    using StringsUpgradeable for uint256;

    IWmcId public wmcId;
    IChallenge public challenge;

    /**
     * 0 - name
     * 1 - description
     * 2 - image
     * 3 - external_link
     */
    mapping(uint256 => string) public contractData;

    /**
     * 0 - name
     * 1 - description
     * 2 - external_url
     */
    mapping(uint256 => string) public tokenData;
    mapping(uint256 => string) public tokenImageData;

    /**
     * 0 - ID
     * 1 - Wins
     * 2 - Won
     * 3 - Referrals
     * 4 - Referral rewards
     * 5 - Referrer ID
     */
    mapping(uint256 => string) public tokenTraitType;

    function initialize() public initializer {
        __Ownable2Step_init();
        wmcId = IWmcId(address(0)); // TODO
        challenge = IChallenge(address(0)); // TODO
    }

    function version() external view returns (uint8) {
        return _getInitializedVersion();
    }

    function setContractData(
        uint256 startAt,
        string[] memory data
    ) public onlyOwner {
        for (uint256 i = 0; i < data.length; i++) {
            contractData[startAt + i] = data[i];
        }
    }

    function setTokenData(
        uint256 startAt,
        string[] memory data
    ) public onlyOwner {
        for (uint256 i = 0; i < data.length; i++) {
            tokenData[startAt + i] = data[i];
        }
    }

    function setTokenImageData(
        uint256 startAt,
        string[] memory data
    ) public onlyOwner {
        for (uint256 i = 0; i < data.length; i++) {
            tokenImageData[startAt + i] = data[i];
        }
    }

    function setTokenTraitType(
        uint256 startAt,
        string[] memory data
    ) public onlyOwner {
        for (uint256 i = 0; i < data.length; i++) {
            tokenTraitType[startAt + i] = data[i];
        }
    }

    function contractURI() external view returns (string memory) {
        string memory metadata = string(
            abi.encodePacked(
                '{"name":"',
                contractData[0],
                '","description":"',
                contractData[1],
                '","image":"',
                contractData[2],
                '","external_link":"',
                contractData[3],
                '","seller_fee_basis_points":0,"fee_recipient":"0x0000000000000000000000000000000000000000"}'
            )
        );

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    _base64(bytes(metadata))
                )
            );
    }

    function tokenURI(
        uint256 tokenId
    ) external view override returns (string memory) {
        // TODO link
        string memory metadata = string(
            abi.encodePacked(
                '{"name":"',
                tokenData[0],
                tokenId.toString(),
                '","description":"',
                tokenData[1],
                '","external_url":"',
                tokenData[2],
                tokenId.toString(),
                '","background_color":"#020202","image":"data:image/svg+xml;base64,',
                _base64(bytes(drawSVG(tokenId))),
                '","attributes":',
                compileAttributes(tokenId),
                "}"
            )
        );

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    _base64(bytes(metadata))
                )
            );
    }

    function drawSVG(uint256 tokenId) public view returns (string memory) {
        address tokenOwner = wmcId.ownerOf(tokenId);
        (, , , , uint256 wins, uint256 won, , , ) = challenge
            .getParticipantData(tokenOwner);

        return
            string(
                abi.encodePacked(
                    '<svg id="millionare-id" width="100%" height="100%" viewBox="0 0 162 258" fill="none" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><style><![CDATA[.B{fill:#fff}.C{font-family:Montserrat, Arial, sans-serif}.D{font-weight:500}.E{font-size:12px}.F{fill-opacity:.06}.G{fill-opacity:.4}.H{dominant-baseline:middle}.I{text-anchor:middle}]]></style><defs><pattern id="A" patternContentUnits="objectBoundingBox" width="1" height="1"><image width="480" height="270" transform="matrix(.004618 0 0 .003704 -.608225 0)" xlink:href="data:image/jpeg;base64,',
                    tokenImageData[0],
                    '"/></pattern><linearGradient id="B" x1="15" y1="-1.368" x2="81.805" y2="81.575" gradientUnits="userSpaceOnUse"><stop stop-color="#1c1c1c"/><stop offset=".515" stop-color="#fff"/><stop offset="1" stop-color="#303030"/></linearGradient></defs><rect x=".5" y=".5" width="161" height="257" rx="11.5" fill="#020202"/><rect x="4" y="4" width="154" height="192" rx="9" fill="url(#A)"/><g class="B F"><rect x="14.5" y="178" width="132" height="20" rx="10"/><rect x="14.5" y="202" width="132" height="20" rx="10"/><rect x="14.5" y="226" width="132" height="20" rx="10"/></g><text x="50%" y="17.5" fill="url(#B)" font-weight="700" font-size="9.15" class="C H I">World Millionare Challenge</text><text x="50%" y="33" font-size="7.35" class="B C D H I">Millionare ID</text><text x="38" y="192" class="B C D E G">ID:</text><text x="57" y="192" class="B C D E">',
                    tokenId.toString(),
                    '</text><text x="21" y="216" class="B C D E G">Won:</text><text x="57" y="216" class="B C D E">$',
                    (won / 10 ** 18).toString(),
                    '</text><text x="23" y="240" class="B C D E G">Wins:</text><text x="57" y="240" class="B C D E">',
                    wins.toString(),
                    "</text></svg>"
                )
            );
    }

    function compileAttributes(
        uint256 tokenId
    ) public view returns (string memory) {
        address tokenOwner = wmcId.ownerOf(tokenId);
        (, , , uint256 referrals) = wmcId.getParticipant(tokenOwner);
        (
            ,
            ,
            uint256 referrerId,
            ,
            uint256 wins,
            uint256 winRewards,
            ,
            uint256 refRewards,

        ) = challenge.getParticipantData(tokenOwner);

        string memory traits = string(
            abi.encodePacked(
                _attributeForTypeAndValue(
                    tokenTraitType[0],
                    tokenId.toString()
                ),
                ",",
                _attributeForTypeAndValue(tokenTraitType[1], wins.toString()),
                ",",
                _attributeForTypeAndValue(
                    tokenTraitType[2],
                    (winRewards / 10 ** 18).toString()
                ),
                ",",
                _attributeForTypeAndValue(
                    tokenTraitType[3],
                    referrals.toString()
                ),
                ",",
                _attributeForTypeAndValue(
                    tokenTraitType[4],
                    (refRewards / 10 ** 18).toString()
                ),
                ",",
                _attributeForTypeAndValue(
                    tokenTraitType[5],
                    referrerId.toString()
                )
            )
        );

        return string(abi.encodePacked("[", traits, "]"));
    }

    function _attributeForTypeAndValue(
        string memory traitType,
        string memory value
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '{"trait_type":"',
                    traitType,
                    '","value":"',
                    value,
                    '"}'
                )
            );
    }

    function _base64(bytes memory data) private pure returns (string memory) {
        if (data.length == 0) return "";

        // load the table into memory
        string
            memory table = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((data.length + 2) / 3);

        // add some extra buffer at the end required for the writing
        string memory result = new string(encodedLen + 32);

        assembly {
            // set the actual output length
            mstore(result, encodedLen)

            // prepare the lookup table
            let tablePtr := add(table, 1)

            // input ptr
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            // result ptr, jump over length
            let resultPtr := add(result, 32)

            // run over the input, 3 bytes at a time
            for {

            } lt(dataPtr, endPtr) {

            } {
                dataPtr := add(dataPtr, 3)

                // read 3 bytes
                let input := mload(dataPtr)

                // write 4 characters
                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(shr(6, input), 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(input, 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
            }

            // padding with '='
            switch mod(mload(data), 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }
        }

        return result;
    }
}
