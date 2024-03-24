// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;


contract Leaderboard {
    struct LeaderboardInternal {
        address[] winners;
        uint[] data;
    }
    mapping(uint => LeaderboardInternal) leaderboards;
    function initializeLeaderboard(uint game) public {
        leaderboards[game] = LeaderboardInternal({
            winners: new address[](0),
            data: new uint[](0)
        });
    }
    function updateLeaderboard(uint game, address to, uint data) public {
        LeaderboardInternal storage leaderboard = leaderboards[game];

        if (leaderboard.winners.length < 20) {
            leaderboard.winners.push(to);
            leaderboard.data.push(data);
        } else {
            for (uint i = 0; i < leaderboard.data.length; i++) {
                if (data > leaderboard.data[i]) {
                    for (uint ii = leaderboard.data.length - 1; ii > i; ii--) {
                        leaderboard.data[ii] = leaderboard.data[ii - 1];
                    }
                    leaderboard.data[i] = data;
                    break;
                }
            }
        }
    }
    function viewLeaderboard(uint game) public view returns(LeaderboardInternal memory l) {
        l = leaderboards[game];
    }
    // function viewMin(uint game) public view returns(uint i) {
    //     Leaderboard storage l = leaderboards[game];
    //     i = l[l.length - 1];
    // }
}