// SPDX-License-Identifier: MIT

pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract PosterFactory is ERC721, ERC721Enumerable, ERC721Burnable, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint256 private _nextposterId;

    struct PosterInfo {
        uint16 height;
        uint16 width;
        bytes pixelValues;
    }

    mapping(uint256 => PosterInfo) public posters;
    mapping(uint256 => mapping(uint256 => address)) public pixelOwners;

    constructor(address defaultAdmin, address minter) ERC721("Poster", "POSTER") {
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(MINTER_ROLE, minter);
    }

    function createPoster(address to, uint16 height, uint16 width)
        public
        onlyRole(MINTER_ROLE)
        returns (uint256 posterId)
    {
        uint256 pixelValuesLength = width * height;
        bytes memory pixelValues = new bytes(pixelValuesLength);
        posterId = _nextposterId++;
        _safeMint(to, posterId);
        posters[posterId] = PosterInfo(width, height, pixelValues);
    }

    function getPixelIdOwner(uint256 posterId, uint256 pixelId) private view returns (address) {
        if (pixelOwners[posterId][pixelId] != address(0)) {
            return pixelOwners[posterId][pixelId];
        } else {
            return ownerOf(posterId);
        }
    }

    function setPixel(uint256 posterId, uint256 x, uint256 y, bytes1 color) public {
        PosterInfo storage poster = posters[posterId];

        require(x < poster.width, "x out of bounds");
        require(y < poster.height, "y out of bounds");

        uint256 pixelId = y * poster.width + x;

        require(getPixelIdOwner(posterId, pixelId) == msg.sender, "Caller is not the owner of the pixel");

        poster.pixelValues[pixelId] = color;
    }

    // The following functions are overrides required by Solidity.

    function _update(address to, uint256 posterId, address auth)
        internal
        override(ERC721, ERC721Enumerable)
        returns (address)
    {
        return super._update(to, posterId, auth);
    }

    function _increaseBalance(address account, uint128 value) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
