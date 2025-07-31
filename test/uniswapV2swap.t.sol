//SPDX-LICENSE-Identifier: MIT
pragma solidity ^0.8.20;

import {IUniswapV2Factory} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Router02} from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {uniswapV2Swap} from "../src/uniswapV2Swap.sol";
import {Test} from "forge-std/Test.sol";
import {TokenA} from "../src/TokenA.sol";
import {TokenB} from "../src/TokenB.sol";
import {console} from "forge-std/console.sol";

contract UniswapV2SwapTest is Test {
    IUniswapV2Factory uniswap_v2_sepolia_factory;
    IUniswapV2Router02 uniswap_v2_sepolia_router;
    uniswapV2Swap uniswapV2SwapInstance;
    TokenA tokenA;
    TokenB tokenB;

    function setUp() public {
        uniswapV2SwapInstance = new uniswapV2Swap();
        tokenA = new TokenA();
        tokenB = new TokenB();
    }

    function testCreatePair() public {
        address pairAddress = uniswapV2SwapInstance.createPair(address(tokenA), address(tokenB));
        // vm.expectRevert();
        assertEq(pairAddress, address(0x142ADC5c1fdAF44Ebb51990FcDD0FeB41BCeb664), "pair address should not be zero");
        console.log("Pair created at address:", pairAddress);
    }

    function testGetPairAddress() public {
        address pairAddress1 = uniswapV2SwapInstance.createPair(address(tokenA), address(tokenB));
        address pairAddress2 = uniswapV2SwapInstance.getPairAddress(address(tokenA), address(tokenB));
        assertEq(pairAddress1, pairAddress2, "pair addresses should match");
        console.log("Pair address retrieved:", pairAddress2);
    }
}
