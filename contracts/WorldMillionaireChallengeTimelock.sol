// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/governance/TimelockController.sol";

contract WorldMillionaireChallengeTimelock is TimelockController {
    uint256 private _minDelay = 259200;
    address[] private _proposers = [0x01B41030c1d98D356827204C0Fdb19fFBaeEb6b3];
    address[] private _executors = [0x01B41030c1d98D356827204C0Fdb19fFBaeEb6b3];

    address private _admin = address(0);

    constructor()
        TimelockController(_minDelay, _proposers, _executors, _admin)
    {}
}
