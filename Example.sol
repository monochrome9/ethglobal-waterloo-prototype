// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DepositContract {
    address public owner;
    address public moderator;
    uint256 public depositLimit;
    uint256 public depositEndTime;
    uint256 public contractBalance;
    uint256 public moderatorReserve;

    bool public closedForDeposits;
    bool public withdrawalAllowed;

    mapping(address => uint256) public deposits;

    event Deposit(address indexed depositor, uint256 amount);
    event ContractClosed(uint256 endTime);
    event Withdrawal(address indexed recipient, uint256 amount);
    event ModeratorWithdrawal(address indexed recipient, uint256 amount);

    modifier onlyOwnerOrModerator() {
        require(msg.sender == owner || msg.sender == moderator, "Only owner or moderator can call this function.");
        _;
    }

    modifier notClosedForDeposits() {
        require(!closedForDeposits, "Deposits are closed.");
        _;
    }

    modifier canWithdraw() {
        require(withdrawalAllowed, "Withdrawal is not allowed yet.");
        _;
    }

    constructor() {
        owner = msg.sender;
        moderator = address(0xc5064174ea2723ec5BaFBC97C074BD348B193369); // Set address
        depositLimit = 1 ether;
        depositEndTime = block.timestamp + 14 days;
    }

    function deposit() external payable notClosedForDeposits {
        require(deposits[msg.sender] + msg.value <= depositLimit, "Deposit limit exceeded.");
        deposits[msg.sender] += msg.value;
        contractBalance += msg.value;
        emit Deposit(msg.sender, msg.value);

        if (contractBalance >= depositLimit || block.timestamp >= depositEndTime) {
            closedForDeposits = true;
            emit ContractClosed(block.timestamp);
        }
    }

    function allowWithdrawal() external onlyOwnerOrModerator {
        require(closedForDeposits, "Deposits are still open.");
        withdrawalAllowed = true;
    }

    function withdraw() external onlyOwnerOrModerator canWithdraw {
        uint256 amount = contractBalance;
        uint256 moderatorFee = amount * 3 / 100; // 3% of the total contract balance
        contractBalance -= moderatorFee;
        moderatorReserve += moderatorFee;

        contractBalance = 0;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Withdrawal failed.");
        emit Withdrawal(msg.sender, amount);
    }

    function withdrawAsModerator() external onlyOwnerOrModerator canWithdraw {
        require(msg.sender == moderator, "Only moderator can call this function.");
        require(block.timestamp >= depositEndTime + 90 days, "Moderator withdrawal is not allowed yet.");
        uint256 amount = contractBalance;
        uint256 moderatorFee = moderatorReserve;
        contractBalance = 0;
        moderatorReserve = 0;
        (bool success, ) = msg.sender.call{value: amount + moderatorFee}("");
        require(success, "Withdrawal failed.");
        emit ModeratorWithdrawal(msg.sender, moderatorFee);
        emit Withdrawal(msg.sender, amount);
    }
}
