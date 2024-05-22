// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@forge-std/Test.sol";
import "@openzeppelin/access/IAccessControl.sol";

import "@src/PosterFactory.sol";

contract PosterFactoryTest is Test {
    PosterFactory private posterFactory;

    address private admin = address(0x1);
    address private minter = address(0x2);
    address private user = address(0x3);

    function setUp() public {
        posterFactory = new PosterFactory(admin, minter);
    }

    function testCreatePoster() public {
        vm.prank(minter);
        posterFactory.createPoster(user, 10, 10);
        assertEq(posterFactory.balanceOf(user), 1);
    }

    function testCreatePosterUnauthorized() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector, address(user), posterFactory.MINTER_ROLE()
            )
        );
        vm.prank(user);
        posterFactory.createPoster(user, 10, 10);
    }
}
