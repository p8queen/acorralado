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

int OT=OP_SELL;
double lots=0.01;
double profit=0.0, targetProfit=6.0;
int magicNumber = 6001;
int ticket;
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
   
   if(!ordersOpen())
      ticket=loadOrder();
      
   profit=getProfit(ticket);
   
   if(profit>=targetProfit){
      lots=0.01;
      targetProfit=10.0;
      closeOrder(ticket);
      }   
   
   if(profit<=(-targetProfit)){
      lots *= 2;
      targetProfit *= 2;
      if(OT==OP_BUY){
         OT=OP_SELL;
         }else{
         OT=OP_BUY;   
         }
      closeOrder(ticket);
      }    
}      
      
int loadOrder(){
   double price = Bid;
   int tk;
   if(OT==OP_BUY)
      price = Ask;
   tk=OrderSend(Symbol(),OT,lots,price,10,0,0,"acorralado mg",magicNumber);
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
         Alert("Error Select getProfit, ",GetLastError());
   r = OrderProfit()+OrderCommission()+OrderSwap();
   return r;
   } 

void closeOrder(int tk){
      if(!OrderSelect(tk,SELECT_BY_TICKET))
         Print("error orderselect, closeOrder: ", GetLastError());
       if(!OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),10))
            Print("error close order: ", GetLastError());

   }     