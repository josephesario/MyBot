//+------------------------------------------------------------------+
//|                                              EnhancedSessionEA.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade/Trade.mqh>

//--- Input Parameters
input group   "Time Zone Settings"
input int      LocalGMTOffset = 2;        // Your Local GMT Offset (e.g., 2 for GMT+2)

input group   "Zone Visualization Settings"
input color   ActiveSLZoneColor        = clrRed;        // Active Stop Loss Zone Color
input color   ActiveTPZoneColor        = clrGreen;      // Active Take Profit Zone Color
input color   HistorySLZoneColor       = C'64,0,0';     // Historical Stop Loss Zone Color
input color   HistoryTPZoneColor       = C'0,64,0';     // Historical Take Profit Zone Color
input color   HistoryZoneOutlineColor  = clrGray;       // Historical Zone Outline Color
input int     ZoneOpacity              = 10;            // Zone Opacity Level (0-255)
input string  ZonePrefix              = "TradeZone_";   // Active Zone Object Prefix
input string  HistoryZonePrefix       = "HistoryZone_"; // Historical Zone Object Prefix

input group   "Trade Zone Settings"
input double  StopLossMultiplier  = 1.0;    // Stop Loss distance multiplier
input double  TakeProfitMultiplier = 2.0;   // Take Profit distance multiplier

input group   "Trade Entry Settings"
input int     SweepThresholdPips  = 2;     // Sweep threshold in pips
input int     StopLossBufferPips  = 5;     // Stop loss buffer in pips
input double  RiskRewardRatio     = 1.5;   // Risk:Reward ratio for take profit

//--- Add these to your input parameters section
input group   "Martingale Settings"
input bool    EnableMartingale    = false;    // Enable Martingale Strategy
input int     MaxMartingaleLevels = 3;        // Maximum Martingale Levels
input double  MartingaleMultiplier = 2.0;     // Lot Size Multiplier

//--- Add this structure to track Martingale state
struct MartingaleState {
    int     currentLevel;         // Current Martingale level
    double  lastLotSize;          // Last position size used
    bool    inMartingaleCycle;    // Whether we're in a Martingale cycle
    string  lastSignalType;       // Last signal type that was traded
    double  lastEntryPrice;       // Last entry price
    bool    lastTradeWasProfit;   // Result of last trade
};



// Additional Input Parameters for Advanced Fibonacci Strategy
input group   "Fibonacci Trading Settings"
input int     LiquidityPoints     = 20;       // Points needed to confirm liquidity break
input int     StructurePoints     = 10;       // Points needed for structure change
input int     FibDrawWidth        = 10;       // Fibonacci Pattern Width in bars
input color   ActiveFibColor      = clrGold;  // Active Fibonacci Pattern Color  
input color   HistoryFibColor     = C'128,128,0';  // Historical Fibonacci Pattern Color
input double  FibLevel618        = 0.618;    // Fibonacci Level 61.8%
input double  FibLevel650        = 0.650;     // Fibonacci Level 65%
input int     ATRPeriod          = 14;       // ATR Period for Stop Loss
input double  ATRMultiplier      = 1.5;      // ATR Multiplier for Stop Loss
input bool    ShowFibHistory     = true;     // Keep Fibonacci History After Trade

//+------------------------------------------------------------------+
//| Enhanced risk management settings                                  |
//+------------------------------------------------------------------+
input group "Risk Management"
input double RiskPercentage = 1.0;         // Risk percentage per trade




input group   "Session Settings"
input color    AsianSessionColor     = C'19,23,34';     // Asian Session Background Color
input color    EuropeanSessionColor  = C'22,19,34';     // European Session Background Color
input color    AmericanSessionColor  = C'34,19,19';     // American Session Background Color
input color    AsianHighColor        = clrAqua;         // Asian Session High Line Color
input color    AsianLowColor         = C'0,128,128';    // Asian Session Low Line Color
input color    EuropeanHighColor     = clrMagenta;      // European Session High Line Color
input color    EuropeanLowColor      = clrPurple;       // European Session Low Line Color
input color    AmericanHighColor     = clrYellow;       // American Session High Line Color
input color    AmericanLowColor      = clrOrange;       // American Session Low Line Color


// Session times in GMT
input group   "Session Times (GMT)"
input int      AsianSessionStartGMT    = 22;      // Asian Session Start Hour (GMT)
input int      AsianSessionEndGMT      = 7;       // Asian Session End Hour (GMT)
input int      EuropeanSessionStartGMT = 7;       // European Session Start Hour (GMT)
input int      EuropeanSessionEndGMT   = 16;      // European Session End Hour (GMT)
input int      AmericanSessionStartGMT = 13;      // American Session Start Hour (GMT)
input int      AmericanSessionEndGMT   = 22;      // American Session End Hour (GMT)



//--- Input Parameters for Breakouts
input group   "Breakout Settings"
input int     WeeklyBreakoutPips  = 10;    // Pips needed for weekly breakout signal
input int     DailyBreakoutPips   = 5;     // Pips needed for daily breakout signal
input int     SessionBreakoutPips = 3;     // Pips needed for session breakout signal
input color   BuySignalColor      = clrLime;    // Buy Signal Color
input color   SellSignalColor     = clrRed;     // Sell Signal Color



input group   "Non-Session Settings"
input color    NonSessionColor     = clrBlack;     // Non-Session Background Color


input group   "Visual Settings"
input color    DailyHighColor     = clrLime;      // Daily High Line Color
input color    DailyLowColor      = clrLime;       // Daily Low Line Color
input color    WeeklyHighColor    = clrYellow;    // Weekly High Line Color
input color    WeeklyLowColor     = clrYellow;   // Weekly Low Line Color
input color    DayStartColor      = clrAqua;      // Day Start Candle Color
input color    WeekStartColor     = clrAqua;   // Week Start Candle Color
input int      LineWidth          = 2;            // Line Width
input int      HistoryBars        = 50;           // Number of historical bars to show



// Panel input parameters
input group   "Panel Design Settings"
input color   PanelBaseColor        = C'16,24,32';   // Panel Base Color
input color   PanelAccentColor      = C'0,162,232';  // Panel Accent Color
input color   PanelTextColor        = C'220,220,220';// Panel Text Color
input color   PanelHeaderColor      = C'0,122,204';  // Panel Header Color
input color   PanelProfitColor      = C'0,255,127';  // Profit Color
input color   PanelLossColor        = C'255,51,51';  // Loss Color
input int     PanelTitleFontSize    = 12;            // Title Font Size
input int     PanelLabelFontSize    = 9;             // Label Font Size
input string  PanelFontName         = "Arial Black";  // Panel Font
input int     PanelWidth            = 400;           // Panel Width
input int     PanelHeight           = 400;           // Panel Height
input int     PanelChartHeight      = 200;           // Chart Section Height




// Global Martingale state
MartingaleState martingaleState;

//+------------------------------------------------------------------+
//| Initialize Martingale State                                        |
//+------------------------------------------------------------------+
void InitializeMartingaleState() {
    martingaleState.currentLevel = 0;
    martingaleState.lastLotSize = 0;
    martingaleState.inMartingaleCycle = false;
    martingaleState.lastSignalType = "";
    martingaleState.lastEntryPrice = 0;
    martingaleState.lastTradeWasProfit = false;
}


//+------------------------------------------------------------------+
//| Calculate Martingale Position Size                                 |
//+------------------------------------------------------------------+
double CalculateMartingaleSize(double baseSize) {
    if(!EnableMartingale || martingaleState.currentLevel >= MaxMartingaleLevels) {
        return baseSize;
    }
    
    double multiplier = MathPow(MartingaleMultiplier, martingaleState.currentLevel);
    double lotSize = baseSize * multiplier;
    
    // Ensure lot size is within bounds
    double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
    
    return MathMin(MathMax(lotSize, minLot), maxLot);
}

//+------------------------------------------------------------------+
//| Update Martingale State After Trade                               |
//+------------------------------------------------------------------+
void UpdateMartingaleState(bool wasProfit, double lotSize, string signalType) {
    if(!EnableMartingale) return;
    
    martingaleState.lastTradeWasProfit = wasProfit;
    martingaleState.lastLotSize = lotSize;
    martingaleState.lastSignalType = signalType;
    
    if(wasProfit) {
        // Reset Martingale cycle on profit
        martingaleState.currentLevel = 0;
        martingaleState.inMartingaleCycle = false;
    } else {
        // Increment level on loss, if not at max
        if(martingaleState.currentLevel < MaxMartingaleLevels) {
            martingaleState.currentLevel++;
            martingaleState.inMartingaleCycle = true;
        } else {
            // Reset if max levels reached
            martingaleState.currentLevel = 0;
            martingaleState.inMartingaleCycle = false;
        }
    }
}


// Global variables
CTrade trade;
datetime lastUpdateTime = 0;
bool first_run = true;
MqlRates rates[];




//+------------------------------------------------------------------+
//| Convert GMT time to local server time                             |
//+------------------------------------------------------------------+
int GMTToServerHour(int gmtHour)
{
    int serverGMTOffset = TimeGMTOffset()/3600;
    int localHour = (gmtHour + serverGMTOffset) % 24;
    if(localHour < 0) localHour += 24;
    return localHour;
}



//+------------------------------------------------------------------+
//| Expert tick function                                              |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Modified OnTick to remove session-related updates                  |
//+------------------------------------------------------------------+
void OnTick()
{
    static datetime lastBar = 0;
    datetime currentBar = iTime(_Symbol, PERIOD_CURRENT, 0);
    
    // Monitor open positions
    MonitorPositions();
    
    // Update panel stats
    UpdateTradeStats();
    

    
     // Process trading logic
    ProcessTrading();
    
    // Update active Fibonacci pattern
    ProcessFibonacciPattern();
    
    // Clean up old patterns if needed
    if(currentFib.isActive && TimeCurrent() - currentFib.startTime > FibDrawWidth * PeriodSeconds(_Period)) {
        if(!currentFib.tradeOpened) {
            // Pattern expired without trade, clean up
            ObjectsDeleteAll(0, "ActiveFib_" + TimeToString(currentFib.startTime));
            currentFib.isActive = false;
        }
    }
    
    if(currentBar != lastBar || first_run)
    {
        UpdateAllLines();
        
        
        // Update panel
        tradePanel.Update();
        
        first_run = false;
        lastBar = currentBar;
    }
}

//+------------------------------------------------------------------+
//| Update trading statistics for panel                               |
//+------------------------------------------------------------------+
void UpdateTradeStats()
{
    // Update daily profit
    double currentProfit = 0;
    
    // Calculate current open positions profit/loss
    for(int i = 0; i < PositionsTotal(); i++)
    {
        if(PositionSelectByTicket(PositionGetTicket(i)))
        {
            currentProfit += PositionGetDouble(POSITION_PROFIT);
        }
    }
    
    // Update daily metrics
    stats.dailyProfit = riskMgr.currentDailyPL + currentProfit;
    
    // Update weekly profit
    static datetime lastWeekUpdate = 0;
    MqlDateTime current;
    TimeToStruct(TimeCurrent(), current);
    
    if(lastWeekUpdate == 0)
    {
        lastWeekUpdate = TimeCurrent();
    }
    else
    {
        MqlDateTime lastUpdate;
        TimeToStruct(lastWeekUpdate, lastUpdate);
        
        // Reset weekly profit on new week
        if(current.day_of_week < lastUpdate.day_of_week)
        {
            stats.weeklyProfit = currentProfit;
        }
        else
        {
            stats.weeklyProfit += currentProfit;
        }
        
        lastWeekUpdate = TimeCurrent();
    }
    
    // Update monthly profit
    static int lastMonth = 0;
    if(lastMonth == 0)
    {
        lastMonth = current.mon;
        stats.monthlyProfit = currentProfit;
    }
    else if(current.mon != lastMonth)
    {
        stats.monthlyProfit = currentProfit;
        lastMonth = current.mon;
    }
    else
    {
        stats.monthlyProfit += currentProfit;
    }
    
    // Update win rate
    if(stats.totalTrades > 0)
    {
        stats.winRate = (double)stats.winTrades / stats.totalTrades * 100;
    }
    
    // Update session win rates
    double asianWinRate = stats.asianTrades > 0 ? ((double)stats.asianWins / stats.asianTrades) * 100 : 0;
    double euroWinRate = stats.euroTrades > 0 ? ((double)stats.euroWins / stats.euroTrades) * 100 : 0;
    double usWinRate = stats.usTrades > 0 ? ((double)stats.usWins / stats.usTrades) * 100 : 0;
    
    // Track largest win/loss
    if(currentProfit > stats.largestWin)
        stats.largestWin = currentProfit;
    if(currentProfit < stats.largestLoss)
        stats.largestLoss = currentProfit;
        
    // Update streaks
    if(currentProfit > 0)
    {
        if(stats.currentStreak >= 0)
            stats.currentStreak++;
        else
            stats.currentStreak = 1;
            
        if(stats.currentStreak > stats.bestWinStreak)
            stats.bestWinStreak = stats.currentStreak;
    }
    else if(currentProfit < 0)
    {
        if(stats.currentStreak <= 0)
            stats.currentStreak--;
        else
            stats.currentStreak = -1;
            
        if(stats.currentStreak < stats.worstLoseStreak)
            stats.worstLoseStreak = stats.currentStreak;
    }
}


