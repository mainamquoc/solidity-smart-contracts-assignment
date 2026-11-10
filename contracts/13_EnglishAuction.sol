// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract EnglishAuction {
    address payable public seller;
    uint256 public auctionEnd;
    address public highestBidder;
    uint256 public highestBid;
    uint256 public constant MIN_INCREMENT = 5;
    mapping(address => uint256) public pendingReturns;
    bool public ended;
    event NewBid(address indexed bidder, uint256 amount);
    event AuctionEnded(address winner, uint256 amount);
    event PendingWithdrawn(address indexed bidder, uint256 amount);
    constructor(uint256 _biddingSeconds, uint256 _startPrice) {
        require(_biddingSeconds > 0 && _startPrice > 0, "Invalid auction");
        seller = payable(msg.sender); auctionEnd = block.timestamp + _biddingSeconds;
        highestBid = _startPrice;
    }
    function bid() external payable {
        require(!ended && block.timestamp < auctionEnd, "Auction ended");
        require(msg.value >= highestBid * (100 + MIN_INCREMENT) / 100 && msg.value > highestBid, "Bid too low");
        if (highestBidder != address(0)) pendingReturns[highestBidder] += highestBid;
        highestBidder = msg.sender; highestBid = msg.value;
        emit NewBid(msg.sender, msg.value);
    }
    function withdrawPending() external returns (bool) {
        uint256 amount = pendingReturns[msg.sender];
        require(amount > 0, "Nothing to withdraw");
        pendingReturns[msg.sender] = 0;
        (bool ok,) = payable(msg.sender).call{value: amount}("");
        require(ok, "ETH transfer failed"); emit PendingWithdrawn(msg.sender, amount); return true;
    }
    function endAuction() external {
        require(!ended, "Already ended");
        require(block.timestamp >= auctionEnd, "Auction active"); ended = true;
        uint256 amount = highestBidder == address(0) ? 0 : highestBid;
        if (amount > 0) {
            (bool ok,) = seller.call{value: amount}(""); require(ok, "ETH transfer failed");
        }
        emit AuctionEnded(highestBidder, amount);
    }
}
