// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {Web3Builder} from "../src/Web3Builder.sol";

contract DeployWeb3Builder is Script {
    function run() external returns (Web3Builder) {
        vm.startBroadcast();

        Web3Builder builder = new Web3Builder();

        vm.stopBroadcast();
        return builder;
    }
}