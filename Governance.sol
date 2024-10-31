// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Governance {
    struct Proposal {
        uint id;
        address proposer;
        string description;
        uint voteCount;
        uint deadline;
        bool executed;
    }

    mapping(uint => Proposal) public proposals;
    mapping(address => bool) public voters;
    mapping(uint => mapping(address => bool)) public votes;
    uint public proposalCount;
    uint public proposalDuration = 3 days;
    uint public minimumVotesRequired = 3;

    event ProposalCreated(uint id, address proposer, string description, uint deadline);
    event VoteCast(uint proposalId, address voter);
    event ProposalExecuted(uint id, bool success);

    modifier onlyVoter() {
        require(voters[msg.sender], "Not a registered voter");
        _;
    }

    constructor(address[] memory _voters) {
        for (uint i = 0; i < _voters.length; i++) {
            voters[_voters[i]] = true;
        }
    }

    function createProposal(string memory _description) public onlyVoter {
        proposalCount++;
        proposals[proposalCount] = Proposal({
            id: proposalCount,
            proposer: msg.sender,
            description: _description,
            voteCount: 0,
            deadline: block.timestamp + proposalDuration,
            executed: false
        });

        emit ProposalCreated(proposalCount, msg.sender, _description, proposals[proposalCount].deadline);
    }

    function vote(uint _proposalId) public onlyVoter {
        Proposal storage proposal = proposals[_proposalId];
        
        require(block.timestamp < proposal.deadline, "Voting period ended");
        require(!votes[_proposalId][msg.sender], "Already voted");

        votes[_proposalId][msg.sender] = true;
        proposal.voteCount++;

        emit VoteCast(_proposalId, msg.sender);
    }

    function executeProposal(uint _proposalId) public {
        Proposal storage proposal = proposals[_proposalId];
        
        require(block.timestamp >= proposal.deadline, "Voting period not ended");
        require(!proposal.executed, "Proposal already executed");
        require(proposal.voteCount >= minimumVotesRequired, "Not enough votes");

        proposal.executed = true;
        // Place execution logic here (e.g., transferring funds, changing parameters, etc.)

        emit ProposalExecuted(_proposalId, true);
    }
}
