// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IUniswapV2Factory} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Router02} from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract uniswapV2Swap {
    IUniswapV2Factory uniswap_v2_sepolia_factory;
    IUniswapV2Router02 uniswap_v2_sepolia_router;
    address constant UNISWAP_V2_SEPOLIA_FACTORY = 0xF62c03E08ada871A0bEb309762E260a7a6a880E6;
    address constant UNISWAP_V2_SEPOLIA_ROUTER = 0xeE567Fe1712Faf6149d80dA1E6934E354124CfE3;

    event PairCreated(address indexed tokenA, address indexed tokenB);
    event LiquidityAdded(
        address indexed tokenA, address indexed tokenB, uint256 amountA, uint256 amountB, address indexed to
    );

    constructor() {
        uniswap_v2_sepolia_factory = IUniswapV2Factory(UNISWAP_V2_SEPOLIA_FACTORY);
        uniswap_v2_sepolia_router = IUniswapV2Router02(UNISWAP_V2_SEPOLIA_ROUTER);
    }

    // first function to create a pair for TokenA and TokenB
    function createPair(address tokenA, address tokenB) external returns (address) {
        require(tokenA != address(0) && tokenB != address(0), "Invalid token address");
        require(tokenA != tokenB, "Tokens must be different");
        address pair = uniswap_v2_sepolia_factory.createPair(tokenA, tokenB);
        emit PairCreated(tokenA, tokenB);
        return pair;
    }

    // get the token pair address that we created
    function getPairAddress(address tokenA, address tokenB) external view returns (address) {
        require(tokenA != address(0) && tokenB != address(0), "Invalid token address");
        return uniswap_v2_sepolia_factory.getPair(tokenA, tokenB);
    }

    // add liquidity to the pair contract that we created
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountA,
        uint256 amountB,
        address to,
        uint256 deadline
    ) external {
        require(tokenA != address(0) && tokenB != address(0), "Invalid token address");
        require(amountA > 0 && amountB > 0, "Amounts must be greater than zero");
        require(to != address(0), "Invalid recipient address");
        require(deadline > block.timestamp, "Deadline must be in the future");
        address pair = uniswap_v2_sepolia_factory.getPair(tokenA, tokenB);
        require(pair != address(0), "Pair does not exist");
        // Approve the router to spend tokens
        IERC20(tokenA).approve(address(uniswap_v2_sepolia_router), amountA);
        IERC20(tokenB).approve(address(uniswap_v2_sepolia_router), amountB);
        // Add liquidity
        uniswap_v2_sepolia_router.addLiquidity(
            tokenA,
            tokenB,
            amountA,
            amountB,
            0, // Min amount A
            0, // Min amount B
            to,
            deadline
        );

        emit PairCreated(tokenA, tokenB);
    }
}
