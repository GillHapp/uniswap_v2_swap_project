// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IUniswapV2Factory} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Router02} from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {uniswapV2Swap} from "../src/uniswapV2Swap.sol";
import {Test} from "forge-std/Test.sol";
import {TokenA} from "../src/TokenA.sol";
import {TokenB} from "../src/TokenB.sol";
import {console} from "forge-std/console.sol";

contract UniswapV2SwapTest is Test {
    uniswapV2Swap uniswapV2SwapInstance;
    TokenA tokenA;
    TokenB tokenB;
    address recipient = address(0x14966573fFB1315B5E12DdD6dfbc675e5017A15a);

    function setUp() public {
        uniswapV2SwapInstance = new uniswapV2Swap();
        tokenA = new TokenA();
        tokenB = new TokenB();
    }

    function testCreatePair() public {
        address pairAddress = uniswapV2SwapInstance.createPair(address(tokenA), address(tokenB));
        assertTrue(pairAddress != address(0), "Pair address should not be zero");
        console.log("Pair created at address:", pairAddress);
    }

    function testGetPairAddress() public {
        address pairAddress1 = uniswapV2SwapInstance.createPair(address(tokenA), address(tokenB));
        address pairAddress2 = uniswapV2SwapInstance.getPairAddress(address(tokenA), address(tokenB));
        assertEq(pairAddress1, pairAddress2, "Pair addresses should match");
        console.log("Pair address retrieved:", pairAddress2);
    }

    function testAddLiquidity() public {
        // Create pair
        address pairAddress = uniswapV2SwapInstance.createPair(address(tokenA), address(tokenB));

        // Transfer tokens to uniswapV2Swap contract
        uint256 amountA = 100 * 10 ** 18; // 100 TokenA
        uint256 amountB = 1000 * 10 ** 18; // 1000 TokenB
        tokenA.transfer(address(uniswapV2SwapInstance), amountA);
        tokenB.transfer(address(uniswapV2SwapInstance), amountB);

        // Add liquidity
        uint256 deadline = block.timestamp + 1 hours;
        (uint256 amountAAdded, uint256 amountBAdded, uint256 liquidity) =
            uniswapV2SwapInstance.addLiquidity(address(tokenA), address(tokenB), amountA, amountB, recipient, deadline);

        // Check balances in the pair contract
        uint256 pairBalanceA = tokenA.balanceOf(pairAddress);
        uint256 pairBalanceB = tokenB.balanceOf(pairAddress);
        assertEq(pairBalanceA, amountAAdded, "TokenA balance in pair should match");
        assertEq(pairBalanceB, amountBAdded, "TokenB balance in pair should match");

        // Check LP tokens for recipient
        IERC20 pairContract = IERC20(pairAddress);
        uint256 lpBalance = pairContract.balanceOf(recipient);
        assertEq(lpBalance, liquidity, "LP token balance should match liquidity");

        console.log("Added liquidity: %s TokenA, %s TokenB", amountAAdded / 10 ** 18, amountBAdded / 10 ** 18);
        console.log("Liquidity tokens received:", liquidity / 10 ** 18);
        console.log("Liquidity added successfully");
    }

    // Test removing liquidity
    function testRemoveLiquidity() public {
        // Create pair and add liquidity
        address pairAddress = uniswapV2SwapInstance.createPair(address(tokenA), address(tokenB));
        uint256 amountA = 100 * 10 ** 18;
        uint256 amountB = 1000 * 10 ** 18;
        tokenA.transfer(address(uniswapV2SwapInstance), amountA);
        tokenB.transfer(address(uniswapV2SwapInstance), amountB);
        uint256 deadline = block.timestamp + 1 hours;
        (,, uint256 liquidity) =
            uniswapV2SwapInstance.addLiquidity(address(tokenA), address(tokenB), amountA, amountB, recipient, deadline);

        // Transfer LP tokens from recipient to uniswapV2Swap
        IERC20 pairContract = IERC20(pairAddress);
        vm.prank(recipient);
        pairContract.transfer(address(uniswapV2SwapInstance), liquidity);
        assertEq(pairContract.balanceOf(recipient), 0, "Recipient LP balance should be zero");
        assertEq(
            pairContract.balanceOf(address(uniswapV2SwapInstance)), liquidity, "uniswapV2Swap should have LP tokens"
        );

        // Record initial balances
        uint256 initialPairBalanceA = tokenA.balanceOf(pairAddress);
        uint256 initialPairBalanceB = tokenB.balanceOf(pairAddress);
        uint256 initialRecipientBalanceA = tokenA.balanceOf(recipient);
        uint256 initialRecipientBalanceB = tokenB.balanceOf(recipient);

        // Remove liquidity as uniswapV2Swap
        vm.prank(address(uniswapV2SwapInstance));
        (uint256 amountARemoved, uint256 amountBRemoved) =
            uniswapV2SwapInstance.removeLiquidity(address(tokenA), address(tokenB), recipient);

        // Check recipient received tokens
        uint256 finalRecipientBalanceA = tokenA.balanceOf(recipient);
        uint256 finalRecipientBalanceB = tokenB.balanceOf(recipient);
        assertEq(finalRecipientBalanceA, initialRecipientBalanceA + amountARemoved, "Recipient should receive TokenA");
        assertEq(finalRecipientBalanceB, initialRecipientBalanceB + amountBRemoved, "Recipient should receive TokenB");

        // Check pair balances decreased
        uint256 finalPairBalanceA = tokenA.balanceOf(pairAddress);
        uint256 finalPairBalanceB = tokenB.balanceOf(pairAddress);
        assertEq(finalPairBalanceA, initialPairBalanceA - amountARemoved, "Pair TokenA balance should decrease");
        assertEq(finalPairBalanceB, initialPairBalanceB - amountBRemoved, "Pair TokenB balance should decrease");

        // Check uniswapV2Swap LP balance decreased
        uint256 finalSwapLPBalance = pairContract.balanceOf(address(uniswapV2SwapInstance));
        assertEq(finalSwapLPBalance, 0, "uniswapV2Swap LP balance should be zero");

        console.log("Removed %s TokenA, %s TokenB", amountARemoved / 10 ** 18, amountBRemoved / 10 ** 18);
        console.log("Liquidity removed successfully");
    }
}
