// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { Script } from "forge-std/Script.sol";
import { Queue } from "../src/Queue.sol";

/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting
contract FooScript is Script {
    Queue internal queue;

    function run() public {
        vm.startBroadcast();
        queue = new Queue();
        vm.stopBroadcast();
    }
}