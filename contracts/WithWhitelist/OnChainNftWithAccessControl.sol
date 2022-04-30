// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; //>=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "../AsciiFacesMetadata.sol";
import "../Base64.sol";

/*
AsciiFaces

(X X)	(O O)	(O X)	(X O)
  ^       ^	      ^	      ^
 ___     ___	 ___	 ___


 */

contract OnChainNftWithAccessControl is
    ERC721Enumerable,
    Ownable,
    AsciiFacesMetadata
{
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

    string[2] AsciiFaceEyes = ["X", "O"];

    mintCombination[] arrayOfAvailableMintCombinations;

    mapping(uint256 => string) id_to_asciiFace;
    mapping(uint256 => uint8) id_to_FaceSymmetry;
    mapping(uint256 => bytes[2]) id_to_Eyes;

    uint256 private lastGetRandomNumber;
    bool useSeedWithTestnet; //1=seed with hash calc, 0=seed just given with example value in program
    bool publicMintActive; //0=whitelist activated, 1=whitelist deactivated->public mint
    event randomNumberInRangeTriggered(
        uint256 _randomNumberInRange,
        string _leftEye,
        string _rightEye
    );

    //other contract dependencies
    address accessControlContractAddress;

    constructor(
        bool _useSeedWithTestnet,
        uint256 _mintPriceWei,
        address _accessControlContractAddress
    ) ERC721("AsciiFaces", "(O O)") {
        require(
            _accessControlContractAddress != address(0),
            "accessControlContractAddress undefined"
        );
        accessControlContractAddress = _accessControlContractAddress;
        useSeedWithTestnet = _useSeedWithTestnet;
        defineMintCombinations();
        maxTokenSupply = arrayOfAvailableMintCombinations.length;
        mintPriceWei = _mintPriceWei;
    }

    function defineMintCombinations() private {
        for (uint256 j = 0; j < AsciiFaceEyes.length; j++) {
            for (uint256 i = 0; i < AsciiFaceEyes.length; i++) {
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
        string memory _generatedData
    ) private {
        //add values to mapping, so you could fetch
        id_to_asciiFace[_tokenID] = _generatedData;
    }

    function enablePublicMint() public onlyOwner {
        publicMintActive = true;
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
            AsciiFaceEyes[_activeMintCombination.LeftEye]
        );
        id_to_Eyes[_tokenId][1] = bytes(
            AsciiFaceEyes[_activeMintCombination.RightEye]
        );
    }

    function mint() public payable returns (bool success) {
        // pre work for mint - start
        require(
            getNrOfLeftTokens() > 0,
            "already minted out, check secondary market"
        );
        require(msg.value >= mintPriceWei, "sent amount too low for minting");

        if (!publicMintActive) {
            //check if access is granted
            require(checkIfWhitelisted(msg.sender), "not whitelisted");
        }

        uint256 currentMintedTokenId = tokensAlreadyMinted.current();

        // pre work for mint - end
        /*
        //short
        bytes memory createdSvgNft = bytes(
            abi.encodePacked(
                svgStartToEye,
                arrayOfAvailableMintCombinations[
                    createRandomNumberInRange(
                        arrayOfAvailableMintCombinations.length
                    )
                ],
                svgEyeToEye,
                svgEyeToEnd
            )
        );
        */

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
            AsciiFaceEyes[randomGeneratedEyesMintCombination.LeftEye],
            AsciiFaceEyes[randomGeneratedEyesMintCombination.RightEye]
        );

        bytes memory createdSvgNft = bytes(
            abi.encodePacked(
                svgStartToEye,
                AsciiFaceEyes[randomGeneratedEyesMintCombination.LeftEye], //X or O
                svgEyeToEye,
                AsciiFaceEyes[randomGeneratedEyesMintCombination.RightEye], //X or O
                svgEyeToEnd
            )
        );

        _safeMint(msg.sender, currentMintedTokenId);

        registerGeneratedToken(
            currentMintedTokenId,
            string(Base64.encode(createdSvgNft))
        );

        //metadata attributes
        createMetadataAttributes(
            currentMintedTokenId,
            randomGeneratedEyesMintCombination
        );

        tokensAlreadyMinted.increment();

        //remove mint combination from available ones, every face is different
        removeMintCombinationUnordered(resultedRandomNumber);

        return true; //success
    }

    function checkIfWhitelisted(address _addressToBeChecked)
        public
        view
        returns (bool)
    {
        //no address 0 require needed, because it is given in the constructor
        //nonetheless it could go wrong if the address would not fix
        accessControlImpl accessControl = accessControlImpl(
            accessControlContractAddress
        );
        return (accessControl.isAccessGranted(_addressToBeChecked));
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
        return
            buildMetadata(
                id_to_asciiFace[_tokenId],
                id_to_FaceSymmetry[_tokenId],
                id_to_Eyes[_tokenId]
            );
        //return buildMetadata(_tokenId);
    }

    //getters - start
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

    //getters - end
}

//add other contract dependencies - start
abstract contract accessControlImpl {
    function isAccessGranted(address _adressToBeChecked)
        public
        view
        virtual
        returns (bool);
    //add other contract dependencies - end
}
