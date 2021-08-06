// SPDX-License-Identifier: agpl-3.0
pragma solidity =0.8.0;

//import {Amm} from "./Amm.sol";
import {IAmm} from "../../interfaces/a.sol";
import {Errors} from "../libraries/helpers/Errors.sol";
import {Calc} from "../libraries/math/Calc.sol";
import {BlockContext} from "../libraries/helpers/BlockContext.sol";
import {IPositionHouse} from "../../interfaces/IPositionHouse.sol";
import {IInsuranceFund} from  "../../interfaces/IInsuranceFund.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
//import "../../interfaces/a.sol";

/**
* @notice This contract is main of Position
* Manage positions with action like: openPostion, closePosition,...
*/

contract PositionHouse is IPositionHouse, BlockContext {
    using SafeMath for uint256;
    using Calc for uint256;


    // contract dependencies
    IInsuranceFund public insuranceFund;
    mapping(address => bool) whitelist;
    mapping(address => bool) blacklist;
    //    address[] whitelist;

    // event position house
    event MarginChanged(address indexed sender, address indexed amm, uint256 amount, int256 fundingPayment);


    function queryOrder(IAmm amm) public view returns (IAmm.Position[] memory positions){
        address trader = msg.sender;
        positions = amm.queryPositions(trader);
    }

    function getOrder(IAmm amm, int256 tick, uint256 index) public view returns (IAmm.Order memory order){

        order = amm.getOrder(msg.sender, tick, index);
        //        return 0;
    }

    function openPosition(
        IAmm _amm,
        IAmm.Side _side,
        uint256 _amountAssetQuote,
        uint256 _amountAssetBase,
        uint16 _leverage,
        uint256 _margin
    ) public {

        // TODO require something here
        require(
            _amountAssetBase != 0 &&
            _amountAssetQuote != 0,
            Errors.VL_INVALID_AMOUNT
        );
        address trader = msg.sender;


        // TODO open market: calc liquidity filled.
        // if can cross tick => filled order next tick. Update filled liquidity, filled index

        //
        //        Side side,
        //        uint256 quoteAmount,
        //        uint256 leverage,
        //        uint256 margin,
        //        address _trader
        _amm.openMarket(IAmm.ParamsOpenMarket(
                _side,
                _amountAssetQuote,
                _leverage,
                _margin,
                msg.sender));


        //        //TODO open market position
        //        int256 positionSize = getUnadjustedPosition(params._amm, _trader).size.toInt();
        //
        //        bool isNewPosition = positionSize.size == 0 ? true : false;
        //
        //        if (isNewPosition) {
        //
        //
        //            // TODO increment position
        //
        //
        //        } else {
        //            // TODO openreverse
        //
        //        }
        // TODO handle open success, update position
        {

        }


    }

    function openLimitOrder(
        IAmm _amm,
        uint256 _amountAssetBase,
        uint256 _amountAssetQuote,
        uint256 _limitPrice,
        IAmm.Side _side,
        int256 _tick,
        uint256 _leverage) public {


        // TODO require for openLimitOrder
        int256 _currentTick = _amm.getCurrentTick();
        if (_side == IAmm.Side.BUY) {
            require(_tick < _currentTick, "Your ordered price is higher than current price");
        } else {
            require(_tick > _currentTick, "Your ordered price is lower than current price");
        }

        address _trader = msg.sender;


        // TODO get old position of _trader
        // positionSize > 0 => LONG
        // positionSize < 0 => SHORT
        //        int256 positionSize = getUnadjustedPosition(params._amm, _trader).size.toInt();


        // TODO calc tick
        //        int tick = _limitAmountPriceBase;



        uint256 nextIndex = _amm.openLimit(
            _amountAssetBase,
            _amountAssetQuote,
            _limitPrice,
            _side,
            _tick,
            _leverage
        );


        //        _amm.positionMap[_trader].push(Position({
        //        index : nextIndex,
        //        tick : _tick})
        //        );
        //

        _amm.addPositionMap(_trader, _tick, nextIndex);


        // TODO Save position

        // TODO emit event

    }


    function openStopLimit(IAmm.Side _side, uint256 _orderPrice, uint256 _limitPrice, uint256 _stopPrice, uint256 _amountAssetQuote) public {

        //
        //        uint256 currentPrice;
        //        // TODO require for openStopLimit
        //        while (_stopPrice != currentPrice) {
        //            currentPrice = calcCurrentPrice();
        //        }
        //
        //        uint256 currentPrice = calcCurrentPrice();
        //        uint256 remainSize = _amountAssetQuote.div(_orderPrice);
        //
        //
        //        while (remainSize != 0) {
        //            if (currentPrice < _orderPrice) {
        //                // tradableSize can trade for trader
        //                uint256 tradableSize = calcTradableSize(currentPrice, _orderPrice, _amountAssetQuote);
        //                // TODO open partial
        //
        //                // update remainSize
        //                remainSize = remainSize.sub(tradableSize);
        //            }
        //        }
    }

    // Mostly done calc formula limit order
    //    function calcTradableSize(Side _side, uint256 _orderPrice, uint256 _limitPrice, uint256 _remainSize) private returns (uint256) {
    //
    //
    //        // TODO calcCurrentPrice
    //        uint256 _currentPrice = calcCurrentPrice();
    //        uint256 amountQuoteReserve = getQuoteReserve();
    //        uint256 amountBaseReserve = getBaseReserve();
    //
    //        uint256 priceAfterTrade = _orderPrice.pow(2).div(_currentPrice);
    //        if (priceAfterTrade.sub(_currentPrice).abs() > _limitPrice.sub(_currentPrice).abs()) {
    //            priceAfterTrade = _limitPrice;
    //        }
    //
    //        uint256 amountQuoteReserveAfter = priceAfterTrade.sqrt().sub(_currentPrice.sqrt()).mul(liquidity.sqrt()).add(amountQuoteReserve);
    //
    //        uint256 amountBaseReserveAfter = liquidity.div(amountQuoteReserveAfter);
    //
    //        uint256 tradableSize = amountBaseReserve.sub(amountBaseReserveAfter).abs();
    //
    //        if (_remainSize < tradableSize && _side == Side.BUY) {
    //            amountBaseReserveAfter = amountBaseReserve.sub(_remainSize);
    //            amountQuoteReserveAfter = amountQuoteReserve.add(_orderPrice.mul(_remainSize));
    //            setQuoteReserve(amountQuoteReserveAfter);
    //            setBaseReserve(amountBaseReserveAfter);
    //            return _remainSize;
    //        } else if (_remainSize < tradableSize && _side == Side.SELL) {
    //            amountBaseReserveAfter = amountBaseReserve.add(_remainSize);
    //            amountQuoteReserveAfter = amountQuoteReserve.sub(_orderPrice.mul(_remainSize));
    //            setQuoteReserve(amountQuoteReserveAfter);
    //            setBaseReserve(amountBaseReserveAfter);
    //            return _remainSize;
    //        }
    //        setQuoteReserve(amountQuoteReserveAfter);
    //        setBaseReserve(amountBaseReserveAfter);
    //        return tradableSize;
    //    }

    function clearPosition() public {


    }


    function addMargin(IAmm _amm, uint256 index, int256 tick, uint256 _addedMargin) public {
        // check condition
        requireAmm(_amm, true);
        requireNonZeroInput(_addedMargin);
        // update margin part in personal position
        address trader = msg.sender;

        //        _amm.addMargin(index, tick, _addedMargin);
        emit MarginChanged(trader, address(_amm), _addedMargin, 0);
    }

    // TODO modify function
    function removeMargin(IAmm _amm, uint256, uint256 index, int256 tick, uint256 _amountRemoved) public {
        // check condition
        requireAmm(_amm, true);
        requireNonZeroInput(_amountRemoved);

        address trader = msg.sender;

        _amm.removeMargin(index, tick, _amountRemoved);
        //        emit MarginChanged(trader, address(_amm), int256(_amountRemoved.toUint()), 0);


    }



    // TODO modify function
    function withdraw(
        IERC20 _token,
        address _receiver,
        uint256 _amount
    ) internal {
        // if withdraw amount is larger than entire balance of vault
        // means this trader's profit comes from other under collateral position's future loss
        // and the balance of entire vault is not enough
        // need money from IInsuranceFund to pay first, and record this prepaidBadDebt
        // in this case, insurance fund loss must be zero
        //        uint256 memory totalTokenBalance = _balanceOf(_token, address(this));
        //        if (totalTokenBalance.toUint() < _amount.toUint()) {
        //            uint256 memory balanceShortage = _amount.subD(totalTokenBalance);
        //            prepaidBadDebt[address(_token)] = prepaidBadDebt[address(_token)].addD(balanceShortage);
        //            insuranceFund.withdraw(_token, balanceShortage);
        //        }
        //
        //        _transfer(_token, _receiver, _amount);
    }


    // TODO modify function
    function payFunding(IAmm _amm) public {
        requireAmm(_amm, true);
        uint256 premiumFraction = _amm.settleFunding();
        //        address(_amm).cumulativePremiumFractions.push(
        //            premiumFraction.add(getLatestCumulativePremiumFraction(_amm))
        //        );


        // funding payment = premium fraction * position
        // eg. if alice takes 10 long position, totalPositionSize = 10
        // if premiumFraction is positive: long pay short, amm get positive funding payment
        // if premiumFraction is negative: short pay long, amm get negative funding payment
        // if totalPositionSize.side * premiumFraction > 0, funding payment is positive which means profit
        uint256 totalTraderPositionSize = _amm.getTotalPositionSize();
        uint256 ammFundingPaymentProfit = premiumFraction.mul(totalTraderPositionSize);

        IERC20 quoteAsset = _amm.quoteAsset();
        //        if (ammFundingPaymentProfit.toInt() < 0) {
        //            insuranceFund.withdraw(quoteAsset, ammFundingPaymentProfit.abs());
        //        } else {
        //            transferToInsuranceFund(quoteAsset, ammFundingPaymentProfit.abs());
        //        }

    }


    // TODO modify function
    function realizeBadDebt(IERC20 _token, uint256 _badDebt) internal {
        //        uint256 memory badDebtBalance = prepaidBadDebt[address(_token)];
        //        if (badDebtBalance.toUint() > _badDebt.toUint()) {
        //            // no need to move extra tokens because vault already prepay bad debt, only need to update the numbers
        //            prepaidBadDebt[address(_token)] = badDebtBalance.subD(_badDebt);
        //        } else {
        //            // in order to realize all the bad debt vault need extra tokens from insuranceFund
        //            insuranceFund.withdraw(_token, _badDebt.sub(badDebtBalance));
        //            prepaidBadDebt[address(_token)] = Decimal.zero();
        //        }
    }


    // TODO modify function
    function transferToInsuranceFund(IERC20 _token, uint256 _amount) internal {
        //        uint256 memory totalTokenBalance = _balanceOf(_token, address(this));
        //        _transfer(
        //            _token,
        //            address(insuranceFund),
        //            totalTokenBalance.toUint() < _amount.toUint() ? totalTokenBalance : _amount
        //        );
    }


    function closePosition(IAmm _amm, uint256 index, uint256 tick) public {

        // TODO require close position

        address _trader = msg.sender;

        // TODO close position
        // calc PnL, transfer money
        //



        _amm.closePosition(_trader);
        //        ammMap[_amm].positionMap[_trader]
        //
        //        Position[] memory templePosition;
        //
        //        for (uint256 i = 0; i < address(_amm).positionMap[_trader].length; i++) {
        //            int256 tickOrder = address(_amm).positionMap[_trader][i].tick;
        //            uint256 indexOrder = address(_amm).positionMap[_trader][i].index;
        //
        //            if (_amm.getIsWaitingOrder(tickOrder, indexOrder) == true) {
        //                //                templePosition.push(Position(indexOrder, tickOrder));
        //
        //            }
        //
        //        }
        //
        //
        //        address(_amm).positionMap[_trader] = templePosition;


        // TODO emit event


    }

    function cancelOrder(IAmm _amm, uint256 index, int256 tick) public {

        // TODO require close order AMM
        require(_amm.getIsOrderExecuted(tick, index) != true, "Your order has executed");
        //        bool flag = true;


        _amm.cancelOrder(index, tick);


        emit CancelOrder(address(_amm), index, tick);
    }


    function getPosition(IAmm _amm, address _trader) public view returns (IAmm.Position memory positionsOpened, IAmm.Position memory positionOrder)  {

        // TODO require getPosition


        //        Position[] memory positions = address(_amm).positionMap[_trader];
        //
        //        for (uint256 i = 0; i < positions.length; i.add(1)) {
        //            int256 tick = positions[i].tick;
        //            uint256 index = positions[i].index;
        //
        //        }

    }



    //  function



    // TODO modify function
    function getUnadjustedPosition(IAmm _amm, address _trader) public view returns (IAmm.Position memory position) {
        //        position = address(_amm).positionMap[_trader][0];
    }


    // TODO modify function
    function setWhitelist(address _address, bool isWhitelist) public {
        whitelist[_address] = isWhitelist;
    }


    // TODO modify function
    function setBlacklist(address _address, bool isBlacklist) public {

        blacklist[_address] = isBlacklist;

    }

    function getWhitelist(address _address) public returns (bool) {

        return whitelist[_address];
        //        tickOrder[tick].order[index].margin.add(amountAdded);
    }

    function getBlacklist(address _address) public returns (bool) {
        return blacklist[_address];
    }

    function requireNonZeroInput(uint256 _decimal) private pure {
        //!0: input is 0
        require(_decimal != 0, Errors.VL_INVALID_AMOUNT);
    }





    /**
    * @notice get latest cumulative premium fraction.
    * @param _amm IAmm address
    * @return latest cumulative premium fraction in 18 digits
    */
    function getLatestCumulativePremiumFraction(IAmm _amm) public view returns (uint256) {
        //        uint256 len = address(_amm).cumulativePremiumFractions.length;
        //        if (len > 0) {
        //            return address(_amm).cumulativePremiumFractions[len - 1];
        //        }
        return 0;
    }


    // require function
    function requireAmm(IAmm _amm, bool _open) private view {

        //405: amm not found
        //505: amm was closed
        //506: amm is open
        //        require(insuranceFund.isExistedAmm(_amm), "405");
        //        require(_open == _amm.open(), _open ? "505" : "506");
    }


}