// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Counter {
    uint256 public count;
    uint256 public constant MAX = 100;
    event Incremented(address who, uint256 newCount);
    event Decremented(address who, uint256 newCount);
    event Reset(address who);

    function increment() public {
        require(count < MAX, "Max limit reached");
        emit Incremented(msg.sender, ++count);
    }
    function decrement() public {
        require(count > 0, "Count is zero");
        emit Decremented(msg.sender, --count);
    }
    function reset() public { count = 0; emit Reset(msg.sender); }
}
