// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IUniswapV2Factory} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Router02} from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract uniswapV2Swap {
    IUniswapV2Factory uniswap_v2_sepolia_factory;
    IUniswapV2Router02 uniswap_v2_sepolia_router;
    address constant UNISWAP_V2_SEPOLIA_FACTORY = 0xF62c03E08ada871A0bEb309762E260a7a6a880E6;
    address constant UNISWAP_V2_SEPOLIA_ROUTER = 0xeE567Fe1712Faf6149d80dA1E6934E354124CfE3;

    event PairCreated(address indexed tokenA, address indexed tokenB);

    constructor() {
        uniswap_v2_sepolia_factory = IUniswapV2Factory(UNISWAP_V2_SEPOLIA_FACTORY);
        uniswap_v2_sepolia_router = IUniswapV2Router02(UNISWAP_V2_SEPOLIA_ROUTER);
    }

    // first function to create a pair for TokenA and TokenB
    function createPair(address tokenA, address tokenB) external {
        require(tokenA != address(0) && tokenB != address(0), "Invalid token address");
        require(tokenA != tokenB, "Tokens must be different");
        uniswap_v2_sepolia_factory.createPair(tokenA, tokenB);
        emit PairCreated(tokenA, tokenB);
    }

    // get the token pair address that we created
    function getPairAddress(address tokenA, address tokenB) external view returns (address) {
        require(tokenA != address(0) && tokenB != address(0), "Invalid token address");
        return uniswap_v2_sepolia_factory.getPair(tokenA, tokenB);
    }
}
