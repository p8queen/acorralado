//+------------------------------------------------------------------+
//|                                                   acorralado.mq4 |
//|                                  Copyright 2018, Gustavo Carmona |
//|                                          https://www.awtt.com.ar |
//+------------------------------------------------------------------+

//+
#property copyright "Copyright 2018, Gustavo Carmona"
#property link      "https://www.awtt.com.ar"
#property version   "1.00"
#property strict
#include "acorralado.mqh"

Acorralado bot("bot",1500), tob("tob",1600);
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
   if(bot.getBotIsOpen()){
      bot.setPendingOrder();
      bot.getBalance();
      //bot.closeWhenFirstOrderTakeProfit();   
      }
   if(tob.getBotIsOpen()){
      tob.setPendingOrder();
      //tob.closeWhenFirstOrderTakeProfit();
      tob.getBalance();
      }
   
   
/*
   if(!bot.getBotIsOpen() && !tob.getBotIsOpen()){
      if(!OrderSelect(bot.getTicketLastExecutedOrder(),SELECT_BY_TICKET,MODE_HISTORY))
         Comment("Error Select Order: ", GetLastError());
      bot.setInitialOrder(OP_BUY);
      tob.setInitialOrder(OP_SELL);
      }
  */ 
      
}      
      
    