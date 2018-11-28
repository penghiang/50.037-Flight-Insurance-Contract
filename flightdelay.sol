pragma solidity ^0.4.25;
contract oraclize {
    function getETHSGD() public view returns (uint);
    function getOracleCost() public returns (uint);
}

contract FlightDelay{
    // create a struct to store address and loyalty points and bought tickets
    // convert sgd => eth
    // Check against changiairport or something for flight status, delay and cancel.
    // extract ticket data? authenticate ticket?

    struct Users {
        address addr;
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
        oraclize oracle = oraclize(SGDoracle);
        uint rate = oracle.getETHSGD();
        // This rate is in 1 ETH -> rate cents.
        // SGD is in cents.
        
        return SGD*1000000000000000000/rate;
    }

    function buyTicket(uint8 ways) public payable {
        if (users[msg.sender].addr == 0) {
            // this is a new user
            users[msg.sender].addr = msg.sender;
            // no point finding out whether it is a new user...
        }
        if (ways == 2) {
            // Check for 150 loyalty points or 30 sgd
            if (users[msg.sender].loyaltyPoints > 150) {
                users[msg.sender].loyaltyPoints -= 150;
            }
            else {
                // calculate exchange rate
                require(msg.value >= 30);

            }
        }
        else {
            // Check for 100 loyalty points or 20 sgd, one way ticket.
        }
    }
    // To calculate how much sgd to usd is, we can use oraclize to convert. 
    // Using the frontend, we can update the value with a listener.
    // The backend (server) should query for the updated sgd value every day.
    // 
    // https://poloniex.com/support/api/
    // https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=SGD
    // https://min-api.cryptocompare.com/documentation

    // function oracle(){

    // }
}