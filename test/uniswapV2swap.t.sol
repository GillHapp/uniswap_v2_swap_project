//SPDX-LICENSE-Identifier: MIT
pragma solidity ^0.8.20;

import {IUniswapV2Factory} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Router02} from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {Test} from "forge-std/Test.sol";
import {TokenA} from "../src/TokenA.sol";
import {TokenB} from "../src/TokenB.sol";
contract UniswapV2SwapTest is Test {
    IUniswapV2Factory uniswap_v2_sepolia_factory;
    IUniswapV2Router02 uniswap_v2_sepolia_router;
    TokenA tokenA;
    TokenB tokenB;

    address constant UNISWAP_V2_SEPOLIA_FACTORY = 0xF62c03E08ada871A0bEb309762E260a7a6a880E6;
    address constant UNISWAP_V2_SEPOLIA_ROUTER = 0xeE567Fe1712Faf6149d80dA1E6934E354124CfE3;

    function setUp() public {
        uniswap_v2_sepolia_factory = IUniswapV2Factory(UNISWAP_V2_SEPOLIA_FACTORY);
        uniswap_v2_sepolia_router = IUniswapV2Router02(UNISWAP_V2_SEPOLIA_ROUTER);
        tokenA = new TokenA();
        tokenB = new TokenB();
    }

    function testCreatePair() public {
        address pairAddress = uniswap_v2_sepolia_factory.getPair(address(tokenA), address(tokenB));
        assertEq(pairAddress, address(0), "Pair should not exist before creation");

        uniswap_v2_sepolia_factory.createPair(address(tokenA), address(tokenB));
        pairAddress = uniswap_v2_sepolia_factory.getPair(address(tokenA), address(tokenB));
        assertNotEq(pairAddress, address(0), "Pair should be created successfully");
    }
}