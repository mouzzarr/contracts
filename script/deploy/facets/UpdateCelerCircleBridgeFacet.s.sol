// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import { UpdateScriptBase } from "./utils/UpdateScriptBase.sol";
import { stdJson } from "forge-std/StdJson.sol";
import { DiamondCutFacet, IDiamondCut } from "lifi/Facets/DiamondCutFacet.sol";
import { CelerCircleBridgeFacet } from "lifi/Facets/CelerCircleBridgeFacet.sol";

contract DeployScript is UpdateScriptBase {
    using stdJson for string;

    function run()
        public
        returns (address[] memory facets, bytes memory cutData)
    {
        address facet = json.readAddress(".CelerCircleBridgeFacet");

        // CelerCircleBridgeFacet
        bytes4[] memory exclude;
        buildDiamondCut(
            getSelectors("CelerCircleBridgeFacet", exclude),
            facet
        );
        if (noBroadcast) {
            if (cut.length > 0) {
                cutData = abi.encodeWithSelector(
                    DiamondCutFacet.diamondCut.selector,
                    cut,
                    address(0),
                    ""
                );
            }
            return (facets, cutData);
        }

        vm.startBroadcast(deployerPrivateKey);
        if (cut.length > 0) {
            cutter.diamondCut(cut, address(0), "");
        }
        facets = loupe.facetAddresses();

        vm.stopBroadcast();
    }
}