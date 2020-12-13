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
  const [owner, dev, user1, user2, veterinary1] = accounts;
  const NAME = 'Noe';
  const SYMBOL = 'NOE';
  /* const animal1 = [user1, 'Murphy', '17/01/2020', 'Male', true, new BN(0)];
  const animal2 = [user2, 'Pixel', '17/01/2020', 'Male', true, new BN(1)];
  const animal3 = [user1, 'Gospelle', '17/01/2020', 'Femelle', true, new BN(2)];
  const animal4 = [user1, 'Patch', '17/01/2020', 'Male', true, new BN(1)]; */
  const userTest1 = ['Théo', '0668312485', true];
  const userVeterinary1 = ['Streed', '0668312485', false, true];

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
  it('Approves veterinary', async function () {
    await this.noe.approveVeterinary(veterinary1, { from: owner });
    const vet1 = await this.noe.getVeterinary(veterinary1);
    // eslint-disable-next-line
    expect(vet1.diploma).to.be.true;
  });
  it('mints NFT to user by calling animalToken()', async function () {
    // eslint-disable-next-line
    await expectRevert(this.noe.animalToken(user1, 'Murphy', '17/01/2020', 'Male', true, new BN(0), { from: veterinary1 }), 'caller is not the vet1');
    await this.noe.animalToken(user1, 'Murphy', '17/01/2020', 'Male', true, new BN(0), { from: veterinary1 });
    await this.noe.animalToken(user2, 'Pixel', '17/01/2020', 'Male', true, new BN(1), { from: veterinary1 });
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
  });
});
