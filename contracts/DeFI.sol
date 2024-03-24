// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;




import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract LiquidityPools is Ownable {
    // very shit liquidity pools. Only for demonstration of possible ways gamers can leverage value off of their games
    struct Pool {
        uint id;
        address gameToken;
        address vsToken;
        uint gameTokenAmount;
        uint vsTokenAmount;
    }
    mapping(uint => Pool) pools;
    address gameShop;
    uint count;
    constructor(address _gameShop) Ownable(msg.sender) {
        gameShop = _gameShop;
        count = 0;
    }
    function createLiquidityPool(address gameToken, address vsToken, uint gameTokenAmount, uint vsTokenAmount) external {
        IERC20 gToken = IERC20(gameToken);
        IERC20 vToken = IERC20(vsToken);
        require(gToken.transferFrom(msg.sender, owner(), gameTokenAmount), "Failed to transfer");
        require(vToken.transferFrom(msg.sender, owner(), vsTokenAmount), "Failed to transfer");
        Pool memory p = Pool({
            id: count,
            gameToken: gameToken,
            vsToken: vsToken,
            gameTokenAmount: gameTokenAmount,
            vsTokenAmount: vsTokenAmount
        });
        pools[count] = p;
        count++;
    }
    function addLiquidity(uint poolId, uint gameTokenAmount, uint vsTokenAmount) external {
        // adds amount deliniated in gameToken;
        Pool storage pool = pools[poolId];
        // Transfer tokens from the caller to this contract
        require(IERC20(pool.gameToken).transferFrom(msg.sender, owner(), gameTokenAmount), "TokenA transfer failed");
        require(IERC20(pool.vsToken).transferFrom(msg.sender, owner(), vsTokenAmount), "TokenB transfer failed");

        pool.gameTokenAmount += gameTokenAmount;
        pool.vsTokenAmount += vsTokenAmount;
    }
    function swap(uint poolId, address token, uint amount) external {
        Pool storage pool = pools[poolId];
        require(token == pool.gameToken || token == pool.vsToken, "Invalid fromToken");

        if (token == pool.gameToken) {
            uint256 swapAmount = getSwapAmount(pool.gameTokenAmount, pool.vsTokenAmount, amount);
            require(IERC20(pool.vsToken).transfer(msg.sender, swapAmount), "Swap failed");
            pool.gameTokenAmount += amount;
            pool.vsTokenAmount -= swapAmount;
        } else {
            uint256 swapAmount = getSwapAmount(pool.vsTokenAmount, pool.gameTokenAmount, amount);
            require(IERC20(pool.gameToken).transfer(msg.sender, swapAmount), "Swap failed");
            pool.vsTokenAmount += amount;
            pool.gameTokenAmount -= swapAmount;
        }
    }
    function viewPools() external view returns(Pool[] memory p) {
        p = new Pool[](count);
        for (uint i = 0; i < count; i++) {
            p[i] = pools[i];
        }
    }
    function getSwapAmount(uint256 fromBalance, uint256 toBalance, uint256 amount) private pure returns (uint256) {
        // This is a simplified example. Use an actual formula for your use case.
        // For example, a constant product formula, or add fees, slippage, etc.
        return (amount * toBalance) / (fromBalance + amount);
    }
}