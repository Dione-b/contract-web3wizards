// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

//  __    __     _    _______    __ _                  _
// / / /\ \ \___| |__|___ / / /\ \ (_)______ _ _ __ __| |___
// \ \/  \/ / _ \ '_ \ |_ \ \/  \/ / |_  / _` | '__/ _` / __|
//  \  /\  /  __/ |_) |__) \  /\  /| |/ / (_| | | | (_| \__ \
//   \/  \/ \___|_.__/____/ \/  \/ |_/___\__,_|_|  \__,_|___/

contract SayHello {
    // Events
    event NewMessage(
        address indexed from,
        uint256 indexed timestamp,
        string message
    );

    uint128 private constant MAX_MESSAGE_LENGTH = 280;
    uint128 public messageCount;

    struct Message {
        address user;
        uint40 timestamp;
        string message;
    }

    mapping(uint128 => Message) public messages;

    error MessageTooLong();
    error EmptyMessage();

    /**
     * @dev Sends a new message
     * @param _message The message to be stored
     */
    function sendMessage(string calldata _message) external {
        if (bytes(_message).length == 0) revert EmptyMessage();
        if (bytes(_message).length > MAX_MESSAGE_LENGTH)
            revert MessageTooLong();

        messages[messageCount] = Message({
            user: msg.sender,
            timestamp: uint40(block.timestamp),
            message: _message
        });

        emit NewMessage(msg.sender, block.timestamp, _message);
        unchecked {
            ++messageCount;
        } // Gas optimization for counter increment
    }

    /**
     * @dev Gets the latest messages
     * @param count Number of latest messages to retrieve
     * @return Message[] Array of latest messages
     */
    function getLatestMessages(
        uint128 count
    ) external view returns (Message[] memory) {
        if (count > messageCount) {
            count = messageCount;
        }

        Message[] memory result = new Message[](count);

        for (uint128 i = 0; i < count; ) {
            result[i] = messages[messageCount - i - 1];
            unchecked {
                ++i;
            } // Gas optimization for loop increment
        }

        return result;
    }
}
