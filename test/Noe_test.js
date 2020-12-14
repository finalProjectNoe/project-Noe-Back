/* eslint-disable */
const { contract, accounts } = require('@openzeppelin/test-environment');
const { BN, expectRevert } = require('@openzeppelin/test-helpers');
// const { web3 } = require('@openzeppelin/test-helpers/src/setup');
const { expect } = require('chai');

const Noe = contract.fromArtifact('Noe');

/* const isSameAnimal = (_animal1, animal1) => {
  return (
    _animal1 === animal1[0] &&
    new BN(_animal1[1]).eq(animal1[1]) &&
    new BN(_animal1[2]).eq(animal1[2]) &&
    new BN(_animal1[3]).eq(animal1[3])
  );
}; */

describe('Noe', function () {
  this.timeout(0);
  const [owner, dev, user1, user2, veterinary1] = accounts; // metamask accounts
  const NAME = 'Noe'; // Nom du contrat
  const SYMBOL = 'NOE'; // Symbol du projet

  // Animal test
  const animal1 = [user1, 'Murphy', '17/01/2020', 'Male', true, new BN(0)];
  const animal2 = [user2, 'Pixel', '17/01/2020', 'Male', true, new BN(1)];
  const animal3 = [user1, 'Gospelle', '17/01/2020', 'Femelle', true, new BN(2)];
  const animal4 = [user1, 'Patch', '17/01/2020', 'Male', true, new BN(1)];

  // Member test
  const userTest1 = ['Théo', '0668312485', true];
  const userTest2 = ['Nico', '0668312485', true];

  // Veterinaire test
  const userVeterinary1 = ['Streed', '0668312485', false, true];

  beforeEach(async function () {
    this.noe = await Noe.new(owner, { from: dev }); // Appel du constructor du smart contract
  });
  it('A un nom', async function () {
    expect(await this.noe.name()).to.equal(NAME); // Test pour vérifier si le contrat à un nom
  });
  it('A un symbol', async function () {
    expect(await this.noe.symbol()).to.equal(SYMBOL); // Test pour vérifier si le contrat à un symbol
  });
  it('has owner', async function () {
    expect(await this.noe.owner()).to.equal(owner); // Test pour vérifier si le contrat à un owner
  });
  it('Membre crée', async function () {
    await this.noe.createMember(userTest1[0], userTest1[1], { from: user1 }); // Test de création du membre
    const userNew1 = await this.noe.getMember(user1); // Variable pour récupérer le membre crée
    // Test des deux variables équivalentes
    expect(userNew1[0]).to.equal(userTest1[0]);
    expect(userNew1[1]).to.equal(userTest1[1]);
    expect(userNew1[2]).to.equal(userTest1[2]);
  });
  it('Vétérinaire crée', async function () {
    await this.noe.createVeterinary(userVeterinary1[0], userVeterinary1[1], { from: veterinary1 }); // Test de création du vététinaire
    const vet1 = await this.noe.getVeterinary(veterinary1); // Variable pour récupérer le vétérinaire crée
    // Test des deux variables équivalentes
    expect(vet1[0]).to.be.equal(userVeterinary1[0]);
    expect(vet1[1]).to.be.equal(userVeterinary1[1]);
    expect(vet1[2]).to.be.equal(userVeterinary1[2]);
    expect(vet1[3]).to.be.equal(userVeterinary1[3]);
  });
  it('Approves veterinary', async function () {
    await this.noe.approveVeterinary(veterinary1, { from: owner }); // Test pour approuver le vétérinaire par le owner
    const vet1 = await this.noe.getVeterinary(veterinary1); // Variable pour récupérer le vétérinaire
    expect(vet1.diploma).to.be.true; // Vérifie que le diplome est à true
  });
});
