// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

contract MessageBoard {
    mapping(address => string) public messages;


    function storeMessage(string calldata message) external {
        messages[msg.sender] = message;
    }

    function previewMessage() external view returns (string memory draftMessage){
        draftMessage = string.concat("Draft [", messages[msg.sender], "]");
    }
}