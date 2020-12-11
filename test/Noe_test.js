const { contract, accounts } = require('@openzeppelin/test-environment');
const { BN } = require('@openzeppelin/test-helpers');
// const { web3 } = require('@openzeppelin/test-helpers/src/setup');
const { expect } = require('chai');

const Noe = contract.fromArtifact('Noe');

const isSameAnimal = (_animal1, animal1) => {
  return (
    _animal1 === animal1[0] &&
    new BN(_animal1[1]).eq(animal1[1]) &&
    new BN(_animal1[2]).eq(animal1[2]) &&
    new BN(_animal1[3]).eq(animal1[3])
  );
};

describe('Noe', function () {
  this.timeout(0);
  const [owner, dev, user1, veterinary1] = accounts;
  const NAME = 'Noe';
  const SYMBOL = 'NOE';
  const animal1 = ['Murphy', '17/01/2020', 'Male', true, new BN(0)];
  const animal2 = ['Pixel', '17/01/2020', 'Male', true, new BN(1)];
  // const animal3 = ['Gospelle', '17/01/2020', 'Femelle', true, new BN(2)];
  // const animal4 = ['Patch', '17/01/2020', 'Male', true, new BN(1)];
  const userTest1 = ['Théo', '0668312485', true];
  const userVeterinary1 = ['Streed', '0668312485', false, false];

  beforeEach(async function () {
    this.noe = await Noe.new(owner, { from: dev });
  });
  it('A un nom', async function () {
    expect(await this.noe.name()).to.equal(NAME);
  });
  it('A un symbol', async function () {
    expect(await this.noe.symbol()).to.equal(SYMBOL);
  });
  it('Membre crée', async function () {
    await this.noe.createMember(userTest1[0], userTest1[1], { from: user1 });
    const userNew1 = await this.noe.getMember(user1);
    expect(userNew1[0]).to.equal(userTest1[0]);
    expect(userNew1[1]).to.equal(userTest1[1]);
    expect(userNew1[2]).to.equal(userTest1[2]);
  });
  it('Vétérinaire crée', async function () {
    await this.noe.createVeterinary(userVeterinary1[0], userVeterinary1[1], { from: veterinary1 });
    const vet1 = await this.noe.getVeterinary(veterinary1);
    expect(vet1[0]).to.be.equal(userVeterinary1[0]);
    expect(vet1[1]).to.be.equal(userVeterinary1[1]);
    expect(vet1[2]).to.be.equal(userVeterinary1[2]);
    expect(vet1[3]).to.be.equal(userVeterinary1[3]);
  });
  it('set tokenId to animal', async function () {
    await this.noe.animalToken(userTest1, animal1, { veterinary1 });
    await this.noe.animalToken(userTest1, animal2, { veterinary1 });
    const _animal1 = await this.noe.getAnimalById(new BN(1));
    const _animal2 = await this.noe.getAnimalById(new BN(1));
    expect(isSameAnimal(_animal1, animal1)).to.be.true;
    expect(isSameAnimal(_animal2, animal2)).to.be.true;
  });
});
