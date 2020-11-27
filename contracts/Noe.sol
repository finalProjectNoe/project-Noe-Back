// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

// pragma experimental ABIencoderV2;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/// @title Un contrat de passeport animaliers
/// @author Théo, Streed, Nico, Mika
/// @notice Ce contrat d'accosier des animaux à des utilisateurs via des vétérinaires 

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

    enum Animals { dog, cat, ferret }

    // Structs

    // Structure membres

    struct Member {
        address eth;
        string name;
        uint256 tel;
        // nb token
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
        address ethVet;
        string name;
        uint256 tel;
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
        address _eth,
        string memory _name,
        uint256 _tel
    ) public notAlreadyRegistered() returns (bool) {
        member[msg.sender] = Member({
            eth: _eth,
            name: _name,
            tel: _tel,
            isMember: true
        });

        registeredMembers[msg.sender] = true;

        emit MemberCreated(msg.sender);

        return registeredMembers[msg.sender];
    }

    function createVeterinary(
        address _ethVet,
        string memory _name,
        uint256 _tel

    ) public returns (bool) {
        veterinary[msg.sender] = Veterinary({
        ethVet: _ethVet,
        name: _name,
        tel: _tel,
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

    function animalToken(address _member, Animal memory animal_) public returns (uint256) {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        _mint(_member, newTokenId);
        _animal[newTokenId] = animal_;
        return newTokenId;
    }
    

    function getAnimalById(uint256 tokenId) public view returns (Animal memory) {
        require(_exists(tokenId), "NOE: Animal query for no nexistent token");
        return _animal[tokenId];
    }
}
