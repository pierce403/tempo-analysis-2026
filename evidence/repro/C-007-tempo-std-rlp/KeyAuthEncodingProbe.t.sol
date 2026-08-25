// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.13 <0.9.0;

import {VmRlp} from "../src/StdVm.sol";
import {TempoTransaction, TempoTransactionLib} from "../src/tx/TempoTransactionLib.sol";

contract KeyAuthEncodingProbe {
    using TempoTransactionLib for TempoTransaction;

    function testStringWrapsRlpKeyAuthorization() public pure {
        TempoTransaction memory transaction = TempoTransactionLib.create();
        transaction = transaction.withKeyAuthorization(hex"c180");

        bytes memory encoded = transaction.encode(VmRlp(address(0)));

        require(encoded.length >= 3, "short encoding");
        require(encoded[encoded.length - 3] == bytes1(0x82), "missing string prefix");
        require(encoded[encoded.length - 2] == bytes1(0xc1), "missing supplied list prefix");
        require(encoded[encoded.length - 1] == bytes1(0x80), "missing supplied list payload");
    }
}
