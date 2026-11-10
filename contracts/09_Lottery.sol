// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Lottery {
    address payable[] private players;
    address public manager;
    uint256 public entryFee;
    uint256 public minPlayers;
    bool private entered;
    event Entered(address indexed player);
    event WinnerSelected(address indexed winner, uint256 amount);
    modifier onlyManager() { require(msg.sender == manager, "Not manager"); _; }
    constructor(uint256 _entryFee, uint256 _minPlayers) {
        require(_entryFee > 0 && _minPlayers > 0, "Invalid lottery");
        manager = msg.sender; entryFee = _entryFee; minPlayers = _minPlayers;
    }
    function enter() public payable {
        require(!entered, "Round settling");
        require(msg.sender != manager, "Manager cannot enter");
        require(msg.value == entryFee, "Wrong entry fee");
        players.push(payable(msg.sender)); emit Entered(msg.sender);
    }
    function playersCount() public view returns (uint256) { return players.length; }
    function pickWinner() public onlyManager {
        require(!entered, "Round settling");
        require(players.length >= minPlayers, "Not enough players");
        // Assignment demonstration only: blockhash randomness is manipulable.
        address payable winner = players[uint256(blockhash(block.number - 1)) % players.length];
        uint256 amount = address(this).balance;
        entered = true; delete players;
        (bool ok,) = winner.call{value: amount}("");
        require(ok, "ETH transfer failed");
        entered = false; emit WinnerSelected(winner, amount);
    }
}
