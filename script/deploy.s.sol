// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/SalukiToken.sol";

contract DeployScript is Script {
    address constant USDT_ADDRESS = 0x...; // 以太坊主网上USDT的合约地址

    function run() external {
        SalukiToken salukiToken = new SalukiToken(USDT_ADDRESS);
        salukiToken.addLP(0x...); // 流动性池地址
        console.log("SalukiToken deployed to:", salukiToken);
    }
}