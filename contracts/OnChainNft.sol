// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; //>=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Base64.sol";
import "./AsciiFacesMetadata.sol";

/*
AsciiFaces

(X X)	(O O)	(O X)	(X O)
  ^       ^	      ^	      ^
 ___     ___	 ___	 ___


 */

contract OnChainNft is ERC721Enumerable, Ownable, AsciiFacesMetadata {
    using Counters for Counters.Counter;

    uint256 private maxTokenSupply;
    uint256 mintPriceWei;
    Counters.Counter private tokensAlreadyMinted;

    string private constant svgStartToEye =
        '<svg width="150" height="150" xmlns="http://www.w3.org/2000/svg"><rect height="150" width="150" fill="black"/><text y="5%" fill="white" text-anchor="start" font-size="18" xml:space="preserve" font-family="monospace"><tspan x="26%" dy="2.4em">(';

    string private constant svgEyeToEye = " ";

    string private constant svgEyeToEnd =
        ')</tspan><tspan x="40%" dy="1.2em">^</tspan><tspan x="32%" dy="1.2em">___</tspan></text></svg>';

    struct mintCombination {
        uint256 LeftEye;
        uint256 RightEye;
    }

    struct s_nftDetails {
        mintCombination createdMintCombination;
        uint256 nameIndex;
    }

    mapping(uint256 => s_nftDetails) private id_to_nftDetails;

    string[4] s_asciiFaceEyes = ["&#x20BF;", "&#x39E;", "X", "O"];
    string[5] s_asciiFaceNames = [
        "Son Goku",
        "Krillin",
        "Vegeta",
        "Piccolo",
        "Majin Boo"
    ];
    string[4] s_FaceNameAttributes = ["BTC", "ETH", "Crossed", "Round"];

    mintCombination[] arrayOfAvailableMintCombinations;

    uint256 private lastGetRandomNumber;
    bool useSeedWithTestnet; //1=seed with hash calc, 0=seed just given with example value in program

    event randomNumberInRangeTriggered(
        uint256 _randomNumberInRange,
        string _leftEye,
        string _rightEye,
        uint256 _faceSymmetery
    );

    constructor(bool _useSeedWithTestnet, uint256 _mintPriceWei)
        ERC721("AsciiFaces", "(O O)")
    {
        useSeedWithTestnet = _useSeedWithTestnet;
        defineMintCombinations();
        maxTokenSupply = arrayOfAvailableMintCombinations.length;
        mintPriceWei = _mintPriceWei;
    }

    function defineMintCombinations() private {
        for (uint256 j = 0; j < s_asciiFaceEyes.length; j++) {
            for (uint256 i = 0; i < s_asciiFaceEyes.length; i++) {
                arrayOfAvailableMintCombinations.push(mintCombination(j, i));
                maxTokenSupply += 1;
            }
        }
    }

    function totalSupply() public view override returns (uint256) {
        return maxTokenSupply;
    }

    function getNrOfLeftTokens() public view returns (uint256) {
        return (maxTokenSupply - tokensAlreadyMinted.current());
    }

    function registerGeneratedToken(
        uint256 _tokenID,
        mintCombination _mintCombination
    ) private {
        //add values to mapping, so you could fetch

        id_to_nftDetails[_tokenID] = s_nftDetails(
            _mintCombination, //eye index left, eye index right
            createRandomNumberInRange(s_asciiFaceNames.length) //name index
        );
    }

    function createRandomNumber() private returns (uint256) {
        //idea of creating a random number by using a value from the wallet address and mix it up with modulo
        if (useSeedWithTestnet) {
            lastGetRandomNumber = uint256(
                (
                    keccak256(
                        abi.encodePacked(
                            (msg.sender),
                            blockhash(block.number - 1),
                            block.timestamp,
                            lastGetRandomNumber
                        )
                    )
                )
            );
        } else {
            lastGetRandomNumber = lastGetRandomNumber + 7;
        }

        return lastGetRandomNumber;
    }

    function createRandomNumberInRange(uint256 _range)
        private
        returns (uint256)
    {
        return createRandomNumber() % _range;
    }

    /*
    function createMetadataAttributes(
        uint256 _tokenId,
        mintCombination memory _activeMintCombination
    ) private {
        //symmetry property
        if (_activeMintCombination.LeftEye == _activeMintCombination.RightEye) {
            //Full symmetry
            id_to_FaceSymmetry[_tokenId] = 100;
        } else {
            //half symmetry
            id_to_FaceSymmetry[_tokenId] = 50;
        }
        //Eye property
        id_to_Eyes[_tokenId][0] = bytes(
            s_asciiFaceEyes[_activeMintCombination.LeftEye]
        );
        id_to_Eyes[_tokenId][1] = bytes(
            s_asciiFaceEyes[_activeMintCombination.RightEye]
        );
    }*/

    function mint() public payable returns (bool success) {
        // pre work for mint - start
        require(
            getNrOfLeftTokens() > 0,
            "already minted out, check secondary market"
        );
        require(msg.value >= mintPriceWei, "sent amount too low for minting");
        // pre work for mint - end

        uint256 currentMintedTokenId = tokensAlreadyMinted.current();

        //more readable
        //create random number in range of available combinations/array length
        uint256 resultedRandomNumber = createRandomNumberInRange(
            arrayOfAvailableMintCombinations.length
        );

        mintCombination
            memory randomGeneratedEyesMintCombination = arrayOfAvailableMintCombinations[
                resultedRandomNumber
            ];

        //observe random number and used eyes with event
        emit randomNumberInRangeTriggered(
            resultedRandomNumber,
            s_asciiFaceEyes[randomGeneratedEyesMintCombination.LeftEye],
            s_asciiFaceEyes[randomGeneratedEyesMintCombination.RightEye]
        );

        _safeMint(msg.sender, currentMintedTokenId);

        registerGeneratedToken(
            currentMintedTokenId,
            randomGeneratedEyesMintCombination
        );

        tokensAlreadyMinted.increment();

        //remove mint combination from available ones, every face is different
        removeMintCombinationUnordered(resultedRandomNumber);

        return true; //success
    }

    function removeMintCombinationUnordered(uint256 _indexToRemove) private {
        require(
            _indexToRemove <= arrayOfAvailableMintCombinations.length ||
                arrayOfAvailableMintCombinations.length > 0,
            "index out of range"
        );
        if (_indexToRemove == arrayOfAvailableMintCombinations.length - 1) {
            arrayOfAvailableMintCombinations.pop();
        } else {
            arrayOfAvailableMintCombinations[
                _indexToRemove
            ] = arrayOfAvailableMintCombinations[
                arrayOfAvailableMintCombinations.length - 1
            ];
            arrayOfAvailableMintCombinations.pop();
        }
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        return buildMetadata(_tokenId);
        //return buildMetadata(_tokenId);
    }

    function buildMetadata(uint256 _tokenId)
        public
        view
        returns (string memory)
    {
        require(_exists(_tokenId), "Nonexistent token"); //ToDo: this is already checked by tokenURI call, we could leave this out

        string memory generatedName = "";
        string memory faceSymmetry = "";

        if (
            id_to_nftDetails[_tokenId].createdMintCombination.LeftEye ==
            id_to_nftDetails[_tokenId].createdMintCombination.RightEye
        ) {
            faceSymmetry = "100"; //left eye == right eye
            //this results in sth like: Son Goku the full BTC eyed AsciiFace
            generatedName = abi.encodePacked(
                s_asciiFaceNames[id_to_nftDetails[_tokenId].nameIndex],
                " the full ",
                s_FaceNameAttributes[
                    id_to_nftDetails[_tokenId].createdMintCombination.LeftEye
                ],
                " eyed AsciiFace"
            );
        } else {
            faceSymmetry = "50"; //left eye == right eye
            //this results in sth like: Son Goku the half BTC, half ETH eyed AsciiFace
            generatedName = abi.encodePacked(
                s_asciiFaceNames[id_to_nftDetails[_tokenId].nameIndex],
                " the half ",
                s_FaceNameAttributes[
                    id_to_nftDetails[_tokenId].createdMintCombination.LeftEye
                ],
                ", half ",
                s_FaceNameAttributes[
                    id_to_nftDetails[_tokenId].createdMintCombination.RightEye
                ],
                " eyed AsciiFace"
            );
        }

        //ToDo: name creation, depending on name index and eye symmetry

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name": "',
                                generatedName,
                                '", "description": "Fully onchain generated AsciiFaces", "image": "data:image/svg+xml;base64,',
                                id_to_asciiFace[_tokenId], //ToDo: need to create svg here with eye attributes
                                '","attributes":[{"trait_type": "Facesymmetry","value":"',
                                faceSymmetry,
                                '%"},{"trait_type":"EyeLeft","value":"',
                                s_asciiFaceEyes[
                                    id_to_nftDetails[_tokenId]
                                        .createdMintCombination
                                        .LeftEye
                                ],
                                '"},{"trait_type":"EyeRight","value":"',
                                s_asciiFaceEyes[
                                    id_to_nftDetails[_tokenId]
                                        .createdMintCombination
                                        .RightEye
                                ],
                                '"}]}'
                            )
                        )
                    )
                )
            );
    }

    //getters start
    //get base64 data from given tokenID -> paste in browser -> svg from tokenId
    function getAsciiFace(uint256 _tokenID)
        public
        view
        returns (string memory)
    {
        require(_tokenID <= maxTokenSupply, "given tokenId is invalid");

        return id_to_asciiFace[_tokenID];
    }

    function getBalance() public view returns (uint256) {
        return (address(this).balance);
    }

    //getters end
}
