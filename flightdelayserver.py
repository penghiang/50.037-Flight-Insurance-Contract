from solc import compile_source
from web3.auto import w3

import json
import requests
from datetime import datetime

from flask import Flask, render_template, request

app = Flask(__name__)

contract_source_code = None
contract_source_code_file = 'FlightDetails.sol'

with open(contract_source_code_file, 'r') as file:
    contract_source_code = file.read()

# Compile FlightDetails
contract_compiled = compile_source(contract_source_code)
interfaceDetails = contract_compiled['<stdin>:FlightDetails']

# Compile FlightDelay
contract_source_code_file = 'flightdelay.sol'
with open(contract_source_code_file, "r") as file:
    contract_source_code = file.read()

contract_compiled = compile_source(contract_source_code)
interfaceDelay = contract_compiled['<stdin>:FlightDelay']

# Compile Oracle
contract_source_code_file = 'converter.sol'
with open(contract_source_code_file, "r") as file:
    contract_source_code = file.read()

contract_compiled = compile_source(contract_source_code)
interfaceOracle = contract_compiled['<stdin>:Oraclize']


# Set the default account
w3.eth.defaultAccount = w3.eth.accounts[2]

# Contract abstraction
DetailsAbstraction = w3.eth.contract(abi=interfaceDetails['abi'], bytecode=interfaceDetails['bin'])
DelayAbstraction = w3.eth.contract(abi=interfaceDelay['abi'], bytecode=interfaceDelay['bin'])
OracleAbstraction = w3.eth.contract(abi=interfaceOracle['abi'], bytecode=interfaceOracle['bin'])

# Create an instance, i.e., deploy on the blockchain
tx_hash = DetailsAbstraction.constructor().transact()
tx_hash2 = DelayAbstraction.constructor().transact({"value": w3.toWei(35, "ether")})
tx_hash3 = OracleAbstraction.constructor().transact({"value": w3.toWei(1, "ether")})

DetailsReceipt = w3.eth.waitForTransactionReceipt(tx_hash)
DelayReceipt = w3.eth.waitForTransactionReceipt(tx_hash2)
OracleReceipt = w3.eth.waitForTransactionReceipt(tx_hash3)


# Contract Object
DetailsContract = w3.eth.contract(address=DetailsReceipt.contractAddress, abi=interfaceDetails['abi'])
DelayContract = w3.eth.contract(address=DelayReceipt.contractAddress, abi=interfaceDelay['abi'])
OracleContract = w3.eth.contract(address=OracleReceipt.contractAddress, abi=interfaceOracle['abi'])
# contract_address = "0x2B6329Ee49Cfe81c6ce80e81A9eD3eE54ae9A424"
# example = w3.eth.contract(contract_address, abi=interface_FlightDetails['abi'])

# Initialisation, we have to link the contracts with each other's addresses.
# We also have to run .addAdmin of FlightDetails so that FlightDelay can execute claims.
DelayContract.functions.updateOracle(OracleReceipt.contractAddress).transact()
DelayContract.functions.updateFlightDetails(DetailsReceipt.contractAddress).transact()
DetailsContract.functions.addAdmin(DelayReceipt.contractAddress).transact()

# Just for testing purposes:
w3.eth.sendTransaction({"to":"0xe48AEcF573F7D65038C274b97AA9979D73Eb4c7B", "from": w3.eth.accounts[9], "value": w3.toWei("5", "ether")})

# # Query SIA API
# from threading import Thread
# from time import time

# API_KEY = "ckjvam4eakgru7feehf3v3aj"
# class Query(Thread):
#     def __init__():




@app.route("/")
def home():
    return render_template('template.html', contractAddress = DelayContract.address.lower(), contractABI = json.dumps(interfaceDelay['abi']))

@app.route("/index")
def index():
    return render_template(
        'landingpage.html',
        contractAddress = DelayContract.address.lower(), 
        contractABI = json.dumps(interfaceDelay['abi']),
        contractAddressDetails = DetailsContract.address.lower(),
        contractABIDetails = json.dumps(interfaceDetails['abi']),
        contractAddressOracle = OracleContract.address.lower(),
        contractABIOracle = json.dumps(interfaceOracle['abi'])
    )

