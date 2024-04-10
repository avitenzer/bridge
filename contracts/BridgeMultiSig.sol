// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BridgeMultiSig is Ownable  {

    address public token;
    event Deposit(address by, uint256 amount);

    mapping(address => bool) public isOwner;
    address[] public owners;
    uint256 public requiredApprovals;

    struct Transaction {
        address to;
        uint256 value;
        bool executed;
    }

    Transaction[] public transactions;

    mapping(uint256 => mapping(address => bool)) public isApproved;

    constructor(address _token, address[] memory _owners, uint256 _requiredApprovals) Ownable(msg.sender) {
        require(_owners.length > 0, "Owners required");
        require(_requiredApprovals > 0 && _requiredApprovals <= _owners.length, "Invalid required number of approvals");

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "Invalid owner");
            require(!isOwner[owner], "Owner not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }

        requiredApprovals = _requiredApprovals;
        token = _token;
    }

    function deposit(uint256 _amount) public {
        IERC20(token).transferFrom(msg.sender, address(this), _amount);
        emit Deposit(msg.sender, _amount);
    }


    function proposeTransaction(address _to, uint256 _amount) public onlyOwner returns (uint256) {
        uint256 txnId = transactions.length;
        transactions.push(Transaction({
            to: _to,
            value: _amount,
            executed: false
        }));
        return txnId;
    }

    function approveTransaction(uint256 _txnId) public onlyOwner {
        require(_txnId < transactions.length, "Transaction does not exist");
        require(!isApproved[_txnId][msg.sender], "Transaction already approved by caller");

        isApproved[_txnId][msg.sender] = true;
    }

    function executeTransaction(uint256 _txnId) public {
        require(_txnId < transactions.length, "Transaction does not exist");
        Transaction storage txn = transactions[_txnId];

        require(!txn.executed, "Transaction already executed");
        uint256 count = 0;
        for (uint256 i = 0; i < owners.length; i++) {
            if (isApproved[_txnId][owners[i]]) count++;
        }

        require(count >= requiredApprovals, "Not enough approvals");

        txn.executed = true;
        IERC20(token).transfer(txn.to, txn.value);
    }

}
