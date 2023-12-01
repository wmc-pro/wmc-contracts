// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/governance/TimelockController.sol";

contract WorldMillionaireChallengeTimelock is TimelockController {
    uint256 private _minDelay = 3 * 24 * 60 * 60;
    // TODO Multisig wallet
    address[] private _proposers = [address(0)];
    address[] private _executors = [address(0)];

    address private _admin = address(0);

    constructor()
        TimelockController(_minDelay, _proposers, _executors, _admin)
    {}
}
