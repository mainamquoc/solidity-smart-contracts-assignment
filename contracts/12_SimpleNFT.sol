// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Educational ERC-721-style subset, not a complete ERC-721 implementation.
contract SimpleNFT {
    string public name;
    string public symbol;
    address public owner;
    uint256 public nextTokenId;
    uint256 public constant MAX_SUPPLY = 100;
    uint256 public mintPrice = 0.01 ether;
    mapping(uint256 => address) public ownerOf;
    mapping(address => uint256) public balances;
    mapping(uint256 => address) public approvals;
    bool private entered;
    event Minted(address indexed to, uint256 indexed tokenId);
    event TransferNFT(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed spender, uint256 indexed tokenId);
    event PaymentsWithdrawn(uint256 amount);
    modifier onlyOwner() { require(msg.sender == owner, "Not the owner"); _; }
    constructor(string memory _name, string memory _symbol) {
        owner = msg.sender; name = _name; symbol = _symbol;
    }
    function mint() external payable returns (uint256 tokenId) {
        require(msg.value == mintPrice, "Wrong mint price");
        require(nextTokenId < MAX_SUPPLY, "Sold out");
        tokenId = nextTokenId++;
        ownerOf[tokenId] = msg.sender; balances[msg.sender]++;
        emit Minted(msg.sender, tokenId); emit TransferNFT(address(0), msg.sender, tokenId);
    }
    function transferNFT(address to, uint256 tokenId) external {
        require(ownerOf[tokenId] == msg.sender, "Not token owner");
        _transfer(msg.sender, to, tokenId);
    }
    function approve(address spender, uint256 tokenId) external {
        require(ownerOf[tokenId] == msg.sender, "Not token owner");
        approvals[tokenId] = spender; emit Approval(msg.sender, spender, tokenId);
    }
    function transferFrom(address from, address to, uint256 tokenId) external {
        require(approvals[tokenId] == msg.sender, "Not approved spender");
        require(from != address(0) && ownerOf[tokenId] == from, "Wrong token owner");
        _transfer(from, to, tokenId);
    }
    function _transfer(address from, address to, uint256 tokenId) private {
        require(to != address(0), "Zero recipient");
        delete approvals[tokenId];
        ownerOf[tokenId] = to; balances[from]--; balances[to]++;
        emit TransferNFT(from, to, tokenId);
    }
    function withdrawPayments() external onlyOwner {
        require(!entered, "Reentrant call");
        uint256 amount = address(this).balance;
        require(amount > 0, "No payments"); entered = true;
        (bool ok,) = payable(owner).call{value: amount}("");
        require(ok, "ETH transfer failed"); entered = false; emit PaymentsWithdrawn(amount);
    }
}
