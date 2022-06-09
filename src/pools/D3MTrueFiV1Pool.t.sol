// SPDX-FileCopyrightText: © 2021-2022 Dai Foundation <www.daifoundation.org>
// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2021-2022 Dai Foundation
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

pragma solidity ^0.8.14;

import { D3MHub } from "../D3MHub.sol";
import { D3MMom } from "../D3MMom.sol";
import { D3MTrueFiV1Pool } from "./D3MTrueFiV1Pool.sol";

import {
    DaiLike,
    PortfolioFactoryLike,
    PortfolioLike,
    ERC20Like,
    WhitelistVerifierLike,
    VatLike
} from "../tests/interfaces/interfaces.sol";

import { D3MTrueFiV1Plan } from "../plans/D3MTrueFiV1Plan.sol";
import { AddressRegistry }   from "../tests/integration/AddressRegistry.sol";
import { D3MPoolBaseTest, Hevm } from "./D3MPoolBase.t.sol";

contract D3MTrueFiV1PoolTest is AddressRegistry, D3MPoolBaseTest {
    PortfolioFactoryLike portfolioFactory;
    PortfolioLike portfolio;

    function setUp() public override {
        hevm = Hevm(address(bytes20(uint160(uint256(keccak256("hevm cheat code"))))));

        dai = DaiLike(DAI);
        vat = VAT;
        hub = address(new D3MHub(vat, DAI_JOIN));

        _setUpTrueFiDaiPortfolio();

        d3mTestPool = address(new D3MTrueFiV1Pool(address(dai), address(portfolio), hub));
    }

    function test_works() public {
        assertEq(portfolio.manager(), address(this));
    }

    /************************/
    /*** Helper Functions ***/
    /************************/

    function _setUpTrueFiDaiPortfolio() internal {
        portfolioFactory = PortfolioFactoryLike(MANAGED_PORTFOLIO_FACTORY_PROXY);

        // Grant address(this) auth access to factory
        hevm.store(MANAGED_PORTFOLIO_FACTORY_PROXY, bytes32(uint256(0)), bytes32(uint256(uint160(address(this)))));
        portfolioFactory.setIsWhitelisted(address(this), true);

        portfolioFactory.createPortfolio("TrueFi-D3M-DAI", "TDD", ERC20Like(DAI), WhitelistVerifierLike(GLOBAL_WHITELIST_LENDER_VERIFIER), 60 * 60 * 24 * 30, 1_000_000 ether, 20);
        uint256 portfoliosCount = portfolioFactory.getPortfolios().length;
        portfolio = PortfolioLike(portfolioFactory.getPortfolios()[portfoliosCount - 1]);
    }
}