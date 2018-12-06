function APIQuery(){

}
var API_KEY = "ckjvam4eakgru7feehf3v3aj";
var API_link = "https://apigw.singaporeair.com/api/v3/flightstatus/getbynumber";
var data = {
    "request":{
      "airlineCode":"SQ",
      "flightNumber":"938",
      "originAirportCode":"SIN",
      "scheduledDepartureDate":"2018-11-27",
      "destinationAirportCode":"",
      "scheduledArrivalDate":""
    },
    "clientUUID":"SIA_query"
  }

  /*
 * This is a JavaScript Scratchpad.
 *
 * Enter some JavaScript, then Right Click or choose from the Execute Menu:
 * 1. Run to evaluate the selected text (Ctrl+R),
 * 2. Inspect to bring up an Object Inspector on the result (Ctrl+I), or,
 * 3. Display to insert the result in a comment after the selection. (Ctrl+L)
 */

var data = {
    'request': {
      'airlineCode': 'SQ',
      'flightNumber': '938',
      'originAirportCode': 'SIN',
      'scheduledDepartureDate': '2018-11-27',
      'destinationAirportCode': '',
      'scheduledArrivalDate': ''
    },
    'clientUUID': 'TestIODocs'
  };
  data["request"]["airlineCode"] = "ggp";
  console.log(data["request"]["airlineCode"]);
  
  var flightnum = document.getElementById("claimflightnum").value;
  var date = document.getElementById("claimdepartdate").value;
  var from = document.getElementById("claimdap").value.toUpperCase() ;
  
  var airlinecode = flightnum.substring(0, 2).toUpperCase();
  var flightnumber = flightnum.substr(2);
  console.log(airlinecode);
  