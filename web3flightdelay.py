from solc import compile_source
from web3.auto import w3
from web3 import Web3

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
w3.eth.defaultAccount = w3.eth.accounts[3]

# Contract abstraction
DetailsAbstraction = w3.eth.contract(abi=interfaceDetails['abi'], bytecode=interfaceDetails['bin'])
DelayAbstraction = w3.eth.contract(abi=interfaceDelay['abi'], bytecode=interfaceDelay['bin'])
OracleAbstraction = w3.eth.contract(abi=interfaceOracle['abi'], bytecode=interfaceOracle['bin'])

# Create an instance, i.e., deploy on the blockchain
tx_hash = DetailsAbstraction.constructor().transact()
DetailsReceipt = w3.eth.waitForTransactionReceipt(tx_hash)

tx_hash2 = DelayAbstraction.constructor().transact({"value": w3.toWei(35, "ether")})
DelayReceipt = w3.eth.waitForTransactionReceipt(tx_hash2)

tx_hash3 = OracleAbstraction.constructor().transact()
OracleReceipt = w3.eth.waitForTransactionReceipt(tx_hash3)

# Contract Object
DetailsContract = w3.eth.contract(address=DetailsReceipt.contractAddress, abi=interfaceDetails['abi'])
DelayContract = w3.eth.contract(address=DelayReceipt.contractAddress, abi=interfaceDelay['abi'])
OracleContract = w3.eth.contract(address=OracleReceipt.contractAddress, abi=interfaceOracle['abi'])
# contract_address = "0x2B6329Ee49Cfe81c6ce80e81A9eD3eE54ae9A424"
# example = w3.eth.contract(contract_address, abi=interface_FlightDetails['abi'])

# print('Calling contracts functions')
# print('Contract address: ', example.address)

DelayContract.functions.updateOracle(OracleReceipt.contractAddress).transact()
DelayContract.functions.updateFlightDetails(DetailsReceipt.contractAddress).transact()
DetailsContract.functions.addAdmin(DelayReceipt.contractAddress).transact()

# print('addUser:', DetailsContract.functions.addUser("123", "today", "here", w3.eth.accounts[1]).transact())
# DetailsContract.functions.flightCancelled("123", "today", "here").transact()
# print(DetailsContract.functions.claim("123", "today", "here", w3.eth.accounts[1]).call())

amount = DelayContract.functions.convertToWei(3000).call()
# amount = w3.toWei(1, "ether")
print(amount)
amount = DelayContract.functions.convertToWei(2000).call()
print(amount)
# amount = DelayContract.functions.convertToWei(13000).call()
# print(amount)

DelayContract.functions.buyTicket(1, "123", "today", "here").transact({"value": amount})

# print(DelayContract.functions.getRecentTicketSelf().call())
print(DelayContract.functions.getRecentTicket(w3.eth.defaultAccount).call())

import time
time.sleep(1)

amount = DelayContract.functions.convertToWei(3000).call()
DelayContract.functions.buyTicket(1, "123", "yestoday", "there").transact({"value": amount})
print(DelayContract.functions.getRecentTicket(w3.eth.defaultAccount).call())

DetailsContract.functions.flightCancelled("123", "today", "here").transact()
DelayContract.functions.claimMoney("123", "yestoday", "there").transact()

time.sleep(4)

DelayContract.functions.claimMoney("123", "today", "here").transact()