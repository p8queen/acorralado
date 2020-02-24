//+------------------------------------------------------------------+
//|                                                   Acorralado.mq4 |
//|                                  Copyright 2018, Gustavo Carmona |
//|                                      awwthttps://www.awtt.com.ar |
//+------------------------------------------------------------------+


//+
#property copyright "Copyright 2018, Gustavo Carmona"
#property link      "https://www.awtt.com.ar"
#property version   "1.00"
#property strict

double baseProfit=5.0;
double lots=0.01, lots_2=0.0;
int OT, OT_2;
double profit=0.0, profit_2=0.0, targetProfit=baseProfit, targetProfit_2=baseProfit;
int magicNumber = 6001;
int ticket, ticket_2;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {


  return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){
   
   if(!ordersOpen()){
      ticket=loadOrder(0.01, ORDER_TYPE_SELL);
      ticket_2=loadOrder(0.01, ORDER_TYPE_BUY);
      }
      
   profit=getProfit(ticket);
   profit_2=getProfit(ticket_2);
   
   Comment("profit: ",profit, ",_2: ",profit_2, "\n target: ",targetProfit,", ",targetProfit_2);
  
   if(profit<=(-targetProfit)){
      lots *= 2;
      targetProfit *= 2;
      targetProfit_2=baseProfit;
       if(!OrderSelect(ticket,SELECT_BY_TICKET))
         Print("ordersOpen: ", GetLastError());
      if(OrderType()==OP_BUY){
         OT=OP_SELL;
         OT_2=OP_BUY;
         }else{
         OT_2=OP_SELL;
         OT=OP_BUY;
         }
      closeOrder(ticket);
      closeOrder(ticket_2);
      ticket=loadOrder(lots,OT);
      lots_2=0.01;
      ticket_2=loadOrder(lots_2,OT_2);
      }    
      
       if(profit_2<=(-targetProfit_2)){
         lots_2 *= 2;
         targetProfit_2 *= 2;
         targetProfit=baseProfit;
          if(!OrderSelect(ticket_2,SELECT_BY_TICKET))
            Print("ordersOpen: ", GetLastError());
         if(OrderType()==OP_BUY){
            OT_2=OP_SELL;
            OT=OP_BUY;
            }else{
            OT=OP_SELL;
            OT_2=OP_BUY;
            }
         closeOrder(ticket);
         closeOrder(ticket_2);
         lots=0.01;
         ticket=loadOrder(lots,OT);
         ticket_2=loadOrder(lots_2,OT_2);
      }
      
}      
      
int loadOrder(double lt, int order_type){
   //t ticket, lt lots
   double price = Bid;
   int tk;
   if(order_type==OP_BUY)
      price = Ask;
   tk=OrderSend(Symbol(),order_type,lt,price,10,0,0,"acorralado mg",magicNumber);
   return tk;
   }  
 
bool ordersOpen(){
   bool checkin;
   checkin = false;
   int a=OrdersTotal()-1;
   while(a>=0){
      if(OrderSelect(a,SELECT_BY_POS)){
         if(OrderMagicNumber()==magicNumber){
            checkin = true;
            a = -1;
            }   
         }
      a--;
      }
   return checkin;
   
   }  

double getProfit(int tk){
   double r=0.0;
   if(!OrderSelect(tk,SELECT_BY_TICKET))
         Print("Error Select getProfit, ",GetLastError());
   r = OrderProfit()+OrderCommission()+OrderSwap();
   return r;
   } 

void closeOrder(int tk){
      if(!OrderSelect(tk,SELECT_BY_TICKET))
         Print("error orderselect, closeOrder: ", GetLastError());
       if(!OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),10))
            Print("error close order: ", GetLastError());

   }     