// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract AccessControl is Ownable {
    mapping(address => uint256) private mapAccessAllowedAddresses; //holds address and allowed nr of allowed elements to be minted by this address
    address[] private addedAddresses; //holds all added addresses
    address nftContractAddress; //used for feedback of minted tokens

    function linkNftContractAddress(address _nftContractAddress)
        public
        onlyOwner
    {
        require(_nftContractAddress != address(0), "null address given");
        nftContractAddress = _nftContractAddress;
    }

    function addAddressToAccessAllowed(
        address _addressToBeAdded,
        uint256 _nrOfAllowedElements
    ) public onlyOwner {
        require(_addressToBeAdded != address(0), "null address given");
        require(_nrOfAllowedElements > 0, "nr of allowed elements <= 0");
        require(
            mapAccessAllowedAddresses[_addressToBeAdded] !=
                _nrOfAllowedElements,
            "given data already added"
        );
        if (mapAccessAllowedAddresses[_addressToBeAdded] == 0) {
            //address not yet added
            addedAddresses.push(_addressToBeAdded);
            console.log(_addressToBeAdded, "added to allowed ones");
        }
        mapAccessAllowedAddresses[_addressToBeAdded] = _nrOfAllowedElements; //set nr of allowed elements to be minted by this address
    }

    function isAccessGranted(address _adressToBeChecked)
        public
        view
        returns (bool)
    {
        require(_adressToBeChecked != address(0), "null address given");
        if (mapAccessAllowedAddresses[_adressToBeChecked] > 0) {
            //so this address would be able to mint tokens, now we check if he already did
            require(
                nftContractAddress != address(0),
                "nftContractAddress not set"
            );
            //call other contract functions
            nftContractImpl nftContract = nftContractImpl(nftContractAddress);
            console.log("balanceOf", nftContract.balanceOf(_adressToBeChecked));
            if (
                nftContract.balanceOf(_adressToBeChecked) <
                mapAccessAllowedAddresses[_adressToBeChecked]
            ) {
                console.log(_adressToBeChecked, "allowed");
                return (true);
            }
        }
    }

    function getNrOfAllowedElementsPerAddress(address _adressToBeChecked)
        public
        view
        returns (uint256)
    {
        require(_adressToBeChecked != address(0), "null address given");
        // require(
        //     mapAccessAllowedAddresses[_adressToBeChecked] > 0,
        //     "address was never added"
        // ); this reverts, we want to get the nur, so we will return 0
        return (mapAccessAllowedAddresses[_adressToBeChecked]);
    }

    function getRemainingNrOfElementsPerAddress(address _adressToBeChecked)
        public
        view
        returns (uint256)
    {
        require(_adressToBeChecked != address(0), "null address given");
        nftContractImpl nftContract = nftContractImpl(nftContractAddress);
        return (mapAccessAllowedAddresses[_adressToBeChecked] -
            nftContract.balanceOf(_adressToBeChecked));
    }

    function removeAdressFromMapping(address _adressToBeRemoved) private {
        require(_adressToBeRemoved != address(0), "null address given");
        delete mapAccessAllowedAddresses[_adressToBeRemoved];
    }

    function getCurrentNrOfElementsInMapping() public view returns (uint256) {
        return (addedAddresses.length);
    }

    function removeAllFromAccessAllowed() public onlyOwner {
        uint256 nrOfDeletesNeeded = addedAddresses.length;
        for (uint256 i; i < nrOfDeletesNeeded; i++) {
            removeAddressFromAccessAllowed(addedAddresses[0]); //refer always deleting first element, because wer reduce array after this call
        }
        delete addedAddresses;
    }

    function removeAddressFromAccessAllowed(address _addressToRemove)
        public
        onlyOwner
    {
        require(_addressToRemove != address(0), "null address given");
        require(
            mapAccessAllowedAddresses[_addressToRemove] > 0,
            "address not found added"
        );
        for (uint256 i; i < addedAddresses.length; i++) {
            if (addedAddresses[i] == _addressToRemove) {
                removeAdressFromMapping(_addressToRemove); //remove from mapping
                removeAddressByIndex(i);
                break;
            }
        }
    }

    function getArrayOfAddresses() public view returns (address[] memory) {
        return addedAddresses;
    }

    function removeAddressByIndex(uint256 _indexToRemove) private {
        require(
            _indexToRemove <= addedAddresses.length ||
                addedAddresses.length > 0,
            "index out of range"
        );
        if (_indexToRemove == addedAddresses.length - 1) {
            addedAddresses.pop();
        } else {
            addedAddresses[_indexToRemove] = addedAddresses[
                addedAddresses.length - 1
            ];
            addedAddresses.pop();
        }
    }
}

abstract contract nftContractImpl {
    function balanceOf(address owner) public view virtual returns (uint256);
}
