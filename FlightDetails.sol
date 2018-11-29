pragma solidity ^0.4.25;
contract FlightDetails {
    struct Flight {
        mapping (address => uint8) users;
        // This mapping checks if users have claimed their delayed insurance.
        // 1 is bought, 2 is delayed, 3 is cancelled.
        bool delayed;
        bool cancelled;
    }
    // The mapping should be [flightNumber][departureDate][from]
    mapping (string => mapping (string => mapping(string => Flight))) private flights;

    mapping (address => bool) private admins;
    address private creator;

    constructor() public {
        creator = msg.sender;
        admins[creator] = true;
    }

    function addAdmin(address admin) {
        require(creator == msg.sender);
        admins[admin] = true;
    }

    function removeAdmin(address admin) {
        require(creator == msg.sender);
        admins[admin] = false;
    }

    function flightCancelled(string flightNumber, string departureDate, string from){
        require(admins[msg.sender]);
        flights[flightNumber][departureDate][from].cancelled = true;
    }

    function flightDelayed(string flightNumber, string departureDate, string from){
        require(admins[msg.sender]);
        flights[flightNumber][departureDate][from].delayed = true;
    }

    function addUser(string flightNumber, string departureDate, string from, address user){
        require(admins[msg.sender]);
        flights[flightNumber][departureDate][from].users[user] = 1;
    }

    // Returns SGD in cents.
    // This function should be called instead of transacted.
    function claim(string flightNumber, string departureDate, string from, address user) returns (uint){
        // How do i make sure that the user is who he claims to be?
        // Claiming is good, people can help other people claim.
        Flight flight = flights[flightNumber][departureDate][from];
        if (flight.cancelled) {
            if(flight.users[user] == 1) {
                return 500000;
            }
            else if (flight.users[user] == 2){
                return 480000;
            }
        }
        else if (flight.delayed) {
            if(flight.users[user] == 1){
                return 20000;
            }
        }
        return 0;
    }

    // This function should be transacted from the other contract.
    // We might need to add the contract to admins
    function _confirmClaim(string flightNumber, string departureDate, string from, address user, uint amount) {
        require(admins[msg.sender]);
        if (amount == 500000 || amount == 480000) {
            flights[flightNumber][departureDate][from].users[user] = 3;
        }
        else if (amount == 20000) {
            flights[flightNumber][departureDate][from].users[user] = 2;
        }
    }

}