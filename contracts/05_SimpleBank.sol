// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleBank {
    mapping(address => uint256) private balances;
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    function deposit() public payable {
        require(msg.value > 0, "Zero deposit");
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }
    function withdraw(uint256 amount) public {
        require(amount > 0 && amount <= balances[msg.sender], "Insufficient balance");
        // Effects precede interaction: a callback cannot spend the same balance twice.
        balances[msg.sender] -= amount;
        (bool ok,) = payable(msg.sender).call{value: amount}("");
        require(ok, "ETH transfer failed");
        emit Withdrawn(msg.sender, amount);
    }
    function myBalance() public view returns (uint256) { return balances[msg.sender]; }
    function bankTotal() public view returns (uint256) { return address(this).balance; }
}
