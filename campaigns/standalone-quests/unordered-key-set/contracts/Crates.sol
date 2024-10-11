// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import './interfaces/ICrates.sol';

contract Crates is ICrates {
    struct Crate {
        uint size;
        uint strength;
        uint index; // 存储在crateIds数组中的位置
    }

    mapping(uint => Crate) private crates;
    uint[] private crateIds;

    /// @notice 插入一个crate。如果ID已存在，则操作失败。
    function insertCrate(
        uint id,
        uint size,
        uint strength
    ) external {
        require(!_isCrate(id), "Already existing");

        crates[id] = Crate(size, strength, crateIds.length);
        crateIds.push(id);
    }

    /// @notice 根据ID检索crate。如果ID不存在，则操作失败。
    function getCrate(uint id) external view returns (uint size, uint strength) {
        require(_isCrate(id), "Crate does not exist");
        Crate storage crate = crates[id];
        return (crate.size, crate.strength);
    }

    /// @notice 检索所有现有crate的ID。
    function getCrateIds() external view returns (uint[] memory) {
        return crateIds;
    }

    /// @notice 根据ID删除crate。如果ID不存在，则操作失败。
    function deleteCrate(uint id) external {
        require(_isCrate(id), "Crate does not exist");

        uint index = crates[id].index;
        uint lastIndex = crateIds.length - 1;
        uint lastId = crateIds[lastIndex];

        // 将最后一个元素移动到要删除的位置
        crateIds[index] = lastId;
        crates[lastId].index = index;

        // 移除最后一个元素
        crateIds.pop();

        // 删除crate映射中的数据
        //delete crates[id];
    }

    /// @notice 私有函数，检查crate是否存在
    function _isCrate(uint id) private view returns (bool) {
        uint index = crates[id].index;

        if (index >= crateIds.length) {
            return false;
        }

        return crateIds[index] == id;
    }
}
