const { contract, accounts } = require('@openzeppelin/test-environment');
const { BN } = require('@openzeppelin/test-helpers');
// const { web3 } = require('@openzeppelin/test-helpers/src/setup');
// const { expect } = require('chai');

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
  const [owner, dev, user1, user2] = accounts;
  const NAME = 'Noe';
  const SYMBOL = 'NOE';

  const animal1 = ['Murphy', '17/01/2020', 'Male', true, new BN(0)];
  const animal2 = ['Pixel', '17/01/2020', 'Male', true, new BN(1)];
  const animal3 = ['Gospelle', '17/01/2020', 'Femelle', true, new BN(2)];
  const animal4 = ['Patch', '17/01/2020', 'Male', true, new BN(1)];

  beforeEach(async function () {
    this.animal = await Noe.new(owner, { from: dev });
  });
  it('A un nom', async function () {
    expect(await this.animal.name()).to.equal(NAME);
  });
  it('A un symbol', async function () {
    expect(await this.animal.symbol()).to.equal(SYMBOL);
  });
});
