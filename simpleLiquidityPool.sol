// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SimpleLiquidityPool {
    IERC20 public tokenA;
    IERC20 public tokenB;
    uint256 public reserveA;
    uint256 public reserveB;

    constructor(IERC20 _tokenA, IERC20 _tokenB) {
        tokenA = _tokenA;
        tokenB = _tokenB;
    }

    // Add liquidity to the pool
    function addLiquidity(uint256 amountA, uint256 amountB) public {
        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transferFrom(msg.sender, address(this), amountB);
        reserveA += amountA;
        reserveB += amountB;
    }

    // Swap Token A for Token B
    function swapAtoB(uint256 amountA) public {
        require(reserveA > 0 && reserveB > 0, "Pool is empty");

        uint256 amountB = getSwapAmount(amountA, reserveA, reserveB);
        require(amountB > 0, "Insufficient output amount");

        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transfer(msg.sender, amountB);

        reserveA += amountA;
        reserveB -= amountB;
    }

    // Swap Token B for Token A
    function swapBtoA(uint256 amountB) public {
        require(reserveA > 0 && reserveB > 0, "Pool is empty");

        uint256 amountA = getSwapAmount(amountB, reserveB, reserveA);
        require(amountA > 0, "Insufficient output amount");

        tokenB.transferFrom(msg.sender, address(this), amountB);
        tokenA.transfer(msg.sender, amountA);

        reserveB += amountB;
        reserveA -= amountA;
    }

    // Calculate the swap amount using the constant product formula: x * y = k
    function getSwapAmount(uint256 inputAmount, uint256 inputReserve, uint256 outputReserve) public pure returns (uint256) {
        uint256 inputAmountWithFee = inputAmount * 997; // 0.3% fee
        uint256 numerator = inputAmountWithFee * outputReserve;
        uint256 denominator = (inputReserve * 1000) + inputAmountWithFee;
        return numerator / denominator;
    }

    // View function to get the current reserves of the pool
    function getReserves() public view returns (uint256, uint256) {
        return (reserveA, reserveB);
    }
}
