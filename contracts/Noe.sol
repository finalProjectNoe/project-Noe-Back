// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/// @title Un contrat de passeport animaliers
/// @author Théo, Streed, Nico, Mika
/// @notice Ce contrat permet d'associer des animaux à des utilisateurs via des vétérinaires

contract Noe is ERC721 {
    
    using Counters for Counters.Counter; // Utilisation du contract Counter d'openzeppelin importait en ligne 6
    Counters.Counter private _tokenIds; // Utilisation de la fonction Counter pour associer un _tokenIds

    address payable private _superAdmin; // Adresse de la personne qui déploie

    /// @notice Name and symbol of the non fungible token, as defined in ERC721.
    constructor(address payable superAdmin) public ERC721("Noe", "NOE") { // Constucteur
        _superAdmin = superAdmin;
    }

    enum Animals {dog, cat, ferret} // Enumération

    event MemberCreated(address _address); // Event pour la créaction d'un membre

    event VeterinaryCreated(address _address); // Event pour la créaction d'un vétérinaire

    event VeterinaryApprove(address _address); // Event qu'on vétérinaire approuve un vétérinaire

    struct Member { // Structure membres
        string name; // Nom du membre
        uint256 tel; // Numéro de téléphone du membre
        bool isMember; // False par défaut, true si la pérsonne est déjà enregistré
    }

    struct Animal { // Structure animales
        string name; // Nom de l'animal
        string dateBirth; // Date de naissance de l'animal
        string sexe; // Sexe de l'animal
        bool vaccin; // Si il est vacciné ou non
        Animals animals; // Enumération de chien chat furret
    }

    struct Veterinary { // Structure vétérinaire
        string name; // Nom du vétérinaire
        uint256 tel; // Numéro de téléphone du vétérinaire
        bool diploma; // False par defaut, le super admin approuve le vétérinaire une fois les diplomes valide
        bool isVeterinary; // False par defaut, il devient vétérinaire une fois que le super admin approuve
    }

    uint256 public animalsCount; // Variable de statue pour compter le nombre d'animaux

    /// @dev Mapping de la struct Animal
    mapping(uint256 => Animal) private _animal;

    /// @dev Mapping de la struct Member
    mapping(address => Member) public member;

    /// @dev Mapping de la struct Veterinary
    mapping(address => Veterinary) public veterinary;

    // This modifer, vérifie si c'est le super admin
    modifier isSuperAdmin() {
        require(msg.sender == _superAdmin, "Vous n'avez pas le droit d'utiliser cette fonction");
        _;
    }

    // This modifer, vérifie si le membre est déjà enregistré
    modifier onlyMember(address _addr) {
        require(member[_addr].isMember == true, "Vous n'étes pas membre");
        _;
    }
    
    // This modifer, vérifie si le membre n'est pas déjà enregistré
    modifier onlyYetMember(address _addr) {
        require(member[_addr].isMember == false, "Vous étes déjà membre");
        _;
    }

    // This modifer, vérifie si le vétérinaire est déjà enregistré
    modifier onlyVeterinary() {
        require(veterinary[msg.sender].isVeterinary == true, "Vous n'étes pas vétérinaire");
        _;
    }
    
    // This modifer, vérifie si le vétérinaire n'est pas déjà enregistré
    modifier yetOnlyVeterinary() {
        require(veterinary[msg.sender].isVeterinary == false, "Vous étes déjà vétérinaire");
        _;
    }

    // This modifer, vérifie si l'animal éxiste ou pas
    modifier animalIdCheck(uint256 animalId) {
        require(animalId < animalsCount, "L'animal n'éxiste pas");
        _;
    }

    /// @dev Permet de créer un nouveau membre en vérifiant qu'il n'est pas déjà membre
    /// @param _name set le nom du membre dans la struct Member
    /// @param _tel set le nom du téléphone dans la struct Member
    function createMember(string memory _name, uint256 _tel) public {
        member[msg.sender] = Member({name: _name, tel: _tel, isMember: true});

        emit MemberCreated(msg.sender); /// emit de l'event MemberCreated
    }

    /// @dev Permet de créer un compte vétérinaire sous réserve de validation du diplôme par le super admin et la fonction approveVeterinary
    /// @param _name set le nom du membre dans la struct vétérinaire
    /// @param _tel set le nom du téléphone dans la struct vétérinaire
    function createVeterinary(string memory _name, uint256 _tel) public {
        veterinary[msg.sender] = Veterinary({name: _name, tel: _tel, diploma: false, isVeterinary: false});

        emit VeterinaryCreated(msg.sender);
    }

    /// @dev Permet de valider le compte vétérinaire après vérification du diplôme
    /// @param _addr passe l'adresse du vétérinaire à approuver
    function approveVeterinary(address _addr) public isSuperAdmin returns (bool) {
        veterinary[_addr].diploma = true; // Set à true le diplome dans la struct Veterinary
        veterinary[_addr].isVeterinary = true; // Set à true, il devient vétérinaire dans la struct Veterinary

        emit VeterinaryApprove(msg.sender); /// emit de l'event VeterinaryApprove
    }

    /// @dev Permet de se connecter en tant que membre
    /// @param _addr de connexion du membre
    /// @param _name nom du membre
    function connectionMember(address _addr, string memory _name) public onlyMember(_addr) {
    }

    /// @dev Permet de se connecter en tant que vétérinaire
    /// @param _addr de connexion du vétérinaire
    /// @param _name nom du vétérinaire
    function connectionVeterinary(address _addr, string memory _name) public onlyVeterinary() {}

    /// @dev Crée un animal et lui associe un token ERC721
    /// @param _member du membre à qui attibuer l'animal/token
    /// @param _name le nom de l'animal
    /// @param _dateBirth date de naissance de l'animal
    /// @param _sexe le sex de l'animal
    /// @param _vaccin si l'animal est vacciné ou non
    /// @param animals_ le type d'animal de l'énunération
    /// @return le numéro de token
    function animalToken(
        address _member,
        string memory _name,
        string memory _dateBirth,
        string memory _sexe,
        bool _vaccin,
        Animals animals_
    ) public onlyVeterinary() returns (uint256) {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        _mint(_member, newTokenId);
        _animal[newTokenId] = Animal({name: _name, dateBirth: _dateBirth, sexe: _sexe, vaccin: _vaccin, animals: animals_});
        return newTokenId;
    }

    /// @dev Permet de retrouver un animal en fonction de son numéro de token
    /// @param tokenId retrouver un animal via son numéro de token
    function getAnimalById(uint256 tokenId) public view returns (Animal memory) {
        require(_exists(tokenId), "NOE: Animal query for no nexistent token");
        return _animal[tokenId];
    }
}
