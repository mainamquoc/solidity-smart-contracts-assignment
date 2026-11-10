// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Escrow {
    enum State { AwaitingPayment, AwaitingDelivery, Complete, Refunded, Disputed }
    address payable public buyer;
    address payable public seller;
    address payable public arbiter;
    State public state;
    event StateChanged(State newState);
    event Paid(address indexed to, uint256 amount);
    modifier onlyBuyer() { require(msg.sender == buyer, "Not buyer"); _; }
    modifier onlyArbiter() { require(msg.sender == arbiter, "Not arbiter"); _; }
    modifier onlyArbiterOrSeller() {
        require(msg.sender == arbiter || msg.sender == seller, "Not arbiter or seller"); _;
    }
    modifier onlyBuyerOrSeller() {
        require(msg.sender == buyer || msg.sender == seller, "Not buyer or seller"); _;
    }
    modifier stateCheck(State expected) { require(state == expected, "Wrong state"); _; }
    constructor(address payable _seller, address payable _arbiter) payable {
        require(msg.value > 0, "Payment required");
        require(_seller != address(0) && _arbiter != address(0), "Zero party");
        require(_seller != msg.sender && _arbiter != msg.sender && _seller != _arbiter, "Distinct parties required");
        buyer = payable(msg.sender); seller = _seller; arbiter = _arbiter;
        state = State.AwaitingDelivery; emit StateChanged(state);
    }
    function confirmDelivery() external onlyBuyer stateCheck(State.AwaitingDelivery) {
        _settle(seller, State.Complete);
    }
    function refundBuyer() external onlyArbiterOrSeller stateCheck(State.AwaitingDelivery) {
        _settle(buyer, State.Refunded);
    }
    function raiseDispute() external onlyBuyerOrSeller stateCheck(State.AwaitingDelivery) {
        state = State.Disputed; emit StateChanged(state);
    }
    function resolveToSeller() external onlyArbiter stateCheck(State.Disputed) {
        _settle(seller, State.Complete);
    }
    function resolveToBuyer() external onlyArbiter stateCheck(State.Disputed) {
        _settle(buyer, State.Refunded);
    }
    function _settle(address payable to, State nextState) private {
        uint256 amount = address(this).balance;
        state = nextState;
        (bool ok,) = to.call{value: amount}("");
        require(ok, "ETH transfer failed"); emit StateChanged(state); emit Paid(to, amount);
    }
}
