// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

// pragma experimental ABIencoderV2;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/// @title Un contrat pour gérer la propriété d'animaux enregistré par des vétérinaires
/// @author Théo Streed Nico Mika
/// @notice Ce contrat permet d'enregistrer des vétérinaires et des membres et attitrer des animaux
contract Noe is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // Adresse de la personne qui déploie

    address payable private _superAdmin;

    // Constucteur

    constructor(address payable superAdmin) public ERC721("Noe", "NOE") {
        _superAdmin = superAdmin;
    }

    // Enum

    enum Animals {dog, cat, ferret}

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
        string name;
        uint8 dateBirth;
        string sexe;
        bool vaccin;
        Animals animals;
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

    mapping(uint256 => Animal) private _animal;

    mapping(address => Member) public member;

    mapping(address => Animal) public animal;

    mapping(address => Veterinary) public veterinary;

    mapping(address => bool) public registeredMembers;

    mapping(address => bool) public registeredVeterinary;

    mapping(address => bool) public approveVet;

    // Fonction Modifier

    // Check si c'est le super admin

    modifier isSuperAdmin() {
        require(msg.sender == _superAdmin, "Vous n'avez pas le droit d'utiliser cette fonction");
        _;
    }

    // Check si le membre est enregistré

    modifier isMember(address _addr) {
        require(member[_addr].isMember == true, "Vous n'êtes pas membre");
        _;
    }

    // Check si le vétérinaire est enregistré

    modifier isVeterinary(address _addr) {
        require(veterinary[_addr].isVeterinary == true, "Vous n'êtes pas vétérinaire");
        _;
    }

    // Check si le member n'est enregisté

    modifier isRegistered() {
        require(registeredMembers[msg.sender], "Vous n'êtes pas enregistré");
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

    function animalToken(address _member, Animal memory animal_) public isVeterinary(_addr) returns (uint256) {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        _mint(_member, newTokenId);
        _animal[newTokenId] = animal_;
        return newTokenId;
    }

    //function tokenByIndex(uint256 _index) external view returns (uint256);
    function getAnimalById(uint256 tokenId) public view returns (Animal memory) {
        require(_exists(tokenId), "NOE: Animal query for no existant token");
        return _animal[tokenId];
    }

    function balanceOf(address _owner) public view returns (uint256 _balance) {
        return ownerAnimalCount[_owner];
    }

    //function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);
    function ownerOf(uint256 _tokenId) public view returns (address _owner) {
        return animalToOwner[_tokenId];
    }
}
