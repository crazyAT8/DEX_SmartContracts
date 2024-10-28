// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interface for ContractA
interface IContractA {
    function deposit() external payable;
}

// Interface for ContractB
interface IContractB {
    function deposit() external payable;
}

contract Router {

    // Addresses of ContractA and ContractB
    address public contractA;
    address public contractB;

    // Event for logging deposit action
    event Deposit(address indexed user, uint256 amount, string destination);

    // Constructor to initialize the addresses of ContractA and ContractB
    constructor(address _contractA, address _contractB) {
        contractA = _contractA;
        contractB = _contractB;
    }

    // Function to deposit to ContractA
    function depositToA() external payable {
        require(msg.value > 0, "Must send some Ether");
        
        // Interact with ContractA's deposit function
        IContractA(contractA).deposit{value: msg.value}();
        
        emit Deposit(msg.sender, msg.value, "ContractA");
    }

    // Function to deposit to ContractB
    function depositToB() external payable {
        require(msg.value > 0, "Must send some Ether");
        
        // Interact with ContractB's deposit function
        IContractB(contractB).deposit{value: msg.value}();
        
        emit Deposit(msg.sender, msg.value, "ContractB");
    }

    // Function to change ContractA's address
    function setContractA(address _contractA) external {
        contractA = _contractA;
    }

    // Function to change ContractB's address
    function setContractB(address _contractB) external {
        contractB = _contractB;
    }

    // Fallback function to prevent accidental transfers
    fallback() external payable {
        revert("Please use the depositToA or depositToB functions");
    }
}
