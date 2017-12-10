pragma solidity ^0.4.15;

import './powerGrid.sol';

contract DateTimeAPI {
        /*
         *  Abstract contract for interfacing with the DateTime contract.
         *
         */
        function isLeapYear(uint16 year) constant returns (bool);
        function getYear(uint timestamp) constant returns (uint16);
        function getMonth(uint timestamp) constant returns (uint8);
        function getDay(uint timestamp) constant returns (uint8);
        function getHour(uint timestamp) constant returns (uint8);
        function getMinute(uint timestamp) constant returns (uint8);
        function getSecond(uint timestamp) constant returns (uint8);
        function getWeekday(uint timestamp) constant returns (uint8);
        function toTimestamp(uint16 year, uint8 month, uint8 day) constant returns (uint timestamp);
        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour) constant returns (uint timestamp);
        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute) constant returns (uint timestamp);
        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute, uint8 second) constant returns (uint timestamp);
}

contract PowerToken {
	// Datetime library used in this contract:
	address constant DATETIME_LIB = 0x1a6184CD4C5Bea62B0116de7962EE7315B7bcBce;

	// Event registered when this token is consumed.
	event Consumed(uint64 amount, uint code);

	address owner;

	// Last Unix timestamp when this token is valid,
	// stored so it won't have to be calculated twice.
	uint expirationTime;

	mapping(address => uint64) balances;

	function monthToTimestamp(uint64 month) returns(uint)
	{
		// Add 1 so to get the first second of the next month.
		month += 1;

		// Month 0 is January 1970:
		uint16 y = 1970 + uint16(month / 12);
		uint8 m = uint8(month % 12);

		// Subtract one second, to get the last second of the valid month.
		return DateTimeAPI(DATETIME_LIB).toTimestamp(y, m, 1) - 1;
	}

	function PowerToken(uint64 expirationMonth) {
		expirationTime = monthToTimestamp(expirationMonth);

		// TODO: Design choice: check expiration from here, too?

		owner = msg.sender;
	}

	modifier checkExpired() {
		require(block.timestamp <= expirationTime);
		_;
	}

	function create(uint64 amount, address destination) public
		checkExpired()
	{
		require(msg.sender == owner);
		balances[destination] += amount;
	}

	function transfer(address to, uint64 amount) public
		checkExpired()
	{
		require(balances[msg.sender] >= amount);
		require(balances[to] + amount > balances[to]);
		balances[msg.sender] -= amount;
		balances[to] += amount;
	}

	function consume(uint64 amount, uint code) public
		checkExpired()
	{
		require(balances[msg.sender] >= amount);
		balances[msg.sender] -= amount;
		Consumed(amount, code);
	}

	function destroy() {
		require(block.timestamp > expirationTime);

		// TODO: design choice: should anyone be able to destroy the contract?
		require(msg.sender == owner);

		address addr = PowerGrid(owner).owner();
		selfdestruct(addr);
	}
}
