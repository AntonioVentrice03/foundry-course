// SPDX-License-Identifier:MIT
pragma solidity ^0.8.18; 

import "forge-std/Script.sol";
import {SimpleStorage} from "../src/SimpleStorage.sol";

contract DeploySimpleStorage is Script{
    function run() external returns (SimpleStorage) {
        //comando della libreria di foundry
        vm.startBroadcast();
        //inseriamo tutte le transazione che vogliamo inviare 
        //crea un contratto di simpleStorage
        SimpleStorage simpleStorage=new SimpleStorage();
        vm.stopBroadcast();
        return simpleStorage;
    }

}