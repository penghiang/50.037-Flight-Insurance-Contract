pragma solidity ^0.4.25;
contract Oraclize {
    function getETHSGD() public view returns (uint);
    function getOracleCost() public returns (uint);
    function updatePrice() public payable;
    function updateOracleCost() public returns (uint);
}

contract FlightDetails {
    function flightCancelled(string flightNumber, string departureDate, string from);
    function flightDelayed(string flightNumber, string departureDate, string from);
    function addUser(string flightNumber, string departureDate, string from, address user);
    function claim(string flightNumber, string departureDate, string from, address user) returns (uint);
    function _confirmClaim(string flightNumber, string departureDate, string from, address user, uint amount);
    function flightFlown(string flightNumber, string departureDate, string from) public returns (bool);
}

contract FlightDelay{
    // create a struct to store address and loyalty points and bought tickets
    // Check against changiairport or something for flight status, delay and cancel.
    // extract ticket data? authenticate ticket?

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

    // These 2 functions are only to be used by the creator of this contract.
    // We are able to change the contracts of the oracle and flightdetails if required.
    // These should be run during initialisation.
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

    // Buys ticket with provided values.
    function buyTicket(string flightNumber, string departureDate, string from, bool points) public payable {
        if (points && users[msg.sender].loyaltyPoints > 100) {
            users[msg.sender].loyaltyPoints -= 100;
        }
        else {
            // calculate exchange rate, 2000 cents.
            require(msg.value >= convertToWei(2000));
        }
        users[msg.sender].loyaltyPoints += 10;
        _buyTicket(flightNumber, departureDate, from, msg.sender);
    }


    // Buys 2 way ticket with provided values.
    function buyTicket2(string flightNumber, string departureDate, string from, string flightNumber2, string departureDate2, string from2, bool points) public payable {
        if (points && users[msg.sender].loyaltyPoints > 150) {
                users[msg.sender].loyaltyPoints -= 150;
        }
        else {
            // calculate exchange rate, 3000 cents.
            require(msg.value >= convertToWei(3000));
        }
        users[msg.sender].loyaltyPoints += 30;
        _buyTicket(flightNumber, departureDate, from, msg.sender);
        _buyTicket(flightNumber2, departureDate2, from2, msg.sender);
    }

    // Updates the oracle's conversion rate and cost
    // Updates FlightDetails with user information.
    // Adds tickets to users list, which we can display later.
    function _buyTicket(string flightNumber, string departureDate, string from, address user) public payable{
        
        FlightDetails flightdetails = FlightDetails(flightDetails);
        Oraclize oracle = Oraclize(SGDoracle);

        require(!flightdetails.flightFlown(flightNumber, departureDate, from));

        uint oracleCost = oracle.getOracleCost();
        
        // We run both updatePrice and updateOracleCost to be updated. 
        // This function sends money to the oracle so it would be topped up to use Oraclize.
        oracle.updatePrice.value(oracleCost)();
        oracle.updateOracleCost();

        flightdetails.addUser(flightNumber, departureDate, from, user);
        users[user].tickets.push(string(abi.encodePacked(flightNumber, "|", departureDate, "|", from)));
    }

    // Uses msg.sender as address
    // First checks the amount of money user is entitled to, then transfers the amount.
    // _confirmClaim is run after .transfer in case this contract doesn't have enough money to transfer.
    function claimMoney(string flightNumber, string departureDate, string from) public returns (uint){
        FlightDetails flightdetails = FlightDetails(flightDetails);
        
        uint amount = flightdetails.claim(flightNumber, departureDate, from, msg.sender);
        // amount is in SGD (cents)
        uint amountWei = convertToWei(amount);

        flightdetails._confirmClaim(flightNumber, departureDate, from, msg.sender, amount);
        msg.sender.transfer(amountWei);
        return amountWei;
    }

    // Allows the user to see his most recent ticket purchase.
    function getRecentTicket(address user) view public returns (string){
        string[] usertickets = users[user].tickets;
        if (usertickets.length > 0) {
            return usertickets[usertickets.length - 1];
        }
        return "";
    }

    function getRecentTicketSelf() view public returns (string){
        return users[msg.sender].tickets[users[msg.sender].tickets.length - 1];
    }

    // Same as getRecentTicket but has another input. 
    // Input should be 1 for the most recent ticket, 2 for the second most recent...
    function getRecentTickets(address user, uint ticketNumber) view public returns (string) {
        require(ticketNumber > 0);
        return users[user].tickets[users[user].tickets.length - ticketNumber];
    }

    function getLoyaltyPoints() view public returns (uint) {
        return users[msg.sender].loyaltyPoints;
    }

    // This fallback function can be used to top up money.
    function () payable public {}
}