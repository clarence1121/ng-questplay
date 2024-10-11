// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import './interfaces/ICrates.sol';

contract Crates is ICrates {
    struct Crate {
        uint size;
        uint strength;
        uint index; 
    }

    mapping(uint => Crate) private crates;
    uint[] private crateIds;

    /// @notice 
    function insertCrate(
        uint id,
        uint size,
        uint strength
    ) external {
        require(!_isCrate(id), "Already existing");

        crates[id] = Crate(size, strength, crateIds.length);
        crateIds.push(id);
    }

    /// @notice 
    function getCrate(uint id) external view returns (uint size, uint strength) {
        require(_isCrate(id), "Crate does not exist");
        Crate storage crate = crates[id];
        return (crate.size, crate.strength);
    }

    /// @notice 
    function getCrateIds() external view returns (uint[] memory) {
        return crateIds;
    }

    /// @notice 
    function deleteCrate(uint id) external {
        require(crateIds[crates[id].index]==id, "Crate does not exist");

        uint index = crates[id].index;
        uint lastIndex = crateIds.length - 1;
        uint lastId = crateIds[lastIndex];

        
        crateIds[index] = lastId;
        crates[lastId].index = index;

        
        crateIds.pop();

       
        //delete crates[id];
        //不刪除的話下一次有人試圖使用這個id 理論上他會在array檢查那邊被擋下來
    }

    /// @notice 
    function _isCrate(uint id) private view returns (bool) {
        uint index = crates[id].index;
        //如果不存在id index = 0
        //

        if (index >= crateIds.length) {
            return false;
        }

        return crateIds[index] == id;
    }
}
