pragma solidity ^0.4.25;
contract Oraclize{
    uint ETHSGD = 16362;
    // This is in cents.
    constructor() payable public {}

    function getOracleCost() public returns (uint) {
       return 4027700000000000;
    }

    function getETHSGD() public view returns (uint){
        return ETHSGD;
    }

    // remember to call updatePrice and updateOracleCost.
    function updatePrice() payable {
        uint cost = getOracleCost();
        require(address(this).balance >= cost);
        // We do not usually send the cost back, but in this testing code we are just sending it to an address.
        msg.sender.transfer(cost);
    }
    
    function updateOracleCost() public returns (uint) {
        return 1;
    }
}


// pragma solidity ^0.4.11;
// import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

// contract ExampleContract is usingOraclize {

//     uint public ETHSGD;
//     // uint public WEISGD;
//     uint public oracleCost;
//     event LogConstructorInitiated(string nextStep);
//     event LogPriceUpdated(string price);
//     event LogNewOraclizeQuery(string description);

//     function ExampleContract() payable {
//        emit LogConstructorInitiated("Constructor was initiated. Call 'updatePrice()' to send the Oraclize Query.");
//     }
   
//     function __callback(bytes32 myid, string result) {
//        if (msg.sender != oraclize_cbAddress()) revert();
//     //   ETHSGD = result;
//     //   WEISGD = parseInt(result, 18);
//        ETHSGD = parseInt(result, 2);
//        emit LogPriceUpdated(result);
//     }

//     function updatePrice() payable {
//         require(msg.value >= oracleCost/10*9);
//         if (oraclize_getPrice("URL") > address(this).balance) {
//             emit LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
//         } else {
//             emit LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
//             oraclize_query("URL", "json(https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=SGD).SGD");
//         }
//     }
    
//     function updateOracleCost() public returns (uint) {
//         oracleCost = oraclize_getPrice("URL");
//         return oracleCost;
//     }
    
//     // function getWEISGD() public view returns (uint) {
//     //     return WEISGD;
//     // }
    
//     function getETHSGD() public view returns (uint) {
//         return ETHSGD;
//     }
    
//     function getOracleCost() public view returns (uint) {
//         return oracleCost;
//     }
    
//     function clearOracleCost() {
//         oracleCost = 0;
//     }

//     function topUp() public payable {
        
//     }
   

// } 
// we can run updateprice every hour.
// api key might be needed for cryptocompare.com
// we can use .listen to listen every hour.
// not sure about the payment to oraclize
// we run update and pay, so we are paying the previous oracle's cost. 

// To calculate how much sgd to usd is, we can use oraclize to convert. 
// Using the frontend, we can update the value with a listener.
// The backend (server) should query for the updated sgd value every day.
// 
// https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=SGD
// https://min-api.cryptocompare.com/documentation



// pragma solidity ^0.4.11;
// import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

// contract ExampleContract is usingOraclize {

//     uint public ETHSGD;
//     // uint public WEISGD;
//     uint public oracleCost;
//     event LogConstructorInitiated(string nextStep);
//     event LogPriceUpdated(string price);
//     event LogNewOraclizeQuery(string description);

//     function ExampleContract() payable {
//        emit LogConstructorInitiated("Constructor was initiated. Call 'updatePrice()' to send the Oraclize Query.");
//     }
   
//     function __callback(bytes32 myid, string result) {
//        if (msg.sender != oraclize_cbAddress()) revert();
//     //   ETHSGD = result;
//     //   WEISGD = parseInt(result, 18);
//        ETHSGD = parseInt(result, 2);
//        emit LogPriceUpdated(result);
//     }

//     function updatePrice() payable {
//         require(msg.value >= oracleCost/10*9);
//         if (oraclize_getPrice("URL") > address(this).balance) {
//             emit LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
//         } else {
//             emit LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
//             oraclize_query("URL", "json(https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=SGD).SGD");
//         } 
//     }
    
//     function updateOracleCost() public returns (uint) {
//         oracleCost = oraclize_getPrice("URL");
//         return oracleCost;
//     }
    
//     // function getWEISGD() public view returns (uint) {
//     //     return WEISGD;
//     // }
    
//     function getETHSGD() public view returns (uint) {
//         return ETHSGD;
//     }
    
//     function getOracleCost() public view returns (uint) {
//         return oracleCost;
//     }
    
//     function clearOracleCost() {
//         oracleCost = 0;
//     }

//     function topUp() public payable {
        
//     }
   

// } 