// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract StakingRewards {
    address payable public owner;
    // Wei rewarded per ONE ETH staked per second; 1000 => 60,000 wei / ETH / minute.
    uint256 public rewardRatePerSecond;
    uint256 public totalStaked;
    uint256 public rewardPool;
    struct Stake { uint256 amount; uint256 startTime; uint256 rewardDebt; }
    mapping(address => Stake) public stakes;
    // Cumulative rate integral preserves historical rates without looping over stakers.
    uint256 public rewardIndex;
    uint256 public lastUpdate;
    mapping(address => uint256) public userIndex;
    bool private entered;
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 principal, uint256 reward);
    event RewardClaimed(address indexed user, uint256 reward);
    event RewardsFunded(uint256 amount);
    event RewardRateChanged(uint256 rate);
    modifier onlyOwner() { require(msg.sender == owner, "Not the owner"); _; }
    modifier nonReentrant() { require(!entered, "Reentrant call"); entered = true; _; entered = false; }
    constructor(uint256 _rate) payable {
        owner = payable(msg.sender); rewardRatePerSecond = _rate;
        rewardPool = msg.value; lastUpdate = block.timestamp;
        emit RewardsFunded(msg.value);
    }
    function _currentIndex() private view returns (uint256) {
        return rewardIndex + rewardRatePerSecond * (block.timestamp - lastUpdate);
    }
    function _checkpoint(address user) private {
        rewardIndex = _currentIndex(); lastUpdate = block.timestamp;
        Stake storage position = stakes[user];
        position.rewardDebt += position.amount * (rewardIndex - userIndex[user]) / 1 ether;
        position.startTime = block.timestamp; userIndex[user] = rewardIndex;
    }
    function stake() external payable nonReentrant {
        require(msg.value > 0, "Zero stake"); _checkpoint(msg.sender);
        stakes[msg.sender].amount += msg.value; totalStaked += msg.value;
        emit Staked(msg.sender, msg.value);
    }
    function pendingReward(address user) public view returns (uint256) {
        Stake storage position = stakes[user];
        return position.rewardDebt + position.amount * (_currentIndex() - userIndex[user]) / 1 ether;
    }
    function unstake() external nonReentrant {
        require(stakes[msg.sender].amount > 0, "No stake"); _checkpoint(msg.sender);
        uint256 principal = stakes[msg.sender].amount;
        uint256 reward = stakes[msg.sender].rewardDebt;
        require(reward <= rewardPool, "Insufficient reward pool");
        totalStaked -= principal; rewardPool -= reward; delete stakes[msg.sender];
        (bool ok,) = payable(msg.sender).call{value: principal + reward}("");
        require(ok, "ETH transfer failed"); emit Unstaked(msg.sender, principal, reward);
    }
    function claimReward() external nonReentrant {
        _checkpoint(msg.sender);
        uint256 reward = stakes[msg.sender].rewardDebt;
        require(reward > 0, "No reward");
        require(reward <= rewardPool, "Insufficient reward pool");
        stakes[msg.sender].rewardDebt = 0; rewardPool -= reward;
        (bool ok,) = payable(msg.sender).call{value: reward}("");
        require(ok, "ETH transfer failed"); emit RewardClaimed(msg.sender, reward);
    }
    function fundRewards() external payable onlyOwner {
        require(msg.value > 0, "Zero funding"); rewardPool += msg.value; emit RewardsFunded(msg.value);
    }
    function setRewardRate(uint256 _newRate) external onlyOwner {
        rewardIndex = _currentIndex(); lastUpdate = block.timestamp;
        rewardRatePerSecond = _newRate; emit RewardRateChanged(_newRate);
    }
}
