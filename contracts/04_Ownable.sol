// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Ownable {
    address public owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() { owner = msg.sender; emit OwnershipTransferred(address(0), owner); }
    modifier onlyOwner() { require(msg.sender == owner, "Not the owner"); _; }
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Zero owner");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract ProtectedVault is Ownable {
    uint256 private treasure;
    bool private entered;
    event Deposited(address indexed from, uint256 amount);
    event Withdrawn(address indexed to, uint256 amount);
    function deposit() public payable {
        require(msg.value > 0, "Zero deposit");
        treasure += msg.value;
        emit Deposited(msg.sender, msg.value);
    }
    function withdraw(address to, uint256 amt) public onlyOwner {
        require(!entered, "Reentrant call");
        require(to != address(0), "Zero recipient");
        require(amt > 0 && amt <= treasure, "Invalid amount");
        entered = true;
        treasure -= amt;
        (bool ok,) = payable(to).call{value: amt}("");
        require(ok, "ETH transfer failed");
        entered = false;
        emit Withdrawn(to, amt);
    }
    function contractBalance() public view returns (uint256) { return address(this).balance; }
}
