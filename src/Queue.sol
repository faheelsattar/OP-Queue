// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;
import { console } from "forge-std/console.sol";

contract Queue {
    mapping(uint256 => uint256) public store;
    uint256 public lastFirst;

    uint256 private constant LAST_MASK = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000000000000;
    uint256 private constant FIRST_MASK = 0x00000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    uint256 private constant LAST_ADD_ONE = 0x0000000000000000000000000000000100000000000000000000000000000000;
    uint256 private constant FIRST_ADD_ONE = 0x0000000000000000000000000000000000000000000000000000000000000001;

    function enqueue(uint256 _data) external returns (bool) {
        uint256 max = type(uint256).max;

        assembly {
            let lastFirstSlot := lastFirst.slot

            let storedData := sload(lastFirstSlot)
            let addOneInLast := add(storedData, LAST_ADD_ONE)
            let removedBits := and(storedData, xor(max, LAST_MASK))

            let updateLastBits := or(removedBits, addOneInLast)
            sstore(lastFirstSlot, updateLastBits)

            let ptr := mload(0x40)

            mstore(ptr, shr(0x80, addOneInLast))
            mstore(add(ptr, 0x20), store.slot)

            let calcNewSlot := keccak256(ptr, 0x40)
            sstore(calcNewSlot, _data)
        }

        return true;
    }

    function dequeue() external returns (uint256 data) {
        uint256 max = type(uint256).max;

        assembly {
            let lastFirstSlot := lastFirst.slot

            let storedData := sload(lastFirstSlot)
            if eq(storedData, 0x0) {
                revert(0, 0)
            }
            let addOneInFirst := add(storedData, FIRST_ADD_ONE)

            let left := shr(0x80, addOneInFirst)
            let right := and(FIRST_MASK, addOneInFirst)

            if eq(left, right) {
                sstore(lastFirstSlot, 0x0)
            }
            if gt(left, right) {
                let removedBits := and(storedData, xor(max, FIRST_MASK))
                let updateFirstBits := or(removedBits, addOneInFirst)
                sstore(lastFirstSlot, updateFirstBits)
            }

            let ptr := mload(0x40)

            mstore(ptr, right)
            mstore(add(ptr, 0x20), store.slot)

            let calcNewSlot := keccak256(ptr, 0x40)
            data := sload(calcNewSlot)
            sstore(calcNewSlot, 0)
        }

        return data;
    }
}