void MonitorPositions() {
    static datetime lastCandleTime = 0;
    static int lastTotal = 0;
    int currentTotal = PositionsTotal();
    datetime currentCandleTime = iTime(_Symbol, PERIOD_CURRENT, 0);
    
    // Check for new candle and manage existing positions
    if(currentCandleTime != lastCandleTime) {
        // Process each open position for breakeven management
        for(int i = 0; i < PositionsTotal(); i++) {
            if(PositionSelectByTicket(PositionGetTicket(i))) {
                ulong ticket = PositionGetTicket(i);
                double entryPrice = PositionGetDouble(POSITION_PRICE_OPEN);
                double currentSL = PositionGetDouble(POSITION_SL);
                double currentProfit = PositionGetDouble(POSITION_PROFIT);
                ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
                
                // Check if position is in profit and not already at breakeven
                if(currentProfit > 0 && MathAbs(currentSL - entryPrice) > 3 * _Point) {
                    double breakevenLevel = entryPrice;
                    
                    // Add small buffer based on position type
                    if(posType == POSITION_TYPE_BUY) {
                        breakevenLevel += 2 * _Point;
                    } else {
                        breakevenLevel -= 2 * _Point;
                    }
                    
                    // Modify stop loss to breakeven
                    if(trade.PositionModify(ticket, breakevenLevel, PositionGetDouble(POSITION_TP))) {
                        Print("Position #", ticket, " moved to breakeven with profit: ", currentProfit);
                    }
                }
            }
        }
        lastCandleTime = currentCandleTime;
    }
    
    // Check for position closures
    if(currentTotal < lastTotal) {
        // Select recent history (last 24 hours)
        HistorySelect(TimeCurrent() - 86400, TimeCurrent());
        int totalDeals = HistoryDealsTotal();
        
        if(totalDeals > 0) {
            // Get the latest deal
            ulong lastDealTicket = HistoryDealGetTicket(totalDeals - 1);
            
            if(lastDealTicket > 0) {
                // Get deal details
                double dealProfit = HistoryDealGetDouble(lastDealTicket, DEAL_PROFIT);
                double dealPrice = HistoryDealGetDouble(lastDealTicket, DEAL_PRICE);
                double dealVolume = HistoryDealGetDouble(lastDealTicket, DEAL_VOLUME);
                datetime dealTime = (datetime)HistoryDealGetInteger(lastDealTicket, DEAL_TIME);
                ENUM_DEAL_TYPE dealType = (ENUM_DEAL_TYPE)HistoryDealGetInteger(lastDealTicket, DEAL_TYPE);
                
                // Find the opening deal
                ulong openTicket = 0;
                double openPrice = 0;
                datetime openTime = 0;
                
                for(int i = totalDeals - 2; i >= 0; i--) {
                    ulong ticket = HistoryDealGetTicket(i);
                    if(ticket <= 0) continue;
                    
                    ENUM_DEAL_TYPE openType = (ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket, DEAL_TYPE);
                    if((dealType == DEAL_TYPE_SELL && openType == DEAL_TYPE_BUY) ||
                       (dealType == DEAL_TYPE_BUY && openType == DEAL_TYPE_SELL)) {
                        openTicket = ticket;
                        openPrice = HistoryDealGetDouble(ticket, DEAL_PRICE);
                        openTime = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
                        break;
                    }
                }
                
                // Process completed trade
                if(openTicket > 0) {
                    bool isBuy = (ENUM_DEAL_TYPE)HistoryDealGetInteger(openTicket, DEAL_TYPE) == DEAL_TYPE_BUY;
                    bool isProfit = dealProfit > 0;
                    
                    // Update Martingale state if enabled
                    if(EnableMartingale) {
                        UpdateMartingaleState(isProfit, dealVolume, isBuy ? "BUY" : "SELL");
                    }
                    
                    // Calculate and save trade zones
                    double slLevel = 0, tpLevel = 0;
                    zoneManager.CalculateZoneLevels(isBuy, openPrice, slLevel, tpLevel);
                    zoneManager.SaveZonesToHistory(isBuy, openPrice, slLevel, tpLevel, 
                                                 openTime, dealTime, isProfit);
                    
                    // Update session and total statistics
                    string currentSession = GetCurrentSession();
                    UpdateSessionStats(currentSession, isProfit);
                    UpdateTotalStats(dealProfit);
                    
                    // Print detailed trade result
                    PrintTradeResult(openPrice, dealPrice, dealProfit, dealVolume,
                                   openTime, dealTime, isBuy);
                }
            }
        }
    }
    
    // Update last known total
    lastTotal = currentTotal;
}
//+------------------------------------------------------------------+
//| Print detailed trade result                                        |
//+------------------------------------------------------------------+
void PrintTradeResult(double openPrice, double closePrice, double profit, 
                     double volume, datetime openTime, datetime closeTime,
                     bool isBuy) {
    string direction = isBuy ? "BUY" : "SELL";
    string result = profit >= 0 ? "PROFIT" : "LOSS";
    string duration = TimeToString(closeTime - openTime, TIME_SECONDS);
    
    Print("=== Trade Result ===");
    Print("Direction: ", direction);
    Print("Open Price: ", openPrice);
    Print("Close Price: ", closePrice);
    Print("Volume: ", volume);
    Print("Profit/Loss: ", profit);
    Print("Duration: ", duration);
    Print("Entry Time: ", TimeToString(openTime));
    Print("Exit Time: ", TimeToString(closeTime));
    Print("==================");
}

//+------------------------------------------------------------------+
//| Update session statistics                                          |
//+------------------------------------------------------------------+
void UpdateSessionStats(string session, bool isWin) {
    if(session == "ASIAN") {
        stats.asianTrades++;
        if(isWin) stats.asianWins++;
        else stats.asianLosses++;
        
        // Update session balance
        stats.asianSessionBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    }
    else if(session == "EUROPEAN") {
        stats.euroTrades++;
        if(isWin) stats.euroWins++;
        else stats.euroLosses++;
        
        // Update session balance
        stats.euroSessionBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    }
    else if(session == "AMERICAN") {
        stats.usTrades++;
        if(isWin) stats.usWins++;
        else stats.usLosses++;
        
        // Update session balance
        stats.usSessionBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    }
}


//+------------------------------------------------------------------+
//| Update total trading statistics                                    |
//+------------------------------------------------------------------+
void UpdateTotalStats(double profit) {
    stats.totalTrades++;
    if(profit > 0) {
        stats.winTrades++;
        stats.totalProfit += profit;
        if(profit > stats.largestWin) stats.largestWin = profit;
    } else {
        stats.lossTrades++;
        stats.totalLoss += MathAbs(profit);
        if(profit < stats.largestLoss) stats.largestLoss = profit;
    }
    
    // Update win rate
    stats.winRate = (double)stats.winTrades / stats.totalTrades * 100;
}

//+------------------------------------------------------------------+
//| Draw breakout signal on chart                                     |
//+------------------------------------------------------------------+
void DrawBreakoutSignal(string name, datetime time, double price, bool isBuySignal)
{
    string objectName = "Signal_" + name + "_" + TimeToString(time);
    
    if(ObjectFind(0, objectName) >= 0)
        ObjectDelete(0, objectName);
    
    // Place arrow on the candle where breakout occurs
    ObjectCreate(0, objectName, OBJ_ARROW, 0, time, price);
    
    if(isBuySignal)
    {
        ObjectSetInteger(0, objectName, OBJPROP_ARROWCODE, 241); // Up arrow
        ObjectSetInteger(0, objectName, OBJPROP_COLOR, BuySignalColor);
        ObjectSetInteger(0, objectName, OBJPROP_ANCHOR, ANCHOR_BOTTOM); // Place arrow below the point
    }
    else
    {
        ObjectSetInteger(0, objectName, OBJPROP_ARROWCODE, 242); // Down arrow
        ObjectSetInteger(0, objectName, OBJPROP_COLOR, SellSignalColor);
        ObjectSetInteger(0, objectName, OBJPROP_ANCHOR, ANCHOR_TOP); // Place arrow above the point
    }
    
    ObjectSetInteger(0, objectName, OBJPROP_WIDTH, 1);
    ObjectSetInteger(0, objectName, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, objectName, OBJPROP_HIDDEN, true);
}




//+------------------------------------------------------------------+
//| Modified OnInit to remove unnecessary initializations              |
//+------------------------------------------------------------------+
int OnInit()
{
    // Set up chart appearance
    ChartSetInteger(0, CHART_COLOR_BACKGROUND, clrBlack);
    ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, clrLime);
    ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, clrRed);
    ChartSetInteger(0, CHART_COLOR_CHART_UP, clrLime);
    ChartSetInteger(0, CHART_COLOR_CHART_DOWN, clrRed);
    ChartSetInteger(0, CHART_SHOW_GRID, false);
    
    // Initialize arrays and variables
    ArrayResize(historyFibs, 0);
    lastLiquidityBreak = 0;
    lastBreakTime = 0;
    currentFib.isActive = false;
    InitializeMartingaleState();
    


    stats.dailyStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    stats.weeklyStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    stats.monthlyStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    
    ArrayResize(historyFibs, 0);

    
    // Create trading panel
    tradePanel.Create();
    
    // Initial updates
    UpdateAllLines();
    
    Print("Server time GMT offset: ", TimeGMTOffset()/3600);
    
 
    
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Draw historical weekly lines with exact candle width               |
//+------------------------------------------------------------------+
void DrawWeeklyLines()
{
    MqlRates rates[];
    ArraySetAsSeries(rates, true);
    
    if(CopyRates(_Symbol, PERIOD_W1, 0, HistoryBars/5, rates) > 0)
    {
        for(int i = 0; i < ArraySize(rates); i++)
        {
            string date_str = TimeToString(rates[i].time, TIME_DATE);
            
            // Use exact candle open and close times
            datetime period_start = rates[i].time;
            datetime period_end = rates[i].time + PeriodSeconds(PERIOD_W1);
            
            DrawLevel("Weekly High :: " + date_str, rates[i].high, period_start, period_end, WeeklyHighColor);
            DrawLevel("Weekly Low :: " + date_str, rates[i].low, period_start, period_end, WeeklyLowColor);
        }
    }
}
//+------------------------------------------------------------------+
//| Check if time is within session                                   |
//+------------------------------------------------------------------+
bool IsWithinSession(datetime time, int sessionStartGMT, int sessionEndGMT)
{
    MqlDateTime dt;
    TimeToStruct(time, dt);
    
    int serverHour = dt.hour;
    int serverGMTOffset = TimeGMTOffset()/3600;
    int gmtHour = (serverHour - serverGMTOffset + 24) % 24;
    
    if(sessionStartGMT < sessionEndGMT)
    {
        return (gmtHour >= sessionStartGMT && gmtHour < sessionEndGMT);
    }
    else
    {
        return (gmtHour >= sessionStartGMT || gmtHour < sessionEndGMT);
    }
}


//+------------------------------------------------------------------+
//| Draw level with exact timing                                       |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Draw level with exact candle width                                 |
//+------------------------------------------------------------------+
void DrawLevel(string name, double price, datetime start_time, datetime end_time, color line_color)
{
    if(ObjectFind(0, name) >= 0)
        ObjectDelete(0, name);
        
    // Get current timeframe in seconds
    ENUM_TIMEFRAMES period = ChartPeriod(0);
    int timeframe_seconds = PeriodSeconds(period);
    
    // Adjust end time to be exactly at the candle open
    end_time = end_time - timeframe_seconds;
        
    ObjectCreate(0, name, OBJ_TREND, 0, start_time, price, end_time, price);
    ObjectSetInteger(0, name, OBJPROP_COLOR, line_color);
    ObjectSetInteger(0, name, OBJPROP_WIDTH, LineWidth);
    ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
    ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
    ObjectSetInteger(0, name, OBJPROP_BACK, false);
    ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
    ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
    
    // Add price label at the start of the line
    string label_name = name + "_Label";
    if(ObjectFind(0, label_name) >= 0)
        ObjectDelete(0, label_name);
        
    ObjectCreate(0, label_name, OBJ_TEXT, 0, start_time, price);
    ObjectSetString(0, label_name, OBJPROP_TEXT, DoubleToString(price, _Digits));
    ObjectSetInteger(0, label_name, OBJPROP_COLOR, line_color);
    ObjectSetInteger(0, label_name, OBJPROP_FONTSIZE, 8);
    ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
}


//+------------------------------------------------------------------+
//| Draw session backgrounds                                          |
//+------------------------------------------------------------------+
void DrawSessionBackgrounds()
{
    datetime current_time = TimeCurrent();
    datetime start_time = current_time - (HistoryBars * PeriodSeconds(PERIOD_D1));
    
    ObjectsDeleteAll(0, "SessionBG_");
    
    for(datetime time = start_time; time <= current_time; time += PeriodSeconds(PERIOD_D1))
    {
        datetime day_start = StringToTime(TimeToString(time, TIME_DATE));
        
        // Convert session times to server time
        int asianStart = GMTToServerHour(AsianSessionStartGMT);
        int asianEnd = GMTToServerHour(AsianSessionEndGMT);
        int euroStart = GMTToServerHour(EuropeanSessionStartGMT);
        int euroEnd = GMTToServerHour(EuropeanSessionEndGMT);
        int usStart = GMTToServerHour(AmericanSessionStartGMT);
        int usEnd = GMTToServerHour(AmericanSessionEndGMT);
        
        // First draw the black background for the entire day
        string black_bg_name = "SessionBG_Black_" + TimeToString(day_start);
        datetime day_end = day_start + PeriodSeconds(PERIOD_D1);
        DrawSessionBackground(black_bg_name, day_start, day_end, NonSessionColor);
        
        // Draw Asian Session
        string asian_name = "SessionBG_Asian_" + TimeToString(day_start);
        datetime asian_start = day_start + asianStart * 3600;
        datetime asian_end = day_start + asianEnd * 3600;
        if(asianStart > asianEnd) asian_end += PeriodSeconds(PERIOD_D1);
        DrawSessionBackground(asian_name, asian_start, asian_end, AsianSessionColor);
        
        // Draw European Session
        string european_name = "SessionBG_European_" + TimeToString(day_start);
        datetime european_start = day_start + euroStart * 3600;
        datetime european_end = day_start + euroEnd * 3600;
        if(euroStart > euroEnd) european_end += PeriodSeconds(PERIOD_D1);
        DrawSessionBackground(european_name, european_start, european_end, EuropeanSessionColor);
        
        // Draw American Session
        string american_name = "SessionBG_American_" + TimeToString(day_start);
        datetime american_start = day_start + usStart * 3600;
        datetime american_end = day_start + usEnd * 3600;
        if(usStart > usEnd) american_end += PeriodSeconds(PERIOD_D1);
        DrawSessionBackground(american_name, american_start, american_end, AmericanSessionColor);
    }
}


//+------------------------------------------------------------------+
//| Draw individual session background                                |
//+------------------------------------------------------------------+
void DrawSessionBackground(string name, datetime start_time, datetime end_time, color bg_color)
{
    if(start_time >= end_time) return;  // Skip invalid time ranges
    
    double upper_price = ChartGetDouble(0, CHART_PRICE_MAX);
    double lower_price = ChartGetDouble(0, CHART_PRICE_MIN);
    
    if(ObjectFind(0, name) >= 0)
        ObjectDelete(0, name);
        
    ObjectCreate(0, name, OBJ_RECTANGLE, 0, start_time, upper_price, end_time, lower_price);
    ObjectSetInteger(0, name, OBJPROP_COLOR, bg_color);
    ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
    ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
    ObjectSetInteger(0, name, OBJPROP_BACK, true);
    ObjectSetInteger(0, name, OBJPROP_FILL, true);
    ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
}

//+------------------------------------------------------------------+
//| Color special candles (day start and week start)                  |
//+------------------------------------------------------------------+
void ColorSpecialCandles()
{
    ArraySetAsSeries(rates, true);
    int copied = CopyRates(_Symbol, PERIOD_CURRENT, 0, 100, rates);
    
    ObjectsDeleteAll(0, "Start ::");  // Clean up old markers
    
    for(int i = 0; i < copied; i++)
    {
        MqlDateTime candle_time;
        TimeToStruct(rates[i].time, candle_time);
        
        string candle_name = "Start :: " + TimeToString(rates[i].time);
            
        // Week start candle (Monday)
        if(candle_time.day_of_week == 1 && candle_time.hour == 0 && candle_time.min == 0)
        {
            DrawCandleHighlight(candle_name, rates[i], WeekStartColor);
        }
        // Day start candle
        else if(candle_time.hour == 0 && candle_time.min == 0)
        {
            DrawCandleHighlight(candle_name, rates[i], DayStartColor);
        }
    }
}

//+------------------------------------------------------------------+
//| Draw candle highlight                                             |
//+------------------------------------------------------------------+
void DrawCandleHighlight(string name, MqlRates& rate, color candle_color)
{
    ObjectCreate(0, name, OBJ_RECTANGLE, 0, rate.time, rate.low, 
                rate.time + PeriodSeconds(PERIOD_CURRENT), rate.high);
    ObjectSetInteger(0, name, OBJPROP_COLOR, candle_color);
    ObjectSetInteger(0, name, OBJPROP_FILL, true);
    ObjectSetInteger(0, name, OBJPROP_BACK, false);
    ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
}

