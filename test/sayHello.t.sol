// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {SayHello} from "../src/SayHello.sol";

contract SayHelloTest is Test {
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");

    SayHello public sayHello;

    event NewMessage(
        address indexed from,
        uint256 indexed timestamp,
        string message
    );

    function setUp() public {
        sayHello = new SayHello();

        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);
    }

    function test_SendMessage() public {
        string memory message = "Hello, World!";

        vm.expectEmit(true, true, false, true);
        emit NewMessage(address(this), block.timestamp, message);

        sayHello.sendMessage(message);

        assertEq(sayHello.messageCount(), 1);

        SayHello.Message[] memory messages = sayHello.getLatestMessages(1);
        assertEq(messages[0].user, address(this));
        assertEq(messages[0].message, message);
    }

    function testFail_MessageTooLong() public {
        string memory longMessage = new string(300);
        sayHello.sendMessage(longMessage);
    }

    function testFail_EmptyMessage() public {
        sayHello.sendMessage("");
    }

    function test_GetLatestMessages() public {
        vm.startPrank(user1);
        sayHello.sendMessage("Message from user1");
        vm.stopPrank();

        vm.startPrank(user2);
        sayHello.sendMessage("Message from user2");
        vm.stopPrank();

        SayHello.Message[] memory messages = sayHello.getLatestMessages(1);
        assertEq(messages[0].user, user2);
        assertEq(messages[0].message, "Message from user2");
    }

    function test_MessageTimestamp() public {
        uint256 testTimestamp = 1000000;
        vm.warp(testTimestamp);

        sayHello.sendMessage("Time test");

        SayHello.Message[] memory messages = sayHello.getLatestMessages(1);
        assertEq(uint256(messages[0].timestamp), testTimestamp);
    }
}
