// SPDX-License-Identifier: ISC
pragma solidity ^0.8.19;

import { IFrxEth } from "../contracts/IFrxEth.sol";
import { deployFraxEtherRedemptionQueue } from "../script/DeployFraxEtherRedemptionQueue.sol";
import { console } from "frax-std/FraxTest.sol";
import { FraxEtherRedemptionQueueParams, FraxEtherRedemptionQueue } from "../contracts/FraxEtherRedemptionQueue.sol";
import { FraxTest } from "frax-std/FraxTest.sol";
import { SigUtils } from "./utils/SigUtils.sol";
import "./Constants.sol" as Constants;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BaseTest is FraxTest, Constants.Helper {
    uint256 internal redeemerPrivateKey;
    address payable internal redeemer;

    IFrxEth public frxETH = IFrxEth(0x5E8422345238F34275888049021821E8E08CAa1f);
    SigUtils public sigUtils_frxETH;

    FraxEtherRedemptionQueue public redemptionQueue;
    address payable public redemptionQueueAddress;


    function defaultSetup() internal {
        vm.createSelectFork(vm.envString("MAINNET_RPC_URL"), 17_105_462);

        // Deploy the contracts
        // ======================

        // Used for the permit test
        sigUtils_frxETH = new SigUtils(frxETH.DOMAIN_SEPARATOR());

        // Deploy the FraxEtherRedemptionQueue
        redemptionQueueAddress = payable(deployFraxEtherRedemptionQueue()._address);
        redemptionQueue = FraxEtherRedemptionQueue(redemptionQueueAddress);

        // Set up the redeemer
        redeemerPrivateKey = 0xA11CE;
        redeemer = payable(vm.addr(redeemerPrivateKey));

        // Give the redeemer 100 frxETH
        hoax(Constants.Mainnet.FRXETH_WHALE);
        frxETH.transfer(redeemer, 100e18);

        // Label the redeemer
        vm.label(redeemer, "redeemer");

        // Set the fee recipient
        hoax(Constants.Mainnet.TIMELOCK_ADDRESS);
        redemptionQueue.setFeeRecipient(Constants.Mainnet.FRXETH_WHALE);
    }

    
}
