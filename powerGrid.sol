pragma solidity ^0.4.15;

import './powerToken.sol';

contract PowerGrid {
 address public owner;
 mapping (uint64 => address) tokens;

 function PowerGrid() {
   owner = msg.sender;
 }

 function hasExpired(uint64 date) returns(bool) {
   return block.timestamp > date;
 }

 modifier verifyExpirationDate(uint64 date) {
   //TODO: convert uint timestamp to uint64
   assert(!hasExpired(date));
   _;
 }

 function create(uint64 amount, address destination, uint64 expirationDate) public
   verifyExpirationDate(expirationDate) 
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
  if (hasExpired(date)) {
    PowerToken(tokens[date]).destroy();
    tokens[date] = 0;
  }
 }

}