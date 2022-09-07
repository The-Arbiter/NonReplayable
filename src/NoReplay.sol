// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import { ERC20 } from "solmate/tokens/ERC20.sol";

/// @title NoReplay uses OPcode 0x44 checks to protect against replay attacks
contract NoReplay {

  // Custom error returned on one network but not the other
  error IncorrectNetwork();

  // Max PoW difficulty is 2^64
  uint256 constant internal MAX_DIFFICULTY = 18446744073709551616;


  /// @dev Returns TRUE for PoS and FALSE for PoW using OPcode 44 values
  // We use block.difficulty as it hasn't been deprecated yet and probably won't be for some time
  function isEthMainnet() public view returns (bool result){
    // Return true if PREVRANDAO is being used (PoS)
    if(block.difficulty > 18446744073709551616){ 
      return true;
    }
    // Return false if DIFFICULTY is being used (PoW)
    return false;
  }

  // Only succeeds for PoS network
  modifier onlyPoS {
    if(!isEthMainnet()){
      revert IncorrectNetwork();
    }
    _;
  }

  // Only succeeds for PoW network
  modifier onlyPoW {
    if(isEthMainnet()){
      revert IncorrectNetwork();
    }
    _;
  }
  
  /// @dev ETHER transfers - just forwards the balance

  function sendEtherOnPoW(address recipient) public payable onlyPoW returns (bool status){
      payable(recipient).transfer(msg.value);
      return true;
  }

  function sendEtherOnPoS(address recipient) public payable onlyPoS returns (bool status){
      payable(recipient).transfer(msg.value);
      return true;
  }

  /// @dev ERC20 forwarding - forwards the balance

  

  /// @dev ERC721 forwarding - same concept




  constructor(){}
}
