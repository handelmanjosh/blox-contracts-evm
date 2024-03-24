// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";



contract Shop is Ownable {
    struct Listing {
        address item;
        bool isNFT;
        uint nftId;
        uint tokenAmount;
        address chargeToken;
        uint price;
        uint listingId;
    }
    constructor() Ownable(msg.sender) {

    }
    struct ShopInternal {
        Listing[] listings;
        bool userListable;
        uint listingNum;
        address owner;
    }
    mapping(uint => ShopInternal) shops;

    function initializeShop(uint game, bool userListable, address owner) public {
        shops[game].userListable = userListable;
        shops[game].listingNum = 0;
        shops[game].owner = owner;
    }
    // function listItemOwner(uint game, address item, bool isNFT, uint nftId, uint tokenAmount, address chargeToken, uint price) external onlyOwner {
    //     ShopInternal storage shop = shops[game];
    //     shop.listings.push(Listing({
    //         item: item,
    //         isNFT: isNFT,
    //         tokenAmount: tokenAmount,
    //         nftId: nftId,
    //         chargeToken: chargeToken,
    //         price: price,
    //         listingId: shop.listingNum
    //     }));
    //     shop.listingNum++;
    // }
    function listItem(uint game, address item, bool isNFT, uint nftId, uint tokenAmount, address chargeToken, uint price) external {
        if (isNFT) {
            IERC721 nft = IERC721(item);
            nft.transferFrom(msg.sender, address(this), nftId);
        } else {
            IERC20 token = IERC20(item);
            require(token.transferFrom(msg.sender, address(this), tokenAmount), "");
        }
        ShopInternal storage shop = shops[game];
        shop.listings.push(Listing({
            item: item,
            isNFT: isNFT,
            tokenAmount: tokenAmount,
            nftId: nftId,
            chargeToken: chargeToken,
            price: price,
            listingId: shop.listingNum
        }));
        shop.listingNum++;
    }
    function buyItem(uint game, uint listingId) external {
        ShopInternal storage shop = shops[game];
        uint found = shop.listings.length;
        for (uint i = 0; i < shop.listings.length; i++) {
            if (shop.listings[i].listingId == listingId) {
                found = i;
                IERC20 chargeToken = IERC20(shop.listings[i].chargeToken);
                require(chargeToken.transferFrom(msg.sender, owner(), shop.listings[i].price));
                if (shop.listings[i].isNFT) {
                    IERC721 sellNFT = IERC721(shop.listings[i].item);
                    sellNFT.transferFrom(address(this), msg.sender, shop.listings[i].nftId);
                } else {
                    IERC20 sellToken = IERC20(shop.listings[i].item);
                    require(sellToken.transferFrom(address(this), msg.sender, shop.listings[i].tokenAmount));
                }
                break;
            }
        }
        for (uint i = found; found < shop.listings.length - 1; found++) {
            shop.listings[i] = shop.listings[i + 1];
        }
        shop.listings.pop();
    }
    function viewShop(uint game) external view returns(ShopInternal memory s) {
        s = shops[game];
    }
}