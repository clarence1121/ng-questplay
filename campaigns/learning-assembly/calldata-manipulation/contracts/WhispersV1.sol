// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract WhispersV1 {

    /// @notice Read and return the uint256 appended behind the expected calldata.
    /// 這題要我們返回參數的部分 也就是跳過前面四個byte(0x00 to 0x03)的函數選擇器 
    function whisperUint256() external pure returns (uint256 value) {
        assembly {
        value := calldataload(0x04)//從0x04開始讀
}
    }

    /// @notice Read and return the string appended behind the expected calldata.
    /// @dev The string is abi-encoded.
    function whisperString() external pure returns (string memory str) {
        // string在calldata裡面 先是selector 接著是32 byte的offset然後才是length
        assembly {
            // Allocate some free memory
            str := mload(0x40)

            // Read length of string data 
            let dataLength := calldataload(0x24)

            // Calculate length of data + length header
            let totalLength := add(dataLength, 0x20)

            // Copy length and string data into memory
            //(你要存入的目標位置,calldata中資料的起始位置,要複製多少byte資料)
            calldatacopy(str, 0x24, totalLength)

            // Update free memory pointer
            let allocated := add(str, totalLength)
            mstore(0x40, allocated)
        }
    }
}
