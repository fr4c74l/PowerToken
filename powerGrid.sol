pragma solidity ^0.4.15;

import './powerToken.sol';

contract PowerGrid {
	address public owner;

	// Maps exparation date (in months since Epoch) to the address
	// of the PowerToken contract. PowerTokens below one PowerGrid
	// are fungible by monthly expiration date.
	// TODO: Handle timezone and Daylight Saving Time.
	mapping (uint64 => address) tokens;

	function PowerGrid() {
		owner = msg.sender;
	}

	function create(
		uint64 amount,
		address destination,
		uint64 expirationDate
	) public
	{
		require(msg.sender == owner);
		address tokenAddr = tokens[expirationDate];
		PowerToken token;
		if (tokenAddr == 0) {
			token = new PowerToken(expirationDate);
			tokens[expirationDate] = address(token);
		} else {
			token = PowerToken(tokenAddr);
		}
		token.create(amount, destination);
	}

	function destroyToken(uint64 date) public {
		PowerToken(tokens[date]).destroy();
		tokens[date] = 0;
	}
}
