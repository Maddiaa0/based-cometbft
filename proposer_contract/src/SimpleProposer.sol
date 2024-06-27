// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {UltraVerifier as VrfVerifier} from "./vrfVerifier.sol";

// Note: when reading this contract, please note i am not prioritizing efficiency in anyway
// do not remember me like this
contract SimpleProposer {
    mapping(uint256 slot => bytes32 pubkey) public $slotProposer;
    mapping(uint256 slot => bytes32 winningChallenge) public $loterryWinnigValues;

    // A registry of who the valid proposers are
    mapping(bytes32 pubkey => bool proposer) public $proposerMapping;

    uint256 public $currentSlot = 0;

    // SnARks MeNTIONed - Take a shot!
    VrfVerifier verifier;

    constructor() {
        $loterryWinnigValues[0] = bytes32(type(uint256).max);
        verifier = new VrfVerifier();
    }
    
    // Proposer submits that they got the lowest result in a "vrf" just a snark of a hash function, not even a real hash function
    // it is currently pedersen but i digress
    function submitVRF(bytes calldata proof, bytes32[] calldata publicInputs) public {

        bytes32 currentWinningChallenge = $loterryWinnigValues[$currentSlot];

        bytes32 proposer = publicInputs[0];
        bytes32 vrfResult = publicInputs[1];

        verifier.verify(proof, publicInputs);

        // If somebody can submit the smaller winning challenge, then they win
        if (vrfResult < currentWinningChallenge) {
            $loterryWinnigValues[$currentSlot] = vrfResult;
            $slotProposer[$currentSlot] = proposer;
        }
    }

    
    function getLeader() public view returns (bytes32) {
        return $slotProposer[$currentSlot];
    }

    // Progress the slot
    // We set the loterry winning values to uint256 max as it is the minimum that will win
    function progressSlot() public {
        $currentSlot += 1;
        $loterryWinnigValues[$currentSlot] = bytes32(type(uint256).max);
    }

    // Insecure ofcourse
    function addProposer(bytes32 pubKey) public {
        $proposerMapping[pubKey] = true;
    }
}
