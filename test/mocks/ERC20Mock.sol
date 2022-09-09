// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import { ERC20 } from "solmate/tokens/ERC20.sol";

/// @title Mock 20 Token
contract ERC20Mock is ERC20{

  /// @notice Instantiate Metadata
  constructor() ERC20("DogCoin", "DOG",18){}

  // Mint function for testing
  function mint(address to, uint256 amount) public {
    _mint(to , amount);
  }

  function getBalance(address who) public view returns(uint256){
    uint256 bal = balanceOf[who];
    return bal;
  }
 
}