// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import "forge-std/Test.sol";

import { ERC20 } from "solmate/tokens/ERC20.sol";
import { ERC721 } from "solmate/tokens/ERC721.sol";
import { ERC1155 } from "solmate/tokens/ERC1155.sol";
import { NoReplay } from "src/NoReplay.sol";
import {ERC20Mock} from "./mocks/ERC20Mock.sol";
import {ERC721Mock} from "./mocks/ERC721Mock.sol";

contract NoReplayTest is Test {

    NoReplay noReplay;
    ERC20Mock mockERC20Token;
    ERC721Mock mockERC721Token;

    function setUp() external {
        noReplay = new NoReplay();
        mockERC20Token = new ERC20Mock();
        mockERC721Token = new ERC721Mock();
    }

    function assumptions(address someAddress) internal{
        // Exclude crap
        vm.assume(someAddress >= address(0x000000000000000000000000000000000000FFff));
        vm.assume(someAddress != address(0x000000000000000000636F6e736F6c652e6c6f67));
        vm.assume(someAddress != address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
        vm.assume(someAddress != address(0xCe71065D4017F316EC606Fe4422e11eB2c47c246));
        vm.assume(someAddress != address(0x4e59b44847b379578588920cA78FbF26c0B4956C));
        // Zero out balance
        if(someAddress.balance != 0){
            vm.deal(someAddress, 0);
        }
    }

    // Test that ETH stuff works for PoW
    function testEtherForwardingPoW(address sender, address recipient, uint256 amount, uint64 difficulty) external {

        vm.assume(sender!=recipient);
        assumptions(sender);
        assumptions(recipient);

        uint256 startingBalance = recipient.balance;

        // Hoax as some address
        vm.deal(sender, amount);
        vm.startPrank(sender);

        // Set some difficulty under 2^64
        vm.difficulty(difficulty);       

        // Send ETH on PoW
        noReplay.sendEtherOnPoW{value: amount}(recipient);

        // Make sure all ETH is forwarded
        if(address(recipient).balance-startingBalance != amount){
            console2.log(address(recipient).balance);
            revert("The recipient didn't get forwarded the ETH!");
        }

        // Make sure that it reverts
        vm.difficulty(2**64 + 1);
        vm.deal(sender, amount);
        vm.expectRevert(abi.encodeWithSignature("IncorrectNetwork()"));
        noReplay.sendEtherOnPoW{value: amount}(recipient);
    }

    // Test that ETH stuff works for PoS
    function testEtherForwardingPoS(address sender, address recipient, uint256 amount, uint64 difficulty) external {

        vm.assume(sender!=recipient);
        assumptions(sender);
        assumptions(recipient);

        uint256 startingBalance = recipient.balance;

        // Hoax as some address
        vm.deal(sender, amount);
        vm.startPrank(sender);

        // Set some difficulty over 2^64
        vm.difficulty(2**64+1);       

        // Send ETH on PoW
        noReplay.sendEtherOnPoS{value: amount}(recipient);

        // Make sure all ETH is forwarded
        if(address(recipient).balance-startingBalance != amount){
            console2.log(address(recipient).balance);
            revert("The recipient didn't get forwarded the ETH!");
        }

        // Make sure that it reverts
        vm.difficulty(difficulty);
        vm.deal(sender, amount);
        vm.expectRevert(abi.encodeWithSignature("IncorrectNetwork()"));
        noReplay.sendEtherOnPoS{value: amount}(recipient);
    }

    // Test that ERC20 stuff works for PoW
    function testERC20ForwardingPoW(address sender, address recipient, uint256 amount, uint64 difficulty) external {

        assumptions(sender);
        assumptions(recipient);
        vm.assume(amount < type(uint256).max/2);
        vm.assume(sender!=recipient);

        uint256 startingBalance = mockERC20Token.getBalance(recipient);

        // Hoax as some address
        vm.startPrank(sender);
        mockERC20Token.mint(sender,amount);
        mockERC20Token.approve(address(noReplay),amount);

        // Set some difficulty under 2^64
        vm.difficulty(difficulty);       

        // Send ETH on PoW
        noReplay.sendERC20OnPoW(address(mockERC20Token),recipient,amount);

        // Make sure all ERC20 is forwarded
        if(mockERC20Token.getBalance(recipient)-startingBalance != amount){
            console2.log(mockERC20Token.getBalance(recipient));
            revert("The recipient didn't get forwarded the ERC20!");
        }

        // Make sure that it reverts
        vm.difficulty(2**64 + 1);
        vm.deal(sender, amount);
        vm.expectRevert(abi.encodeWithSignature("IncorrectNetwork()"));
        noReplay.sendERC20OnPoW(address(mockERC20Token),recipient,amount);
    }

    // Test that ERC20 stuff works for PoS
    function testERC20ForwardingPoS(address sender, address recipient, uint256 amount, uint64 difficulty) external {

        assumptions(sender);
        assumptions(recipient);
        vm.assume(amount < type(uint256).max/2);
        vm.assume(sender!=recipient);

        uint256 startingBalance = mockERC20Token.getBalance(recipient);

        // Hoax as some address
        vm.startPrank(sender);
        mockERC20Token.mint(sender,amount);
        mockERC20Token.approve(address(noReplay),amount);

        // Set some difficulty over 2^64
        vm.difficulty(2**64 + 1);       

        // Send ETH on PoW
        noReplay.sendERC20OnPoS(address(mockERC20Token),recipient,amount);

        /// Make sure all ERC20 is forwarded
        if(mockERC20Token.getBalance(recipient)-startingBalance != amount){
            console2.log(mockERC20Token.getBalance(recipient));
            revert("The recipient didn't get forwarded the ERC20!");
        }

        // Make sure that it reverts
        vm.difficulty(difficulty);
        vm.deal(sender, amount);
        vm.expectRevert(abi.encodeWithSignature("IncorrectNetwork()"));
        noReplay.sendERC20OnPoS(address(mockERC20Token),recipient,amount);
    }
       
}
