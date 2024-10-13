// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract MemoryLayout {

    /// @notice Create an uint256 memory array.
    /// @param size The size of the array.
    /// @param value The initial value of each element of the array.
    function createUintArray(
        uint256 size, 
        uint256 value
    ) public pure returns (uint256[] memory array) {
        assembly {
            array:=mload(0x40)
            mstore(array,size)//把size存到起始位置
            let offset:=0x20//to decimal = 32  means 32 bytes
            for {let i := 0} lt(i, size) {i := add(i, 0x01)} {
                mstore(add(array, offset), value)
                offset := add(offset, 0x20)
            }
            mstore(0x40 , add(array,offset))
        }
    }

function createBytesArray(
    uint256 size, 
    bytes1 value
) public pure returns (bytes memory array) {
    assembly {
        
        array := mload(0x40)

     
        mstore(array, size)

       
        let dataStart := add(array, 0x20)

       
        for { let i := 0 } lt(i, size) { i := add(i, 1) } {
            mstore8(add(dataStart, i), value)
        }

      
        let totalSize := add(0x20, size) 

        mstore(0x40, add(array, totalSize))
    }
}



}