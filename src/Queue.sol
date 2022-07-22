// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

contract Queue {
    mapping(uint256 => uint256) public store;

    uint256 public lastFirst;
    uint256 private constant MASK = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    uint256 private constant LAST_MASK = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000000000000;
    uint256 private constant LAST_ADD_ONE = 0x0000000000000000000000000000000100000000000000000000000000000000;

    function enqueue() external returns (bytes32) {
        uint256 max = type(uint256).max;
        bytes32 updateLastBits;

        assembly {
            let lastFirstSlot := lastFirst.slot
            let storeSlot := store.slot

            let storedData := sload(lastFirstSlot)
            let addOneInLast := add(storedData, LAST_ADD_ONE)
            let removedBits := and(storedData, xor(max, LAST_MASK))

            updateLastBits := or(removedBits, addOneInLast)

            // let calcStoreSlot := sha3(storeSlot, shr(0x80, storedData))

            sstore(lastFirstSlot, updateLastBits)
        }
        return updateLastBits;
    }
}
