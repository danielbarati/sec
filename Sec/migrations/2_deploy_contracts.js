const SecContract = artifacts.require("SecContract");

module.exports = function(deployer) {
    deployer.deploy(SecContract);
}