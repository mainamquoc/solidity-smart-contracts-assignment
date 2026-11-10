// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MultisigWallet {
    address[] public owners;
    uint256 public required;
    struct Transaction { address to; uint256 value; bool executed; }
    Transaction[] public transactions;
    mapping(uint256 => mapping(address => bool)) public confirmed;
    mapping(address => bool) public isOwner;
    mapping(uint256 => uint256) private confirmationCounts;
    event Submission(uint256 indexed txId);
    event Confirmation(address indexed owner, uint256 indexed txId);
    event Execution(uint256 indexed txId);
    event Deposit(address indexed sender, uint256 amount);
    modifier onlyOwner() { require(isOwner[msg.sender], "Not an owner"); _; }
    modifier validTransaction(uint256 txId) { require(txId < transactions.length, "Invalid transaction"); _; }
    constructor(address[] memory _owners, uint256 _required) {
        require(_required > 0 && _required <= _owners.length, "Invalid threshold");
        for (uint256 i; i < _owners.length; i++) {
            require(_owners[i] != address(0) && !isOwner[_owners[i]], "Invalid or duplicate owner");
            isOwner[_owners[i]] = true; owners.push(_owners[i]);
        }
        required = _required;
    }
    receive() external payable { emit Deposit(msg.sender, msg.value); }
    // Submission includes the submitter's first confirmation (matches the PDF example).
    function submitTransaction(address to, uint256 value) external onlyOwner {
        require(to != address(0) && value > 0, "Invalid transfer");
        uint256 txId = transactions.length;
        transactions.push(Transaction(to, value, false)); emit Submission(txId);
        _confirm(txId);
    }
    function confirmTransaction(uint256 txId) external onlyOwner validTransaction(txId) { _confirm(txId); }
    function _confirm(uint256 txId) private {
        require(!transactions[txId].executed, "Already executed");
        require(!confirmed[txId][msg.sender], "Already confirmed");
        confirmed[txId][msg.sender] = true; confirmationCounts[txId]++;
        emit Confirmation(msg.sender, txId);
        // Keep confirmations if not funded yet; explicit execute can retry after a deposit.
        if (confirmationCounts[txId] >= required && address(this).balance >= transactions[txId].value) {
            executeTransaction(txId);
        }
    }
    function executeTransaction(uint256 txId) public onlyOwner validTransaction(txId) {
        Transaction storage txn = transactions[txId];
        require(!txn.executed, "Already executed");
        require(confirmationCounts[txId] >= required, "Not enough confirmations");
        require(address(this).balance >= txn.value, "Insufficient wallet balance");
        txn.executed = true;
        (bool ok,) = payable(txn.to).call{value: txn.value}("");
        require(ok, "ETH transfer failed"); emit Execution(txId);
    }
    function getConfirmations(uint256 txId) external view validTransaction(txId) returns (uint256) {
        return confirmationCounts[txId];
    }
}
