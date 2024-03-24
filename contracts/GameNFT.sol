// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract GameNFT is ERC721 {
    uint counter;
    string description;
    // this is a datamap of nft => (field => value);
    string[] keys;
    uint[] values;
    mapping(uint => mapping(string => uint)) datamap;
    constructor(string memory name, string memory abbr, string[] memory passedKeys, uint[] memory passedValues) ERC721(name, abbr) {
        keys = passedKeys;
        values = passedValues;
    }
    function mint(address recipient) public returns (uint256) {
        counter++;
        _mint(recipient, counter);
        for (uint i = 0; i < keys.length; i++) {
            datamap[counter][keys[i]] = values[i];
        }
        return counter;
    }
    function getKeysAndValues(uint nft) external view returns(string[] memory k, uint[] memory v) {
        k = new string[](keys.length);
        v = new uint[](keys.length);
        for (uint i = 0; i < keys.length; i++) {
            k[i] = keys[i];
            v[i] = datamap[nft][keys[i]];
        }
    }
    function updateMetadata(uint nft, string[] calldata k, uint[] calldata v) external {
        for (uint i = 0; i < k.length; i++) {
            datamap[nft][k[i]] = v[i];
        }
    }
}