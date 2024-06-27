import {JsonRpcProvider, ethers, randomBytes} from "ethers";
import SimpleProposer from "../../proposer_contract/out/SimpleProposer.sol/SimpleProposer.json" assert {type: "json"};
import { Wallet } from "ethers";
import {execSync, spawn} from "node:child_process";

const SimpleProposerAbi = SimpleProposer.abi;
const defaultKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";

const PROPOSAL_CONTRACT_ADDRESS = "0x2279B7A0a67DB372996a5FaB50D91eAA73d2eBe6";


async function main() {
    const provider = new JsonRpcProvider("http://localhost:8545");
    const wallet = new Wallet(defaultKey, provider);

    const contract = new ethers.Contract(PROPOSAL_CONTRACT_ADDRESS, SimpleProposerAbi, wallet);

    const proposer = await contract.getLeader();
    console.log(proposer);
}

main();