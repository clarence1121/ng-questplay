// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IERC721.sol";
import "./interfaces/IAmuletPouch.sol";

/**
 * @dev ERC-721 Token Receiver contract for AmuletPouch.
 */
contract AmuletPouch {
    // Amulet 合約地址
    IERC721 public immutable amulet;

    // 成員列表
    mapping(address => bool) private _members;
    address[] private _memberList;

    // 提現請求結構
    struct WithdrawRequest {
        address requester;
        uint256 tokenId;
        uint256 votes;
        bool exists;
        mapping(address => bool) hasVoted;
    }

    // 所有提現請求，使用 requestId 作為鍵
    mapping(uint256 => WithdrawRequest) private _withdrawRequests;
    uint256 private _currentRequestId;

    // 事件定義
    event WithdrawRequested(address indexed requester, uint256 indexed tokenId, uint256 indexed requestId);

    /**
     * @dev 構造函數，設置 Amulet 合約地址。
     * @param _amuletAddress Amulet 合約地址。
     */
    constructor(address _amuletAddress) {
        require(_amuletAddress != address(0), "AmuletPouch: invalid Amulet address");
        amulet = IERC721(_amuletAddress);
        _currentRequestId = 0;
    }

    /**
     * @dev 返回是否為成員。
     * @param _user 要檢查的地址。
     */
    function isMember(address _user) external view returns (bool) {
        return _members[_user];
    }

    /**
     * @dev 返回總成員數量。
     */
    function totalMembers() external view returns (uint256) {
        return _memberList.length;
    }

    /**
     * @dev 返回指定 requestId 的請求信息。
     * @param _requestId 提現請求的 ID。
     */
    function withdrawRequest(uint256 _requestId) external view returns (address, uint256) {
        require(_withdrawRequests[_requestId].exists, "AmuletPouch: request does not exist");
       WithdrawRequest storage temp =  _withdrawRequests[_requestId];
        return (temp.requester, temp.tokenId);
    }

    /**
     * @dev 返回指定 requestId 的投票數量。
     * @param _requestId 提現請求的 ID。
     */
    function numVotes(uint256 _requestId) external view  returns (uint256) {
        require(_withdrawRequests[_requestId].exists, "AmuletPouch: request does not exist");
        return _withdrawRequests[_requestId].votes;
    }

    /**
     * @dev 成員對指定的提現請求進行投票。
     * @param _requestId 提現請求的 ID。
     */
    function voteFor(uint256 _requestId) external  {
        require(_members[msg.sender], "AmuletPouch: caller is not a member");
        WithdrawRequest storage request = _withdrawRequests[_requestId];
        require(request.exists, "AmuletPouch: request does not exist");
        require(!request.hasVoted[msg.sender], "AmuletPouch: already voted for this request");

        // 註記已投票
        request.hasVoted[msg.sender] = true;
        request.votes += 1;

        // 如果是請求者，默認投票
        // 根據描述，提請者已經隱含投票，所以在創建請求時應該已經投票
        // 此處不需要額外處理

        // 不需要觸發事件
    }

    /**
     * @dev 處理指定的提現請求，將 Amulet 轉移給請求者。
     * @param _requestId 提現請求的 ID。
     */
    function withdraw(uint256 _requestId) external  {
        WithdrawRequest storage request = _withdrawRequests[_requestId];
        require(request.exists, "AmuletPouch: request does not exist");
        require(msg.sender == request.requester, "AmuletPouch: caller is not the requester");

        uint256 majority = (_memberList.length / 2) + 1;
        require(request.votes >= majority, "AmuletPouch: not enough votes");

        // 清除請求
        delete _withdrawRequests[_requestId];

        // 轉移 Amulet 給請求者
        amulet.safeTransferFrom(address(this), msg.sender, request.tokenId);
    }

    /**
     * @dev ERC-721 接受者回調函數，處理接收到的 Amulet。
     * @param _operator 操作員地址。
     * @param _from 發送者地址。
     * @param _tokenId 接收到的 Amulet 的 ID。
     * @param _data 附加的數據，用於提現請求。
     * @return bytes4 返回接受者標識符。
     */
    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) external  returns (bytes4) {
        require(msg.sender == address(amulet), "AmuletPouch: only Amulet tokens are accepted");

        if (!_members[_from]) {
            // 新成員，添加到成員列表
            _members[_from] = true;
            _memberList.push(_from);
        } else {
            if (_data.length > 0) {
                // 提現請求
                require(_data.length == 32, "AmuletPouch: invalid data length");

                uint256 requestedTokenId;
                // 從 _data 中提取 tokenId
                assembly {
                    requestedTokenId := calldataload(132) // _data starts at offset 132
                }

                // 創建新的提現請求
                uint256 requestId = _currentRequestId;
                WithdrawRequest storage newRequest = _withdrawRequests[requestId];
                newRequest.requester = _from;
                newRequest.tokenId = requestedTokenId;
                newRequest.votes = 1; // 提請者隱含投票
                newRequest.exists = true;
                newRequest.hasVoted[_from] = true;

                emit WithdrawRequested(_from, requestedTokenId, requestId);

                _currentRequestId += 1;
            }
        }

        return this.onERC721Received.selector;
    }

    /**
     * @dev 返回當前提現請求的數量。
     */
    function getCurrentRequestId() external view returns (uint256) {
        return _currentRequestId;
    }

    /**
     * @dev 返回所有成員地址（僅用於測試或前端顯示）。
     */
    function getAllMembers() external view returns (address[] memory) {
        return _memberList;
    }
}
