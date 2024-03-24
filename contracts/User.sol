// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;


contract User {
    mapping(uint => mapping(address => mapping(string => uint))) data;
    mapping(uint => string[]) keys;
    mapping(address => bool) status;
    function initializeUserData(uint game, string[] calldata userKeys) public {
        keys[game] = new string[](userKeys.length);
        for (uint i = 0; i < userKeys.length; i++) {
            keys[game][i] = userKeys[i];
        }
    }
    function updateUserData(uint game, address user, string[] calldata userKeys, uint[] calldata values) public {
        for (uint i = 0; i < userKeys.length; i++) {
            data[game][user][userKeys[i]] = values[i];
        }
    } 
    function getUserData(uint game, address user) public view returns(string[] memory userKeys, uint[] memory values) {
        userKeys = keys[game];
        values = new uint[](userKeys.length);
        for (uint i = 0; i < userKeys.length; i++) {
            values[i] = data[game][user][userKeys[i]];
        }
    }
}