pragma solidity ^0.4.25;
contract Oraclize {
    function getETHSGD() public view returns (uint);
    function getOracleCost() public returns (uint);
}

contract FlightDetails {
    function addAdmin(address admin);
    function removeAdmin(address admin);
    
}

contract FlightDelay{
    // create a struct to store address and loyalty points and bought tickets
    // convert sgd => eth
    // Check against changiairport or something for flight status, delay and cancel.
    // extract ticket data? authenticate ticket?
    // users should be able to getInsuredFlights

    struct Users {
        uint loyaltyPoints;
        uint[] tickets;
    }

    mapping (address => Users) private users;
    Users[] insuredUsers;
    address private SGDoracle;
    address private creator;
    
    constructor(FlightDelay) public {
        creator = msg.sender;
    }

    function updateOracle(address oracleAddress) public {
        require(msg.sender == creator);
        SGDoracle = oracleAddress;
    }

    // answer returned is in Wei.
    // SGD input is in cents.
    function convertToEth(uint SGD) public returns (uint) {
        // SGDoracle.getRate();
        Oraclize oracle = Oraclize(SGDoracle);
        uint rate = oracle.getETHSGD();
        // This rate is in 1 ETH -> rate cents.
        // SGD is in cents.
        
        return SGD*1000000000000000000/rate;
    }

    function buyTicket(uint8 ways) public payable {
        if (ways == 2) {
            // Round trip ticket.
            // Check for 150 loyalty points or 30 sgd
            if (users[msg.sender].loyaltyPoints > 150) {
                users[msg.sender].loyaltyPoints -= 150;
            }
            else {
                // calculate exchange rate, 3000 cents.
                require(msg.value >= convertToEth(3000));
            }
            users[msg.sender].loyaltyPoints += 30;
            // TODO: buy ticket.
        }
        else {
            // Check for 100 loyalty points or 20 sgd, one way ticket.
            if (users[msg.sender].loyaltyPoints > 100) {
                users[msg.sender].loyaltyPoints -= 100;
            }
            else {
                // calculate exchange rate, 3000 cents.
                require(msg.value >= convertToEth(2000));
            }
            users[msg.sender].loyaltyPoints += 10;
            // TODO: buy ticket.
        }
    }
    function claimMoney() public {

    }

    // Current plan is our server queries API then uploads it to a contract which has all the information.
    // When travellers claim, the function will check the record against the contract which has all the information.

}