//+------------------------------------------------------------------+
//|                                                  YukkuriRate.mq4 |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

extern int point = 10;  //1pips

void playUp(){
   if(Symbol()=="EURUSD"){
      PlaySound("yu_yuroruagattayo.wav");
   }
   if(Symbol()=="GBPUSD"){
      PlaySound("yu_pondoruagattayo.wav");
   }
}

void playDown(){
   if(Symbol()=="EURUSD"){
      PlaySound("yu_yurorusagattayo.wav");
   }
   if(Symbol()=="GBPUSD"){
      PlaySound("yu_pondorusagattayo.wav");
   }
}

int myInteger(int a,int p){
   return (int)(a/p);
}

int OnInit()
{
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
   double bairitu;
   if(Open[0]<30.0){
      bairitu=10000;
   }
   else{
      bairitu=100;
   }

   int open = (int)(iOpen(NULL,PERIOD_M1,0)*bairitu);
   int now = Bid*bairitu;
   
   //Print("test--",open," ",now," ",myInteger(now,point)," ",myInteger(open,point));

   if(myInteger(now,point)>myInteger(open,point)){
      playUp();
   }
   else if(myInteger(now,point)<myInteger(open,point)){
      playDown();
   }

   return(rates_total);
}
