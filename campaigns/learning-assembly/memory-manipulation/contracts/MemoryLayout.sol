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
        // 獲取當前的內存指針（0x40標誌free memory pointer位置）
        array := mload(0x40)

        // 將size存儲到內存中的array的第一個32位元位置，代表元素數量
        mstore(array, size)

        // 資料從array的第32位元位置開始，因為第一個32位是size
        let dataStart := add(array, 0x20)

        // 使用循環將每個byte都初始化為`value`
        // 為了實現左對齊，我們從32字節的最高位開始存儲數據
        for { let i := 0 } lt(i, size) { i := add(i, 0x1) } {
            // 在每個 32 字節區塊內，我們從高位 (31 - i) 開始放置 value
            mstore8(add(dataStart, i), value)
        }

        // 計算所需的內存大小 (32 bytes for length + actual data size)
        let totalSize := add(0x20, size)

        // 更新free memory pointer位置，確保不會覆蓋到分配的內存
        mstore(0x40, add(array, totalSize))
    }
}





}