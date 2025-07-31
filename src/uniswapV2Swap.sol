// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@uniswap/v2-core/contracts/UniswapV2Factory.sol";

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint256) external view returns (address pair);
    function allPairsLength() external view returns (uint256);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract uniswapV2Swap {
    IUniswapV2Factory uniswap_v2_sepolia_factory;
    address uniswap_v2_sepolia_router;
    address constant UNISWAP_V2_SEPOLIA_FACTORY = 0xF62c03E08ada871A0bEb309762E260a7a6a880E6;
    address constant UNISWAP_V2_SEPOLIA_ROUTER = 0xeE567Fe1712Faf6149d80dA1E6934E354124CfE3;

    constructor(){

    }
}
