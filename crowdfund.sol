// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract crowdfunding 
{
    mapping(address=>uint) public contributors;
    address public manager;
    uint public minimumContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfContributors;

    struct Request
    {
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address=>bool) voters;
    }
    mapping  (uint=>Request) public request;
    uint public numReqest;

    constructor(uint _target, uint _deadline) {
        target= _target;
        deadline= block.timestamp+_deadline;
        minimumContribution=100 wei;
        manager=msg.sender;
    }
    function sendEth() public payable 
    {
        require(block.timestamp < deadline,"Deadline has passed");
        require(msg.value>=minimumContribution,"Minimum contribution is not met");
        if(contributors[msg.sender]==0)
        {
            noOfContributors++;
        }
        contributors[msg.sender]+=msg.value;
        raisedAmount+=msg.value;
    }
    function getContractBalance() public view returns (uint)
    {
        return address(this).balance;
    }
    function refund() public
    {
        require(block.timestamp > deadline && raisedAmount < target,"you are not eligible");
        require(contributors[msg.sender]>0);
        address payable user=payable (msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender]=0;
    }
    modifier onlyManager()
    {
        require(msg.sender==manager,"only manager can call this function");
        _;
    }
    function createRequest(string memory _description , address payable _recipient,uint _value)public onlyManager
    {
        Request storage newRequest  = request[numReqest];
        numReqest ++;
        newRequest.description=_description;
        newRequest.recipient=_recipient;
        newRequest.value=_value;
        newRequest.completed= false;
        newRequest.noOfVoters=0;
    }
    function voteRequest(uint _requestNO)public 
    {
        require(contributors[msg.sender]>0,"You mist be contributor");
        Request storage thisRequest= request[_requestNO];
        require(thisRequest.voters[msg.sender]==false,"you have already voted");
        thisRequest.voters[msg.sender]==true;
        thisRequest.noOfVoters++;
    }
    function makePayment(uint _requestNO) public onlyManager
    {
        require(raisedAmount>target);
        Request storage thisRequest=request[_requestNO];
        require( thisRequest.completed==false,"The request has been completed");
        require(thisRequest.noOfVoters > noOfContributors/2,"majority does not gain");
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed=true;

    }
}