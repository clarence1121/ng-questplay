// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract FreeMemoryPointer {

    /// @notice Returns the value of the free memory pointer.
    function getFreeMemoryPointer() internal pure returns (uint256 memoryAddress) {
        assembly {
            memoryAddress:=mload(0x40)
        }
    }

    /// @notice Returns the highest memory address accessed so far.
    function getMaxAccessedMemory() internal pure returns (uint256 memoryAddress) {
        assembly {
            memoryAddress:=msize()
        }
    }

    /// @notice Allocates `size` bytes in memory.
    /// @return memoryAddress Address of start of allocated memory.
    function allocateMemory(uint256 size) internal pure returns (uint256 memoryAddress) {
                assembly {
            // Read the free memory pointer
            let fmp := mload(0x40)
            // //如果allocate的範圍超過最大容許 就revert
            // if gt(add(fmp,size),msize()){
            //     revert(0,0)
            // }
            // Increment the free memory pointer by size bytes
            mstore(0x40, add(fmp, size))
            memoryAddress:=fmp
                }
            }

    /// @notice Frees the highest `size` bytes from memory.
    /// @dev Should revert if reserved space will be deallocated.
    function freeMemory(uint256 size) internal pure {
                assembly {

            // Calculate new memory pointer
            let fmp := mload(0x40)
            let new_fmp := sub(fmp, size)//pointer前移

            // Overflow if new memory pointer falls below 0x80 (reserved space)
            //new pointer不可能大於原本的pointer
            if or(lt(new_fmp, 0x80), gt(new_fmp, fmp)) {
                revert(0, 0)
            }

            // Update memory pointer with new value
            mstore(0x40, new_fmp)
        }
    }
}