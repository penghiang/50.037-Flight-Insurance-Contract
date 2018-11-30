pragma solidity ^0.4.25;
contract Oraclize {
    function getETHSGD() public view returns (uint);
    function getOracleCost() public returns (uint);
}

contract FlightDetails {
    function flightCancelled(string flightNumber, string departureDate, string from);
    function flightDelayed(string flightNumber, string departureDate, string from);
    function addUser(string flightNumber, string departureDate, string from, address user);
    function claim(string flightNumber, string departureDate, string from, address user) returns (uint);
    function _confirmClaim(string flightNumber, string departureDate, string from, address user, uint amount);
}

contract FlightDelay{
    // create a struct to store address and loyalty points and bought tickets
    // convert sgd => eth
    // Check against changiairport or something for flight status, delay and cancel.
    // extract ticket data? authenticate ticket?
    // users should be able to getInsuredFlights

    struct Users {
        uint loyaltyPoints;
        string[] tickets;
    }

    mapping (address => Users) private users;
    Users[] insuredUsers;
    address private SGDoracle;
    address private flightDetails;
    address private creator;
    
    constructor() payable public {
        creator = msg.sender;
    }

    function updateOracle(address oracleAddress) public {
        require(msg.sender == creator);
        SGDoracle = oracleAddress;
    }

    function updateFlightDetails(address flightDetailsAddress) public {
        require(msg.sender == creator);
        flightDetails = flightDetailsAddress;
    }

    // answer returned is in Wei.
    // SGD input is in cents.
    function convertToWei(uint SGD) public returns (uint) {
        // SGDoracle.getRate();
        Oraclize oracle = Oraclize(SGDoracle);
        uint rate = oracle.getETHSGD();
        // This rate is in 1 ETH -> rate cents.
        // SGD is in cents.
        return SGD*1000000000000000000/rate;
    }

    function buyTicket(uint8 ways, string flightNumber, string departureDate, string from) public payable {
        FlightDetails flightdetails = FlightDetails(flightDetails);
        if (ways == 2) {
            // Round trip ticket.
            // Check for 150 loyalty points or 30 sgd
            // TODO: allow another destination, since it's a round trip ticket.
            if (users[msg.sender].loyaltyPoints > 150) {
                users[msg.sender].loyaltyPoints -= 150;
            }
            else {
                // calculate exchange rate, 3000 cents.
                require(msg.value >= convertToWei(3000));
            }
            users[msg.sender].loyaltyPoints += 30;
            flightdetails.addUser(flightNumber, departureDate, from, msg.sender);
            users[msg.sender].tickets.push(string(abi.encodePacked(flightNumber, departureDate, from)));
            // TODO: buy ticket.
        }
        else {
            // Check for 100 loyalty points or 20 sgd, one way ticket.
            if (users[msg.sender].loyaltyPoints > 100) {
                users[msg.sender].loyaltyPoints -= 100;
            }
            else {
                // convertToWei works from outside when called.
                require(msg.value >= convertToWei(2000));
            }
            users[msg.sender].loyaltyPoints += 10;
            flightdetails.addUser(flightNumber, departureDate, from, msg.sender);
            users[msg.sender].tickets.push(string(abi.encodePacked(flightNumber, departureDate, from)));
            // TODO: buy ticket.
        }
    }
    function claimMoney(string flightNumber, string departureDate, string from) public {
        FlightDetails flightdetails = FlightDetails(flightDetails);
        
        uint amount = flightdetails.claim(flightNumber, departureDate, from, msg.sender);
        // amount is in SGD (cents)
        uint amountWei = convertToWei(amount);

        flightdetails._confirmClaim(flightNumber, departureDate, from, msg.sender, amount);
        msg.sender.transfer(amountWei);
    }

    function getRecentTicket(address user) view public returns (string){
        return users[user].tickets[users[user].tickets.length - 1];
        // return users[user].tickets[0];
    }

    function getRecentTicketSelf() view public returns (string){
        return users[msg.sender].tickets[users[msg.sender].tickets.length - 1];
        // return users[msg.sender].tickets[0];
    }

    // Current plan is our server queries API then uploads it to a contract which has all the information.
    // When travellers claim, the function will check the record against the contract which has all the information.
}