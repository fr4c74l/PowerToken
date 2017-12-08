pragma solidity ^0.4.15;

import './powerGrid.sol';

contract PowerToken {
  event Consumed(uint64 amount, uint code);

  address owner;
  uint64 expirationDate;
  mapping(address => uint64) balances;

  function PowerToken(uint64 date) {
    owner = msg.sender;
    expirationDate = date;
  }

  modifier verifyExpirationDate(uint64 date) {
    //TODO: convert uint timestamp to uint64
    assert(block.timestamp < date);
    _;
  }

  function create(uint64 amount, address destination) public {
    require(msg.sender == owner);
    balances[destination] += amount;
  }

  function transfer(address to, uint64 amount) public
    verifyExpirationDate(expirationDate)
  {
    require(balances[msg.sender] >= amount);
    require(balances[to] + amount > balances[to]);
    balances[msg.sender] -= amount;
    balances[to] += amount;
  }

  function consume(uint64 amount, uint code) public
    verifyExpirationDate(expirationDate)
  {
    require(balances[msg.sender] >= amount);
    balances[msg.sender] -= amount;
    Consumed(amount, code);
  }

  function destroy() {
    require(msg.sender == owner);
    address addr = PowerGrid(owner).owner();
    selfdestruct(addr);
  }
}