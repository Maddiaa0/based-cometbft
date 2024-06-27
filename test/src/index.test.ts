
// Get the json of the compiled contract
import {JsonRpcProvider, ethers, randomBytes} from "ethers";
import SimpleProposer from "../../proposer_contract/out/SimpleProposer.sol/SimpleProposer.json";
import { Wallet } from "ethers";
import {execSync, spawn} from "node:child_process";
import json2toml from "json2toml";
import toml from "toml";
import fs from "fs";

const SimpleProposerAbi = SimpleProposer.abi;
const defaultKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";

const COMET_EXE_PATH = "../cometbft/build/cometbft";
const NARGO_PROJECT_PATH = "../vrf";

function generateValidator() {
    // Call the comet bft gen-validator command
    const output = execSync(`${COMET_EXE_PATH} gen-validator`);
    const keyString = Buffer.from(output).toString("utf-8");
    // Remove before the first json delimiter
    const key = JSON.parse(keyString.slice(keyString.indexOf("{")));
    return key;
}

function generateNargoProof(params: object) {
    // Call the comet bft gen-validator command
    const proverTomlPath = NARGO_PROJECT_PATH + "/Prover.toml";
    const verifierTomlPath = NARGO_PROJECT_PATH + "/Verifier.toml";

    const ptoml =  json2toml(params);
    fs.writeFileSync(proverTomlPath, ptoml);

    execSync(`(cd ${NARGO_PROJECT_PATH} && nargo prove)`);

    const proof = fs.readFileSync(`${NARGO_PROJECT_PATH}/proofs/vrf.proof`);
    const proofHex = Buffer.from(proof.toString(), "hex").toString("hex");

    // Get the verifier toml path
    const data = fs.readFileSync(verifierTomlPath);
    const tomlData = toml.parse(data.toString());
    console.log(tomlData)

    return [proofHex, tomlData];
}

describe("Comet BFT alternative proposer test", () => {


    // NOTES:
    // We want to deploy proposer contract
    // We want to run 2 processes, and make sure that the proposer is the same in each process
    // We want to send the transactions pretending to be the two different proposers

    // NEXT:
    // add snarks to the process
    it("Should rip a proposal", async () => {
        const NUMBER_OF_ROUNDS = 10;
        const PROPOSAL_CONTRACT_ADDRESS = "0x9A9f2CCfdE556A7E9Ff0848998Aa4a0CFD8863AE";

        const provider = new JsonRpcProvider("http://localhost:8545");
        const wallet = new Wallet(defaultKey, provider);
        const proposerContract = new ethers.Contract(PROPOSAL_CONTRACT_ADDRESS, SimpleProposerAbi, wallet);

        // Send the transaction to the pro
        const nargoValPub = "0x" + "5d1d11c70e635ef6f290bf7a7da2e075eb9c634f".padStart(64, "0");
        const nargoSalt = "0x" + Buffer.from(randomBytes(30)).toString("hex");

        const defaultValdiatorPubKey = Buffer.from("5d1d11c70e635ef6f290bf7a7da2e075eb9c634f".padStart(64, "0"), "hex");
        const [proof, publicInputsMap] = generateNargoProof({proposer: nargoValPub, salt: nargoSalt});


        const publicInputs = [publicInputsMap.proposer, publicInputsMap.return];
        await proposerContract.submitVRF("0x" + proof, publicInputs);

    })
})


//

        // If i was able to get lots of validators running

        // Write the relevant config.json for the first validator - with public key pair
        // Use gen-validator command
        // const validator0 = generateValidator();
        // const validator1 = generateValidator();

        // const validators = [validator0];



        // Create an instance of the validator config file for each validator

        // for (const val of validators) {
        //     // 1. Write the validator file
        //     // We make a new folder for each of the validators 
            
        //     fs.writeFileSync(`./validator${val.index}`, JSON.stringify(val));

        //     // 2. Start an subprocess instance of comet BFT using this file
        //     spawn(COMET_EXE_PATH, ["--home", `./validator${val.index}`]);
        // }

        // Play the proposal game for the number of rounds that we would like to play
        // for (let i = 0; i < NUMBER_OF_ROUNDS; i++) {
            // For each of these rounds we want to play the proposer game

            // Send the proposal for each of the validators 
            // const txs = [];
            // for (const val of validators) {
                // TODO: Generate the snarks - can be done out of process
                // const salt = randomBytes(32);
                // const validatorPubkey = val.publicKey;
                
                // Send transaction to get the validator's bid
                // const tx = proposerContract.submitVRF(validatorPubkey, salt);
                // txs.push(tx);
            // }
            // Wait for all transactions to land
            // await Promise.all(txs);

        // }