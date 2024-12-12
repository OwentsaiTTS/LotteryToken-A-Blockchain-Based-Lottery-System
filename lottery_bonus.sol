// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface ERC20Interface {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function transfer(address to, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
}

contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        require(a + b >= a, "SafeMath: addition overflow");
        return a + b;
    }

    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function safeMul(uint a, uint b) public pure returns (uint c) {
        require(a == 0 || a * b / a == b, "SafeMath: multiplication overflow");
        return a * b;
    }

    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }
}

contract LotteryToken is ERC20Interface, SafeMath {
    struct Ticket {
        address player;
        uint[3] numbers;
    }

    string public name = "LotteryToken";
    string public symbol = "LTT";
    uint8 public decimals = 0;  // Assuming no decimals for simplicity in lottery
    uint256 public _totalSupply = 1000000;
    mapping(address => uint256) public balances;
    mapping(address => uint) lastClaimed;   
    address public contractCreator;
    uint public jackpot;
    address[] public players;
    address public winner;
    uint public lastDrawTime;
    uint public ticketPrice = 100;
    uint public rewardPercentage = 90;
    Ticket[] public tickets;


    constructor() {
        contractCreator = msg.sender;
        jackpot = 0;
        balances[contractCreator] = _totalSupply;
        emit Transfer(address(0), contractCreator, _totalSupply);
    }

    function totalSupply() public view override returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address tokenOwner) public view override returns (uint balance) {
        return balances[tokenOwner];
    }

    function transfer(address to, uint tokens) public override returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public override returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
    
    function faucet() public {
        // Creator cannot claim tokens for themselves
        require(msg.sender != contractCreator, "Contract creator cannot claim tokens for themselves.");
        // Can only claim once every 30 seconds
        require(block.timestamp - lastClaimed[msg.sender] >= 30 seconds, "You can only claim once every 30 seconds.");
        uint tokens = 500;
        // Insufficient tokens in the faucet
        require(balances[contractCreator] >= tokens, "Insufficient tokens in the faucet.");

        lastClaimed[msg.sender] = block.timestamp;
        transferFrom(contractCreator, msg.sender, tokens);
        // Transfer tokens from contractCreator to msg.sender (token claimer)
        emit Transfer(contractCreator, msg.sender, tokens);
    }

    function random() public view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender)));
    }

    function buyTicket(uint number1, uint number2, uint number3) public {
        uint[3] memory numbers = [number1, number2, number3];
        require(balanceOf(msg.sender) >= ticketPrice, "Insufficient tokens to buy tickets.");
        require(isUniqueNumbers(numbers), "Numbers must be unique and within 1 to 46");     // Ensure the three numbers are unique

        // Split the ticket price
        uint prizeContribution = safeMul(ticketPrice, rewardPercentage) / 100;     // Contribution to the prize pool (90%)
        
        jackpot = safeAdd(jackpot, prizeContribution);     // Add to the prize pool
        transfer(contractCreator, ticketPrice);            // Transfer all tokens to the contract creator, who will distribute to the winners

        tickets.push(Ticket({
            player: msg.sender,
            numbers: numbers
        }));

        players.push(msg.sender);
    }

    function draw() public {
        require(msg.sender == contractCreator, "Only the banker can draw.");
        require(lastDrawTime + 2 minutes < block.timestamp, "Draw can only be called once every 2 minutes.");
        require(tickets.length > 0, "No tickets sold");

        uint[3] memory winningNumbers = generateWinningNumbers();      // Draw three winning numbers
        address[] memory winners = determineWinners(winningNumbers);   // Determine the winners

        if (winners.length > 0) {     // If there are winners, distribute the prize
            uint prize = safeDiv(jackpot, winners.length);
            for (uint i = 0; i < winners.length; i++) {
                transfer(winners[i], prize);
            }
            jackpot = 0;     // Reset the prize pool
        }
        
        lastDrawTime = block.timestamp;
        delete tickets;
    }

    // Check that the three numbers are unique
    function isUniqueNumbers(uint[3] memory numbers) private pure returns (bool) {
        return numbers[0] != numbers[1] && numbers[0] != numbers[2] && numbers[1] != numbers[2]
            && validRange(numbers[0]) && validRange(numbers[1]) && validRange(numbers[2]);
    }

    // Ensure the numbers are within the range [1, 46]
    function validRange(uint number) private pure returns (bool) {
        return number >= 1 && number <= 46;
    }

    // Generate three winning numbers
    function generateWinningNumbers() private view returns (uint[3] memory numbers) {
        numbers[0] = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, tickets.length))) % 46 + 1;
        do {
            numbers[1] = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, numbers[0]))) % 46 + 1;
        } while (numbers[1] == numbers[0]);
        do {
            numbers[2] = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, numbers[1]))) % 46 + 1;
        } while (numbers[2] == numbers[0] || numbers[2] == numbers[1]);
        
        return numbers;
    }

    // Check if the numbers match to determine winners
    function determineWinners(uint[3] memory winningNumbers) private view returns (address[] memory) {
        address[] memory tempWinners = new address[](tickets.length);
        uint count = 0;
        for (uint i = 0; i < tickets.length; i++) {
            if (compareNumbers(tickets[i].numbers, winningNumbers)) {
                tempWinners[count] = tickets[i].player;
                count++;
            }
        }
        address[] memory winners = new address[](count);
        for (uint i = 0; i < count; i++) {
            winners[i] = tempWinners[i];
        }
        return winners;
    }

    function compareNumbers(uint[3] memory a, uint[3] memory b) private pure returns (bool) {
        return (a[0] == b[0] || a[0] == b[1] || a[0] == b[2]) &&
               (a[1] == b[0] || a[1] == b[1] || a[1] == b[2]) &&
               (a[2] == b[0] || a[2] == b[1] || a[2] == b[2]);
    }

    function getAllPlayers() public view returns (address[] memory) {
        return players;
    }
}
