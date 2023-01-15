# ZKSnarks

This demonstration of ZKPs uses Snarkjs library to show how a proof can be generated in json format.

A circuit is a huge mathematical expression used by the system to calculate the outputs and the proof. The zero-knowledge proof itself is proof that you have successfully done the calculation.
A circuit can be really complex, but fortunately, there are circuit programming languages and libraries that make it easy to write your own circuits.

This demo makes use of circomlib and snarkjs libraries to deliver a simple implementation of ZKPs, where the inputs and final proofs generated are both in the json formats.

### The proof generated through snarkjs and circom can be passed on as cross-chain data through the Router Protocol, and be used to verify knowledge at the other endpoint, i.e, the Minting Blockchain, using the same technologies at the servers.
