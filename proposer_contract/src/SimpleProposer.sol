// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Note: when reading this contract, please note i am not prioritizing efficiency in anyway
// do not remember me like this
contract SimpleProposer {
    // Next steps:
    // - We probably want the votes to be weighted by stake in some way - rather than have all votes be equal

    mapping(uint256 slot => bytes32 pubkey) public $slotProposer;
    mapping(uint256 slot => bytes32 winningChallenge) public $loterryWinnigValues;

    // A registry of who the valid proposers are
    mapping(bytes32 pubkey => bool proposer) public $proposerMapping;

    uint256 public $currentSlot = 0;
    
    // Stage 0 - we mock the vrf (it is not verifiable or random at all)
    // Stage 1 - we accept values proposers that submit a snark of their public key and some randomness result
    // any sufficient pre image resistant hash function will do
    // The SNARK will:
    // - need to prove who the proposer is who they say they are
    // - need to prove k
    function submitVRF(bytes32 proposer, bytes32 randomness) public {
        if (!$proposerMapping[proposer]) {
            revert("Proposer not in registry");
        }

        bytes32 currentWinningChallenge = $loterryWinnigValues[$currentSlot];

        // TODO: replace with snark
        bytes32 newChallenge = sha256(abi.encodePacked(proposer, randomness));

        // If somebody can submit the smaller winning challenge, then they win
        if (newChallenge < currentWinningChallenge) {
            $loterryWinnigValues[$currentSlot] = newChallenge ;
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
