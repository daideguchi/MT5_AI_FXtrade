//+------------------------------------------------------------------+
//|                                                      BB_RSI_MA    |
//|                              Copyright 2023, Your_Name            |
//+------------------------------------------------------------------+
#property copyright "2023, Your_Name"
#property link      "https://www.example.com"
#property version   "1.00"
#property strict

#include <Trade/Trade.mqh>
#include <Indicators/Indicators.mqh>
#include <MovingAverages.mqh>

// Input parameters
input int      BBPeriod = 20;          // Bollinger Bands period
input double   BBDeviation = 2.0;      // Bollinger Bands deviation
input int      RSI_Period = 14;        // RSI period
input double   RSI_UpperLevel = 70.0;  // RSI upper level
input double   RSI_LowerLevel = 30.0;  // RSI lower level
input int      Short_MA_Period = 5;    // Short-term moving average period
input int      Long_MA_Period = 14;    // Long-term moving average period
input double   LotSize = 0.01;         // Lot size

// Global variables
CiBands BollingerBands;
CiRSI RSI_Indicator;
CTrade trade;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    // Initialize Bollinger Bands
    BollingerBands.Create(_Symbol, _Period, BBPeriod, PRICE_CLOSE, BBDeviation, MODE_SMA);

    // Initialize RSI
    RSI_Indicator.Create(_Symbol, _Period, RSI_Period, PRICE_CLOSE);

    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Get the latest Bollinger Bands values
    double BBUpper = BollingerBands.Upper(0);
    double BBLower = BollingerBands.Lower(0);

    // Get the latest RSI value
    double currentRSI = RSI_Indicator.Main(0);

    // Get the latest moving averages values
    double shortMA = iMA(_Symbol, _Period, Short_MA_Period, 0, MODE_SMA, PRICE_CLOSE);
    double longMA = iMA(_Symbol, _Period, Long_MA_Period, 0, MODE_SMA, PRICE_CLOSE);

    // Define trading rules
    bool buySignal  = SymbolInfoDouble(_Symbol, SYMBOL_ASK) < BBLower && currentRSI < RSI_LowerLevel && shortMA > longMA;
    bool sellSignal = SymbolInfoDouble(_Symbol, SYMBOL_BID) > BBUpper && currentRSI > RSI_UpperLevel && shortMA < longMA;

    // Get position information
    ulong positionTicket;
    bool hasPosition = PositionSelect(_Symbol);
    if (hasPosition)
    {
        positionTicket = PositionGetTicket(0);
    }

    // Execute trades
    if (buySignal && !hasPosition)
    {
        trade.Buy(LotSize);
    }
    else if (sellSignal && !hasPosition)
    {
        trade.Sell(LotSize);
    }
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Release Bollinger Bands and RSI resources
    IndicatorRelease(BollingerBands.Handle());
    IndicatorRelease(RSI_Indicator.Handle());
}


//+------------------------------------------------------------------+
