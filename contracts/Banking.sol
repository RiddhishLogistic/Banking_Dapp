// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Banking {
    address public bank;
    mapping(address => uint256) public userAccount;
    mapping(address => bool) public userExists;

    constructor() {
        bank = msg.sender;
    }

    event CreateAcc(address indexed account);
    event Deposit(address depositer, uint256 amount, uint256 balance);
    event Withdraw(address withdrower, uint256 amount, uint256 balance);
    event Transfer(address sender, address reciver, uint256 amount);
    event SendEth(address from, address to, uint256 amount);

    function createAcc() public payable {
        require(msg.sender != bank, "Bank owner can't create account");
        require(userExists[msg.sender] == false, "account already created");
        userAccount[msg.sender] = msg.value;
        userExists[msg.sender] = true;

        emit CreateAcc(msg.sender);
    }

    function deposit() public payable {
        require(userExists[msg.sender] == true, "Account is not created");
        require(msg.value > 0, "Value for deposit is Zero");
        userAccount[msg.sender] = userAccount[msg.sender] + msg.value;

        emit Deposit(msg.sender, msg.value, userAccount[msg.sender]);
    }

    function withdraw(uint256 amount) public payable {
        require(
            userAccount[msg.sender] >= amount,
            "insufficeint balance in Bank account"
        );
        require(userExists[msg.sender] == true, "Account is not created");
        require(amount > 0, "Enter non-zero value for withdrawal");
        userAccount[msg.sender] = userAccount[msg.sender] - amount;

        (bool sent, ) = payable(msg.sender).call{value: amount}("");
        require(sent, "withdrawal failed");

        emit Withdraw(msg.sender, amount, userAccount[msg.sender]);
    }

    function TransferAmount(address payable userAddress, uint256 amount)
        public
    {
        require(
            userAccount[msg.sender] >= amount,
            "insufficeint balance in Bank account"
        );
        require(userExists[msg.sender] == true, "Account is not created");
        require(
            userExists[userAddress] == true,
            "to Transfer account does not exists in bank accounts"
        );
        require(amount > 0, "Enter non-zero value for sending");
        userAccount[msg.sender] = userAccount[msg.sender] - amount;
        userAccount[userAddress] = userAccount[userAddress] + amount;

        emit Transfer(msg.sender, userAddress, amount);
    }

    function sendEther(address payable toAddress, uint256 amount)
        public
        payable
    {
        require(amount > 0, "Enter non-zero value for send");
        require(userExists[msg.sender] == true, "Account is not created");
        require(
            userAccount[msg.sender] >= amount,
            "insufficeint balance in Bank account"
        );
        userAccount[msg.sender] = userAccount[msg.sender] - amount;
        toAddress.transfer(amount);

        emit SendEth(msg.sender, toAddress, amount);
    }

    function userAccountBalance() public view returns (uint256) {
        return userAccount[msg.sender];
    }

    function accountExist() public view returns (bool) {
        return userExists[msg.sender];
    }

    function CheckBankContractBalance() public view returns (uint256) {
        require(msg.sender == bank, "Only bank can check this");
        return address(this).balance;
    }
}