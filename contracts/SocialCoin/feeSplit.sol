// SPDX-License-Identifier: MIT
pragma solidity^0.8.0;

import "../OZ/Ownable.sol";
import "../OZ/IERC20.sol";

contract feeSplit is Ownable{

constructor () {
    ratio = 5;
    tokenContract = 0xab43eF7C7Fc6D3e87F0086FAA4f73dCBdF3aD2fc;
    sharerContract = 0xab43eF7C7Fc6D3e87F0086FAA4f73dCBdF3aD2fc;
    poolingContract = 0xab43eF7C7Fc6D3e87F0086FAA4f73dCBdF3aD2fc;
    callRatio = 100;
}
uint ratio;
uint callRatio;
address tokenContract;
address sharerContract;
address poolingContract;

function setRatio (uint _ratio) external onlyOwner {
    ratio = _ratio;
}

function setTokenContract (address _tokenContract) external onlyOwner {
    tokenContract = _tokenContract;
}

function setPoolingContract (address _poolingContract) external onlyOwner {
    poolingContract = _poolingContract;
}

function setSharerContract (address _sharerContract) external onlyOwner {
    sharerContract = _sharerContract;
}

function setCallRatio (uint _callRatio) external onlyOwner {
    callRatio = _callRatio;
}

function divideToContracts () 
    external {
uint callerReward = (IERC20(tokenContract).balanceOf(address(this)))/callRatio;   
uint splitAmount = (IERC20(tokenContract).balanceOf(address(this))) - callerReward;
require(splitAmount > 0);
uint poolingPortion = splitAmount/ratio;
uint sharerPortion = splitAmount - poolingPortion;
IERC20(tokenContract).transfer(poolingContract, poolingPortion);
IERC20(tokenContract).transfer(sharerContract, sharerPortion);
IERC20(tokenContract).transfer(msg.sender, callerReward);
}
}