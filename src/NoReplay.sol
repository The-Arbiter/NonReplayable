// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import { ERC20 } from "solmate/tokens/ERC20.sol";
import { ERC721 } from "solmate/tokens/ERC721.sol";
import { ERC1155 } from "solmate/tokens/ERC1155.sol";

/// @title The NoReplay contract uses OPcode 0x44 checks to protect against replay attacks
/// @dev You can deploy your own instance so you don't have to trust an existing deployed one!
/// @author @pcaversaccio (network detector PoC)
/// @author @0xArbiter (contract + ETH)
/// @author @amxx (ERC20, ERC721, ERC1155, optimisations)
contract NoReplay {

  // Custom error returned on one network but not the other
  error IncorrectNetwork();

  // Max PoW difficulty is 2^64
  uint256 constant internal MAX_DIFFICULTY = 2**64;


  /** @dev Returns TRUE for PoS and FALSE for PoW using OPcode 44 values
  /*  We use block.difficulty as it hasn't been deprecated yet and probably won't be for some time
  /*  NOTE: There is a non-zero chance that PREVRANDAO < 2^64. Please see EIP-4399 for details.
  */
  function isEthMainnet() public view returns (bool result){
    return(block.difficulty > MAX_DIFFICULTY);
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

  function sendEtherOnPoW(address recipient) public payable onlyPoW returns (bool status) {
    _sendEther(recipient);
    return true;
  }

  function sendEtherOnPoS(address recipient) public payable onlyPoS returns (bool status) {
    _sendEther(recipient);
    return true;
  }

  /// @dev ERC20 forwarding - forwards the balance

  function sendERC20OnPoW(address token, address recipient, uint256 amount) public payable onlyPoW returns (bool status) {
    _sendERC20(token, recipient, amount);
    return true;
  }

  function sendERC20OnPoS(address token, address recipient, uint256 amount) public payable onlyPoS returns (bool status) {
    _sendERC20(token, recipient, amount);
    return true;
  }

  function sendAllERC20OnPoW(address token, address recipient) public onlyPoW returns (bool status) {
    _sendERC20(token, recipient, ERC20(token).balanceOf(msg.sender));
    return true;
  }

  function sendAllERC20OnPoS(address token, address recipient) public onlyPoS returns (bool status) {
    _sendERC20(token, recipient, ERC20(token).balanceOf(msg.sender));
    return true;
  }

  /// @dev ERC721 forwarding - same concept

  function sendERC721OnPoW(address token, address recipient, uint256 tokenId) public onlyPoW returns (bool status) {
    _sendERC721(token, recipient, tokenId);
    return true;
  }

  function sendERC721OnPoS(address token, address recipient, uint256 tokenId) public onlyPoS returns (bool status) {
    _sendERC721(token, recipient, tokenId);
    return true;
  }

  /// @dev ERC1155 forwarding - same concept

  function sendERC1155OnPoW(address token, address recipient, uint256 tokenId, uint256 amount, bytes calldata data) public onlyPoW returns (bool status) {
    _sendERC1155(token, recipient, tokenId, amount, data);
    return true;
  }

  function sendERC1155OnPoS(address token, address recipient, uint256 tokenId, uint256 amount, bytes calldata data) public onlyPoS returns (bool status) {
    _sendERC1155(token, recipient, tokenId, amount, data);
    return true;
  }

  function sendAllERC1155OnPoW(address token, address recipient, uint256 tokenId, bytes calldata data) public onlyPoW returns (bool status) {
    _sendERC1155(token, recipient, tokenId, ERC1155(token).balanceOf(recipient, tokenId), data);
    return true;
  }

  function sendAllERC1155OnPoS(address token, address recipient, uint256 tokenId, bytes calldata data) public onlyPoS returns (bool status) {
    _sendERC1155(token, recipient, tokenId, ERC1155(token).balanceOf(recipient, tokenId), data);
    return true;
  }

  function sendERC1155BatchOnPoW(address token, address recipient, uint256[] calldata tokenIds, uint256[] calldata amounts, bytes calldata data) public onlyPoW returns (bool status) {
    _sendERC1155Batch(token, recipient, tokenIds, amounts, data);
    return true;
  }

  function sendERC1155BatchOnPoS(address token, address recipient, uint256[] calldata tokenIds, uint256[] calldata amounts, bytes calldata data) public onlyPoS returns (bool status) {
    _sendERC1155Batch(token, recipient, tokenIds, amounts, data);
    return true;
  }

  function sendAllERC1155BatchOnPoW(address token, address recipient, uint256[] calldata tokenIds, bytes calldata data) public onlyPoW returns (bool status) {
    _sendERC1155Batch(token, recipient, tokenIds, ERC1155(token).balanceOfBatch(_arrayFill(msg.sender, tokenIds.length), tokenIds), data);
    return true;
  }

  function sendAllERC1155BatchOnPoS(address token, address recipient, uint256[] calldata tokenIds, bytes calldata data) public onlyPoS returns (bool status) {
    _sendERC1155Batch(token, recipient, tokenIds, ERC1155(token).balanceOfBatch(_arrayFill(msg.sender, tokenIds.length), tokenIds), data);
    return true;
  }

  // Helpers
  function _sendEther(address recipient) private {
    (bool success, ) = payable(recipient).call{ value: msg.value }("");
    require(success);
  }

  function _sendERC20(address token, address recipient, uint256 amount) private {
    ERC20(token).transferFrom(msg.sender, recipient, amount);
  }

  function _sendERC721(address token, address recipient, uint256 tokenId) private {
    ERC721(token).transferFrom(msg.sender, recipient, tokenId);
  }

  function _sendERC1155(address token, address recipient, uint256 tokenId, uint256 amount, bytes memory data) private {
    ERC1155(token).safeTransferFrom(msg.sender, recipient, tokenId, amount, data);
  }

  function _sendERC1155Batch(address token, address recipient, uint256[] memory tokenIds, uint256[] memory amounts, bytes memory data) private {
    ERC1155(token).safeBatchTransferFrom(msg.sender, recipient, tokenIds, amounts, data);
  }

  function _arrayFill(address value, uint256 length) private pure returns (address[] memory result) {
    result = new address[](length);
    for (uint256 i = 0; i < length; ++i) { result[i] = value; }
  }

  constructor(){}
}
