// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {HorseStore} from "../../src/HorseStore.sol";

contract HorseStoreTest is Test {
    HorseStore horseStore;
    address USER = makeAddr("user");
    string public constant NFT_NAME = "HorseStore";
    string public constant NFT_SYMBOL = "HS";

    uint256 constant ONE_HUNDRED = 100;
    uint256 constant TWO = 2;
    uint256 constant ZERO = 0;
    uint256 constant TEN = 10;
    uint256 constant TWO_DAYS = 2 days;

    function setUp() external {
        horseStore = new HorseStore();
    }

    modifier mintNft() {
        vm.prank(USER);
        horseStore.mintHorse();
        _;
    }

    //////////////////////////
    // test Name and Symbol //
    //////////////////////////

    function testNameHorseStore() public {
        string memory name = horseStore.name();
        assertEq(name, NFT_NAME);
    }

    function testSymbolHorseStore() public {
        string memory symbol = horseStore.symbol();
        assertEq(symbol, NFT_SYMBOL);
    }

    ////////////////////
    // test mintHorse //
    ////////////////////

    function testMintNftRevertsWhenNonExistentIdIsProvided() public {
        vm.expectRevert(HorseStore.HorseStore__InvalidId.selector);
        vm.prank(USER);
        horseStore.feedHorse(ONE_HUNDRED);
    }

    function testMintNftRevertsWhenNonExistentIdIsProvededAndNftMinted() public mintNft {
        vm.expectRevert();
        horseStore.feedHorse(TWO);
    }

    ////////////////////
    // test feedHorse //
    ////////////////////

    function testShouldFeedHorse() public mintNft {
        uint256 lastFedTimeStamp = block.timestamp;
        vm.prank(USER);
        horseStore.feedHorse(ZERO);
        assert(horseStore.horseIdToFedTimeStamp(ZERO) == lastFedTimeStamp);
    }

    ///////////////////////
    // test isHappyHorse //
    ///////////////////////

    function testIsHorseHappyShouldRevertWhenIdIsNotValid() public {
        vm.expectRevert(HorseStore.HorseStore__InvalidId.selector);
        vm.prank(USER);
        horseStore.isHappyHorse(ONE_HUNDRED);
    }

    function testIsHorseHappyReturnsFalse() public mintNft {
        vm.prank(USER);
        horseStore.feedHorse(ZERO);
        vm.warp(TWO_DAYS);
        vm.roll(block.number + TEN);
        assertEq(horseStore.isHappyHorse(ZERO), false);
    }

    function testIsHorseHappyReturnsTrue() public mintNft {
        vm.warp(TWO_DAYS);
        vm.roll(ONE_HUNDRED);
        vm.prank(USER);
        horseStore.feedHorse(ZERO);
        assertEq(horseStore.isHappyHorse(ZERO), true);
    }
}
