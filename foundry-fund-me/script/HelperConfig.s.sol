//1.Deploy moks when we are on a local anvil chain
//2 keep track of contract address across different chains 

//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";
contract HelperConfig is Script {
    //if we are on a local anvil, we deploy mocks
    //otherwise, grap the existing address form ethe live network  
    NetworkConfig public activeNetworkConfig;
    uint8 public constant DECIMAL=8;
    int256 public constant INITIAL_PRICE=200e8;
    struct NetworkConfig{
        address priceFeed;
    }
    constructor(){
        //se il chainid è uguale a quello di sepolia prendere da chainlink
        if(block.chainid==11155111){
            activeNetworkConfig=getSepoliaEthConfig();
        }
        else{
            activeNetworkConfig=getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns(NetworkConfig memory) {
        //price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed:0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;

    }
    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed!=address(0))
        {
            return activeNetworkConfig;
        }

        // mocks == fake contract
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed= new MockV3Aggregator(DECIMAL,INITIAL_PRICE);
        vm.stopBroadcast();
        NetworkConfig memory anvilConfig= NetworkConfig({
            priceFeed:address(mockPriceFeed)
        });
        return anvilConfig;
    }
    
}