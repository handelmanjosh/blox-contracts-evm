// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./GameToken.sol";
import "./GameNFT.sol";
import "./Leaderboard.sol";
import "./User.sol";
import "./GameShop.sol";
import "./Shop.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

struct GameData {
    address creator;
    string name;
    string code;
    address[] nftCollections;
    address[] tokens;
    string description;
    string imgSrc;
}
contract Game is ERC721Enumerable, Ownable {
    struct Progress {
        string code;
    }
    mapping(uint => GameData) games;
    mapping(address => mapping(string => Progress)) progress;
    mapping(address => string[]) names;
    uint gameCounter;
    address public leaderboard;
    address public shop;
    address public userManager;
    address public gameShop;
    constructor() ERC721("Games", "GAME") Ownable(msg.sender) {
        gameCounter = 0;
        Leaderboard l = new Leaderboard();
        Shop s = new Shop();
        User u = new User();
        GameShop gs = new GameShop(address(this));
        leaderboard = address(l);
        shop = address(s);
        userManager = address(u);
        gameShop = address(gs);
    }
    struct Token {
        string name;
        string symbol;
        string description;
        uint supply;
    }
    struct NFT {
        string name;
        string symbol;
        string[] keys;
        uint[] values;
    }
    struct UserData {
        string[] keys;
        uint[] values; // not used
    }
    function editGame(uint gameId, string calldata code) public {
        games[gameId].code = code;
    }
    function createTokens(Token[] calldata tokens) private returns (address[] memory) {
        address[] memory tokenAddresses = new address[](tokens.length);
        for (uint i = 0; i < tokens.length; i++) {
            GameToken token = new GameToken(tokens[i].supply, tokens[i].name, tokens[i].symbol, tokens[i].description, owner());
            tokenAddresses[i] = address(token);
        }
        return tokenAddresses;
    }
    function createNFTs(NFT[] calldata nfts) private returns (address[] memory) {
        address[] memory nftAddresses = new address[](nfts.length);
        for (uint i = 0; i < nfts.length; i++) {
            GameNFT nft = new GameNFT(nfts[i].name, nfts[i].symbol, nfts[i].keys, nfts[i].values);
            nftAddresses[i] = address(nft);
        }
        return nftAddresses;
    }
    function viewSavedGameNames() external view returns(string[] memory p) {
        p = names[msg.sender];
    }
    function viewSavedGame(string calldata name) external view returns(string memory c) {
        c = progress[msg.sender][name].code;
    }
    function saveGame(string memory gameName, string memory code) public {
        // Check if this is a new game for the user to avoid duplicates in userGames
        if(bytes(progress[msg.sender][gameName].code).length == 0) {
            names[msg.sender].push(gameName);
        }
        progress[msg.sender][gameName] = Progress(code);
    }
    struct GameInfo {
        string code;
        string description;
        string name;
        string imgSrc;
    }
    // function editGame() change name, change code, add tokens and nfts and userData
    function createGame(GameInfo calldata gameInfo, Token[] calldata tokens, NFT[] calldata nfts, UserData calldata userData) external {
        // uint test = (tokenNames.length + tokenSymbols.length + tokenDescriptions.length + tokenSupply.length) / 4;
        // require(test == tokenSupply.length, "Invalid parameter lengths");
        // test = (nftNames.length + nftSymbols.length + nftDescriptions.length) / 3;
        // require(test == nftDescriptions.length, "Invalid parameter lengths");
        address[] memory tokenAddresses = createTokens(tokens);
        address[] memory nftAddresses = createNFTs(nfts);

        GameData memory gameData = GameData({
            name: gameInfo.name,
            creator: msg.sender,
            code: gameInfo.code,
            nftCollections: nftAddresses,
            tokens: tokenAddresses,
            description: gameInfo.description,
            imgSrc: gameInfo.imgSrc
        });
        gameCounter++;
        games[gameCounter] = gameData;
        Leaderboard l = Leaderboard(leaderboard);
        l.initializeLeaderboard(gameCounter);
        User user = User(userManager);
        user.initializeUserData(gameCounter, userData.keys);
        Shop s = Shop(shop);
        s.initializeShop(gameCounter, false, msg.sender);
        _mint(msg.sender, gameCounter); // need to mint the game nft
    }
    function viewGameTokens(uint game) view external returns(address[] memory a) {
        a = games[game].tokens;
    }
    function viewGameNFTs(uint game) view external returns(address[] memory a) {
        a = games[game].nftCollections;
    }
    function viewGame(uint game) view external returns(GameData memory g) {
        g = games[game];
    }
    function viewGames() view external returns(string[] memory g, uint[] memory n) {
        g = new string[](gameCounter);
        n = new uint[](gameCounter);
        for (uint i = 1; i <= gameCounter; i++) {
            g[i - 1] = games[i].name;
            n[i - 1] = i;    
        }
    }

    // function transferPayment
    // function transferGameAsset
    // view games - not strictly necessary
}