//+------------------------------------------------------------------+
//| Draw historical daily lines with exact candle width                |
//+------------------------------------------------------------------+
void DrawDailyLines()
{
    MqlRates rates[];
    ArraySetAsSeries(rates, true);
    
    if(CopyRates(_Symbol, PERIOD_D1, 0, HistoryBars, rates) > 0)
    {
        for(int i = 0; i < ArraySize(rates); i++)
        {
            string date_str = TimeToString(rates[i].time, TIME_DATE);
            
            // Use exact candle open and close times
            datetime period_start = rates[i].time;
            datetime period_end = rates[i].time + PeriodSeconds(PERIOD_D1);
            
            DrawLevel("Daily High :: " + date_str, rates[i].high, period_start, period_end, DailyHighColor);
            DrawLevel("Daily Low :: " + date_str, rates[i].low, period_start, period_end, DailyLowColor);
        }
    }
}



//+------------------------------------------------------------------+
//| Draw historical high/low lines                                    |
//+------------------------------------------------------------------+
// Modify DrawHistoricalLines for better naming consistency
void DrawHistoricalLines()
{
    datetime time_arr[];
    double high_arr[];
    double low_arr[];
    
    ArraySetAsSeries(time_arr, true);
    ArraySetAsSeries(high_arr, true);
    ArraySetAsSeries(low_arr, true);
    
    // Draw daily levels
    int copied = CopyTime(_Symbol, PERIOD_D1, 2, HistoryBars-2, time_arr);
    if(copied > 0)
    {
        CopyHigh(_Symbol, PERIOD_D1, 2, HistoryBars-2, high_arr);
        CopyLow(_Symbol, PERIOD_D1, 2, HistoryBars-2, low_arr);
        
        for(int i = 0; i < copied; i++)
        {
            datetime period_start = time_arr[i];
            datetime period_end = period_start + PeriodSeconds(PERIOD_D1);
            
            string high_name = "Daily High :: " + TimeToString(period_start, TIME_DATE);
            string low_name = "Daily Low :: " + TimeToString(period_start, TIME_DATE);
            
            DrawLevel(high_name, high_arr[i], period_start, period_end, DailyHighColor);
            DrawLevel(low_name, low_arr[i], period_start, period_end, DailyLowColor);
        }
    }
    
    // Draw weekly levels
    copied = CopyTime(_Symbol, PERIOD_W1, 0, HistoryBars/5, time_arr);
    if(copied > 0)
    {
        CopyHigh(_Symbol, PERIOD_W1, 0, HistoryBars/5, high_arr);
        CopyLow(_Symbol, PERIOD_W1, 0, HistoryBars/5, low_arr);
        
        for(int i = 0; i < copied; i++)
        {
            datetime period_start = time_arr[i];
            datetime period_end = period_start + PeriodSeconds(PERIOD_W1);
            
            string high_name = "Weekly High :: " + TimeToString(period_start, TIME_DATE);
            string low_name = "Weekly Low :: " + TimeToString(period_start, TIME_DATE);
            
            DrawLevel(high_name, high_arr[i], period_start, period_end, WeeklyHighColor);
            DrawLevel(low_name, low_arr[i], period_start, period_end, WeeklyLowColor);
        }
    }
}



