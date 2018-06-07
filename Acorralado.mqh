//+------------------------------------------------------------------+
//|                                                   Acorralado.mqh |
//|                                  Copyright 2018, Gustavo Carmona |
//|                                           http://www.awtt.com.ar |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Gustavo Carmona"
#property link      "http://www.awtt.com.ar"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Acorralado
  {
private:
   int lsNumOrder[10];
   double deltaTips;
public:
                     Acorralado();
                    ~Acorralado();
  void               setInitialOrder(int OP);                    
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Acorralado::Acorralado()
  {
   ArrayInitialize(lsNumOrder, -1);
   deltaTips = 30*0.0001;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Acorralado::~Acorralado()
  {
  }
//+------------------------------------------------------------------+

void Acorralado::setInitialOrder(int OP){
   double price, st, tp, lots;
   lots = 0.01;
   if(OP==OP_BUY){
      price = Ask;
      st = price-2*deltaTips;
      tp = price + deltaTips;
      }
   else{
      price = Bid;
      st = price+2*deltaTips;
      tp = price - deltaTips;
      }
   
   lsNumOrder[9] = OrderSend("EURUSD",OP,lots,price,10,st,tp,"bot acorralado");
   ArraySort(lsNumOrder,WHOLE_ARRAY,0,MODE_DESCEND);
   OP = (OP+1)%2;
   
   price -= deltaTips;
   lots += 0.02;
   st = price+2*deltaTips;
   tp = price - deltaTips;
   lsNumOrder[9] = OrderSend("EURUSD",OP_SELLSTOP,lots,price,10,st,tp,"bot acorralado");
   ArraySort(lsNumOrder,WHOLE_ARRAY,0,MODE_DESCEND);
   OP = (OP+1)%2;

   price += deltaTips;
   lots *= 2;
   st = price-2*deltaTips;
   tp = price + deltaTips;
   lsNumOrder[9] = OrderSend("EURUSD",OP_BUYSTOP,lots,price,10,st,tp,"bot acorralado");
   ArraySort(lsNumOrder,WHOLE_ARRAY,0,MODE_DESCEND);
   
   }