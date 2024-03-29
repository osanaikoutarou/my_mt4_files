#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#property strict

extern double TakeProfit=250.0;  //profit 
extern double Lots=0.1;
extern double TrailingStop=35.0; //loss cat

extern int MAX_TICKET_NUM = 1;

int LONG_NOW = 10001;
int SHORT_NOW = 10002;
int STATUS_GC = 20001;
int STATUS_DC = 20002;

/*-------------------original function-------------------*/

/** return direction if changed line1<>line2 */
int Crossed(double line1,double line2)
{
   static int last_direction = 0;
   static int current_direction = 0;

   if(line1>line2)
      current_direction=STATUS_GC;  //golden cross
   
   if(line1<line2)
      current_direction=STATUS_DC;  //dead cross

   if(current_direction != last_direction) {
      last_direction = current_direction;
      return(current_direction);
   }
   else {
      return (0);
   }
}

/*-------------------------------------------------------*/

int OnInit()
{
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){}

/*--------------------------------------------------------*/

bool ErrorChecker(int bars,double takeprofit){
   if(bars<1000){
      Print("bars less!!");
      return(false);
   }
   if(takeprofit<5){
      Print("TakeProfit less than 5");
      return(false);
   }
   return(true);
}

bool checkTicketError(int ticket,string message){
   if(ticket<=0){
      Print("TicketError : ",message," : ",GetLastError());
      return(false);
   }
   return(true);      
}

bool checkOrderSelect(bool b,string message){
   if(!b){
      Print("OrderSelectError : ",message," : ",GetLastError());
      return(false);
   }
   return(true);      
}

bool checkOrderModify(bool b,string message){
   if(!b){
      Print("OrderModifyError : ",message," : ",GetLastError());
      return(false);
   }
   return(true);      
}


/*--------------------------------------------------------*/


/*-------------------ENTRY---------------------------------*/

int getAction(int status1){
   if(status1 == STATUS_GC){
      return(LONG_NOW);
   }
   else if(status1 == STATUS_DC){
      return(SHORT_NOW);
   }
   
   return(-1);
}






void OnTick()
{
   int cnt;
   int ticket;
   int total;
   double shortEma;
   double longEma;
   
   if(ErrorChecker(Bars,TakeProfit)==false){
      return;
   }
      
   /*------calc-----*/

   shortEma = iMA(NULL,0,8,0,MODE_EMA,PRICE_CLOSE,0);
   longEma = iMA(NULL,0,13,0,MODE_EMA,PRICE_CLOSE,0);
   int isCrossed = Crossed(shortEma,longEma);
   int action = getAction(isCrossed);
   
   /*--------Trade--Entry------*/
   
   total = OrdersTotal();
   if(total < MAX_TICKET_NUM){
      if(action==LONG_NOW){      
         //ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,1,0,Ask+TakeProfit*Point,"comment",1234,0,Green);
         ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,1,0,0,"comment",1234,0,Green);

         if(checkTicketError(ticket,"Error opening BUY order")){
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)){
               Print("BUY order operand : ",OrderOpenPrice());
            }
         }
      }
      else if(action==SHORT_NOW){
         //ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,1,0,Bid-TakeProfit*Point,"comment",1234,0,Red);
         ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,1,0,0,"comment",1234,0,Red);
         
         if(checkTicketError(ticket,"Error opening SELL order")){
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)){
               Print("SELL order opened : ",OrderOpenPrice());
            }
         }  
      }
      return;
   }
   
   /*--------Trade--Close------*/
   
   for(cnt=0;cnt<total;cnt++){
      if(!checkOrderSelect(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADEALLOWED),"first select")){
         return;
      }
      
      if(OrderSymbol()==Symbol()){
         if(OrderType()==OP_BUY){
            if(action == SHORT_NOW){
               checkOrderSelect(OrderClose(OrderTicket(),OrderLots(),Bid,1,Violet),"op_buy");
               return;
            }   
            else if(TrailingStop>0){
               if(Bid-OrderOpenPrice()>Point*TrailingStop){
                  if(OrderStopLoss()<Bid-Point*TrailingStop){
                     checkOrderModify(
                        OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Green)
                        ,"buy_trailing");
                     return;
                  }
               }
            }
         }
         
         if(OrderType()==OP_SELL){
            if(action == LONG_NOW){
               checkOrderSelect(OrderClose(OrderTicket(),OrderLots(),Ask,1,Violet),"sell");
               return;
            }
            else if(TrailingStop>0){
               if((OrderOpenPrice()-Ask)>(Point*TrailingStop)){
                  if((OrderStopLoss()>(Ask+Point*TrailingStop)) || (OrderStopLoss()==0)){
                     checkOrderModify(
                        OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,OrderTakeProfit(),0,Red)
                        ,"sell_trailing");
                     return;
                  }
               }
            }
         }
      }
   }
   
   return;
}