//+------------------------------------------------------------------+
//| Calculate historical breakouts                                     |
//+------------------------------------------------------------------+
void CalculateHistoricalBreakouts()
{
    ArraySetAsSeries(rates, true);
    int copied = CopyRates(_Symbol, PERIOD_M1, 0, HistoryBars * 1440, rates);
    
    if(copied <= 0) return;
    
    double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    double pipSize = point * 10;
    
    // Structure for tracking period levels
    struct PeriodLevels {
        double high;
        double low;
        datetime time;
        bool highSignalGenerated;
        bool lowSignalGenerated;
        string dateStr;  // For tracking unique periods
    };
    
    // Initialize period trackers
    PeriodLevels prevWeek, currWeek;
    PeriodLevels prevDay, currDay;
    PeriodLevels prevAsian, currAsian;
    PeriodLevels prevEuro, currEuro;
    PeriodLevels prevUS, currUS;
    
    // Initialize all structures
    prevWeek.high = prevDay.high = prevAsian.high = prevEuro.high = prevUS.high = 0;
    prevWeek.low = prevDay.low = prevAsian.low = prevEuro.low = prevUS.low = DBL_MAX;
    prevWeek.highSignalGenerated = prevDay.highSignalGenerated = prevAsian.highSignalGenerated = 
    prevEuro.highSignalGenerated = prevUS.highSignalGenerated = false;
    prevWeek.lowSignalGenerated = prevDay.lowSignalGenerated = prevAsian.lowSignalGenerated = 
    prevEuro.lowSignalGenerated = prevUS.lowSignalGenerated = false;
    
    currWeek = prevWeek;
    currDay = prevDay;
    currAsian = prevAsian;
    currEuro = prevEuro;
    currUS = prevUS;
    
    string currentWeekStr = "";
    string currentDayStr = "";
    string currentAsianStr = "";
    string currentEuroStr = "";
    string currentUSStr = "";
    
    for(int i = copied-1; i >= 0; i--)
    {
        MqlDateTime time_struct;
        TimeToStruct(rates[i].time, time_struct);
        
        // Weekly Processing
        string weekStr = TimeToString(rates[i].time, TIME_DATE);
        if(time_struct.day_of_week == 1 && time_struct.hour == 0 && time_struct.min == 0)
        {
            // If we have previous week data, check for breakouts
            if(prevWeek.high > 0 && !prevWeek.highSignalGenerated && 
               currWeek.high > (prevWeek.high + WeeklyBreakoutPips * pipSize))
            {
                DrawHistoricalSignal("Weekly_HighBreak", rates[i].time, currWeek.high, true);
                prevWeek.highSignalGenerated = true;
            }
            
            if(prevWeek.low < DBL_MAX && !prevWeek.lowSignalGenerated && 
               currWeek.low < (prevWeek.low - WeeklyBreakoutPips * pipSize))
            {
                DrawHistoricalSignal("Weekly_LowBreak", rates[i].time, currWeek.low, false);
                prevWeek.lowSignalGenerated = true;
            }
            
            // Transfer current to previous and reset current
            prevWeek = currWeek;
            currWeek.high = rates[i].high;
            currWeek.low = rates[i].low;
            currWeek.time = rates[i].time;
            currWeek.highSignalGenerated = false;
            currWeek.lowSignalGenerated = false;
            currWeek.dateStr = weekStr;
            currentWeekStr = weekStr;
        }
        else
        {
            if(currentWeekStr == weekStr)
            {
                currWeek.high = MathMax(currWeek.high, rates[i].high);
                currWeek.low = MathMin(currWeek.low, rates[i].low);
            }
        }
        
        // Daily Processing
        string dayStr = TimeToString(rates[i].time, TIME_DATE);
        if(time_struct.hour == 0 && time_struct.min == 0)
        {
            if(prevDay.high > 0 && !prevDay.highSignalGenerated && 
               currDay.high > (prevDay.high + DailyBreakoutPips * pipSize))
            {
                DrawHistoricalSignal("Daily_HighBreak", rates[i].time, currDay.high, true);
                prevDay.highSignalGenerated = true;
            }
            
            if(prevDay.low < DBL_MAX && !prevDay.lowSignalGenerated && 
               currDay.low < (prevDay.low - DailyBreakoutPips * pipSize))
            {
                DrawHistoricalSignal("Daily_LowBreak", rates[i].time, currDay.low, false);
                prevDay.lowSignalGenerated = true;
            }
            
            prevDay = currDay;
            currDay.high = rates[i].high;
            currDay.low = rates[i].low;
            currDay.time = rates[i].time;
            currDay.highSignalGenerated = false;
            currDay.lowSignalGenerated = false;
            currDay.dateStr = dayStr;
            currentDayStr = dayStr;
        }
        else
        {
            if(currentDayStr == dayStr)
            {
                currDay.high = MathMax(currDay.high, rates[i].high);
                currDay.low = MathMin(currDay.low, rates[i].low);
            }
        }
        
        // Asian Session Processing
        if(IsWithinSession(rates[i].time, AsianSessionStartGMT, AsianSessionEndGMT))
        {
            if(currAsian.dateStr != dayStr)
            {
                if(prevAsian.high > 0 && !prevAsian.highSignalGenerated &&
                   currAsian.high > (prevAsian.high + SessionBreakoutPips * pipSize))
                {
                    DrawHistoricalSignal("Asian_HighBreak", rates[i].time, currAsian.high, true);
                    prevAsian.highSignalGenerated = true;
                }
                
                if(prevAsian.low < DBL_MAX && !prevAsian.lowSignalGenerated &&
                   currAsian.low < (prevAsian.low - SessionBreakoutPips * pipSize))
                {
                    DrawHistoricalSignal("Asian_LowBreak", rates[i].time, currAsian.low, false);
                    prevAsian.lowSignalGenerated = true;
                }
                
                prevAsian = currAsian;
                currAsian.high = rates[i].high;
                currAsian.low = rates[i].low;
                currAsian.time = rates[i].time;
                currAsian.highSignalGenerated = false;
                currAsian.lowSignalGenerated = false;
                currAsian.dateStr = dayStr;
            }
            else
            {
                currAsian.high = MathMax(currAsian.high, rates[i].high);
                currAsian.low = MathMin(currAsian.low, rates[i].low);
            }
        }
        
        // European Session Processing
        if(IsWithinSession(rates[i].time, EuropeanSessionStartGMT, EuropeanSessionEndGMT))
        {
            if(currEuro.dateStr != dayStr)
            {
                if(prevEuro.high > 0 && !prevEuro.highSignalGenerated &&
                   currEuro.high > (prevEuro.high + SessionBreakoutPips * pipSize))
                {
                    DrawHistoricalSignal("European_HighBreak", rates[i].time, currEuro.high, true);
                    prevEuro.highSignalGenerated = true;
                }
                
                if(prevEuro.low < DBL_MAX && !prevEuro.lowSignalGenerated &&
                   currEuro.low < (prevEuro.low - SessionBreakoutPips * pipSize))
                {
                    DrawHistoricalSignal("European_LowBreak", rates[i].time, currEuro.low, false);
                    prevEuro.lowSignalGenerated = true;
                }
                
                prevEuro = currEuro;
                currEuro.high = rates[i].high;
                currEuro.low = rates[i].low;
                currEuro.time = rates[i].time;
                currEuro.highSignalGenerated = false;
                currEuro.lowSignalGenerated = false;
                currEuro.dateStr = dayStr;
            }
            else
            {
                currEuro.high = MathMax(currEuro.high, rates[i].high);
                currEuro.low = MathMin(currEuro.low, rates[i].low);
            }
        }
        
        // US Session Processing
        if(IsWithinSession(rates[i].time, AmericanSessionStartGMT, AmericanSessionEndGMT))
        {
            if(currUS.dateStr != dayStr)
            {
                if(prevUS.high > 0 && !prevUS.highSignalGenerated &&
                   currUS.high > (prevUS.high + SessionBreakoutPips * pipSize))
                {
                    DrawHistoricalSignal("American_HighBreak", rates[i].time, currUS.high, true);
                    prevUS.highSignalGenerated = true;
                }
                
                if(prevUS.low < DBL_MAX && !prevUS.lowSignalGenerated &&
                   currUS.low < (prevUS.low - SessionBreakoutPips * pipSize))
                {
                    DrawHistoricalSignal("American_LowBreak", rates[i].time, currUS.low, false);
                    prevUS.lowSignalGenerated = true;
                }
                
                prevUS = currUS;
                currUS.high = rates[i].high;
                currUS.low = rates[i].low;
                currUS.time = rates[i].time;
                currUS.highSignalGenerated = false;
                currUS.lowSignalGenerated = false;
                currUS.dateStr = dayStr;
            }
            else
            {
                currUS.high = MathMax(currUS.high, rates[i].high);
                currUS.low = MathMin(currUS.low, rates[i].low);
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Draw historical signal                                            |
//+------------------------------------------------------------------+
void DrawHistoricalSignal(string name, datetime time, double price, bool isBuySignal)
{
    string objectName = "HistSignal_" + name + "_" + TimeToString(time);
    
    if(ObjectFind(0, objectName) >= 0)
        ObjectDelete(0, objectName);
    
    ObjectCreate(0, objectName, OBJ_ARROW, 0, time, price);
    
    if(isBuySignal)
    {
        ObjectSetInteger(0, objectName, OBJPROP_ARROWCODE, 241); // Up arrow
        ObjectSetInteger(0, objectName, OBJPROP_COLOR, BuySignalColor);
        ObjectSetInteger(0, objectName, OBJPROP_ANCHOR, ANCHOR_BOTTOM);
    }
    else
    {
        ObjectSetInteger(0, objectName, OBJPROP_ARROWCODE, 242); // Down arrow
        ObjectSetInteger(0, objectName, OBJPROP_COLOR, SellSignalColor);
        ObjectSetInteger(0, objectName, OBJPROP_ANCHOR, ANCHOR_TOP);
    }
    
    ObjectSetInteger(0, objectName, OBJPROP_WIDTH, 1);
    ObjectSetInteger(0, objectName, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, objectName, OBJPROP_HIDDEN, true);
}


//+------------------------------------------------------------------+
//| Draw weekly lines                                                  |
//+------------------------------------------------------------------+
void UpdateAllLines()
{
    // Clean up old objects
    ObjectsDeleteAll(0, "HighLow_");
    
    // Draw weekly lines only
    DrawWeeklyLines();
    DrawSessionLines();
    DrawDailyLines();
    DrawSessionBackgrounds();
    
    // Force chart redraw
    ChartRedraw(0);
}



void OnDeinit(const int reason)
{
    ObjectsDeleteAll(0, "HighLow_");
    ObjectsDeleteAll(0, "SessionBG_");
    ObjectsDeleteAll(0, "Start ::");
    ObjectsDeleteAll(0, "Session_");
    ObjectsDeleteAll(0, "Signal_");
    ObjectsDeleteAll(0, "HistSignal_");
    ObjectsDeleteAll(0, "Asian Session");     // Add these lines
    ObjectsDeleteAll(0, "European Session");  // to clean up
    ObjectsDeleteAll(0, "American Session");  // session lines
    ObjectsDeleteAll(0, "Current_Fib_");
    if(!ShowFibHistory) {
        ObjectsDeleteAll(0, "History_Fib_");
    }
        ObjectsDeleteAll(0, "TradeZone_");
    ObjectsDeleteAll(0, "ActiveFib_");
    if(!ShowFibHistory) {
        ObjectsDeleteAll(0, "HistFib_");
    }
}


///--------------------------


// Add structure for tracking trade performance
struct TradeStats {
    int totalTrades;
    int winTrades;
    int lossTrades;
    double totalProfit;
    double totalLoss;
    double largestWin;
    double largestLoss;
    double winRate;
    
    // Session specific
    int asianTrades;
    int asianWins;
    int euroTrades;
    int euroWins;
    int usTrades;
    int usWins;
    
    // Time frames
    double dailyProfit;
    double weeklyProfit;
    double monthlyProfit;
    
    // Streaks
    int currentStreak;
    int bestWinStreak;
    int worstLoseStreak;
    
    int asianLosses;  // Track Asian session losses
    int euroLosses;   // Track European session losses
    int usLosses;     // Track US session losses
    
    double asianSessionBalance;    // Starting balance for Asian session
    double euroSessionBalance;     // Starting balance for European session
    double usSessionBalance;       // Starting balance for US session
    
    double dailyStartBalance;      // Balance at start of day
    double weeklyStartBalance;     // Balance at start of week
    double monthlyStartBalance;    // Balance at start of month
};

// Add structure for risk management
struct RiskManager {
    double maxDailyLoss;
    double maxDailyProfit;
    double currentDailyPL;
    double riskPerTrade;
    bool tradingAllowed;
    datetime lastReset;
};

// Global variables
TradeStats stats;
RiskManager riskMgr;
int panelID = 0;



//+------------------------------------------------------------------+
//| Trade Panel Class Definition                                     |
//+------------------------------------------------------------------+
class CTradePanel {
private:
    // Panel properties
    string prefix;
    string fontName;
    color backgroundColor;
    color headerColor;
    color accentColor;
    color textColor;
    color profitColor;
    color lossColor;
    int titleFontSize;
    int labelFontSize;
    int xPos, yPos;
    int panelWidth, panelHeight;
    int labelHeight;
    int panelChartHeight;


public:
    //+------------------------------------------------------------------+
    //| Constructor                                                        |
    //+------------------------------------------------------------------+
    CTradePanel() {
        prefix = "TradePanel_";
        fontName = PanelFontName;
        backgroundColor = PanelBaseColor;
        headerColor = PanelHeaderColor;
        accentColor = PanelAccentColor;
        textColor = PanelTextColor;
        profitColor = PanelProfitColor;
        lossColor = PanelLossColor;
        titleFontSize = PanelTitleFontSize;
        labelFontSize = PanelLabelFontSize;
        xPos = 20;
        yPos = 20;
        panelWidth = PanelWidth;
        panelHeight = PanelHeight;
        labelHeight = 22;
        panelChartHeight = PanelChartHeight;
    }

    //+------------------------------------------------------------------+
    //| Public Methods                                                     |
    //+------------------------------------------------------------------+
    void Create() {
        CreateGradientBackground();
        CreateHeader();
        CreatePerformanceSection();
        CreateSessionStats();
        CreateRiskStatus();
    }

    void Update() {
        UpdatePerformanceMetrics();
        UpdateSessionStats();
        UpdateRiskStatus();
    }

private:
    //+------------------------------------------------------------------+
    //| Create Panel Sections                                             |
    //+------------------------------------------------------------------+
    void CreateGradientBackground() {
        CreateRectangleLabel(prefix + "BG", xPos, yPos, panelWidth, panelHeight, backgroundColor);
        CreateRectangleLabel(prefix + "Border", xPos, yPos, panelWidth, 2, accentColor);
        CreateRectangleLabel(prefix + "BorderLeft", xPos, yPos, 2, panelHeight, accentColor);
        CreateRectangleLabel(prefix + "BorderRight", xPos + panelWidth - 2, yPos, 2, panelHeight, accentColor);
        CreateRectangleLabel(prefix + "BorderBottom", xPos, yPos + panelHeight - 2, panelWidth, 2, accentColor);
    }
    

    void CreateHeader() {
        CreateRectangleLabel(prefix + "Header", xPos, yPos, panelWidth, 45, headerColor);
        CreateLabel(prefix + "Title", "Financial Freedom", xPos + panelWidth/2, yPos + 15, 
                   textColor, titleFontSize, fontName, true);
        CreateLabel(prefix + "Subtitle", StringFormat("%s | %s", _Symbol, GetTimeframeStr()), 
                   xPos + panelWidth/2, yPos + 35, textColor, labelFontSize, fontName, true);
    }

    void CreatePerformanceSection() {
        int currentY = yPos + 80;
        CreateSection("PERFORMANCE", currentY);
        currentY += 25;
        
        CreateMetricDisplay("Daily P/L", DoubleToString(stats.dailyProfit, 2), currentY, stats.dailyProfit >= 0);
        currentY += labelHeight;
        CreateMetricDisplay("Weekly P/L", DoubleToString(stats.weeklyProfit, 2), currentY, stats.weeklyProfit >= 0);
        currentY += labelHeight;
        CreateMetricDisplay("Monthly P/L", DoubleToString(stats.monthlyProfit, 2), currentY, stats.monthlyProfit >= 0);
    }

    void CreateSessionStats() {
        int currentY = yPos + 190;
        CreateSection("SESSION STATS", currentY);
        currentY += 25;
        
        string asianStats = StringFormat("%d/%d", stats.asianWins, stats.asianTrades);
        string euroStats = StringFormat("%d/%d", stats.euroWins, stats.euroTrades);
        string usStats = StringFormat("%d/%d", stats.usWins, stats.usTrades);
        
        CreateSessionDisplay("ASIAN", asianStats, currentY, stats.asianWins >= stats.asianTrades/2);
        currentY += labelHeight;
        CreateSessionDisplay("EURO", euroStats, currentY, stats.euroWins >= stats.euroTrades/2);
        currentY += labelHeight;
        CreateSessionDisplay("US", usStats, currentY, stats.usWins >= stats.usTrades/2);
    }

    void CreateRiskStatus() {
        int currentY = yPos + 300;
        CreateSection("RISK STATUS", currentY);
        currentY += 25;
        
        string status = riskMgr.tradingAllowed ? "ACTIVE" : "BLOCKED";
        color statusColor = riskMgr.tradingAllowed ? profitColor : lossColor;
        
        CreateLabel(prefix + "RiskStatus", status, xPos + panelWidth/2, currentY, 
                   statusColor, titleFontSize, fontName, true);
    }

    //+------------------------------------------------------------------+
    //| Helper Methods                                                     |
    //+------------------------------------------------------------------+
    void CreateSection(string title, int y) {
        CreateRectangleLabel(prefix + "Section_" + title, xPos + 10, y, panelWidth - 20, 2, accentColor);
        CreateLabel(prefix + "Title_" + title, title, xPos + 15, y - 15, 
                   accentColor, labelFontSize, fontName);
    }

    void CreateMetricDisplay(string label, string value, int y, bool isPositive) {
        CreateLabel(prefix + label + "_Label", label, xPos + 15, y, textColor, labelFontSize, fontName);
        CreateLabel(prefix + label + "_Value", value, xPos + panelWidth - 20, y, 
                   isPositive ? profitColor : lossColor, labelFontSize, fontName, true, ANCHOR_RIGHT);
    }

    void CreateSessionDisplay(string session, string stats, int y, bool isPositive) {
        CreateLabel(prefix + "Session_" + session, session, xPos + 15, y, textColor, labelFontSize, fontName);
        CreateLabel(prefix + "Stats_" + session, stats, xPos + panelWidth - 20, y, 
                   isPositive ? profitColor : lossColor, labelFontSize, fontName, true, ANCHOR_RIGHT);
    }

    void CreateRectangleLabel(string name, int x, int y, int w, int h, color bgColor) {
        if(ObjectFind(0, name) >= 0)
            ObjectDelete(0, name);
            
        ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
        ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
        ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
        ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
        ObjectSetInteger(0, name, OBJPROP_YSIZE, h);
        ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bgColor);
        ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
        ObjectSetInteger(0, name, OBJPROP_BACK, false);
        ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
    }

    void CreateLabel(string name, string text, int x, int y, color clr, 
                    int fontSize, string font, bool centered = false, 
                    ENUM_ANCHOR_POINT anchor = ANCHOR_LEFT) {
        if(ObjectFind(0, name) >= 0)
            ObjectDelete(0, name);
            
        ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
        ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
        ObjectSetString(0, name, OBJPROP_TEXT, text);
        ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
        ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
        ObjectSetString(0, name, OBJPROP_FONT, font);
        ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
        ObjectSetInteger(0, name, OBJPROP_ANCHOR, centered ? ANCHOR_CENTER : anchor);
        ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
    }

    void UpdateLabel(string name, string text, color clr = CLR_NONE) {
        if(ObjectFind(0, name) >= 0) {
            ObjectSetString(0, name, OBJPROP_TEXT, text);
            if(clr != CLR_NONE)
                ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
        }
    }

    void UpdateMetric(string label, double value) {
        string labelName = prefix + label + "_Value";
        string valueText = DoubleToString(value, 2);
        color valueColor = value >= 0 ? profitColor : lossColor;
        UpdateLabel(labelName, valueText, valueColor);
    }

    void UpdateSession(string session, int wins, int total) {
        string statsName = prefix + "Stats_" + session;
        string statsText = StringFormat("%d/%d (%.1f%%)", 
                          wins, total, 
                          total > 0 ? (double)wins/total * 100 : 0.0);
        color statsColor = (total > 0 && wins >= total/2) ? profitColor : lossColor;
        UpdateLabel(statsName, statsText, statsColor);
    }

    string GetTimeframeStr() {
        switch(Period()) {
            case PERIOD_M1:  return "M1";
            case PERIOD_M5:  return "M5";
            case PERIOD_M15: return "M15";
            case PERIOD_M30: return "M30";
            case PERIOD_H1:  return "H1";
            case PERIOD_H4:  return "H4";
            case PERIOD_D1:  return "D1";
            case PERIOD_W1:  return "W1";
            case PERIOD_MN1: return "MN";
            default: return "TF";
        }
    }

    void UpdatePerformanceMetrics() {
        UpdateMetric("Daily P/L", stats.dailyProfit);
        UpdateMetric("Weekly P/L", stats.weeklyProfit);
        UpdateMetric("Monthly P/L", stats.monthlyProfit);
    }

    void UpdateSessionStats() {
        UpdateSession("ASIAN", stats.asianWins, stats.asianTrades);
        UpdateSession("EURO", stats.euroWins, stats.euroTrades);
        UpdateSession("US", stats.usWins, stats.usTrades);
    }

    void UpdateRiskStatus() {
        string status = riskMgr.tradingAllowed ? "ACTIVE" : "BLOCKED";
        color statusColor = riskMgr.tradingAllowed ? profitColor : lossColor;
        UpdateLabel(prefix + "RiskStatus", status, statusColor);
    }
};


// Global panel object
CTradePanel tradePanel;



//+------------------------------------------------------------------+
//| Close all open positions                                          |
//+------------------------------------------------------------------+
void CloseAllPositions()
{
    for(int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if(PositionSelectByTicket(PositionGetTicket(i)))
        {
            ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            double volume = PositionGetDouble(POSITION_VOLUME);
            ulong ticket = PositionGetTicket(i);
            
            if(posType == POSITION_TYPE_BUY)
            {
                trade.PositionClose(ticket);
                Print("Closed buy position #", ticket, " due to risk management");
            }
            else if(posType == POSITION_TYPE_SELL)
            {
                trade.PositionClose(ticket);
                Print("Closed sell position #", ticket, " due to risk management");
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Draw session lines with exact candle width                         |
//+------------------------------------------------------------------+
void DrawSessionLines()
{
    MqlRates rates[];
    ArraySetAsSeries(rates, true);
    int copied = CopyRates(_Symbol, PERIOD_CURRENT, 0, HistoryBars * 1440, rates);
    
    if(copied <= 0) return;
    
    datetime current_time = TimeCurrent();
    datetime start_time = current_time - (HistoryBars * PeriodSeconds(PERIOD_D1));
    
    ENUM_TIMEFRAMES period = ChartPeriod(0);
    int timeframe_seconds = PeriodSeconds(period);
    
    // Process each day
    for(datetime process_time = start_time; process_time <= current_time; process_time += PeriodSeconds(PERIOD_D1))
    {
        datetime day_start = StringToTime(TimeToString(process_time, TIME_DATE));
        
        datetime first_asian_candle = 0, last_asian_candle = 0;
        datetime first_euro_candle = 0, last_euro_candle = 0;
        datetime first_us_candle = 0, last_us_candle = 0;
        
        double asian_high = 0, asian_low = DBL_MAX;
        double euro_high = 0, euro_low = DBL_MAX;
        double us_high = 0, us_low = DBL_MAX;
        
        bool asian_started = false, euro_started = false, us_started = false;
        
        // Process each candle
        for(int i = 0; i < copied; i++)
        {
            if(rates[i].time < day_start || rates[i].time >= day_start + PeriodSeconds(PERIOD_D1))
                continue;
                
            // Asian Session
            if(IsWithinSession(rates[i].time, AsianSessionStartGMT, AsianSessionEndGMT))
            {
                if(!asian_started)
                {
                    first_asian_candle = rates[i].time;
                    asian_started = true;
                }
                asian_high = MathMax(asian_high, rates[i].high);
                asian_low = MathMin(asian_low, rates[i].low);
                last_asian_candle = rates[i].time;
            }
            
            // European Session
            if(IsWithinSession(rates[i].time, EuropeanSessionStartGMT, EuropeanSessionEndGMT))
            {
                if(!euro_started)
                {
                    first_euro_candle = rates[i].time;
                    euro_started = true;
                }
                euro_high = MathMax(euro_high, rates[i].high);
                euro_low = MathMin(euro_low, rates[i].low);
                last_euro_candle = rates[i].time;
            }
            
            // US Session
            if(IsWithinSession(rates[i].time, AmericanSessionStartGMT, AmericanSessionEndGMT))
            {
                if(!us_started)
                {
                    first_us_candle = rates[i].time;
                    us_started = true;
                }
                us_high = MathMax(us_high, rates[i].high);
                us_low = MathMin(us_low, rates[i].low);
                last_us_candle = rates[i].time;
            }
        }
        
        // Draw lines only if we have valid data
        string date_str = TimeToString(day_start, TIME_DATE);
        
        if(asian_started && asian_high > 0 && asian_low < DBL_MAX)
        {
            DrawLevel("Asian Session High :: " + date_str, asian_high, first_asian_candle, last_asian_candle + timeframe_seconds, AsianHighColor);
            DrawLevel("Asian Session Low :: " + date_str, asian_low, first_asian_candle, last_asian_candle + timeframe_seconds, AsianLowColor);
        }
        
        if(euro_started && euro_high > 0 && euro_low < DBL_MAX)
        {
            DrawLevel("European Session High :: " + date_str, euro_high, first_euro_candle, last_euro_candle + timeframe_seconds, EuropeanHighColor);
            DrawLevel("European Session Low :: " + date_str, euro_low, first_euro_candle, last_euro_candle + timeframe_seconds, EuropeanLowColor);
        }
        
        if(us_started && us_high > 0 && us_low < DBL_MAX)
        {
            DrawLevel("American Session High :: " + date_str, us_high, first_us_candle, last_us_candle + timeframe_seconds, AmericanHighColor);
            DrawLevel("American Session Low :: " + date_str, us_low, first_us_candle, last_us_candle + timeframe_seconds, AmericanLowColor);
        }
    }
}



//--






// Structure for tracking Fibonacci patterns
struct FibPattern {
    datetime startTime;
    datetime endTime;
    double highPrice;
    double lowPrice;
    double level618;
    double level65;
    bool isActive;
    bool tradeOpened;
    int direction;  // 1 for bullish, -1 for bearish
};

// Global variables
FibPattern currentFib;
FibPattern historyFibs[];
int lastLiquidityBreak = 0;  // 1 for bullish break, -1 for bearish break
datetime lastBreakTime = 0;

//+------------------------------------------------------------------+
//| Enhanced liquidity detection with better institutional levels       |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Enhanced liquidity detection with better institutional levels       |
//+------------------------------------------------------------------+
bool CheckLiquidityBreak() {
    MqlRates rates[];
    ArraySetAsSeries(rates, true);
    
    if(CopyRates(_Symbol, _Period, 0, 50, rates) < 50) 
        return false;
        
    // Find significant price clusters/liquidity pools
    double upperLiquidity = 0;
    double lowerLiquidity = 0;
    int upperCount = 0;
    int lowerCount = 0;
    
    // First pass: identify potential liquidity zones
    for(int i = 5; i < 20; i++) {
        // Look for clustered highs
        for(int j = i+1; j < i+5; j++) {
            if(j >= 20) break;
            if(MathAbs(rates[i].high - rates[j].high) <= 20 * _Point) {
                upperCount++;
                upperLiquidity = rates[i].high;
            }
        }
        
        // Look for clustered lows
        for(int j = i+1; j < i+5; j++) {
            if(j >= 20) break;
            if(MathAbs(rates[i].low - rates[j].low) <= 20 * _Point) {
                lowerCount++;
                lowerLiquidity = rates[i].low;
            }
        }
    }
    
    // Verify volume at liquidity levels using tick volume
    long volumes[];
    ArraySetAsSeries(volumes, true);
    if(!CopyTickVolume(_Symbol, _Period, 0, 50, volumes)) {
        Print("Failed to copy tick volume data");
        return false;
    }
    
    double avgVolume = 0;
    for(int i = 0; i < 10; i++) {
        avgVolume += (double)volumes[i];
    }
    avgVolume /= 10;
    
    double currentVolume = (double)volumes[0];
    double points = LiquidityPoints * _Point;
    
    // Check for true liquidity break with volume confirmation
    if(upperCount >= 3 && rates[0].close > upperLiquidity + points && 
       TimeCurrent() - lastBreakTime > PeriodSeconds(PERIOD_H1) &&
       currentVolume > avgVolume * 1.5) {
        
        // Verify price momentum
        double momentum = rates[0].close - rates[1].close;
        if(momentum > points) {
            lastLiquidityBreak = 1;
            lastBreakTime = TimeCurrent();
            currentFib.highPrice = rates[0].high;
            currentFib.lowPrice = upperLiquidity - (points * 2);
            Print("Bullish liquidity break detected at: ", rates[0].close, 
                  " Volume: ", currentVolume, " Avg Volume: ", avgVolume);
            return true;
        }
    }
    
    if(lowerCount >= 3 && rates[0].close < lowerLiquidity - points && 
       TimeCurrent() - lastBreakTime > PeriodSeconds(PERIOD_H1) &&
       currentVolume > avgVolume * 1.5) {
        
        // Verify price momentum
        double momentum = rates[1].close - rates[0].close;
        if(momentum > points) {
            lastLiquidityBreak = -1;
            lastBreakTime = TimeCurrent();
            currentFib.highPrice = lowerLiquidity + (points * 2);
            currentFib.lowPrice = rates[0].low;
            Print("Bearish liquidity break detected at: ", rates[0].close,
                  " Volume: ", currentVolume, " Avg Volume: ", avgVolume);
            return true;
        }
    }
    
    return false;
}


//+------------------------------------------------------------------+
//| Enhanced structure verification with proper momentum               |
//+------------------------------------------------------------------+
bool VerifyStructureChange() {
    if(lastLiquidityBreak == 0) return false;
    
    MqlRates rates[];
    ArraySetAsSeries(rates, true);
    
    if(CopyRates(_Symbol, _Period, 0, 20, rates) < 20) 
        return false;
        
    double structurePoints = StructurePoints * _Point;
    
    if(lastLiquidityBreak == 1) {
        // For buy signals, check for bullish structure
        int bullishCandles = 0;
        double lowestLow = rates[0].low;
        
        for(int i = 1; i < 5; i++) {
            if(rates[i].close > rates[i].open) bullishCandles++;
            if(rates[i].low < lowestLow) lowestLow = rates[i].low;
        }
        
        // Require bullish structure
        return bullishCandles >= 3 && rates[0].close > rates[1].high;
    } 
    else {
        // For sell signals, check for bearish structure
        int bearishCandles = 0;
        double highestHigh = rates[0].high;
        
        for(int i = 1; i < 5; i++) {
            if(rates[i].close < rates[i].open) bearishCandles++;
            if(rates[i].high > highestHigh) highestHigh = rates[i].high;
        }
        
        // Require bearish structure
        return bearishCandles >= 3 && rates[0].close < rates[1].low;
    }
}


//+------------------------------------------------------------------+
//| Draw Fibonacci pattern with diagonal trend                         |
//+------------------------------------------------------------------+
void DrawFibonacciPattern(FibPattern &fib, bool isHistory = false) {
    string prefix = isHistory ? "HistFib_" : "ActiveFib_";
    color fibColor = isHistory ? HistoryFibColor : ActiveFibColor;
    
    // Calculate end point based on trend
    MqlRates rates[];
    ArraySetAsSeries(rates, true);
    int copied = CopyRates(_Symbol, _Period, 0, FibDrawWidth, rates);
    if(copied <= 0) return;
    
    // Calculate trend angle
    double priceRange = fib.highPrice - fib.lowPrice;
    datetime timeRange = FibDrawWidth * PeriodSeconds(_Period);
    double trendAngle = fib.direction == 1 ? 1 : -1;
    
    // Draw main trend line
    string trendName = prefix + TimeToString(fib.startTime);
    datetime endTime = fib.startTime + timeRange;
    double endPrice = fib.direction == 1 ? 
                     fib.lowPrice + (priceRange * trendAngle) : 
                     fib.lowPrice - (priceRange * trendAngle);
                     
    ObjectCreate(0, trendName, OBJ_TREND, 0, fib.startTime, fib.highPrice, 
                endTime, endPrice);
    ObjectSetInteger(0, trendName, OBJPROP_COLOR, fibColor);
    ObjectSetInteger(0, trendName, OBJPROP_WIDTH, 2);
    ObjectSetInteger(0, trendName, OBJPROP_RAY_RIGHT, false);
    
    // Calculate Fibonacci levels
    double range = fib.highPrice - fib.lowPrice;
    fib.level618 = fib.lowPrice + (range * FibLevel618);
    fib.level65 = fib.lowPrice + (range * FibLevel650);
    
    // Draw FibLevel618 level with trend
    string level618Name = prefix + "618_" + TimeToString(fib.startTime);
    double end618 = fib.level618 + (priceRange * trendAngle * FibLevel618);
    ObjectCreate(0, level618Name, OBJ_TREND, 0, fib.startTime, fib.level618,
                endTime, end618);
    ObjectSetInteger(0, level618Name, OBJPROP_COLOR, fibColor);
    ObjectSetInteger(0, level618Name, OBJPROP_STYLE, STYLE_DOT);
    ObjectSetInteger(0, level618Name, OBJPROP_RAY_RIGHT, false);
    
    // Draw FibLevel650 level with trend
    string level65Name = prefix + "65_" + TimeToString(fib.startTime);
    double end65 = fib.level65 + (priceRange * trendAngle * FibLevel650);
    ObjectCreate(0, level65Name, OBJ_TREND, 0, fib.startTime, fib.level65,
                endTime, end65);
    ObjectSetInteger(0, level65Name, OBJPROP_COLOR, fibColor);
    ObjectSetInteger(0, level65Name, OBJPROP_STYLE, STYLE_DOT);
    ObjectSetInteger(0, level65Name, OBJPROP_RAY_RIGHT, false);
    
    // Add floating labels at the start of each line
    string label618Name = prefix + "Label618_" + TimeToString(fib.startTime);
    ObjectCreate(0, label618Name, OBJ_TEXT, 0, fib.startTime, fib.level618);
    ObjectSetString(0, label618Name, OBJPROP_TEXT, "FibLevel618");
    ObjectSetInteger(0, label618Name, OBJPROP_COLOR, fibColor);
    ObjectSetInteger(0, label618Name, OBJPROP_ANCHOR, ANCHOR_LEFT);
    
    string label65Name = prefix + "Label65_" + TimeToString(fib.startTime);
    ObjectCreate(0, label65Name, OBJ_TEXT, 0, fib.startTime, fib.level65);
    ObjectSetString(0, label65Name, OBJPROP_TEXT, "FibLevel650");
    ObjectSetInteger(0, label65Name, OBJPROP_COLOR, fibColor);
    ObjectSetInteger(0, label65Name, OBJPROP_ANCHOR, ANCHOR_LEFT);
    
    // Add horizontal extension lines (optional)
    string ext618Name = prefix + "Ext618_" + TimeToString(fib.startTime);
    string ext65Name = prefix + "Ext65_" + TimeToString(fib.startTime);
    
    ObjectCreate(0, ext618Name, OBJ_TREND, 0, endTime, end618, 
                endTime + (timeRange/2), end618);
    ObjectCreate(0, ext65Name, OBJ_TREND, 0, endTime, end65, 
                endTime + (timeRange/2), end65);
    
    ObjectSetInteger(0, ext618Name, OBJPROP_COLOR, fibColor);
    ObjectSetInteger(0, ext65Name, OBJPROP_COLOR, fibColor);
    ObjectSetInteger(0, ext618Name, OBJPROP_STYLE, STYLE_DOT);
    ObjectSetInteger(0, ext65Name, OBJPROP_STYLE, STYLE_DOT);
    ObjectSetInteger(0, ext618Name, OBJPROP_RAY_RIGHT, false);
    ObjectSetInteger(0, ext65Name, OBJPROP_RAY_RIGHT, false);
}

//+------------------------------------------------------------------+
//| Process Fibonacci pattern creation                                 |
//+------------------------------------------------------------------+
void ProcessFibonacciPattern() {
    if(!currentFib.isActive) return;
    
    // Get recent price movement
    MqlRates rates[];
    ArraySetAsSeries(rates, true);
    if(CopyRates(_Symbol, _Period, 0, FibDrawWidth, rates) <= 0) return;
    
    // Update pattern end points based on price movement
    if(currentFib.direction == 1) {
        // Bullish pattern
        if(rates[0].high > currentFib.highPrice) {
            currentFib.highPrice = rates[0].high;
            DrawFibonacciPattern(currentFib);
        }
    } else {
        // Bearish pattern
        if(rates[0].low < currentFib.lowPrice) {
            currentFib.lowPrice = rates[0].low;
            DrawFibonacciPattern(currentFib);
        }
    }
}

//+------------------------------------------------------------------+
//| Calculate ATR-based stop loss                                     |
//+------------------------------------------------------------------+
double CalculateATRStopLoss(bool isLong) {
    double atr[];
    ArraySetAsSeries(atr, true);
    
    if(CopyBuffer(iATR(_Symbol, _Period, ATRPeriod), 0, 0, 1, atr) <= 0)
        return 0;
        
    double stopDistance = atr[0] * ATRMultiplier;
    double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    
    return isLong ? currentPrice - stopDistance : currentPrice + stopDistance;
}

//+------------------------------------------------------------------+
//| Calculate ATR-based stop loss                                     |
//+------------------------------------------------------------------+
double CalculateATRStopLoss(bool isLong, double entryPrice) {
    double atr[];
    ArraySetAsSeries(atr, true);
    
    if(CopyBuffer(iATR(_Symbol, _Period, ATRPeriod), 0, 0, 1, atr) <= 0)
        return 0;
        
    double stopDistance = atr[0] * ATRMultiplier;
    
    // Get minimum stop level
    double minStopLevel = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point;
    
    // Ensure stop distance is at least the minimum required
    stopDistance = MathMax(stopDistance, minStopLevel * 1.1); // Add 10% buffer
    
    return isLong ? entryPrice - stopDistance : entryPrice + stopDistance;
}




//----



//+------------------------------------------------------------------+
//| Calculate optimal stop loss based on structure                     |
//+------------------------------------------------------------------+
double CalculateStructureBasedStop(bool isBuy, const MqlRates &rates[], int startBar = 1, int lookback = 10) {
    if(ArraySize(rates) < lookback + startBar) return 0;
    
    double stopLevel = 0;
    
    if(isBuy) {
        // For buy trades, find recent swing low
        double lowestLow = rates[startBar].low;
        for(int i = startBar; i < lookback + startBar; i++) {
            if(rates[i].low < lowestLow) lowestLow = rates[i].low;
        }
        stopLevel = lowestLow - (10 * _Point); // Add buffer
    } else {
        // For sell trades, find recent swing high
        double highestHigh = rates[startBar].high;
        for(int i = startBar; i < lookback + startBar; i++) {
            if(rates[i].high > highestHigh) highestHigh = rates[i].high;
        }
        stopLevel = highestHigh + (10 * _Point); // Add buffer
    }
    
    return stopLevel;
}

//+------------------------------------------------------------------+
//| Calculate position size based on risk                             |
//+------------------------------------------------------------------+
double CalculatePositionSize(double entryPrice, double stopLoss) {
    double riskAmount = AccountInfoDouble(ACCOUNT_BALANCE) * (RiskPercentage / 100.0);
    double pipValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
    double stopDistance = MathAbs(entryPrice - stopLoss) / _Point;
    
    if(stopDistance <= 0 || pipValue <= 0) return 0;
    
    double positionSize = (riskAmount / (stopDistance * pipValue));
    positionSize = NormalizeDouble(positionSize, 2); // Round to 2 decimal places
    
    // Ensure position size meets minimum and maximum requirements
    double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
    
    return MathMin(MathMax(positionSize, minLot), maxLot);
}







//---

//+------------------------------------------------------------------+
//| Enhanced Zone Manager with History                                 |
//+------------------------------------------------------------------+
class CZoneManager {
private:
    color slZoneColor;
    color tpZoneColor;
    color historySlZoneColor;
    color historyTpZoneColor;
    color historyZoneOutlineColor;
    int zoneOpacity;
    string prefix;
    string historyPrefix;
    
public:
    CZoneManager() {
        slZoneColor = ActiveSLZoneColor;
        tpZoneColor = ActiveTPZoneColor;
        historySlZoneColor = HistorySLZoneColor;
        historyTpZoneColor = HistoryTPZoneColor;
        historyZoneOutlineColor = HistoryZoneOutlineColor;
        zoneOpacity = ZoneOpacity;
        prefix = ZonePrefix;
        historyPrefix = HistoryZonePrefix;
    }
    
void DrawTradingZones(bool isBuy, double entryPrice, double slLevel, double tpLevel) {
    datetime currentTime = TimeCurrent();
    datetime futureTime = currentTime + (PeriodSeconds(PERIOD_CURRENT) * 10); // Reduced time extension
    
    // Clean up previous active zones
    ObjectsDeleteAll(0, prefix);
    
    // Draw Stop Loss Zone - Compact version
    string slZoneName = prefix + "SL";
    double zonePadding = 2 * _Point; // Minimal padding for visibility
    
    if(isBuy) {
        // For buy trades, SL zone is below entry
        ObjectCreate(0, slZoneName, OBJ_RECTANGLE, 0, 
                    currentTime, slLevel,     // Bottom of zone at SL level
                    futureTime, entryPrice);  // Top of zone at entry
    } else {
        // For sell trades, SL zone is above entry
        ObjectCreate(0, slZoneName, OBJ_RECTANGLE, 0, 
                    currentTime, entryPrice,  // Bottom of zone at entry
                    futureTime, slLevel);     // Top of zone at SL level
    }
    
    ObjectSetInteger(0, slZoneName, OBJPROP_COLOR, slZoneColor);
    ObjectSetInteger(0, slZoneName, OBJPROP_FILL, true);
    ObjectSetInteger(0, slZoneName, OBJPROP_BACK, true);
    ObjectSetInteger(0, slZoneName, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, slZoneName, OBJPROP_HIDDEN, true);
    
    // Draw Take Profit Zone - Compact version
    string tpZoneName = prefix + "TP";
    
    if(isBuy) {
        // For buy trades, TP zone is above entry
        ObjectCreate(0, tpZoneName, OBJ_RECTANGLE, 0,
                    currentTime, entryPrice,  // Bottom of zone at entry
                    futureTime, tpLevel);     // Top of zone at TP level
    } else {
        // For sell trades, TP zone is below entry
        ObjectCreate(0, tpZoneName, OBJ_RECTANGLE, 0,
                    currentTime, tpLevel,     // Bottom of zone at TP level
                    futureTime, entryPrice);  // Top of zone at entry
    }
    
    ObjectSetInteger(0, tpZoneName, OBJPROP_COLOR, tpZoneColor);
    ObjectSetInteger(0, tpZoneName, OBJPROP_FILL, true);
    ObjectSetInteger(0, tpZoneName, OBJPROP_BACK, true);
    ObjectSetInteger(0, tpZoneName, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, tpZoneName, OBJPROP_HIDDEN, true);
}

//+------------------------------------------------------------------+
//| Save compact history zones                                         |
//+------------------------------------------------------------------+
void SaveZonesToHistory(bool isBuy, double entryPrice, double slLevel, double tpLevel, 
                       datetime openTime, datetime closeTime, bool isProfit) {
    string timeStr = TimeToString(openTime);
    
    // Draw historical stop loss zone - Compact version
    string historySlName = historyPrefix + "SL_" + timeStr;
    
    if(isBuy) {
        ObjectCreate(0, historySlName, OBJ_RECTANGLE, 0,
                    openTime, slLevel,      // Bottom at SL
                    closeTime, entryPrice); // Top at entry
    } else {
        ObjectCreate(0, historySlName, OBJ_RECTANGLE, 0,
                    openTime, entryPrice,   // Bottom at entry
                    closeTime, slLevel);    // Top at SL
    }
    
    ObjectSetInteger(0, historySlName, OBJPROP_COLOR, historySlZoneColor);
    ObjectSetInteger(0, historySlName, OBJPROP_FILL, true);
    ObjectSetInteger(0, historySlName, OBJPROP_BACK, true);
    ObjectSetInteger(0, historySlName, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, historySlName, OBJPROP_HIDDEN, true);
    
    // Draw historical take profit zone - Compact version
    string historyTpName = historyPrefix + "TP_" + timeStr;
    
    if(isBuy) {
        ObjectCreate(0, historyTpName, OBJ_RECTANGLE, 0,
                    openTime, entryPrice,   // Bottom at entry
                    closeTime, tpLevel);    // Top at TP
    } else {
        ObjectCreate(0, historyTpName, OBJ_RECTANGLE, 0,
                    openTime, tpLevel,      // Bottom at TP
                    closeTime, entryPrice); // Top at entry
    }
    
    ObjectSetInteger(0, historyTpName, OBJPROP_COLOR, historyTpZoneColor);
    ObjectSetInteger(0, historyTpName, OBJPROP_FILL, true);
    ObjectSetInteger(0, historyTpName, OBJPROP_BACK, true);
    ObjectSetInteger(0, historyTpName, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, historyTpName, OBJPROP_HIDDEN, true);
    
    // Add entry line
    string entryLineName = historyPrefix + "Entry_" + timeStr;
    ObjectCreate(0, entryLineName, OBJ_TREND, 0,
                openTime, entryPrice, closeTime, entryPrice);
    ObjectSetInteger(0, entryLineName, OBJPROP_COLOR, historyZoneOutlineColor);
    ObjectSetInteger(0, entryLineName, OBJPROP_STYLE, STYLE_SOLID);
    ObjectSetInteger(0, entryLineName, OBJPROP_WIDTH, 1);
    ObjectSetInteger(0, entryLineName, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, entryLineName, OBJPROP_HIDDEN, true);
}

  void CalculateZoneLevels(bool isBuy, double entryPrice, double &slLevel, double &tpLevel) {
    double atr[];
    ArraySetAsSeries(atr, true);
    
    // Get ATR for dynamic zone calculation
    if(CopyBuffer(iATR(_Symbol, PERIOD_CURRENT, ATRPeriod), 0, 0, 1, atr) <= 0)
        return;
        
    double baseDistance = atr[0];
    
    if(isBuy) {
        // For buy trades
        slLevel = entryPrice - (baseDistance * StopLossMultiplier);
        tpLevel = entryPrice + (baseDistance * TakeProfitMultiplier);
    }
    else {
        // For sell trades
        slLevel = entryPrice + (baseDistance * StopLossMultiplier);
        tpLevel = entryPrice - (baseDistance * TakeProfitMultiplier);
    }
}

};

// Global zone manager instance
CZoneManager zoneManager;



//--

//+------------------------------------------------------------------+
//| Check liquidity across multiple timeframes                         |
//+------------------------------------------------------------------+
struct LiquidityInfo {
    bool found;
    string timeframe;
    double level;
    datetime time;
};

//+------------------------------------------------------------------+
//| Enhanced liquidity check across timeframes                         |
//+------------------------------------------------------------------+
LiquidityInfo CheckLiquidityBreakAll() {
    LiquidityInfo result;
    result.found = false;
    
    // Check Weekly liquidity first
    MqlRates weeklyRates[];
    ArraySetAsSeries(weeklyRates, true);
    if(CopyRates(_Symbol, PERIOD_W1, 0, 10, weeklyRates) > 0) {
        double weeklyHigh = weeklyRates[1].high;
        double weeklyLow = weeklyRates[1].low;
        
        if(CheckPriceCrossLevel(weeklyHigh, true) || CheckPriceCrossLevel(weeklyLow, false)) {
            result.found = true;
            result.timeframe = "WEEKLY";
            result.level = CheckPriceCrossLevel(weeklyHigh, true) ? weeklyHigh : weeklyLow;
            result.time = weeklyRates[1].time;
            return result;
        }
    }
    
    // Check Daily liquidity
    MqlRates dailyRates[];
    ArraySetAsSeries(dailyRates, true);
    if(CopyRates(_Symbol, PERIOD_D1, 0, 10, dailyRates) > 0) {
        double dailyHigh = dailyRates[1].high;
        double dailyLow = dailyRates[1].low;
        
        if(CheckPriceCrossLevel(dailyHigh, true) || CheckPriceCrossLevel(dailyLow, false)) {
            result.found = true;
            result.timeframe = "DAILY";
            result.level = CheckPriceCrossLevel(dailyHigh, true) ? dailyHigh : dailyLow;
            result.time = dailyRates[1].time;
            return result;
        }
    }
    
    // Check Session liquidity
    if(IsWithinSession(TimeCurrent(), AsianSessionStartGMT, AsianSessionEndGMT)) {
        if(CheckSessionLiquidity("ASIAN")) {
            result.found = true;
            result.timeframe = "ASIAN";
            result.level = lastLiquidityBreak == 1 ? currentFib.highPrice : currentFib.lowPrice;
            result.time = TimeCurrent();
            return result;
        }
    }
    else if(IsWithinSession(TimeCurrent(), EuropeanSessionStartGMT, EuropeanSessionEndGMT)) {
        if(CheckSessionLiquidity("EUROPEAN")) {
            result.found = true;
            result.timeframe = "EUROPEAN";
            result.level = lastLiquidityBreak == 1 ? currentFib.highPrice : currentFib.lowPrice;
            result.time = TimeCurrent();
            return result;
        }
    }
    else if(IsWithinSession(TimeCurrent(), AmericanSessionStartGMT, AmericanSessionEndGMT)) {
        if(CheckSessionLiquidity("AMERICAN")) {
            result.found = true;
            result.timeframe = "AMERICAN";
            result.level = lastLiquidityBreak == 1 ? currentFib.highPrice : currentFib.lowPrice;
            result.time = TimeCurrent();
            return result;
        }
    }
    
    return result;
}

//+------------------------------------------------------------------+
//| Check if price crosses a specific level                            |
//+------------------------------------------------------------------+
bool CheckPriceCrossLevel(double level, bool isHigh) {
    MqlRates rates[];
    ArraySetAsSeries(rates, true);
    if(CopyRates(_Symbol, _Period, 0, 3, rates) < 3) return false;
    
    double points = LiquidityPoints * _Point;
    
    if(isHigh) {
        return rates[0].close > level + points && rates[1].close < level;
    } else {
        return rates[0].close < level - points && rates[1].close > level;
    }
}

//+------------------------------------------------------------------+
//| Check session-specific liquidity                                   |
//+------------------------------------------------------------------+
bool CheckSessionLiquidity(string session) {
    MqlRates rates[];
    ArraySetAsSeries(rates, true);
    
    if(CopyRates(_Symbol, _Period, 0, 50, rates) < 50) 
        return false;
        
    long volumes[];
    ArraySetAsSeries(volumes, true);
    if(!CopyTickVolume(_Symbol, _Period, 0, 50, volumes)) 
        return false;
        
    double avgVolume = 0;
    for(int i = 0; i < 10; i++) avgVolume += (double)volumes[i];
    avgVolume /= 10;
    
    double currentVolume = (double)volumes[0];
    double points = LiquidityPoints * _Point;
    
    // Look for session-specific price clusters
    double upperLiquidity = 0, lowerLiquidity = 0;
    int upperCount = 0, lowerCount = 0;
    
    for(int i = 5; i < 20; i++) {
        for(int j = i+1; j < i+5; j++) {
            if(j >= 20) break;
            if(MathAbs(rates[i].high - rates[j].high) <= 20 * _Point) {
                upperCount++;
                upperLiquidity = rates[i].high;
            }
            if(MathAbs(rates[i].low - rates[j].low) <= 20 * _Point) {
                lowerCount++;
                lowerLiquidity = rates[i].low;
            }
        }
    }
    
    if(upperCount >= 3 && rates[0].close > upperLiquidity + points && 
       currentVolume > avgVolume * 1.5) {
        lastLiquidityBreak = 1;
        return true;
    }
    
    if(lowerCount >= 3 && rates[0].close < lowerLiquidity - points && 
       currentVolume > avgVolume * 1.5) {
        lastLiquidityBreak = -1;
        return true;
    }
    
    return false;
}




//+------------------------------------------------------------------+
//| Get current trading session                                        |
//+------------------------------------------------------------------+
string GetCurrentSession() {
    datetime current = TimeCurrent();
    
    if(IsWithinSession(current, AsianSessionStartGMT, AsianSessionEndGMT))
        return "ASIAN";
    if(IsWithinSession(current, EuropeanSessionStartGMT, EuropeanSessionEndGMT))
        return "EUROPEAN";
    if(IsWithinSession(current, AmericanSessionStartGMT, AmericanSessionEndGMT))
        return "AMERICAN";
        
    return "NO_SESSION";
}


//+------------------------------------------------------------------+
//| Enhanced ATR-based Stop Loss Calculator                            |
//+------------------------------------------------------------------+
double CalculateEnhancedStopLoss(bool isBuy, double entryPrice) {
    // Get ATR values
    double atr[];
    ArraySetAsSeries(atr, true);
    
    if(CopyBuffer(iATR(_Symbol, PERIOD_CURRENT, ATRPeriod), 0, 0, 3, atr) <= 0)
        return 0;
        
    // Get recent price action for liquidity analysis
    MqlRates rates[];
    ArraySetAsSeries(rates, true);
    if(CopyRates(_Symbol, PERIOD_CURRENT, 0, 20, rates) <= 0)
        return 0;
        
    // Base stop distance from ATR
    double baseStopDistance = atr[0] * ATRMultiplier;
    
    // Find recent swing levels for stop placement
    double swingLevel = 0;
    double liquidityLevel = 0;
    
    if(isBuy) {
        // For buy trades, find recent swing low and liquidity sweep level
        swingLevel = rates[0].low;
        for(int i = 1; i < 20; i++) {
            // Find swing low
            if(rates[i].low < swingLevel) {
                swingLevel = rates[i].low;
            }
            
            // Look for liquidity sweep pattern
            if(i < 18 && rates[i].low < rates[i+1].low && rates[i].low < rates[i-1].low) {
                liquidityLevel = rates[i].low;
                break;
            }
        }
        
        // Place stop below the lowest of: 
        // 1. ATR-based distance
        // 2. Recent swing low
        // 3. Liquidity sweep level
        double atrStop = entryPrice - baseStopDistance;
        double swingStop = swingLevel - (10 * _Point);
        double liquidityStop = liquidityLevel - (15 * _Point);
        
        // Use the most conservative (lowest) stop level
        double stopLevel = MathMax(atrStop, MathMax(swingStop, liquidityStop));
        
        // Ensure minimum stop distance
        double minStop = entryPrice - (SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point);
        return MathMin(stopLevel, minStop);
    }
    else {
        // For sell trades, find recent swing high and liquidity sweep level
        swingLevel = rates[0].high;
        for(int i = 1; i < 20; i++) {
            // Find swing high
            if(rates[i].high > swingLevel) {
                swingLevel = rates[i].high;
            }
            
            // Look for liquidity sweep pattern
            if(i < 18 && rates[i].high > rates[i+1].high && rates[i].high > rates[i-1].high) {
                liquidityLevel = rates[i].high;
                break;
            }
        }
        
        // Place stop above the highest of:
        // 1. ATR-based distance
        // 2. Recent swing high
        // 3. Liquidity sweep level
        double atrStop = entryPrice + baseStopDistance;
        double swingStop = swingLevel + (10 * _Point);
        double liquidityStop = liquidityLevel + (15 * _Point);
        
        // Use the most conservative (highest) stop level
        double stopLevel = MathMin(atrStop, MathMin(swingStop, liquidityStop));
        
        // Ensure minimum stop distance
        double minStop = entryPrice + (SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point);
        return MathMax(stopLevel, minStop);
    }
}


//+------------------------------------------------------------------+
//| Calculate Dynamic Take Profit                                      |
//+------------------------------------------------------------------+
double CalculateEnhancedTakeProfit(bool isBuy, double entryPrice, double stopLoss) {
    // Get ATR for volatility-based calculations
    double atr[];
    ArraySetAsSeries(atr, true);
    if(CopyBuffer(iATR(_Symbol, PERIOD_CURRENT, ATRPeriod), 0, 0, 1, atr) <= 0)
        return 0;
        
    // Get recent price action
    MqlRates rates[];
    ArraySetAsSeries(rates, true);
    if(CopyRates(_Symbol, PERIOD_CURRENT, 0, 50, rates) <= 0)
        return 0;
        
    double stopDistance = MathAbs(entryPrice - stopLoss);
    double atrValue = atr[0];
    
    // Find significant price levels
    double nearestResistance = FindNearestResistance(rates, entryPrice);
    double nearestSupport = FindNearestSupport(rates, entryPrice);
    
    if(isBuy) {
        // For buy trades
        double minTarget = entryPrice + (stopDistance * 1.5); // Minimum 1.5:1 RR
        double atrTarget = entryPrice + (atrValue * 2);      // 2 x ATR
        double structureTarget = nearestResistance;          // Next resistance level
        
        // Use the most conservative target that's still above minimum
        double takeProfit = minTarget;
        
        if(atrTarget > minTarget && atrTarget < structureTarget) {
            takeProfit = atrTarget;
        } else if(structureTarget > minTarget && structureTarget < atrTarget) {
            takeProfit = structureTarget;
        }
        
        return takeProfit;
    } else {
        // For sell trades
        double minTarget = entryPrice - (stopDistance * 1.5); // Minimum 1.5:1 RR
        double atrTarget = entryPrice - (atrValue * 2);      // 2 x ATR
        double structureTarget = nearestSupport;             // Next support level
        
        // Use the most conservative target that's still below minimum
        double takeProfit = minTarget;
        
        if(atrTarget < minTarget && atrTarget > structureTarget) {
            takeProfit = atrTarget;
        } else if(structureTarget < minTarget && structureTarget > atrTarget) {
            takeProfit = structureTarget;
        }
        
        return takeProfit;
    }
}



//+------------------------------------------------------------------+
//| Enhanced Liquidity Sweep Detection and Trading                     |
//+------------------------------------------------------------------+
struct LiquidityLevel {
    double price;
    datetime time;
    bool isTop;
    int touches;
    bool swept;
};

// Global variables for tracking liquidity levels
LiquidityLevel activeLevels[];

//+------------------------------------------------------------------+
//| Detect Liquidity Levels and Order Blocks                          |
//+------------------------------------------------------------------+
void DetectLiquidityLevels() {
    MqlRates rates[];
    ArraySetAsSeries(rates, true);
    
    if(CopyRates(_Symbol, PERIOD_CURRENT, 0, 100, rates) <= 0) 
        return;
        
    // Look for price clusters and rejection points
    for(int i = 20; i < 90; i++) {
        // Check for potential liquidity level
        if(IsLiquidityLevel(rates, i)) {
            LiquidityLevel level;
            level.time = rates[i].time;
            level.touches = 1;
            level.swept = false;
            
            // Determine if it's top or bottom liquidity
            if(IsTopLiquidity(rates, i)) {
                level.price = rates[i].high;
                level.isTop = true;
            } else {
                level.price = rates[i].low;
                level.isTop = false;
            }
            
            // Add to active levels if unique
            if(!LiquidityLevelExists(level.price)) {
                int size = ArraySize(activeLevels);
                ArrayResize(activeLevels, size + 1);
                activeLevels[size] = level;
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Check if price level is potential liquidity zone                   |
//+------------------------------------------------------------------+
bool IsLiquidityLevel(const MqlRates &rates[], int index) {
    int touches = 0;
    double level = rates[index].high; // Check both high and low
    
    // Look for multiple touches of this level
    for(int i = index - 10; i < index + 10; i++) {
        if(i < 0 || i >= ArraySize(rates)) continue;
        
        if(MathAbs(rates[i].high - level) <= 20 * _Point || 
           MathAbs(rates[i].low - level) <= 20 * _Point) {
            touches++;
        }
    }
    
    return touches >= 3; // Require at least 3 touches
}

//+------------------------------------------------------------------+
//| Identify top or bottom liquidity                                   |
//+------------------------------------------------------------------+
bool IsTopLiquidity(const MqlRates &rates[], int index) {
    double avgPrice = 0;
    for(int i = index - 5; i < index + 5; i++) {
        if(i < 0 || i >= ArraySize(rates)) continue;
        avgPrice += rates[i].close;
    }
    avgPrice /= 10;
    
    return rates[index].high > avgPrice;
}

//+------------------------------------------------------------------+
//| Enhanced Trade Decision with Fibonacci                             |
//+------------------------------------------------------------------+
void ProcessTrading() {
    if(PositionsTotal() > 0) return;
    
    MqlRates rates[];
    ArraySetAsSeries(rates, true);
    if(CopyRates(_Symbol, PERIOD_CURRENT, 0, 50, rates) <= 0) return;
    
    // Update liquidity levels and Fibonacci patterns
    DetectLiquidityLevels();
    UpdateFibonacciPatterns(rates);
    
    // Look for trade setups
    for(int i = 0; i < ArraySize(activeLevels); i++) {
        if(activeLevels[i].swept) continue;
        
        // Check for liquidity sweep setup
        if(IsValidSweepSetup(rates, activeLevels[i])) {
            // Determine trade direction
            bool isBuy = !activeLevels[i].isTop;
            
            // Check for orderblock formation
            if(IsValidOrderBlock(rates, isBuy)) {
                // Verify Fibonacci confirmation
                if(HasFibonacciConfirmation(rates, isBuy, rates[0].close)) {
                    ExecuteSweepTrade(isBuy, rates[0].close, activeLevels[i].price);
                    activeLevels[i].swept = true;
                }
            }
        }
    }
}


//+------------------------------------------------------------------+
//| Update and track Fibonacci patterns                                |
//+------------------------------------------------------------------+
void UpdateFibonacciPatterns(const MqlRates& rates[]) {
    // Update current Fibonacci pattern if active
    if(currentFib.isActive) {
        if(currentFib.direction == 1) { // Bullish pattern
            if(rates[0].high > currentFib.highPrice) {
                currentFib.highPrice = rates[0].high;
                DrawFibonacciPattern(currentFib);
            }
        } else { // Bearish pattern
            if(rates[0].low < currentFib.lowPrice) {
                currentFib.lowPrice = rates[0].low;
                DrawFibonacciPattern(currentFib);
            }
        }
    }
    
    // Create new Fibonacci pattern if we have a significant move
    if(!currentFib.isActive) {
        if(CheckForFibonacciSetup(rates)) {
            currentFib.isActive = true;
            currentFib.startTime = rates[0].time;
            DrawFibonacciPattern(currentFib);
        }
    }
}

//+------------------------------------------------------------------+
//| Check for potential Fibonacci setup                                |
//+------------------------------------------------------------------+
bool CheckForFibonacciSetup(const MqlRates &rates[]) {
    if(ArraySize(rates) < 20) return false;
    
    // Calculate momentum and trend direction
    double momentum = 0;
    int direction = 0; // 1 for bullish, -1 for bearish
    
    // Find significant swing points
    double highestHigh = rates[1].high;
    double lowestLow = rates[1].low;
    int swingIndex = 1;
    
    // Look for swing points in last 20 candles
    for(int i = 1; i < 20; i++) {
        if(rates[i].high > highestHigh) {
            highestHigh = rates[i].high;
            swingIndex = i;
        }
        if(rates[i].low < lowestLow) {
            lowestLow = rates[i].low;
            swingIndex = i;
        }
    }
    
    // Calculate momentum
    momentum = rates[0].close - rates[swingIndex].close;
    
    // Determine trend direction based on momentum
    if(MathAbs(momentum) > 20 * _Point) { // Minimum momentum threshold
        direction = (momentum > 0) ? 1 : -1;
    } else {
        return false; // Not enough momentum
    }
    
    // Check for pattern formation
    if(direction == 1) { // Bullish pattern
        // Check for bullish momentum and structure
        if(rates[0].close > rates[1].close && 
           rates[0].close > rates[2].close && 
           rates[0].low > rates[1].low) {
            
            // Set up Fibonacci levels for bullish pattern
            currentFib.direction = 1;
            currentFib.highPrice = highestHigh;
            currentFib.lowPrice = lowestLow;
            currentFib.level618 = lowestLow + ((highestHigh - lowestLow) * FibLevel618);
            currentFib.level65 = lowestLow + ((highestHigh - lowestLow) * FibLevel650);
            return true;
        }
    }
    else { // Bearish pattern
        // Check for bearish momentum and structure
        if(rates[0].close < rates[1].close && 
           rates[0].close < rates[2].close && 
           rates[0].high < rates[1].high) {
            
            // Set up Fibonacci levels for bearish pattern
            currentFib.direction = -1;
            currentFib.highPrice = highestHigh;
            currentFib.lowPrice = lowestLow;
            currentFib.level618 = highestHigh - ((highestHigh - lowestLow) * FibLevel618);
            currentFib.level65 = highestHigh - ((highestHigh - lowestLow) * FibLevel650);
            return true;
        }
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Check if price is at valid Fibonacci level                         |
//+------------------------------------------------------------------+
bool HasFibonacciConfirmation(const MqlRates& rates[], bool isBuy, double price) {
    if(!currentFib.isActive) return false;
    
    double tolerance = 10 * _Point; // 10 points tolerance for level test
    
    if(isBuy) {
        // For buy trades, check if price is near 0.618 or 0.65 level after pullback
        return (MathAbs(price - currentFib.level618) <= tolerance ||
                MathAbs(price - currentFib.level65) <= tolerance) &&
               rates[0].close > rates[0].open; // Confirming bullish candle
    } else {
        // For sell trades, check if price is near 1 - 0.618 or 1 - 0.65 level after pullback
        double invLevel618 = currentFib.highPrice - (currentFib.highPrice - currentFib.lowPrice) * FibLevel618;
        double invLevel65 = currentFib.highPrice - (currentFib.highPrice - currentFib.lowPrice) * FibLevel650;
        
        return (MathAbs(price - invLevel618) <= tolerance ||
                MathAbs(price - invLevel65) <= tolerance) &&
               rates[0].close < rates[0].open; // Confirming bearish candle
    }
}



//+------------------------------------------------------------------+
//| Validate Liquidity Sweep Setup                                     |
//+------------------------------------------------------------------+
bool IsValidSweepSetup(const MqlRates &rates[], const LiquidityLevel &level) {
    if(level.isTop) {
        // Sweep above resistance - Look for SELL setup
        // Price must sweep above level and then close below it
        return rates[0].high > level.price && 
               rates[0].close < level.price - (20 * _Point) &&
               rates[0].close < rates[0].open; // Confirming bearish close
    } else {
        // Sweep below support - Look for BUY setup
        // Price must sweep below level and then close above it
        return rates[0].low < level.price && 
               rates[0].close > level.price + (20 * _Point) &&
               rates[0].close > rates[0].open; // Confirming bullish close
    }
}

bool IsValidOrderBlock(const MqlRates &rates[], bool isBuy) {
    if(isBuy) {
        Print("isBuy: ", isBuy, 
              ", Close[1]: ", rates[1].close, ", Open[1]: ", rates[1].open,
              ", Low[0]: ", rates[0].low, ", Low[1]: ", rates[1].low,
              ", Close[0]: ", rates[0].close, ", Open[0]: ", rates[0].open);
        return rates[1].close > rates[1].open && // Bullish candle
               rates[0].low > rates[1].low &&    // Higher low
               rates[0].close > rates[0].open;   // Another bullish candle
    } else {
        Print("isBuy: ", isBuy, 
              ", Close[1]: ", rates[1].close, ", Open[1]: ", rates[1].open,
              ", High[0]: ", rates[0].high, ", High[1]: ", rates[1].high,
              ", Close[0]: ", rates[0].close, ", Open[0]: ", rates[0].open);
        return rates[1].close < rates[1].open && // Bearish candle
               rates[0].high < rates[1].high &&  // Lower high
               rates[0].close < rates[0].open;   // Another bearish candle
    }
}


// Add these structures at the top of your code
struct TradeSignal {
    string type;      // Type of signal (e.g., "LIQUIDITY_SWEEP", "FIBONACCI", etc.)
    datetime time;    // When the signal was generated
    bool executed;    // Whether this signal was traded
};

struct SessionTrades {
    int totalTrades;          // Total trades in current session
    string activeSignals[];   // Types of signals already traded this session
};

// Global variables for trade management
TradeSignal currentSignal;
SessionTrades sessionTrades;

//+------------------------------------------------------------------+
//| Reset session trades at session change                             |
//+------------------------------------------------------------------+
void ResetSessionTrades() {
    static string lastSession = "";
    string currentSession = GetCurrentSession();
    
    if(lastSession != currentSession) {
        sessionTrades.totalTrades = 0;
        ArrayResize(sessionTrades.activeSignals, 0);
        lastSession = currentSession;
    }
}

//+------------------------------------------------------------------+
//| Check if signal type already traded in current session             |
//+------------------------------------------------------------------+
bool IsSignalAlreadyTraded(string signalType) {
    for(int i = 0; i < ArraySize(sessionTrades.activeSignals); i++) {
        if(sessionTrades.activeSignals[i] == signalType) {
            return true;
        }
    }
    return false;
}

//+------------------------------------------------------------------+
//| Record new trade signal                                            |
//+------------------------------------------------------------------+
void RecordTradeSignal(string signalType) {
    int size = ArraySize(sessionTrades.activeSignals);
    ArrayResize(sessionTrades.activeSignals, size + 1);
    sessionTrades.activeSignals[size] = signalType;
    sessionTrades.totalTrades++;
}

//+------------------------------------------------------------------+
//| Verify if new trade can be opened                                  |
//+------------------------------------------------------------------+
bool CanOpenNewTrade(string signalType) {
    // Reset session trades if needed
    ResetSessionTrades();
    
    // Check if we're in a valid trading session
    if(GetCurrentSession() == "NO_SESSION") {
        Print("No active trading session");
        return false;
    }
    
    // Check maximum trades per session
    if(sessionTrades.totalTrades >= 2) {
        Print("Maximum session trades reached");
        return false;
    }
    
    // Check if signal type already traded
    if(IsSignalAlreadyTraded(signalType)) {
        Print("Signal type already traded in current session");
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Modified Execute Trade with Fibonacci Levels                       |
//+------------------------------------------------------------------+
void ExecuteSweepTrade(bool isBuy, double currentPrice, double sweepLevel) {
    if(!CanOpenNewTrade("FIBSWEEP")) return;
    
    // Calculate entry, stop loss and take profit levels
    double entryPrice = GetFibonacciEntryPrice(isBuy, currentPrice);
    if(entryPrice == 0) return;  // Invalid entry price
    
    MqlRates priceRates[];  // Renamed from rates to avoid conflict
    ArraySetAsSeries(priceRates, true);
    if(CopyRates(_Symbol, PERIOD_CURRENT, 0, 20, priceRates) <= 0) return;
    
    double stopLoss = CalculateFibonacciStopLoss(isBuy, entryPrice, priceRates);
    if(stopLoss == 0) return;  // Invalid stop loss
    
    double takeProfit = CalculateFibonacciTakeProfit(isBuy, entryPrice, stopLoss);
    if(takeProfit == 0) return;  // Invalid take profit
    
    // Calculate base position size
    double basePositionSize = CalculatePositionSize(entryPrice, stopLoss);
    
    // Apply Martingale multiplier if enabled
    double finalPositionSize = EnableMartingale ? 
                              CalculateMartingaleSize(basePositionSize) : 
                              basePositionSize;
    
    // Execute the trade
    bool tradeResult = false;
    if(isBuy) {
        tradeResult = trade.Buy(finalPositionSize, _Symbol, 0, stopLoss, takeProfit, "FibSweepBuy");
    } else {
        tradeResult = trade.Sell(finalPositionSize, _Symbol, 0, stopLoss, takeProfit, "FibSweepSell");
    }
    
    if(tradeResult) {
        ulong ticket = trade.ResultOrder();
        AddNewPosition(ticket, entryPrice, stopLoss, takeProfit, 
                      isBuy ? POSITION_TYPE_BUY : POSITION_TYPE_SELL);
        
        // Update tracking for Martingale
        if(EnableMartingale) {
            martingaleState.lastEntryPrice = entryPrice;
            martingaleState.lastLotSize = finalPositionSize;
        }
        
        Print("Trade executed: ", (isBuy ? "BUY" : "SELL"), 
              " at ", entryPrice,
              " SL: ", stopLoss,
              " TP: ", takeProfit,
              " Size: ", finalPositionSize,
              EnableMartingale ? " Martingale Level: " + IntegerToString(martingaleState.currentLevel) : "");
    }
}


//+------------------------------------------------------------------+
//| Calculate entry price based on Fibonacci levels                    |
//+------------------------------------------------------------------+
double GetFibonacciEntryPrice(bool isBuy, double currentPrice) {
    if(!currentFib.isActive) return 0;
    
    if(isBuy) {
        // Use 0.618 or 0.65 retracement level for entry
        return MathMin(currentFib.level618, currentFib.level65);
    } else {
        // Use inverse Fibonacci levels for sell trades
        double invLevel618 = currentFib.highPrice - (currentFib.highPrice - currentFib.lowPrice) * FibLevel618;
        double invLevel65 = currentFib.highPrice - (currentFib.highPrice - currentFib.lowPrice) * FibLevel650;
        return MathMax(invLevel618, invLevel65);
    }
}

//+------------------------------------------------------------------+
//| Calculate stop loss using Fibonacci levels                         |
//+------------------------------------------------------------------+
double CalculateFibonacciStopLoss(bool isBuy, double entryPrice, const MqlRates& rates[]) {
    if(!currentFib.isActive) return 0;
    
    double atrStop = CalculateATRStopLoss(isBuy, entryPrice);
    double structureStop = CalculateStructureBasedStop(isBuy, rates);
    double fibStop;
    
    if(isBuy) {
        // Use the previous Fibonacci level as stop loss
        fibStop = currentFib.lowPrice - (10 * _Point); // Add buffer
    } else {
        // Use the previous Fibonacci level as stop loss
        fibStop = currentFib.highPrice + (10 * _Point); // Add buffer
    }
    
    // Use the most conservative stop level
    return isBuy ? 
           MathMin(MathMin(atrStop, structureStop), fibStop) : 
           MathMax(MathMax(atrStop, structureStop), fibStop);
}

//+------------------------------------------------------------------+
//| Calculate take profit using Fibonacci extension                    |
//+------------------------------------------------------------------+
double CalculateFibonacciTakeProfit(bool isBuy, double entryPrice, double stopLoss) {
    double riskDistance = MathAbs(entryPrice - stopLoss);
    double extension = 1.618; // Fibonacci extension level
    
    return isBuy ? 
           entryPrice + (riskDistance * extension) : 
           entryPrice - (riskDistance * extension);
}














// Modify the TradePosition structure to include candle tracking
struct TradePosition {
    ulong ticket;
    double entryPrice;
    double currentSL;
    double originalSL;
    double takeProfit;
    datetime openTime;
    bool movedToBreakeven;
    ENUM_POSITION_TYPE type;
    int candlesSinceEntry;    // Add this to track candles
    datetime lastCandleTime;  // Add this to track candle updates
};
// Global array to track open positions
TradePosition openPositions[];

//+------------------------------------------------------------------+
//| Initialize position tracking                                       |
//+------------------------------------------------------------------+
void InitializePositionTracking() {
    ArrayResize(openPositions, 0);
    
    // Load existing positions
    for(int i = 0; i < PositionsTotal(); i++) {
        if(PositionSelectByTicket(PositionGetTicket(i))) {
            if(PositionGetString(POSITION_SYMBOL) == _Symbol) {
                TradePosition pos;
                pos.ticket = PositionGetInteger(POSITION_TICKET);
                pos.entryPrice = PositionGetDouble(POSITION_PRICE_OPEN);
                pos.currentSL = PositionGetDouble(POSITION_SL);
                pos.originalSL = pos.currentSL;
                pos.takeProfit = PositionGetDouble(POSITION_TP);
                pos.openTime = (datetime)PositionGetInteger(POSITION_TIME);
                pos.movedToBreakeven = false;
                pos.type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
                
                int size = ArraySize(openPositions);
                ArrayResize(openPositions, size + 1);
                openPositions[size] = pos;
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Update position tracking with candle counting                      |
//+------------------------------------------------------------------+
void UpdatePositionTracking() {
    static datetime lastUpdate = 0;
    datetime currentTime = TimeCurrent();
    
    // Only update every second
    if(currentTime <= lastUpdate) return;
    lastUpdate = currentTime;
    
    // Get current candle time
    datetime currentCandleTime = iTime(_Symbol, PERIOD_CURRENT, 0);
    
    // Remove closed positions first
    for(int i = ArraySize(openPositions) - 1; i >= 0; i--) {
        if(!PositionSelectByTicket(openPositions[i].ticket)) {
            ArrayRemove(openPositions, i, 1);
            continue;
        }
    }
    
    // Update candle count and check for stop loss updates
    for(int i = 0; i < ArraySize(openPositions); i++) {
        if(PositionSelectByTicket(openPositions[i].ticket)) {
            // Update candle count if we're in a new candle
            if(currentCandleTime > openPositions[i].lastCandleTime) {
                openPositions[i].candlesSinceEntry++;
                openPositions[i].lastCandleTime = currentCandleTime;
            }
            
            // Check if position is in profit
            double currentProfit = PositionGetDouble(POSITION_PROFIT);
            
            // If we have profit and 3 candles have passed, move stop to entry
            if(currentProfit > 0 && openPositions[i].candlesSinceEntry >= 3 && !openPositions[i].movedToBreakeven) {
                double breakevenLevel = openPositions[i].entryPrice;
                
                // Add small buffer based on position type
                if(openPositions[i].type == POSITION_TYPE_BUY) {
                    breakevenLevel += 2 * _Point; // 2 points buffer for buy trades
                } else {
                    breakevenLevel -= 2 * _Point; // 2 points buffer for sell trades
                }
                
                // Modify the position's stop loss
                if(trade.PositionModify(openPositions[i].ticket, breakevenLevel, openPositions[i].takeProfit)) {
                    openPositions[i].movedToBreakeven = true;
                    openPositions[i].currentSL = breakevenLevel;
                    Print("✓ Position #", openPositions[i].ticket, 
                          " moved to breakeven after ", openPositions[i].candlesSinceEntry,
                          " candles with profit: ", currentProfit);
                } else {
                    Print("✗ Failed to modify position #", openPositions[i].ticket, 
                          " Error: ", GetLastError());
                }
            }
        }
    }
}


//+------------------------------------------------------------------+
//| Manage position stops                                             |
//+------------------------------------------------------------------+
void ManagePositionStops() {
    if(ArraySize(openPositions) <= 1) return; // Only manage when multiple positions are open
    
    bool hasWinningTrade = false;
    
    // First check if any trade is in profit
    for(int i = 0; i < ArraySize(openPositions); i++) {
        if(PositionSelectByTicket(openPositions[i].ticket)) {
            double currentProfit = PositionGetDouble(POSITION_PROFIT);
            if(currentProfit > 0) {
                hasWinningTrade = true;
                break;
            }
        }
    }
    
    // If we have a winning trade, move other trades to breakeven if not already done
    if(hasWinningTrade) {
        for(int i = 0; i < ArraySize(openPositions); i++) {
            if(!openPositions[i].movedToBreakeven) {
                if(PositionSelectByTicket(openPositions[i].ticket)) {
                    // Calculate breakeven level with 1 point buffer
                    double breakevenLevel = openPositions[i].entryPrice;
                    if(openPositions[i].type == POSITION_TYPE_BUY) {
                        breakevenLevel += 1 * _Point; // Small buffer for buy trades
                    } else {
                        breakevenLevel -= 1 * _Point; // Small buffer for sell trades
                    }
                    
                    // Modify stop loss to breakeven
                    if(trade.PositionModify(openPositions[i].ticket, 
                                          breakevenLevel, 
                                          openPositions[i].takeProfit)) {
                        openPositions[i].movedToBreakeven = true;
                        openPositions[i].currentSL = breakevenLevel;
                        Print("Modified position ", openPositions[i].ticket, 
                              " stop loss to breakeven at ", breakevenLevel);
                    }
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Add new position to tracking with candle initialization            |
//+------------------------------------------------------------------+
void AddNewPosition(ulong ticket, double entryPrice, double stopLoss, 
                   double takeProfit, ENUM_POSITION_TYPE type) {
    TradePosition pos;
    pos.ticket = ticket;
    pos.entryPrice = entryPrice;
    pos.currentSL = stopLoss;
    pos.originalSL = stopLoss;
    pos.takeProfit = takeProfit;
    pos.openTime = TimeCurrent();
    pos.movedToBreakeven = false;
    pos.type = type;
    pos.candlesSinceEntry = 0;
    pos.lastCandleTime = iTime(_Symbol, PERIOD_CURRENT, 0);
    
    int size = ArraySize(openPositions);
    ArrayResize(openPositions, size + 1);
    openPositions[size] = pos;
}


//+------------------------------------------------------------------+
//| Update Trade Management function to be called in OnTick            |
//+------------------------------------------------------------------+
void UpdateTradeManagement() {
    // Main update logic
    UpdatePositionTracking();
    
    // Print position status periodically
    static datetime lastStatusUpdate = 0;
    if(TimeCurrent() - lastStatusUpdate >= 60) { // Every minute
        PrintPositionStatus();
        lastStatusUpdate = TimeCurrent();
    }
}

//+------------------------------------------------------------------+
//| Print detailed position status for debugging                       |
//+------------------------------------------------------------------+
void PrintPositionStatus() {
    if(ArraySize(openPositions) == 0) return;
    
    Print("=== Position Status Update ===");
    for(int i = 0; i < ArraySize(openPositions); i++) {
        if(PositionSelectByTicket(openPositions[i].ticket)) {
            Print("Position #", openPositions[i].ticket,
                  " Type: ", (openPositions[i].type == POSITION_TYPE_BUY ? "BUY" : "SELL"),
                  " Entry: ", openPositions[i].entryPrice,
                  " Current SL: ", openPositions[i].currentSL,
                  " Candles Passed: ", openPositions[i].candlesSinceEntry,
                  " BE Status: ", (openPositions[i].movedToBreakeven ? "Moved" : "Not Moved"),
                  " Profit: ", PositionGetDouble(POSITION_PROFIT));
        }
    }
    Print("===========================");
}


//+------------------------------------------------------------------+
//| Calculate Take Profit Based on Sweep Level                         |
//+------------------------------------------------------------------+
double CalculateSweepTakeProfit(bool actualDirection, double entryPrice, double sweepLevel) {
    double sweepDistance = MathAbs(entryPrice - sweepLevel);
    
    if(actualDirection) { // BUY after sweep of lows
        return entryPrice + (sweepDistance * 2); // 1:2 risk:reward
    } else { // SELL after sweep of highs
        return entryPrice - (sweepDistance * 2);
    }
}
//+------------------------------------------------------------------+
//| Identify top or bottom liquidity                                   |
//+------------------------------------------------------------------+
bool IsOrderblockValid(const MqlRates &rates[], bool isTopSweep) {
    // For top sweep (SELL setup)
    if(isTopSweep) {
        return 
            rates[1].close < rates[1].open &&    // Bearish candle
            rates[0].high < rates[1].high &&     // Lower high
            rates[0].close < rates[0].open;      // Confirming bearish candle
    }
    // For bottom sweep (BUY setup)
    else {
        return 
            rates[1].close > rates[1].open &&    // Bullish candle
            rates[0].low > rates[1].low &&       // Higher low
            rates[0].close > rates[0].open;      // Confirming bullish candle
    }
}


//+------------------------------------------------------------------+
//| Check if liquidity level already exists                            |
//+------------------------------------------------------------------+
bool LiquidityLevelExists(double checkPrice) {
    for(int i = 0; i < ArraySize(activeLevels); i++) {
        // Consider levels within 5 points as the same level
        if(MathAbs(activeLevels[i].price - checkPrice) <= 5 * _Point) {
            return true;
        }
    }
    return false;
}

//+------------------------------------------------------------------+
//| Initialize Liquidity Tracking                                      |
//+------------------------------------------------------------------+
void InitializeLiquidityTracking() {
    ArrayResize(activeLevels, 0); // Clear existing levels
    
    // Pre-allocate space and initialize each element
    ArrayResize(activeLevels, 20);
    for(int i = 0; i < ArraySize(activeLevels); i++) {
        activeLevels[i].price = 0;
        activeLevels[i].time = 0;
        activeLevels[i].isTop = false;
        activeLevels[i].touches = 0;
        activeLevels[i].swept = false;
    }
}

//+------------------------------------------------------------------+
//| Clear and reset all liquidity levels                              |
//+------------------------------------------------------------------+
void ResetLiquidityLevels() {
    for(int i = 0; i < ArraySize(activeLevels); i++) {
        activeLevels[i].price = 0;
        activeLevels[i].time = 0;
        activeLevels[i].isTop = false;
        activeLevels[i].touches = 0;
        activeLevels[i].swept = false;
    }
}

//+------------------------------------------------------------------+
//| Helper function to create empty LiquidityLevel                     |
//+------------------------------------------------------------------+
LiquidityLevel EmptyLiquidityLevel() {
    LiquidityLevel empty;
    empty.price = 0;
    empty.time = 0;
    empty.isTop = false;
    empty.touches = 0;
    empty.swept = false;
    return empty;
}


//+------------------------------------------------------------------+
//| Find nearest resistance level above price                          |
//+------------------------------------------------------------------+
double FindNearestResistance(const MqlRates &rates[], double currentPrice) {
    double resistance = DBL_MAX;
    
    // Look for swing highs
    for(int i = 1; i < ArraySize(rates) - 1; i++) {
        if(rates[i].high > currentPrice && 
           rates[i].high > rates[i+1].high && 
           rates[i].high > rates[i-1].high) {
            
            if(rates[i].high < resistance) {
                resistance = rates[i].high;
            }
        }
    }
    
    // If no valid resistance found, use default calculation
    if(resistance == DBL_MAX) {
        resistance = currentPrice + (MathAbs(rates[0].high - rates[0].low) * 2);
    }
    
    return resistance;
}

//+------------------------------------------------------------------+
//| Find nearest support level below price                             |
//+------------------------------------------------------------------+
double FindNearestSupport(const MqlRates &rates[], double currentPrice) {
    double support = -DBL_MAX;
    
    // Look for swing lows
    for(int i = 1; i < ArraySize(rates) - 1; i++) {
        if(rates[i].low < currentPrice && 
           rates[i].low < rates[i+1].low && 
           rates[i].low < rates[i-1].low) {
            
            if(rates[i].low > support) {
                support = rates[i].low;
            }
        }
    }
    
    // If no valid support found, use default calculation
    if(support == -DBL_MAX) {
        support = currentPrice - (MathAbs(rates[0].high - rates[0].low) * 2);
    }
    
    return support;
}







