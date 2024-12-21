// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ARTutorialsPlatform {
    // Owner of the platform
    address public owner;

    // Tutorial structure
    struct Tutorial {
        uint id;
        string title;
        string description;
        string url; // URL to AR content
        address creator;
        uint price; // in wei
        uint purchases;
    }

    // Mapping of tutorial ID to Tutorial
    mapping(uint => Tutorial) public tutorials;
    uint public tutorialCount;

    // Mapping of users who purchased a tutorial
    mapping(uint => mapping(address => bool)) public hasPurchased;

    // Events
    event TutorialCreated(uint id, string title, address indexed creator);
    event TutorialPurchased(uint id, address indexed buyer);

    // Modifier to restrict access to owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Function to create a new tutorial
    function createTutorial(string memory _title, string memory _description, string memory _url, uint _price) public {
        require(bytes(_title).length > 0, "Title cannot be empty");
        require(bytes(_url).length > 0, "URL cannot be empty");
        require(_price > 0, "Price must be greater than zero");

        tutorialCount++;
        tutorials[tutorialCount] = Tutorial(tutorialCount, _title, _description, _url, msg.sender, _price, 0);
        emit TutorialCreated(tutorialCount, _title, msg.sender);
    }

    // Function to purchase a tutorial
    function purchaseTutorial(uint _id) public payable {
        require(_id > 0 && _id <= tutorialCount, "Invalid tutorial ID");
        Tutorial storage tutorial = tutorials[_id];
        require(msg.value == tutorial.price, "Incorrect value sent");
        require(!hasPurchased[_id][msg.sender], "Already purchased");

        // Transfer funds to the creator
        payable(tutorial.creator).transfer(msg.value);
        tutorial.purchases++;
        hasPurchased[_id][msg.sender] = true;

        emit TutorialPurchased(_id, msg.sender);
    }

    // Function to get tutorial details
    function getTutorial(uint _id) public view returns (string memory, string memory, string memory, uint, uint) {
        require(_id > 0 && _id <= tutorialCount, "Invalid tutorial ID");
        Tutorial memory tutorial = tutorials[_id];
        return (tutorial.title, tutorial.description, tutorial.url, tutorial.price, tutorial.purchases);
    }
}
