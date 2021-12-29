// SPDX-License-Identifier: MIT
pragma solidity^0.8.0;
import "../OZ/Ownable.sol";
import "../OZ/IERC20.sol";
import "../OZ/ECDSA.sol";

contract sharerRewards is Ownable{
    using ECDSA for bytes32;
    address public serverAddress;
    mapping (address => bool) public serverAddresses;
    mapping (address => uint) nonces;
    address tokenContract;
constructor(address _serverAddress) {
    serverAddress = _serverAddress;
    serverAddresses[_serverAddress] = true;
  }

  function setServerAddress (address _serverAddress) external onlyOwner{
    serverAddress = _serverAddress;
    serverAddresses[_serverAddress] = true;
  }

  function removeServerAddress (address _serverAddress) external onlyOwner {
    serverAddresses[_serverAddress] = false;
  }

  function setTokenContract (address _tokenContract) external onlyOwner {
    tokenContract = _tokenContract;
  }

    function serverVerify(bytes32 r, bytes32 s, uint8 v, uint amountToTransfer) internal returns(bool) {
    bytes32 hash = keccak256(abi.encodePacked(nonces[msg.sender], address(this), amountToTransfer));
    address signer = ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)), v, r, s);
    require( serverAddresses[signer],"SIGNER MUST BE SERVER"); 
    nonces[msg.sender]++;
    return serverAddresses[signer];  
  }

  function transferRewards (bytes32 r, bytes32 s, uint8 v, uint amountToTransfer) external {
    require(serverVerify(r,s,v,amountToTransfer), "Verification failed");
      IERC20(tokenContract).transfer(msg.sender, amountToTransfer);
  }
}