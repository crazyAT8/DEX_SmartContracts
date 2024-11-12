// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FeeCollector {
    address public owner;
    uint256 public totalFeesCollected;

    // Fee distribution percentages (in basis points, where 10000 = 100%)
    struct Recipient {
        address recipientAddress;
        uint256 percentage;
    }

    Recipient[] public recipients;

    constructor() {
        owner = msg.sender;
    }

    // Modifier to ensure only the owner can call certain functions
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    // Set recipients and their respective percentages (in basis points)
    function setRecipients(address[] memory _recipients, uint256[] memory _percentages) public onlyOwner {
        require(_recipients.length == _percentages.length, "Recipients and percentages length mismatch");
        uint256 totalPercentage = 0;

        // Clear existing recipients
        delete recipients;

        for (uint256 i = 0; i < _recipients.length; i++) {
            require(_percentages[i] > 0, "Percentage must be greater than 0");
            totalPercentage += _percentages[i];
            recipients.push(Recipient(_recipients[i], _percentages[i]));
        }

        require(totalPercentage == 10000, "Total percentage must equal 100%");
    }

    // Function to collect fees
    function collectFee() external payable {
        require(msg.value > 0, "Fee must be greater than zero");
        totalFeesCollected += msg.value;
    }

    // Distribute collected fees to recipients based on their percentages
    function distributeFees() public onlyOwner {
        require(totalFeesCollected > 0, "No fees collected");

        uint256 amountToDistribute = totalFeesCollected;

        for (uint256 i = 0; i < recipients.length; i++) {
            uint256 recipientAmount = (amountToDistribute * recipients[i].percentage) / 10000;
            payable(recipients[i].recipientAddress).transfer(recipientAmount);
        }

        totalFeesCollected = 0;
    }

    // Withdraw any remaining funds in the contract
    function withdrawRemaining() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    // Fallback function to receive ETH directly
    receive() external payable {
        totalFeesCollected += msg.value;
    }
}
