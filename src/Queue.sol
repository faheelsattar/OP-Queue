// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

contract Queue {
    mapping(uint256 => uint256) public store;
    uint256 public lastFirst;
    
    uint256 private constant MASK = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    uint256 private constant LAST_MASK = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000000000000;
    uint256 private constant LAST_ADD_ONE = 0x0000000000000000000000000000000100000000000000000000000000000000;

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

    function getStore(uint256 _key) external view returns (uint256) {
        return store[_key];
    }
}