@app.route("/buy")
def buy():
    return render_template(
        'buytickets.html',
        contractAddress = DelayContract.address.lower(), 
        contractABI = json.dumps(interfaceDelay['abi']),
        contractAddressDetails = DetailsContract.address.lower(),
        contractABIDetails = json.dumps(interfaceDetails['abi']),
        contractAddressOracle = OracleContract.address.lower(),
        contractABIOracle = json.dumps(interfaceOracle['abi'])
    )

@app.route("/main")
def mainpage():
    return render_template(
        'mainpage.html',
        contractAddress = DelayContract.address.lower(), 
        contractABI = json.dumps(interfaceDelay['abi']),
        contractAddressDetails = DetailsContract.address.lower(),
        contractABIDetails = json.dumps(interfaceDetails['abi']),
        contractAddressOracle = OracleContract.address.lower(),
        contractABIOracle = json.dumps(interfaceOracle['abi'])
    )

@app.route("/sia_query", methods=["POST"])
def sia_query():
    API_KEY = "ckjvam4eakgru7feehf3v3aj"
    API_link = "https://apigw.singaporeair.com/api/v3/flightstatus/getbynumber"

    data = {
        "request":{
            "airline": ""
        },
        "clientUUID":"client1"
    }

    airlinecode = ""
    flightnumber = ""
    origin = ""
    date = ""
    
    try:
        airlinecode = request.json["airline"]
        flightnumber = request.json["flightnum"]
        origin = request.json["origin"]
        date = request.json["date"]
    except KeyError:
        print("exception")
    data["request"]["airlineCode"] = airlinecode
    data["request"]["flightNumber"] = flightnumber
    data["request"]["originAirportCode"] = origin
    data["request"]["scheduledDepartureDate"] = date

    r = requests.post(API_link, data=str(data), headers={"apikey":API_KEY, "content-type": "application/json"})
    # check the result time if time is good or bad or wtv

    results = r.json()
    if (results["status"] == "SUCCESS"):
        leg = results["response"]["flights"][0]["legs"][0]

        if(leg["flightStatus"].lower() == "cancelled"):
            return "cancelled"
        if(leg["flightStatus"].lower() == "delayed"):
            return "delayed"
            
        datetimeformat = "%Y-%m-%dT%H:%M"
        scheduled_dt = datetime.strptime(leg["scheduledArrivalTime"], datetimeformat)
        try:
            actual_dt = datetime.strptime(leg["actualArrivalTime"], datetimeformat)
        except KeyError:
            return "no actualArrivalTime"

        diff = actual_dt - scheduled_dt
        if (diff.total_seconds() > 3600):
            # 1 hour delay
            return "delayed"
        return ""
    return "failed"
    # print(r.text)
    # return r.text
    # return r.json()


if __name__ == "__main__":
    app.run()









# # print('addUser:', DetailsContract.functions.addUser("123", "today", "here", w3.eth.accounts[1]).transact())
# # DetailsContract.functions.flightCancelled("123", "today", "here").transact()
# # print(DetailsContract.functions.claim("123", "today", "here", w3.eth.accounts[1]).call())

# amount = DelayContract.functions.convertToWei(3000).call()
# # amount = w3.toWei(1, "ether")
# print(amount)
# amount = DelayContract.functions.convertToWei(2000).call()
# print(amount)

# DelayContract.functions.buyTicket("123", "today", "here").transact({"value": amount})

# print(DelayContract.functions.getRecentTicket(w3.eth.defaultAccount).call())

# # import time
# # time.sleep(1)

# amount = DelayContract.functions.convertToWei(3000).call()
# DelayContract.functions.buyTicket("123", "yestoday", "there").transact({"value": amount})
# print(DelayContract.functions.getRecentTicket(w3.eth.defaultAccount).call())

# DetailsContract.functions.flightCancelled("123", "today", "here").transact()
# DelayContract.functions.claimMoney("123", "yestoday", "there").transact()

# # time.sleep(2)

# DelayContract.functions.claimMoney("123", "today", "here").transact()

# # Claim money works, we might need to change the code of updating the oracle to transact or call or whatever.