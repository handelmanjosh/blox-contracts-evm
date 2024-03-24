// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./GameToken.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GameShop is Ownable {
    struct Listing {
        uint id;
        bool isToken;
        uint amount;
        uint gameId;
        uint price;
        address tokenAddress;
        address sellToken;
        address seller;
    }
    // can just use balance functions to get balance of game tokens and of games
    // game shop has a gamedao
    // map token address to proposals
    // proposals can do things like call the game function to do other things
    mapping(uint => address) gameToToken;
    mapping(address => uint) tokenToGame;

    address public gameContract;
    Listing[] public listings;
    address[] activeGameTokens;
    uint public count;
    constructor(address _gameContract) Ownable(msg.sender)  {
        gameContract = _gameContract;

        count = 0;
    }   
    function split(uint game, uint supply, string calldata name, string calldata symbol) external {
        IERC721Enumerable nft = IERC721Enumerable(gameContract);
        nft.transferFrom(msg.sender, address(this), game);
        GameToken token = new GameToken(supply, name, symbol, "",  msg.sender);
        address tokenAddress = address(token);
        gameToToken[game] = tokenAddress;
        tokenToGame[tokenAddress] = game;
        activeGameTokens.push(tokenAddress);
    }
    function redeem(uint game) external {
        address tokenAddress = gameToToken[game];
        GameToken token = GameToken(tokenAddress);
        token.transferFrom(msg.sender, address(this), 1000);
        IERC721Enumerable g = IERC721Enumerable(gameContract);
        g.transferFrom(address(this), msg.sender, game);
        // delete
        delete gameToToken[game];
        delete tokenToGame[tokenAddress];
        for (uint i = 0; i < activeGameTokens.length; i++) {
            if (activeGameTokens[i] == tokenAddress) {
                activeGameTokens[i] = activeGameTokens[activeGameTokens.length - 1];
                activeGameTokens.pop();
                break;
            }
        }
    }
    function list(bool isToken, uint amount, uint gameId, uint price, address sellToken) external {
        address tokenAddress;
        if (isToken) {
            tokenAddress = gameToToken[gameId];
            GameToken token = GameToken(tokenAddress);
            token.transferFrom(msg.sender, address(this), price);
        } else {
            IERC721Enumerable nft = IERC721Enumerable(gameContract);
            nft.transferFrom(msg.sender, address(this), gameId);
        }
        Listing memory l = Listing({
            id: count,
            isToken: isToken,
            amount: amount,
            gameId: gameId,
            tokenAddress: tokenAddress,
            price: price,
            sellToken: sellToken,
            seller: msg.sender
        });
        listings.push(l);
        count++;
    }
    function buy(uint listingId) external {
        uint found = listings.length;
        for (uint i = 0; i < listings.length; i++) {
            if (listings[i].id == listingId) {
                found = i;
                IERC20 sellToken = IERC20(listings[i].sellToken);
                sellToken.transferFrom(msg.sender, listings[i].seller, listings[i].price);
                if (listings[i].isToken) {
                    GameToken token = GameToken(listings[i].tokenAddress);
                    token.transferFrom(address(this), msg.sender, listings[i].amount);
                } else {
                    IERC721Enumerable g = IERC721Enumerable(gameContract);
                    g.transferFrom(address(this), msg.sender, listings[i].gameId);
                }
                break;
            }
        }
        for (uint i = found; found < listings.length - 1; found++) {
            listings[i] = listings[i + 1];
        }
        listings.pop();
        count--;
    }
    function getGameForToken(address token) external view returns(uint g) {
        g = tokenToGame[token];
    }
    function viewActiveGameTokens() external view returns(address[] memory t) {
        t = activeGameTokens;
    }
    function getTokenForGame(uint game) external view returns (address a) {
        a = gameToToken[game];
    }
}
