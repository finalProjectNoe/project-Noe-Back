// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/// @title Un contrat de passeport animaliers
/// @author Théo, Streed, Nico, Mika
/// @notice Ce contrat permet d'associer des animaux à des utilisateurs via des vétérinaires

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
        string name;
        uint256 tel;
        // nb token
        bool isMember;
    }

    // Structure animales

    struct Animal {
        string name;
        string dateBirth;
        string sexe;
        bool vaccin;
        Animals animals;
    }

    // Structure vétérinaire

    struct Veterinary {
        string name;
        uint256 tel;
        bool diploma;
        bool isVeterinary;
    }

    // Variables de statues

    uint256 public animalsCount;

    mapping(uint256 => Animal) private _animal;

    mapping(address => Member) public member;

    mapping(address => Veterinary) public veterinary;

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

    modifier isVeterinary() {
        require(veterinary[msg.sender].isVeterinary == true, "Vous n'étes pas vétérinaire");
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

    // Functions

    /// Permet de créer un nouveau membre en vérifiant qu'il n'est pas déjà membre
    function createMember(string memory _name, uint256 _tel) public returns (bool) {
        member[msg.sender] = Member({name: _name, tel: _tel, isMember: true});

        emit MemberCreated(msg.sender);
    }

    /// Permet de créer un compte vétérinaire sous réserve de validation du diplôme par le super admin
    function createVeterinary(string memory _name, uint256 _tel) public returns (bool) {
        veterinary[msg.sender] = Veterinary({name: _name, tel: _tel, diploma: false, isVeterinary: false});

        emit VeterinaryCreated(msg.sender);
    }

    /// Permet de valider le compte vétérinaire après vérification du diplôme
    function approveVeterinary(address _addr) public isSuperAdmin returns (bool) {
        veterinary[_addr].diploma = true;
        veterinary[_addr].isVeterinary = true;

        emit VeterinaryApprove(msg.sender);
    }

    /// Permet de se connecter en tant que membre
    function connectionMember(address _addr, string memory _name) public isMember(_addr) {
    }

    /// Permet de se connecter en tant que vétérinaire
    function connectionVeterinary(address _addr, string memory _name) public isVeterinary() {}

    ///
    function animalToken(
        address _member,
        string memory _name,
        string memory _dateBirth,
        string memory _sexe,
        bool _vaccin,
        Animals animals_
    ) public isVeterinary() returns (uint256) {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        _mint(_member, newTokenId);
        _animal[newTokenId] = Animal({name: _name, dateBirth: _dateBirth, sexe: _sexe, vaccin: _vaccin, animals: animals_});
        return newTokenId;
    }

    /// Permet de retrouver un animal en fonction de son index
    function getAnimalById(uint256 tokenId) public view returns (Animal memory) {
        require(_exists(tokenId), "NOE: Animal query for no nexistent token");
        return _animal[tokenId];
    }
}