/*   help   */
/*

"OrderSend()"
symbol       -   通貨
cmd           -   取引タイプ。取引操作子のどれか。
volume       -   ロット数
price        -   オープン価格
slippage     -   スリッページ
stoploss     -   ストップロス値
takeprofit   -   利確値
comment       -   コメント。コメントの最後の部分はサーバーによって変更される。
magic         -   オーダー識別番号。ユーザ定義の識別番号。
expiration   -   有効期限
arrow_color  -   チャート上の矢印の色。
              もしこの変数が間違っているかCLR_NONE値であれば
              チャート上に何も描かれない。




"OrderSelect()"
index    -   オーダー番号か2番目の引数に依存するオーダーチケット
select      -   選択フラグ。これは以下の値をとる:
                 SELECT_BY_POS - オーダー番号
                 SELECT_BY_TICKET - チケット番号
pool=MODE_TRADES  -   オーダー番号の選択。
                         SELECT_BY_POSを指定した時に用いる。これらは以下の値をとる:
                         MODE_TRADES(デフォルト) - 有効ポジションリストから選択される
                         MODE_HISTORY - ヒストリーリストから選択される




"OrderOpenprice()"
現在、選択されているオーダーの約定価格を返します。

"OrderModify()"
   前回開いたポジションや未決オーダーを修正する。
   もし成功すれば、この関数はTRUEを返す。
   もし失敗すれば、この関数はFALSEを返す。
   エラー情報の詳細を得たい場合はGetLastError()関数を呼び出す。
   Notes:指定価格と有効期限は未決オーダーでのみ変更できる。

ticket    -   重複しないオーダーチケット
price      -   未決オーダーのエントリー価格
stoploss     -   ストップロス値
takeprofit  -   利確値
expiration  -   有効期限
Color     -   チャート上の決済矢印の色。
              もしこの変数が間違っているかCLR_NONE値であれば
              チャート上に何も描かれない。


"Point"
現在の通貨値の最小単位。(USD/JPY： 0.01、GBP/USD： 0.0001)


int cmd
定数　　　　　　　　　　　　値　　　　　　　解説
OP_BUY　　　　　　　　　　０　　　　　　　　買いポジション　　
OP_SELL　　　　 　　　　　１　　　　　　　　売りポジション
OP_BUYLIMIT　　　　　　 ２　　　　　　　　指値で買う
OP_SELLLIMIT　　　　　　３　　　　　　　　指値で売る
OP_BUYSTOP　 　　　　　４　　　　　　　　逆指値で買う
OP_SELLSTOP　　　　　　５　　　　　　　　逆指値で売る

double　stoploss:
損失を含んだときに手仕舞おうと思う値段。（逆指値手仕舞いの値段）
double takeprofit:
含み益の際に手仕舞おうと思っている値段。（逆指値手仕舞いの値段）
int magic:
注文に対して割り振ったマジックナンバー

*/