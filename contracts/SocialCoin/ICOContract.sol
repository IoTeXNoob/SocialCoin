// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../OZ/IERC20.sol";
import "../OZ/Ownable.sol";
contract socialIco is Ownable {
     event Bought(uint256 amount);
     mapping (address => uint) tokensBought; 
constructor (){
   tokenContract = 0xab43eF7C7Fc6D3e87F0086FAA4f73dCBdF3aD2fc;
    }

address tokenContract;
uint price;
uint minLimit;
uint maxAmount;
function setTokenContract (address _tokenContract) external onlyOwner{
  tokenContract = _tokenContract;
}

function setPrice (uint _price) external onlyOwner {
  price = _price;
}

function setMinLimit (uint _minLimit) external onlyOwner {
  minLimit = _minLimit;
}

function setMaxAmount (uint _maxAmount) external onlyOwner {
  maxAmount = _maxAmount;
}

function buy() payable public {
    uint256 amountToBuy = (msg.value)*price; //price is set in IOTX
    uint256 icoBalance = IERC20(tokenContract).balanceOf(address(this));
    require(amountToBuy > minLimit, "You need to send more IOTX");
    require(amountToBuy <= icoBalance, "Not enough tokens in the reserve");
    require(tokensBought[msg.sender] + amountToBuy <= maxAmount, "You can't buy that much $SOCL");
    IERC20(tokenContract).transfer(msg.sender, amountToBuy);
    tokensBought[msg.sender]+=amountToBuy;
    emit Bought(amountToBuy);
}
  function withdraw() external onlyOwner {
    address payable _owner = payable (owner());
    _owner.transfer(address(this).balance);
  }

}