// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IERC165.sol";
import "./interfaces/IERC721.sol";
import "./interfaces/IERC721Metadata.sol";
import "./interfaces/IERC721TokenReceiver.sol";

/**
 * @dev ERC-721 token contract.
 */
contract Amulet {
    // 合約名稱與符號
    string private _name;
    string private _symbol;

    // Token ID 計數器
    uint256 private _currentTokenId;

    // Token ID 到擁有者地址的映射
    mapping(uint256 => address) private _owners;

    // 擁有者地址到其擁有的 Token 數量的映射
    mapping(address => uint256) private _balances;

    // Token ID 到授權地址的映射
    mapping(uint256 => address) private _tokenApprovals;

    // 擁有者地址到授權地址到授權金額的映射
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Token ID 到其 URI 的映射
    mapping(uint256 => string) private _tokenURIs;

    // 擁有者地址
    address private _owner;

    // ERC-165 支持的接口 ID
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    /**
     * @dev 事件定義
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev 構造函數，設置名稱和符號，並設置合約創建者為擁有者
     */
    constructor() {
        _name = "Amulet";
        _symbol = "AMULET";
        _owner = msg.sender;
        _currentTokenId = 0;
    }

    /**
     * @dev ERC-165 標準支持的實現
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        return
            interfaceId == _INTERFACE_ID_ERC165 ||
            interfaceId == _INTERFACE_ID_ERC721 ||
            interfaceId == _INTERFACE_ID_ERC721_METADATA;
    }

    /**
     * @dev 返回合約名稱
     */
    function name() external view returns (string memory) {
        return _name;
    }

    /**
     * @dev 返回合約符號
     */
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev 返回指定 Token ID 的 URI
     * Reverts if Token ID 無效
     */
    function tokenURI(uint256 tokenId) external view returns (string memory) {
        require(_owners[tokenId]!=address(0), "Amulet: URI query for nonexistent token");
        return _tokenURIs[tokenId];
    }

    /**
     * @dev 返回指定地址擁有的 Token 數量
     */
    function balanceOf(address owner) external view returns (uint256) {
        require(owner != address(0), "Amulet: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev 返回指定 Token ID 的擁有者
     * Reverts if Token ID 無效
     */
    function ownerOf(uint256 tokenId) external view  returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "Amulet: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev 授權指定地址管理指定 Token ID
     */
    function approve(address to, uint256 tokenId) external {
        //先確定你是token id 的owner 或者是owner有授權跟給妳
        require(msg.sender==_owners[tokenId] || _operatorApprovals[msg.sender][to] , "not owner of no approve");
        _approve(to, tokenId);
    }

    /**
     * @dev 返回指定 Token ID 的授權地址
     */
    function getApproved(uint256 tokenId) internal view  returns (address) {
        require(_exists(tokenId), "Amulet: approved query for nonexistent token");
        return _tokenApprovals[tokenId];
    }

    /**
     * @dev 設置或取消授權操作員管理所有者的所有 Token
     */
    function setApprovalForAll(address operator, bool approved) external  {
        require(operator != msg.sender, "Amulet: approve to caller");

        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /**
     * @dev 返回操作員是否被授權管理所有者的所有 Token
     */
    function isApprovedForAll(address owner, address operator) public view  returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev 轉移指定 Token ID 從一個地址到另一個地址
     */
    function transferFrom(address from, address to, uint256 tokenId) external  {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Amulet: transfer caller is not owner nor approved");
        _transfer(from, to, tokenId);
    }

    /**
     * @dev 安全的轉移指定 Token ID，檢查接收者是否支持 ERC721 接口
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev 安全的轉移指定 Token ID，並附加數據
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public  {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Amulet: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev 鑄造一個新的 Amulet，並分配給指定地址
     * 只有合約創建者可以調用
     */
    function mint(address to, string memory uri) external returns (uint256) {
        require(msg.sender == _owner, "Amulet: only owner can mint");
        require(to != address(0), "Amulet: mint to the zero address");

        uint256 tokenId = _currentTokenId;
        _currentTokenId += 1;

        _balances[to] += 1;
        _owners[tokenId] = to;
        _tokenURIs[tokenId] = uri;

        emit Transfer(address(0), to, tokenId);

        return tokenId;
    }

    /**
     * @dev 內部函數，安全地轉移 Token，並檢查接收者是否支持 ERC721 接口
     */
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "Amulet: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev 內部函數，轉移 Token
     */
    function _transfer(address from, address to, uint256 tokenId) internal {
        require(_owners[tokenId] == from, "Amulet: transfer of token that is not own");
        require(to != address(0), "Amulet: transfer to the zero address");

        // 清除之前的授權
        _approve(address(0), tokenId);

        // 更新餘額和擁有者
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev 內部函數，授權指定地址管理 Token
     */
    function _approve(address to, uint256 tokenId) internal {
        _tokenApprovals[tokenId] = to;
        emit Approval(_owners[tokenId], to, tokenId);
    }

    /**
     * @dev 內部函數，檢查是否授權或擁有者
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_exists(tokenId), "Amulet: operator query for nonexistent token");
        address owner = _owners[tokenId];
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev 內部函數，檢查 Token 是否存在
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev 內部函數，檢查接收者是否支持 ERC721 接口
     */
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        internal
        returns (bool)
    {
        if (isContract(to)) {
            try IERC721TokenReceiver(to).onERC721Received(msg.sender, from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721TokenReceiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("Amulet: transfer to non ERC721Receiver implementer");
                } else {
                    // 向上拋出錯誤訊息
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev 內部函數，檢查地址是否為合約
     */
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}

