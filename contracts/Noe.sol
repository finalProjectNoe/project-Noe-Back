// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

// pragma experimental ABIencoderV2;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Noe is ERC721 {
    // Adresse de la personne qui déploie

    address payable private _superAdmin;

    // Constucteur

    constructor(address payable superAdmin) public ERC721("Noe", "NOE") {
        _superAdmin = superAdmin;
    }

    // Structs

    // Structure membres

    struct Member {
        string firstName;
        string lastName;
        address userAddress;
        string postalAddress;
        uint256 postalCode;
        string city;
        bool isMember;
    }

    // Structure animales

    struct Animal {
        uint256 animalId;
        string name;
        uint8 dateBirth;
        string sexe;
        string vaccin;
    }

    // Structure vétérinaire

    struct Veterinary {
        string firstName;
        string lastName;
        address veterinaryAddress;
        string postalAddress;
        uint256 postalCode;
        string city;
        bool diploma;
        bool isVeterinary;
    }

    // Variables de statues

    uint256 public animalsCount;

    mapping(address => Member) public member;

    mapping(address => Animal) public animal;

    mapping(address => Veterinary) public veterinary;

    mapping(address => bool) public registeredMembers;

    mapping(address => bool) public registeredVeterinary;

    mapping(address => bool) public approveVet;

    // Enum

    enum Animals { dog, cat, ferret }

    // Fonction Modifier

    // Check si c'est le super admin

    modifier isSuperAdmin() {
        require(msg.sender == _superAdmin, "Vous n'avez pas le droit d'utiliser cette fonction");
        _;
    }

    // Check si le membre est enregistré

    modifier isMember(address _addr) {
        require(member[_addr].isMember == true, "Vous n'étes pas membre");
        _;
    }

    // Check si le vétérinaire est enregistré

    modifier isVeterinary(address _addr) {
        require(veterinary[_addr].isVeterinary == true, "Vous n'étes pas vétérinaire");
        _;
    }

    // Check si le member n'est enregisté

    modifier isRegistered() {
        require(registeredMembers[msg.sender], "Vous n'étes pas enregisté");
        _;
    }

    // Check si le member est enregisté

    modifier notAlreadyRegistered() {
        require(!registeredMembers[msg.sender], "Vous étes deja enregisté");
        _;
    }

    // Check si l'animal est enregisté

    modifier animalIdCheck(uint256 animalId) {
        require(animalId < animalsCount, "L'animal n'éxiste pas");
        _;
    }

    // Events

    event MemberCreated(address _address);

    event VeterinaryCreated(address _address);

    event VeterinaryApprove(address _address);

    // Function

    function createMember(
        string memory _firstName,
        string memory _lastName,
        address _userAddress,
        string memory _postalAddress,
        uint256 _postalCode,
        string memory _city
    ) public notAlreadyRegistered() returns (bool) {
        member[msg.sender] = Member({
            firstName: _firstName,
            lastName: _lastName,
            userAddress: _userAddress,
            postalAddress: _postalAddress,
            postalCode: _postalCode,
            city: _city,
            isMember: true
        });

        registeredMembers[msg.sender] = true;

        emit MemberCreated(msg.sender);

        return registeredMembers[msg.sender];
    }

    function createVeterinary(
        string memory _firstName,
        string memory _lastName,
        address _veterinaryAddress,
        string memory _postalAddress,
        uint256 _postalCode,
        string memory _city
    ) public returns (bool) {
        veterinary[msg.sender] = Veterinary({
            firstName: _firstName,
            lastName: _lastName,
            veterinaryAddress: _veterinaryAddress,
            postalAddress: _postalAddress,
            postalCode: _postalCode,
            city: _city,
            diploma: false,
            isVeterinary: false
        });

        registeredVeterinary[msg.sender] = true;

        emit VeterinaryCreated(msg.sender);

        return registeredVeterinary[msg.sender];
    }

    function approveVeterinary(address _addr) public isSuperAdmin returns (bool) {
        veterinary[_addr].diploma = true;
        veterinary[_addr].isVeterinary = true;

        approveVet[msg.sender] = true;

        emit VeterinaryApprove(msg.sender);

        return approveVet[msg.sender];
    }

    function connectionMember(address _addr) public isMember(_addr) {}

    function connectionVeterinary(address _addr) public isVeterinary(_addr) {}
}
