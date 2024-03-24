// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract GameToken is ERC20 {
    string public description;
    uint public supply;
    constructor(uint _supply, string memory name, string memory abbr, string memory _description, address to) ERC20(name, abbr) {
        _mint(to, _supply);
        description = _description;
        supply = _supply;
    }
}
