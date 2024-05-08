// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Ballot {

    struct Vote {
        address voterAddress;
        bool choice;
    }
    
    struct Voter {
        string voterName;
        bool voted;
    }

    uint256 private countResult = 0;
    uint256 public finalResult = 0;
    uint256 public totalVoter = 0;
    uint256 public totalVote = 0;
    address public ballotOfficialAddress;      
    string public ballotOfficialName;
    string public proposal;
    
    mapping(uint256 => Vote) private votes;
    mapping(address => Voter) public voterRegister;
    
    enum State { Created, Voting, Ended }
	State public state;
	
	// Creates a new ballot contract
	constructor(
        string memory _ballotOfficialName,
        string memory _proposal
    ) {
        ballotOfficialAddress = msg.sender;
        ballotOfficialName = _ballotOfficialName;
        proposal = _proposal;
        
        state = State.Created;
    }
    
    
	modifier condition(bool _condition) {
		require(_condition, "Condition not met");
		_;
	}

	modifier onlyOfficial() {
		require(msg.sender == ballotOfficialAddress, "Not authorized");
		_;
	}

	modifier inState(State _state) {
		require(state == _state, "Invalid state");
		_;
	}

    event VoterAdded(address indexed voter);
    event VoteStarted();
    event VoteEnded(uint256 finalResult);
    event VoteDone(address indexed voter);
    
    // Add voter
    function addVoter(address _voterAddress, string memory _voterName)
        public
        inState(State.Created)
        onlyOfficial
    {
        Voter memory v;
        v.voterName = _voterName;
        v.voted = false;
        voterRegister[_voterAddress] = v;
        totalVoter++;
        emit VoterAdded(_voterAddress);
    }

    // Declare voting starts now
    function startVote()
        public
        inState(State.Created)
        onlyOfficial
    {
        state = State.Voting;     
        emit VoteStarted();
    }

    // Voters vote by indicating their choice (true/false)
    function doVote(bool _choice)
        public
        inState(State.Voting)
        returns (bool voted)
    {
        bool found = false;
        
        if (bytes(voterRegister[msg.sender].voterName).length != 0 
        && !voterRegister[msg.sender].voted){
            voterRegister[msg.sender].voted = true;
            Vote memory v;
            v.voterAddress = msg.sender;
            v.choice = _choice;
            if (_choice){
                countResult++; // Counting on the go
            }
            votes[totalVote] = v;
            totalVote++;
            found = true;
        }
        emit VoteDone(msg.sender);
        return found;
    }
    
    // End votes
    function endVote()
        public
        inState(State.Voting)
        onlyOfficial
    {
        state = State.Ended;
        finalResult = countResult; // Move result from private countResult to public finalResult
        emit VoteEnded(finalResult);
    }
}
