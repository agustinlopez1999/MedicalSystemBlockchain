// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

contract WHO_COVID{
    //World Health Organization address
    address public WHO;

    //constructor
    constructor(){
        WHO = msg.sender;
    }

    //mapping to relate valid health centers
    mapping(address => bool) public validity_HealthCenters;

    //mapping to relate Health Center address with his contract
    mapping(address => address) public HealthCenter_Contract;

    //array with addresses with valid health centers
    address[] public health_centers_addresses;

    //array with the addresses that ask for access
    address[] requests;

    //events
    event accessRequest(address);
    event NewValidHealthCenter(address);
    event NewContract(address, address);

    //modifiers that allows only WHO
    modifier onlyWHO(address _address){
        require(_address == WHO);
        _;
    }

    //function to request acccess into the medical system
    function requestAccess() public{
        requests.push(msg.sender);
        emit accessRequest(msg.sender);
    }

    //function that shows request array
    function showRequests() public view onlyWHO(msg.sender) returns(address[] memory){
        return requests;
    }

    //function that validates new health centers
    function HealthCenter(address _healthCenter) public onlyWHO(msg.sender){
        validity_HealthCenters[_healthCenter] = true;
        emit NewValidHealthCenter(_healthCenter);
    }

    //function that creates a new smart contract of a health center
    function FactoryHealthCenter() public{
        require(validity_HealthCenters[msg.sender] == true,"You don't have permissions");
        address HealthCenter_contract = address(new ContractHealthCenter(msg.sender));
        health_centers_addresses.push(HealthCenter_contract);
        HealthCenter_Contract[msg.sender] = HealthCenter_contract;
        emit NewContract(HealthCenter_contract,msg.sender);
    }
}

contract ContractHealthCenter{

    address public HealthCenter_contract;
    address public contractAddress;

    constructor(address _address){
        HealthCenter_contract = _address;
        contractAddress = address(this);
    }

    //mapping to relate person hash with results struct
    mapping (bytes32 => results) COVIDresults;

    struct results{
        bool diagnosis;
        string IPFScode;
    }

    //events
    event newResult(bool, string);

    //modifier that allows only HealthCenter
    modifier onlyHealthCenter(address _address){
        require(_address == HealthCenter_contract,"You don't have permissions");
        _;
    }
    //Example IPFS: QmUhMZ7e6WHqUVhQ2vDEY32vDTXRVQvMEgzaFA8MN7Sf2X
    //function to emit result of covid test
    function CovidTestResults(string memory _idPerson, bool _COVIDresult, string memory _IPFScode) public onlyHealthCenter(msg.sender){
        bytes32 hash_idPerson = keccak256(abi.encodePacked(_idPerson));
        COVIDresults[hash_idPerson] = results(_COVIDresult,_IPFScode);
        emit newResult(_COVIDresult,_IPFScode);
    }

    //function that allows visualization of the results
    function viewResults(string memory _idPerson) public view returns (string memory, string memory){
        bytes32 hash_idPerson = keccak256(abi.encodePacked(_idPerson));
        string memory testResult;

        if(COVIDresults[hash_idPerson].diagnosis == true)
            testResult = "Positive";
        else
            testResult = "Negative";
        
        return(testResult,COVIDresults[hash_idPerson].IPFScode);
    }



}