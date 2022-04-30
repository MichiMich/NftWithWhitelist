// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; //>=0.8.0 <0.9.0;

//use IonChain, define functions
import "./Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/*
call looks like this
function buildMetadata(id_to_asciiFace[_tokenId], id_to_FaceSymmetry[_tokenId] , id_to_Eyes[_tokenId])

 */

abstract contract AsciiFacesMetadata {
    function buildMetadata(
        string memory _base64EncodedSvgData,
        uint8 _faceSymmetry,
        bytes[2] memory _asciiEyes
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name": "AsciiFaces", ',
                                '"description": "Fully onchain generated AsciiFaces", "image": "data:image/svg+xml;base64,',
                                _base64EncodedSvgData,
                                '","attributes":[{"trait_type": "Facesymmetry","value":"',
                                Strings.toString(_faceSymmetry),
                                '%"},{"trait_type":"EyeLeft","value":"',
                                _asciiEyes[0],
                                '"},{"trait_type":"EyeRight","value":"',
                                _asciiEyes[1],
                                '"}]}'
                            )
                        )
                    )
                )
            );
    }
}
