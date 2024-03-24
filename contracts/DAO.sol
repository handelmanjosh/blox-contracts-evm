// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import "./Game.sol";
import "./GameShop.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DAO is Ownable {
    struct Proposal {
        uint gameNum;
        string code;
        uint votes;
    }
    address gameContract;
    address gameShopContract;
    mapping(uint => mapping(uint => Proposal)) proposals;
    mapping(uint => uint) counts;
    constructor(address _gameContract, address _gameShopContract) Ownable(msg.sender) {
        gameContract = _gameContract;
        gameShopContract = _gameShopContract;
    }
    function createProposal(uint gameId, string calldata code) external {
        // Game game = Game(gameContract);
        //GameData memory g = game.viewGame(gameId);
        GameShop gs = GameShop(gameShopContract);
        address tokenAddress = gs.getTokenForGame(gameId);
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(msg.sender) > 0, "Not a DAO member");
        token.transferFrom(msg.sender, owner(), token.balanceOf(msg.sender));
        Proposal memory p = Proposal({
            gameNum: gameId,
            code: code,
            votes: token.balanceOf(msg.sender)
        });
        uint count = counts[gameId];
        proposals[gameId][count] = p;
        counts[gameId]++;
    }
    function vote(uint gameId, uint proposalId) external {
        GameShop gs = GameShop(gameShopContract);
        address tokenAddress = gs.getTokenForGame(gameId);
        GameToken token = GameToken(tokenAddress);
        require(token.balanceOf(msg.sender) > 0, "Not a DAO member");
        token.transferFrom(msg.sender, owner(), token.balanceOf(msg.sender));
        proposals[gameId][proposalId].votes += token.balanceOf(msg.sender);
        if (proposals[gameId][proposalId].votes > token.supply() / 2) {
            Game g = Game(gameContract);
            g.editGame(gameId, proposals[gameId][proposalId].code);
            delete proposals[gameId][proposalId];
        }
    }
    function viewProposals(uint gameId) external view returns(Proposal[] memory p) {
        p = new Proposal[](counts[gameId]);
        for (uint i = 0; i < counts[gameId]; i++) {
            p[i] = proposals[gameId][i];
        }
    }
}