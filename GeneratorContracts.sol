// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DynamicDepositContractGenerator {
    address public owner;

    event NewDepositContract(address indexed contractAddress, address indexed owner);

    constructor() {
        owner = msg.sender;
    }

    function createDepositContract(
        uint256 depositDuration,
        uint256 moderatorFeePercentage,
        uint256 depositLimit
    ) external {
        DepositContract newContract = new DepositContract(
            msg.sender,
            depositDuration * 1 days,
            moderatorFeePercentage,
            depositLimit
        );

        emit NewDepositContract(address(newContract), msg.sender);
    }
}

contract DepositContract {
    address public owner;
    address public moderator;
    uint256 public depositEndTime;
    uint256 public depositLimit;
    uint256 public moderatorFeePercentage;

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

    constructor(
        address _owner,
        uint256 _depositDuration,
        uint256 _moderatorFeePercentage,
        uint256 _depositLimit
    ) {
        owner = _owner;
        moderator = msg.sender;
        depositEndTime = block.timestamp + _depositDuration;
        moderatorFeePercentage = _moderatorFeePercentage;
        depositLimit = _depositLimit;
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
        uint256 moderatorFee = amount * moderatorFeePercentage / 100;
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
