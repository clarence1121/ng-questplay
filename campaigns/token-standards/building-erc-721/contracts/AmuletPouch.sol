// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IERC721.sol";

/**
 * @dev ERC-721 Token Receiver contract for AmuletPouch.
 */
contract AmuletPouch {
    // Amulet contract address
    IERC721 public immutable amulet;

    // Member list
    mapping(address => bool) private _members;
    address[] private _memberList;

    // Tokens owned by the contract
    mapping(uint256 => bool) private _ownedTokens;
    uint256[] private _tokenIds;

    // Withdrawal request structure
    struct WithdrawRequest {
        address requester;
        uint256 tokenId;
        uint256 votes;
        bool exists;
        mapping(address => bool) hasVoted;
    }

    // All withdrawal requests, using requestId as the key
    mapping(uint256 => WithdrawRequest) private _withdrawRequests;
    uint256 private _currentRequestId;

    // Event definitions
    event WithdrawRequested(address indexed requester, uint256 indexed tokenId, uint256 indexed requestId);

    /**
     * @dev Constructor, sets the Amulet contract address.
     * @param _amuletAddress Amulet contract address.
     */
    constructor(address _amuletAddress) {
        require(_amuletAddress != address(0), "AmuletPouch: invalid Amulet address");
        amulet = IERC721(_amuletAddress);
        _currentRequestId = 0;
    }

    /**
     * @dev Returns whether the user is a member.
     * @param _user The address to check.
     */
    function isMember(address _user) external view returns (bool) {
        return _members[_user];
    }

    /**
     * @dev Returns the total number of members.
     */
    function totalMembers() external view returns (uint256) {
        return _memberList.length;
    }

    /**
     * @dev Returns the request information for a given requestId.
     * @param _requestId The ID of the withdrawal request.
     */
    function withdrawRequest(uint256 _requestId) external view returns (address, uint256) {
        require(_withdrawRequests[_requestId].exists, "AmuletPouch: request does not exist");
        WithdrawRequest storage temp = _withdrawRequests[_requestId];
        return (temp.requester, temp.tokenId);
    }

    /**
     * @dev Returns the number of votes for a given requestId.
     * @param _requestId The ID of the withdrawal request.
     */
    function numVotes(uint256 _requestId) external view returns (uint256) {
        require(_withdrawRequests[_requestId].exists, "AmuletPouch: request does not exist");
        return _withdrawRequests[_requestId].votes;
    }

    /**
     * @dev Members vote for a specified withdrawal request.
     * @param _requestId The ID of the withdrawal request.
     */
    function voteFor(uint256 _requestId) external {
        require(_members[msg.sender], "AmuletPouch: caller is not a member");
        WithdrawRequest storage request = _withdrawRequests[_requestId];
        require(request.exists, "AmuletPouch: request does not exist");
        require(!request.hasVoted[msg.sender], "AmuletPouch: already voted for this request");

        // Mark as voted
        request.hasVoted[msg.sender] = true;
        request.votes += 1;
    }

    /**
     * @dev Allows the requester to withdraw their token after approval.
     * @param _requestId The ID of the withdrawal request.
     */
    function withdraw(uint256 _requestId) external {
        WithdrawRequest storage request = _withdrawRequests[_requestId];
        require(request.exists, "AmuletPouch: request does not exist");
        require(msg.sender == request.requester, "AmuletPouch: caller is not the requester");

        uint256 totalmembers = _memberList.length;
        uint256 majority = (totalmembers / 2) + 1;
        require(request.votes >= majority, "AmuletPouch: not enough votes");

        // Store tokenId before modifying the request
        uint256 tokenId = request.tokenId;
        address requester = request.requester;

        // Mark the request as processed
        request.exists = false;

        // Remove token from owned tokens
        delete _ownedTokens[tokenId];

        // Remove tokenId from _tokenIds array
        // for (uint256 i = 0; i < _tokenIds.length; i++) {
        //     if (_tokenIds[i] == tokenId) {
        //         _tokenIds[i] = _tokenIds[_tokenIds.length - 1];
        //         _tokenIds.pop();
        //         break;
        //     }
        // }

        // Transfer the token to the requester
        amulet.transferFrom(address(this), requester, tokenId);
    }

    /**
     * @dev Handles the receipt of an NFT.
     */
    function onERC721Received(
        address /* _operator */,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) external returns (bytes4) {
        require(msg.sender == address(amulet), "AmuletPouch: only Amulet tokens are accepted");
        require(_from != address(0), "AmuletPouch: invalid member address");

        if (!_members[_from]) {
            // New member, add to member list
            _members[_from] = true;
            _memberList.push(_from);
        }

        // Record that the contract owns the token
        _ownedTokens[_tokenId] = true;
       // _tokenIds.push(_tokenId);

        // If data is provided, create a withdrawal request
        if (_data.length > 0) {
            require(_data.length == 32, "AmuletPouch: invalid data length");

            // Use abi.decode to parse `_data` to get `requestedTokenId`
            uint256 requestedTokenId = abi.decode(_data, (uint256));

            // Ensure the requested token exists in the contract
            require(_ownedTokens[requestedTokenId], "AmuletPouch: requested token does not exist in pouch");

            // Create a new withdrawal request
            uint256 requestId = _currentRequestId;
            WithdrawRequest storage newRequest = _withdrawRequests[requestId];
            newRequest.requester = _from;
            newRequest.tokenId = requestedTokenId;
            newRequest.votes = 1; // Requester implicitly votes for themselves
            newRequest.exists = true;
            newRequest.hasVoted[_from] = true;

            emit WithdrawRequested(_from, requestedTokenId, requestId);

            _currentRequestId += 1;
        }
        //return this.onERC721Received.selector;
        return  bytes4(keccak256(abi.encodePacked("onERC721Received(address,address,uint256,bytes)")));
    }

    /**
     * @dev Returns the current number of withdrawal requests.
     */
    function getCurrentRequestId() external view returns (uint256) {
        return _currentRequestId;
        
    }

    /**
     * @dev Returns all member addresses (for testing or frontend display).
     */
    function getAllMembers() external view returns (address[] memory) {
        return _memberList;
    }
}
