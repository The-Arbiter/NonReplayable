// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import "forge-std/Test.sol";

import { NoReplay } from "src/NoReplay.sol";
import {ERC20Mock} from "./mocks/ERC20Mock.sol";
import {ERC721Mock} from "./mocks/ERC721Mock.sol";
import {ERC1155Mock} from "./mocks/ERC1155Mock.sol";

contract NoReplayTest is Test {

    NoReplay noReplay;
    ERC20Mock mockERC20Token;
    ERC721Mock mockERC721Token;
    ERC1155Mock mockERC1155Token;

    function setUp() external {
        noReplay = new NoReplay();
        mockERC20Token = new ERC20Mock();
        mockERC721Token = new ERC721Mock();
        mockERC1155Token = new ERC1155Mock();
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
        
        noReplay.sendEtherOnPoW{value: amount}(recipient);
        
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
        
        noReplay.sendEtherOnPoS{value: amount}(recipient);
        
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

        noReplay.sendERC20OnPoW(address(mockERC20Token),recipient,amount);
        
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

        noReplay.sendERC20OnPoS(address(mockERC20Token),recipient,amount);

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


    // Test that ERC721 stuff works for PoW
    function testERC721ForwardingPoW(address sender, address recipient, uint256 amount, uint64 difficulty) external {

        assumptions(sender);
        assumptions(recipient);
        vm.assume(sender!=recipient);

        uint256 startingBalance = mockERC721Token.balanceOf(recipient);

        // Hoax as some address
        vm.startPrank(sender);
        uint256 tokenId = mockERC721Token.safeMint(sender);
        mockERC721Token.approve(address(noReplay),tokenId);

        // Set some difficulty under 2^64
        vm.difficulty(difficulty);       
        
        noReplay.sendERC721OnPoW(address(mockERC721Token), recipient, tokenId);

        if(mockERC721Token.balanceOf(recipient)-startingBalance != 1){
            console2.log(mockERC721Token.balanceOf(recipient));
            revert("The recipient didn't get forwarded the ERC721!");
        }

        // Make sure that it reverts
        vm.difficulty(2**64 + 1);
        vm.deal(sender, amount);
        vm.expectRevert(abi.encodeWithSignature("IncorrectNetwork()"));
        noReplay.sendERC721OnPoW(address(mockERC721Token), recipient, tokenId);
    }


    // Test that ERC1155 stuff works for PoW
    function testERC1155ForwardingPoW(address sender, address recipient, uint256 amount, uint64 difficulty) external {

        assumptions(sender);
        assumptions(recipient);
        vm.assume(sender!=recipient);

        uint256 startingBalance = mockERC1155Token.balanceOf(recipient,1);

        // Hoax as some address
        vm.startPrank(sender);
        mockERC1155Token.mint(sender,1);
        mockERC1155Token.setApprovalForAll(address(noReplay),true);

        // Set some difficulty under 2^64
        vm.difficulty(difficulty);       
        
        noReplay.sendERC1155OnPoW(address(mockERC1155Token), recipient, 1,1, "");
        
        if(mockERC1155Token.balanceOf(recipient,1)-startingBalance != 1){
            revert("The recipient didn't get forwarded the ERC1155!");
        }

        // Make sure that it reverts
        vm.difficulty(2**64 + 1);
        vm.deal(sender, amount);
        vm.expectRevert(abi.encodeWithSignature("IncorrectNetwork()"));
        noReplay.sendERC1155OnPoW(address(mockERC1155Token), recipient, 1,1, "");
    }


    // Test that ERC1155 stuff works for PoS
    function testERC1155ForwardingPoS(address sender, address recipient, uint256 amount, uint64 difficulty) external {

        assumptions(sender);
        assumptions(recipient);
        vm.assume(sender!=recipient);

        uint256 startingBalance = mockERC1155Token.balanceOf(recipient,1);

        // Hoax as some address
        vm.startPrank(sender);
        mockERC1155Token.mint(sender,1);
        mockERC1155Token.setApprovalForAll(address(noReplay),true);

        // Set some difficulty over 2^64
        vm.difficulty(2**64+1);       

        noReplay.sendERC1155OnPoS(address(mockERC1155Token), recipient, 1,1, "");

        if(mockERC1155Token.balanceOf(recipient,1)-startingBalance != 1){
            revert("The recipient didn't get forwarded the ERC1155!");
        }

        // Make sure that it reverts
        vm.difficulty(difficulty);
        vm.deal(sender, amount);
        vm.expectRevert(abi.encodeWithSignature("IncorrectNetwork()"));
        noReplay.sendERC1155OnPoS(address(mockERC1155Token), recipient, 1,1, "");
    }

    // Make sure that check recipient reverts when the sender is the recipient
    function testCheckRecipient(address sender, uint256 amount, uint64 difficulty) external {

        assumptions(sender);

        // Hoax as some address
        vm.deal(sender, amount);
        vm.startPrank(sender);

        // Set some difficulty under 2^64
        vm.difficulty(difficulty);       
        
        vm.expectRevert(abi.encodeWithSignature("SameRecipient()"));
        noReplay.sendEtherOnPoW{value: amount}(sender);

    }

       
}
