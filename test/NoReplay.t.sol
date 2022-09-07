// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import "forge-std/Test.sol";

import {NoReplay} from "src/NoReplay.sol";

contract NoReplayTest is Test {

    NoReplay noReplay;

    function setUp() external {
        noReplay = new NoReplay();
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

        assumptions(sender);
        assumptions(recipient);

        // Hoax as some address
        vm.deal(sender, amount);
        vm.startPrank(sender);

        // Set some difficulty under 2^64
        vm.difficulty(difficulty);       

        // Send ETH on PoW
        noReplay.sendEtherOnPoW{value: amount}(recipient);

        // Make sure all ETH is forwarded
        if(address(recipient).balance != amount){
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

        assumptions(sender);
        assumptions(recipient);

        // Hoax as some address
        vm.deal(sender, amount);
        vm.startPrank(sender);

        // Set some difficulty over 2^64
        vm.difficulty(2**64+1);       

        // Send ETH on PoW
        noReplay.sendEtherOnPoS{value: amount}(recipient);

        // Make sure all ETH is forwarded
        if(address(recipient).balance != amount){
            console2.log(address(recipient).balance);
            revert("The recipient didn't get forwarded the ETH!");
        }

        // Make sure that it reverts
        vm.difficulty(difficulty);
        vm.deal(sender, amount);
        vm.expectRevert(abi.encodeWithSignature("IncorrectNetwork()"));
        noReplay.sendEtherOnPoS{value: amount}(recipient);
    }
       
}
