#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 1

#property indicator_color1 PaleGreen

extern int shift00001 = 0;
extern int alertNum = 20;
extern int MATURM1 = 120;
extern int MATURM2 = 200;

double target[];

//int alertNum;

int OnInit()
{
   ObjectCreate("Target1", OBJ_HLINE, 0, 0, 0); ObjectSet("Target1",OBJPROP_COLOR,Yellow);
   ObjectCreate("Target2", OBJ_HLINE, 0, 0, 0); ObjectSet("Target2",OBJPROP_COLOR,Red);
   
   return(INIT_SUCCEEDED);
}

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
   double MA1H = iMA(NULL,PERIOD_H1,MATURM1,0,MODE_SMA,PRICE_CLOSE,0);
   double ShiftMA1H = MA1H + (double)(shift00001*0.0001);
   ObjectMove("Target1", 0, Time[0], ShiftMA1H);
   
   double MA2H = iMA(NULL,PERIOD_H1,MATURM2,0,MODE_SMA,PRICE_CLOSE,0);
   double ShiftMA2H = MA2H + (double)(shift00001*0.0001);
   ObjectMove("Target2", 0, Time[0], ShiftMA2H);

   int span=3;
   if(Period()==1) span = 40;
   if(Period()==5) span = 5;
   if(Period()==15) span = 3;
   
   int limit=span+1;
   bool alertFlag = true;
   for(int i = limit-1; i > 0; i--){
      if(iHigh(NULL,0,i)>=ShiftMA1H && iLow(NULL,0,i)<=ShiftMA1H){
         alertFlag = false;
         break;
      }
   }
   
   if(alertFlag){
      if(iHigh(NULL,0,0)>=ShiftMA1H && iLow(NULL,0,0)<=ShiftMA1H){
         Alert(Symbol(),":TouchMA1");
      }
   }

   /* -- 2 -- */   
   
   for(int i = limit-1; i > 0; i--){
      if(iHigh(NULL,0,i)>=ShiftMA2H && iLow(NULL,0,i)<=ShiftMA2H){
         alertFlag = false;
         break;
      }
   }
   
   if(alertFlag){
      if(iHigh(NULL,0,0)>=ShiftMA2H && iLow(NULL,0,0)<=ShiftMA2H){
         Alert(Symbol(),":TouchMA2");
      }
   }

   return(rates_total);
}