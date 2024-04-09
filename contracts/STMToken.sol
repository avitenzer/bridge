
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract STMToken is ERC20 {
    constructor() ERC20("STMToken", "STK") {
        _mint(msg.sender, 5_000 ether);
    }
}