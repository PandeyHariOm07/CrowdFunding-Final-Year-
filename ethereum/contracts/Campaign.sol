// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

    //to create many projects
contract CampaignFactory{

     address[] public deployedCampaigns;
    function createCampaign(uint minimum) public{
        address newCampaign = address(new Campaign(minimum,msg.sender));
        deployedCampaigns.push(newCampaign);
    }
    function getDeployedCampaign() public view returns (address[] memory){
        return deployedCampaigns;
    }
}
    //contract for single campaign
contract Campaign{

    //structure for the Requester,who asks for fund.
    struct Request{
        string description;
        uint value;
        address payable recipient;
        bool complete;
        uint approvalCount;
        mapping(address => bool) approvals;// votes in favour
    }
    address public manager;
    uint public minimumContribution;
    Request[] public requests;
    uint public approversCount; //how many people total voted
    mapping(address => bool) public approvers;

    //contructor for initialisation
    constructor(uint minimum,address creator){
        manager = creator;
        minimumContribution = minimum;
    }
    //fuction for the contributors to make donation.
    function contribute() public payable{
        //donation must be greater then minimum value
        require(msg.value > minimumContribution);
        // contributor added to approvers array
        approvers[msg.sender] = true;
        approversCount++;
    }

        modifier restricted(){ //means only manager can approve or is authorised
        require(msg.sender == manager); //condition that should be true to run below statements
        _;
        }

    //function to create request
    function createRequest( string memory description, uint value, address payable recipient) public restricted{
        //"modifier restricted" implemented
        // Request memory newRequest = Request({
        //     description: description,
        //     value: value,
        //     recipient: recipient,
        //     complete: false,
        //     approvalCount: 0
        // });

        // requests.push(newRequest);
         Request storage newRequest = requests.push();
         newRequest.description = description;
         newRequest.value = value;
         newRequest.recipient = recipient;
         newRequest.complete = false;
         newRequest.approvalCount =0;
    }

    //which project should be approved
    function approveRequest(uint index) public {
        Request storage request = requests[index];
        require(approvers[msg.sender]); //is authorised
        require(!request.approvals[msg.sender]); //should have not voted before

        request.approvals[msg.sender]=true;
        request.approvalCount++;
    }

    //to Finalsize whom the money or funds will be given
    function finalizeRequest(uint index) public restricted{
        Request storage request = requests[index];
        require(request.approvalCount > (approversCount /2));  //majority votes
        require(!request.complete); //fund is not yet transfered

        request.recipient.transfer(request.value);
        request.complete = true;
    }

    function getRequestsCount() public view returns (uint){
        return requests.length;
    }
}