/* eslint-disable */
const { contract, accounts } = require('@openzeppelin/test-environment');
const { BN } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');

const Noe = contract.fromArtifact('Noe');

const isSameAnimal = (_animal1, animal1) => {
  return (
    new BN(_animal1[0]).eq(animal1[0]) &&
    _animal1 === animal1[1] &&
    _animal1 === animal1[2] &&
    _animal1 === animal1[3] &&
    _animal1 === animal1[4] &&
    _animal1 === animal1[5] 
    )
};

describe('Noe', function () {
  this.timeout(0);

  const [owner, dev, user1, veterinary1] = accounts;
  const NAME = 'Noe';
  const SYMBOL = 'NOE';
  const userTest1 = ['Théo', '0668312485', true];
  const userVeterinary1 = ['Streed', '0668312485', false, true];

  const animal1 = ['Murphy', '17/01/2020', 'Male', true, new BN(1)];
  const animal2 = ['Pixel', '01/12/2019', 'Male', true, new BN(0)];
  const animal3 = ['Baloo', '17/01/2020', 'Male', true, new BN(1)];
  const animal4 = ['Murphy', '17/01/2020', 'Male', true, new BN(0)];

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
    const userNew1 = await this.noe.getMember({ from: user1 });
    expect(userNew1[0]).to.equal(userTest1[0]);
    expect(userNew1[1]).to.equal(userTest1[1]);
    expect(userNew1[2]).to.equal(userTest1[2]);
  });

  it('Vétérinaire crée', async function () {
    await this.noe.createVeterinary(userVeterinary1[0], userVeterinary1[1], { from: veterinary1 });
    const vet1 = await this.noe.getVeterinary({ from: veterinary1 });
    expect(vet1[0]).to.be.equal(userVeterinary1[0]);
    expect(vet1[1]).to.be.equal(userVeterinary1[1]);
    expect(vet1[2]).to.be.equal(userVeterinary1[2]);
    expect(vet1[3]).to.be.equal(userVeterinary1[3]);
  });

  it('Approves veterinary', async function () {
    await this.noe.approveVeterinary(veterinary1, { from: owner });
    const vet1 = await this.noe.getVeterinary({ from: veterinary1 });
    /* eslint-disable-next-line */
    expect(vet1.diploma).to.be.true;
  });

  it('increment tokenId by calling animalToken()', async function () {
    await this.noe.approveVeterinary(veterinary1, { from: owner });
    await this.noe.animalToken(user1, animal1[0], animal1[1], animal1[2], animal1[3], animal1[4], { from: veterinary1 });
    expect(await this.noe.tokenOfOwnerByIndex(user1, new BN(0)), 'id should be 1').to.be.a.bignumber.equal(new BN(1));
    await this.noe.animalToken(user1, animal2[0], animal2[1], animal2[2], animal2[3], animal2[4], { from: veterinary1 });
    expect(await this.noe.tokenOfOwnerByIndex(user1, new BN(1)), 'id should be 2').to.be.a.bignumber.equal(new BN(2));
  });

  it('set tokenId to animal', async function () {
    await this.noe.approveVeterinary(veterinary1, { from: owner });

    await this.noe.animalToken(user1, animal1[0], animal1[1], animal1[2], animal1[3], animal1[4], { from: veterinary1 });
    await this.noe.animalToken(user1, animal2[0], animal2[1], animal2[2], animal2[3], animal2[4], { from: veterinary1 });

    const _animal1 = await this.noe.getAnimalById(new BN(1));
    const _animal2 = await this.noe.getAnimalById(new BN(2));

    expect(isSameAnimal(_animal1, animal1)).to.be.true;
    expect(isSameAnimal(_animal2, animal2)).to.be.true;
  })

  it('Mints NFT animal to user by calling animalToken()', async function () {
    await this.noe.approveVeterinary(veterinary1, { from: owner });
    await this.noe.animalToken(user1, animal1[0], animal1[1], animal1[2], animal1[3], animal1[4], { from: veterinary1 });
    await this.noe.animalToken(user1, animal2[0], animal2[1], animal2[2], animal2[3], animal2[4], { from: veterinary1 });
    expect(await this.noe.balanceOf(user1), 'user wrong balance').to.be.a.bignumber.equal(new BN(2));
    const balanceOfUser1 = await this.noe.balanceOf(user1);
    const ids = [];
    for (let i = 0; i < balanceOfUser1; ++i) {
      ids.push(await this.noe.tokenOfOwnerByIndex(user1, i));
    }
    for (let i = 0; i < balanceOfUser1; ++i) {
      expect(await this.noe.ownerOf(ids[i])).to.equal(user1);
    }
  });
});
