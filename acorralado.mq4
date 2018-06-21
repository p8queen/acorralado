//+------------------------------------------------------------------+
//|                                                     emaMA.mq4 |
//|                                  Copyright 2018, Gustavo Carmona |
//|                                      awwthttps://www.awtt.com.ar |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|el usuario hace una orden de compra o venta, con las lineas 
//| Ema separadas. Luego el robot va comprando o vendiendo o cerrando
//| en los cruces. Usa periodos H1 y las EMA de 10 y 50. 
//+------------------------------------------------------------------+

//+
#property copyright "Copyright 2018, Gustavo Carmona"
#property link      "https://www.awtt.com.ar"
#property version   "1.00"
#property strict
#include "acorralado.mqh"

Acorralado bot("bot"), tob("tob");
double profitBot, profitTob;
int lastOP;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  bot.setInitialOrder(OP_SELL);
  tob.setInitialOrder(OP_BUY);

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
   //if last order executed
   
   profitTob = 0;
   profitBot = 0;
   bot.setPendingOrder();
   tob.setPendingOrder();
   bot.closeWhenFirstOrderTakeProfit();
   tob.closeWhenFirstOrderTakeProfit();
   bot.getBalance();
   tob.getBalance();
   

   if(!bot.getBotIsOpen() && !tob.getBotIsOpen()){
      if(!OrderSelect(bot.getTicketLastExecutedOrder(),SELECT_BY_TICKET,MODE_HISTORY))
         Comment("Error Select Order: ", GetLastError());
      bot.setInitialOrder(OP_BUY);
      tob.setInitialOrder(OP_SELL);
      }
   
      
}      
      
    