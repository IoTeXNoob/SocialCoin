// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "../OZ/IERC20.sol";
import "../OZ/IERC20Metadata.sol";
import "../OZ/Context.sol";
import "../OZ/Ownable.sol";

contract socialCoin is Context, IERC20, IERC20Metadata, Ownable{
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;
    mapping (address => bool) public noTaxWallets;
    address[] allNoTaxWallets;
    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    address payable storageWallet;
    uint x;
   

    constructor(string memory name_ , string memory symbol_, address payable myWallet, uint taxPercent) {
        _name = name_;
        _symbol = symbol_;
        _mint(msg.sender, 100*10**decimals());
        storageWallet = myWallet;
        x = taxPercent;
        noTaxWallets [msg.sender] = true;
        allNoTaxWallets.push(msg.sender);
    }

    function returnNoTaxWallets() external view returns (address [] memory){
        return allNoTaxWallets;
    }

    function viewTax() external view returns(uint){
    return x;
    }

    function viewStorageWallet() external view returns(address){
    return storageWallet;
    }

    function changeStorageWallet(address payable myNewWallet) external onlyOwner {
        storageWallet = myNewWallet;
    }

    function changeTaxPercent(uint newTaxPercent) external onlyOwner {
        x = newTaxPercent;
    }

    function addNoTaxWallets(address newAddress) external onlyOwner {
        noTaxWallets[newAddress] = true;
        allNoTaxWallets.push(newAddress);
    }
    
    function removeNoTaxWallets(address removeAddress, uint index) external onlyOwner{
      delete noTaxWallets[removeAddress];
      allNoTaxWallets[index] =allNoTaxWallets[allNoTaxWallets.length - 1];
      require(allNoTaxWallets[index] == removeAddress);
        allNoTaxWallets.pop();
    }
    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }

        if (noTaxWallets[sender] == true ) {
            
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
        }
        else {
         
        uint amountTax = amount*x/100; //assuming x is uint between 0 and 100
        _balances[storageWallet] += amountTax;

        _balances[recipient] += amount - amountTax;

        emit Transfer(sender, recipient, amount);
        }

         _afterTokenTransfer(sender, recipient, amount);
         
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}