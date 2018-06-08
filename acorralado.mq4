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

Acorralado bot;
double profit;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  bot.setInitialOrder(OP_BUY);

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
   
   profit = 0;
   bot.setPendingOrder();
   profit = bot.getBalance();
   Comment("Balance= ",profit);
   bot.closePendingOrder();

}      
      
    