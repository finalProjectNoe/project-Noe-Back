const { contract, accounts } = require('@openzeppelin/test-environment');
const { expect } = require('chai');
const Noe = contract.fromArtifact('Noe');

describe('Noe', function () {
  this.timeout(0);
  const [owner, dev, user1, veterinary1] = accounts;
  const NAME = 'Noe';
  const SYMBOL = 'NOE';
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
});
