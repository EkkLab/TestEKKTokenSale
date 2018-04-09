pragma solidity ^0.4.21;

import "ds-test/test.sol";

import "./Tokensale2.sol";

contract Tokensale2Test is DSTest {
    Tokensale2 tokensale;

    function setUp() public {
        tokensale = new Tokensale2();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
