// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SimpleProposer} from "../src/SimpleProposer.sol";

contract SimpleProposerTest is Test {
    SimpleProposer public sp;

    function setUp() public {
        sp = new SimpleProposer();
    }
}
