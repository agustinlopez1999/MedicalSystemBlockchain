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
    mapping(address => bool) validity_HealthCenters;

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
        emit NewContract(HealthCenter_contract,msg.sender);
    }
}

contract ContractHealthCenter{
    address public contractAddress;
    constructor(address _address){
        contractAddress = _address;
    }

}