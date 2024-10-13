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

        // 初始化為`value`
        for { let i := 0 } lt(i, size) { i := add(i, 0x01) } {
            mstore(add(dataStart, i), value)
        }
        let totalSize := add(0x20, size) 

        mstore(0x40, add(array, totalSize))
    }
}
function tt()external pure returns(bytes memory array){
    bytes memory result = createBytesArray(5, 0xAA);
    return result;

}
function tt2() external pure returns (bytes memory array) {
        // 建立長度為 5 的 bytes 陣列
        bytes memory result = new bytes(5);
        // 使用 uint 型別作為索引
        for (uint i = 0; i < 5; i++) {
            result[i] = 0xAA;
        }
        return result;
    }



}