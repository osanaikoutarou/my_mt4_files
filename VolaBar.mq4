//+------------------------------------------------------------------+
//|                                                      VolaBar.mq4 |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_separate_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

#property  indicator_buffers 4

#property  indicator_color1  White
#property  indicator_color2  Cyan
#property  indicator_color3  Yellow
#property  indicator_color4  Red

double vola[];
double vola10[];
double vola21[];
double vola200[];

int OnInit()
  {
  
   SetIndexStyle(0,DRAW_HISTOGRAM,DRAW_LINE,1);
   SetIndexStyle(1,DRAW_LINE,DRAW_LINE,2);
   SetIndexStyle(2,DRAW_LINE,DRAW_LINE,2);
   SetIndexStyle(3,DRAW_LINE,DRAW_LINE,2);
   
   SetIndexBuffer(0,vola);
   SetIndexBuffer(1,vola10);  
   SetIndexBuffer(2,vola21);
   SetIndexBuffer(3,vola200);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
  
   int i,j,limit;
   limit=rates_total-prev_calculated;
   
   for(i=limit-1; i>=0; i--){
      vola[i] = High[i] - Low[i];
      
      vola10[i] = 0;
      for(j=0;j<10;j++){
         int k = MathMin(limit-1,i+j);
         vola10[i] = vola10[i] + (High[k]-Low[k])/10.0;
      }
      
      vola21[i] = 0;
      for(j=0;j<21;j++){
         int k = MathMin(limit-1,i+j);
         vola21[i] = vola21[i] + (High[k]-Low[k])/21.0;
      }
      
      vola200[i] = 0;
      for(j=0;j<200;j++){
         int k = MathMin(limit-1,i+j);
         vola200[i] = vola200[i] + (High[k]-Low[k])/200.0;
      }
   }
   
   
   return(rates_total);
  }
//+------------------------------------------------------------------+
