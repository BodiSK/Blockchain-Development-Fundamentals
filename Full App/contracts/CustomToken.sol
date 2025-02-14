// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract CustomToken is ERC20 {
    constructor()
        ERC20("Crowd", "CRW")
    {
        _mint(msg.sender, 50_000 * 10 ** decimals());
    }

    function decimals() public pure override returns (uint8) {
        return 8;
    }
}