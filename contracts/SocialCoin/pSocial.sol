// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "../OZ/ERC20.sol";
import "../OZ/ERC20Burnable.sol";
import "../OZ/Ownable.sol";
import "../OZ/IERC20.sol";

contract PooledSocialCoin is ERC20, ERC20Burnable, Ownable {
    constructor() ERC20("pSocial", "pSOCL") {
        minLimit = 10;
        tokenFee = 5;
    }

    address tokenContract;
    uint tokenFee;
    uint minLimit;

    function mint(address to, uint256 amount) internal {
        _mint(to, amount);
    }

    function setTokenContract (address _tokenContract) external onlyOwner {
        tokenContract = _tokenContract;
    }

    function setTokenFee (uint _tokenFee) external onlyOwner {
        tokenFee = _tokenFee; //This is the on transfer fee by SOCL, the pool doesn't take any fee
    }
    function setMinLimit (uint _minLimit) external onlyOwner{
        minLimit = _minLimit;
    }

    function pooling  (uint poolAmount) 
        external  {
        uint poolBalance = IERC20(tokenContract).balanceOf(address(this)); //get the pools balance
        uint totalShares = totalSupply();                               //get the total shares 
        IERC20(tokenContract).transferFrom(msg.sender, address(this), poolAmount); //
        uint realPooledAmount = poolAmount - ((tokenFee*poolAmount)/100);
        require (realPooledAmount >= minLimit, "You must pool more $SOCL");
        if (totalShares == 0 || poolBalance == 0 ) {
            mint(msg.sender, realPooledAmount);
        }
        else {
            uint userShare = (realPooledAmount * totalShares)/poolBalance;
            mint(msg.sender, userShare);
        }
    }

    function viewBalance () external view returns(uint) {
        uint poolBalance = IERC20(tokenContract).balanceOf(address(this));
        uint totalShares = totalSupply();   
        return ((balanceOf(msg.sender)*poolBalance)/totalShares);
    }

    function quitPool (uint userShare) 
        external {
        require((IERC20(address(this)).balanceOf(msg.sender))>= userShare);
        uint poolBalance = IERC20(tokenContract).balanceOf(address(this)); //get the pools balance
        uint totalShares = totalSupply();                               //get the total shares
        uint userAmount = (userShare*poolBalance)/totalShares;
        require (userAmount > 0);
        burn(userShare);
        IERC20(tokenContract).transfer(msg.sender, userAmount);
    }



}