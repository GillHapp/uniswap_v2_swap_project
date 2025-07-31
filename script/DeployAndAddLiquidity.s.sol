// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {console} from "forge-std/console.sol";
import "forge-std/Script.sol";
import "../src/TokenA.sol";
import "../src/TokenB.sol";

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IUniswapV2Router02 {
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);
}

contract DeployAndAddLiquidity is Script {
    address constant UNISWAP_V2_FACTORY = 0xF62c03E08ada871A0bEb309762E260a7a6a880E6;
    address constant UNISWAP_V2_ROUTER = 0xeE567Fe1712Faf6149d80dA1E6934E354124CfE3;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("SEPOLIA_PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        vm.startBroadcast(deployerPrivateKey);

        // Deploy TokenA
        TokenA tokenA = new TokenA();
        console.log("TokenA deployed to:", address(tokenA));

        // Deploy TokenB
        TokenB tokenB = new TokenB();
        console.log("TokenB deployed to:", address(tokenB));

        // Create TokenA/TokenB pair
        IUniswapV2Factory factory = IUniswapV2Factory(UNISWAP_V2_FACTORY);
        factory.createPair(address(tokenA), address(tokenB));
        address pair = factory.getPair(address(tokenA), address(tokenB));
        console.log("TokenA/TokenB pair created at:", pair);

        // Approve tokens for Router
        uint256 amountA = 1_000 * 10 ** 18; // 1,000 TokenA
        uint256 amountB = 1_000 * 10 ** 18; // 1,000 TokenB (1:1 price)
        IERC20(address(tokenA)).approve(UNISWAP_V2_ROUTER, amountA);
        IERC20(address(tokenB)).approve(UNISWAP_V2_ROUTER, amountB);
        console.log("Approved TokenA and TokenB for Router");

        // Add liquidity
        IUniswapV2Router02 router = IUniswapV2Router02(UNISWAP_V2_ROUTER);
        uint256 deadline = block.timestamp + 10 * 60; // 10 minutes
        (uint256 amountAUsed, uint256 amountBUsed, uint256 liquidity) = router.addLiquidity(
            address(tokenA),
            address(tokenB),
            amountA,
            amountB,
            0, // amountAMin (set to 0 for simplicity)
            0, // amountBMin
            deployer,
            deadline
        );
        // console.log("Added", amountAUsed / 10 ** 18, "TokenA and", amountBUsed / 10 ** 18, "TokenB to pool");
        console.log("Received", liquidity / 10 ** 18, "LP tokens");

        // Verify LP balance
        IERC20 pairContract = IERC20(pair);
        uint256 lpBalance = pairContract.balanceOf(deployer);
        console.log("LP tokens in wallet:", lpBalance / 10 ** 18);

        vm.stopBroadcast();
    }
}
