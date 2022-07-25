// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

contract Queue {
    mapping(uint256 => uint256) public store;
    uint256 public lastFirst;

    uint256 private constant LAST_MASK = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000000000000;
    uint256 private constant FIRST_MASK = 0x00000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    uint256 private constant LAST_ADD_ONE = 0x0000000000000000000000000000000100000000000000000000000000000000;
    uint256 private constant FIRST_ADD_ONE = 0x0000000000000000000000000000000000000000000000000000000000000001;

    function enqueue(uint256 _data) external {
        uint256 max256 = type(uint256).max;
        uint256 max128 = type(uint128).max;

        assembly {
            let lastFirstSlot := lastFirst.slot

            let storedData := sload(lastFirstSlot)
            let addOneInLast := add(storedData, LAST_ADD_ONE)

            //overflow check
            if eq(addOneInLast, 0) {
                revert(0, 0)
            }
            let last := shr(0x80, addOneInLast)

            if gt(last, max128) {
                revert(0, 0)
            }

            let removedBits := and(storedData, xor(max256, LAST_MASK))

            let updateLastBits := or(removedBits, addOneInLast)
            sstore(lastFirstSlot, updateLastBits)

            let ptr := mload(0x40)

            mstore(ptr, last)
            mstore(add(ptr, 0x20), store.slot)

            let calcNewSlot := keccak256(ptr, 0x40)
            sstore(calcNewSlot, _data)
        }
    }

    function dequeue() external returns (uint256 data) {
        uint256 max256 = type(uint256).max;

        assembly {
            let lastFirstSlot := lastFirst.slot

            let storedData := sload(lastFirstSlot)
            if eq(storedData, 0x0) {
                revert(0, 0)
            }
            let addOneInFirst := add(storedData, FIRST_ADD_ONE)

            let last := shr(0x80, addOneInFirst)
            let first := and(FIRST_MASK, addOneInFirst)

            if eq(last, first) {
                sstore(lastFirstSlot, 0x0)
            }
            if gt(last, first) {
                let removedBits := and(storedData, xor(max256, FIRST_MASK))
                let updateFirstBits := or(removedBits, addOneInFirst)
                sstore(lastFirstSlot, updateFirstBits)
            }

            let ptr := mload(0x40)

            mstore(ptr, first)
            mstore(add(ptr, 0x20), store.slot)

            let calcNewSlot := keccak256(ptr, 0x40)
            data := sload(calcNewSlot)
            sstore(calcNewSlot, 0)
        }
    }
}
