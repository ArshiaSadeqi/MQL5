//+------------------------------------------------------------------+
//|                                           OrderBlockDetectorAdv  |
//|                       Advanced OB Detection for MQL5            |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 4
#property strict

input int MaxBarsToScan = 1000;
input bool ShowBullishOB = true;
input bool ShowBearishOB = true;

// Indicator buffers
double obTypeBuffer[];      // 1 = Bullish, -1 = Bearish, 0 = None
double obHighBuffer[];      // OB High (top of box)
double obLowBuffer[];       // OB Low (bottom of box)
double obTimeBuffer[];      // Time of OB (stored as datetime-to-double)

//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, obTypeBuffer);   
   SetIndexBuffer(1, obHighBuffer);   
   SetIndexBuffer(2, obLowBuffer);    
   SetIndexBuffer(3, obTimeBuffer);   

   ArraySetAsSeries(obTypeBuffer, true);
   ArraySetAsSeries(obHighBuffer, true);
   ArraySetAsSeries(obLowBuffer, true);
   ArraySetAsSeries(obTimeBuffer, true);

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
 {
   int start;

   if(prev_calculated == 0) {
      start = MathMax(2, rates_total - MaxBarsToScan);
      ArrayInitialize(obTypeBuffer, 0);
      ArrayInitialize(obHighBuffer, 0.0);
      ArrayInitialize(obLowBuffer, 0.0);
      ArrayInitialize(obTimeBuffer, 0.0);
   }
   else {
      start = prev_calculated - 1;
   }

   for(int i = start; i < rates_total; i++) {
      obTypeBuffer[i] = 0;
      obHighBuffer[i] = 0;
      obLowBuffer[i] = 0;
      obTimeBuffer[i] = 0;

      // --- Bullish OB ---
      if(ShowBullishOB && close[i - 2] < open[i - 2] && close[i - 1] > high[i - 2]) {
         obTypeBuffer[i] = 1;
         obHighBuffer[i] = close[i - 1];
         obLowBuffer[i] = MathMin(low[i-1], low[i-2]);
         obTimeBuffer[i] = (double)time[i - 2];
       }

      // --- Bearish OB ---
      if(ShowBearishOB && close[i - 2] > open[i - 2] && close[i - 1] < low[i - 2]) {
         obTypeBuffer[i] = -1;
         obHighBuffer[i] = MathMax(high[i-1], high[i-2]);
         obLowBuffer[i] = close[i - 1];
         obTimeBuffer[i] = (double)time[i - 2];
       }
        
       Print("type : ", obTypeBuffer[i]);
   }

   return(rates_total);
}
//+------------------------------------------------------------------+
