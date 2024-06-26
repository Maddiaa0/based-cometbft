// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {SimpleProposer} from "../src/SimpleProposer.sol";

contract DeployProposer is Script {
    function setUp() public {}

    function run() public returns (SimpleProposer sp) {
        vm.broadcast();
        sp = new SimpleProposer();
    }
}
