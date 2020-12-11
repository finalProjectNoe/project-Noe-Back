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
  const [owner, dev, user1, user2, veterinary1] = accounts;
  const NAME = 'Noe';
  const SYMBOL = 'NOE';
  // const animal1 = ['Murphy', '17/01/2020', 'Male', true, new BN(0)];
  // const animal2 = ['Pixel', '17/01/2020', 'Male', true, new BN(1)];
  // const animal3 = ['Gospelle', '17/01/2020', 'Femelle', true, new BN(2)];
  // const animal4 = ['Patch', '17/01/2020', 'Male', true, new BN(1)];
  const userTest1 = ['Théo', new BN(0, 6, 6, 8, 3, 1, 2, 4, 8, 5), true];
  const vetApprouve = [true, true];
  const animal1 = ['0x67b3dc27E5fc43f0C491eCcCEcb9588Df2042501', 'Murphy', '17/01/2020', 'Male', true, new BN(0)];
  const animal2 = ['0x67b3dc27E5fc43f0C491eCcCEcb9588Df2042502', 'Pixel', '17/01/2020', 'Male', true, new BN(1)];
  const animal3 = ['0x67b3dc27E5fc43f0C491eCcCEcb9588Df2042503', 'Gospelle', '17/01/2020', 'Femelle', true, new BN(2)];
  const animal4 = ['0x67b3dc27E5fc43f0C491eCcCEcb9588Df2042504', 'Patch', '17/01/2020', 'Male', true, new BN(1)];
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
  it('has owner', async function () {
    expect(await this.noe.owner()).to.equal(owner);
  });
  it('Membre crée', async function () {
    await this.noe.createMember(user1, userTest1, { from: user1 });
  });
  it('Vétérinaire crée', async function () {
    await this.noe.createVeterinary(veterinary1, userVeterinary1[0], userVeterinary1[1], { from: veterinary1 });
    const vet1 = await this.noe.getVeterinary(veterinary1);
    expect(vet1[0]).to.be.equal(userVeterinary1[0]);
    expect(vet1[1]).to.be.equal(userVeterinary1[1]);
    expect(vet1[2]).to.be.equal(userVeterinary1[2]);
    expect(vet1[3]).to.be.equal(userVeterinary1[3]);
  });
  it('Vétérinaire approuvé', async function () {
    await this.noe.approveVeterinary(vetApprouve, { from: owner });
  });
  it('mints NFT to user by calling animalToken()', async function () {
    await this.noe.animalToken(animal1[0], animal1[1], animal1[2], animal1[3], animal1[4], { from: owner });
    await this.noe.animalToken(user2, animal2, { from: owner });
    await this.noe.animalToken(user1, animal3, { from: owner });
    await this.noe.animalToken(user1, animal4, { from: owner });
    expect(await this.noe.balanceOf(user1), 'user1 wrong balance').to.be.a.bignumber.equal(new BN(3));
    expect(await this.noe.balanceOf(user2), 'user2 wrong balance').to.be.a.bignumber.equal(new BN(1));
    const balanceOfUser1 = await this.noe.balanceOf(user1);
    const ids = [];
    for (let i = 0; i < balanceOfUser1; ++i) {
      ids.push(await this.noe.tokenOfOwnerByIndex(user1, i));
    }
    for (let i = 0; i < balanceOfUser1; ++i) {
      expect(await this.noe.ownerOf(ids[i])).to.equal(user1);
    }
    expect(await this.noe.ownerOf(2)).to.equal(user2);
    await this.noe.approveVeterinary(veterinary1, { from: owner });
    expect(await this.noe.approveVeterinary()).to.be.true;
  });
  /* describe('mint() and ownerOf()', () => {
    it('verifies ownership after mint', async function () {
      await this.contract.mint('3');
      assert.equal(await this.noe.ownerOf.call(3), user1);
    });
  }); */
});
