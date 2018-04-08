module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  networks: {
    development: {
      host: "127.0.0.1",
      port: 50000,
      gas: 5000000,
      network_id: "*" // Match any network id
    },
    gethTestNet: {
      host: "127.0.0.1",
      port: 8545,
      gas: 50000000,
      network_id: "*"
    },
    ganacheTestNet: {
      host: "127.0.0.1",
      port: 7545,
      gas: 5000000,
      network_id: "*"
    },
    ropsten:  {
      network_id: 3,
      host: "localhost",
      port:  8545,
      gas:   2900000
    },
    ropsten_test:  {
      network_id: "*",
      host: "52.237.77.0",
      port:  8545,
      gas:   2900000
    }

  },
  rpc: {
    host: 'localhost',
    post:8545
  }
};
