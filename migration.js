const ColorMinter = artifacts.require('ColorMinter');
const Exchange = artifacts.require('Exchange');
const erfan = artifacts.require('erfan');

module.exports = function (deployer) {
	deployer.deploy(ColorMinter);
	deployer.deploy(Exchange);
	deployer.deploy(erfan);
};
