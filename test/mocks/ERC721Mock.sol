// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import { ERC721 } from "solmate/tokens/ERC721.sol";

/// @title Mock 721 Token
contract ERC721Mock is ERC721{

  /// @notice The total supply of tokens
  uint256 public totalSupply = 0;

  /// @notice Instantiate Metadata
  constructor() ERC721("Mock", "MOCK"){}

  /// @notice Mint a token to the given address
  function safeMint(address to) public payable returns(uint256){
    _safeMint(to, totalSupply);
    ++totalSupply;
    return totalSupply-1;
  }

  /// @notice Burn the given token
  function burn(uint256 id) public payable {
    _burn(id);
    --totalSupply;
  }

  /// @notice Implement an empty uri func
  function tokenURI(uint256 id) public view override returns (string memory) {}

}