// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenB is ERC20 {
    constructor() ERC20("Token B", "TKNB") {
        _mint(msg.sender, 1_000_000 * 10 ** 18); // Mint 1,000,000 tokens (18 decimals)
    }
}
