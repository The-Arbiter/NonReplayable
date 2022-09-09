// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import { ERC1155 } from "solmate/tokens/ERC1155.sol";

/// @title Mock 1155 Token
contract ERC1155Mock is ERC1155{

  /// @notice The total supply of tokens
  uint256 public totalSupply = 0;

  /// @notice Instantiate Metadata
  constructor() ERC1155(){}

    /// @notice Mint a token to the given address
  function mint(address to, uint256 id) public payable returns(uint256){
    _mint(to, id, 1, "");
    ++totalSupply;
    return totalSupply-1;
  }

  function getBalance(address who, uint256 id) public view returns(uint256){
    uint256 bal = balanceOf[who][id];
    return bal;
  }

  /// @notice Implement an empty uri func
  function uri(uint256 id) public view override returns (string memory) {}

}