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
   char p;
   double deltaTips, lots;
   double priceBuys, priceSells;
   double balance;
   
public:
                     Acorralado();
                    ~Acorralado();
  void               setInitialOrder(int OP);                    
  void               setPendingOrder();                    
  void               closePendingOrder();                    
  double             getBalance();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Acorralado::Acorralado()
  {
   ArrayInitialize(lsNumOrder, -1);
   p=0;
   deltaTips = 40*0.0001;
   balance = 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Acorralado::~Acorralado()
  {
  }
//+------------------------------------------------------------------+

void Acorralado::setInitialOrder(int OP){
   double price, st, tp;
   lots = 0.01;
   if(OP==OP_BUY){
      price = Ask;
      priceBuys = price;
      st = priceBuys - 2*deltaTips - 5*deltaTips;
      tp = priceBuys + deltaTips;
      priceSells = priceBuys - deltaTips;
      }
   else{
      price = Bid;
      priceSells = price;
      st = priceSells + 2*deltaTips + 5*deltaTips;
      tp = priceSells - deltaTips;
      priceBuys = priceSells + deltaTips;
      }
   
   lsNumOrder[p] = OrderSend("EURUSD",OP,lots,price,10,st,tp,"bot acorralado");
   p++;
   lots += 0.02;
   
   if(OP==OP_BUY){   
      lsNumOrder[p] = OrderSend("EURUSD",OP_SELLSTOP,lots,priceSells,10,priceSells+2*deltaTips+5*deltaTips,priceSells-deltaTips,"bot acorralado");
  }else{
      lsNumOrder[p] = OrderSend("EURUSD",OP_BUYSTOP,lots,priceBuys,10,priceBuys-2*deltaTips-5*deltaTips,priceBuys+deltaTips,"bot acorralado");
      }
   
    
   }
 
 void Acorralado::setPendingOrder(void){
      if(OrderSelect(lsNumOrder[p],SELECT_BY_TICKET,MODE_TRADES)){
         
         
      if(OrderType()==OP_SELL){
         //open buystop
         lots *= 2;
         p++;
         lsNumOrder[p] = OrderSend("EURUSD",OP_BUYSTOP,lots,priceBuys,10,priceBuys-2*deltaTips-5*deltaTips,priceBuys+deltaTips,"bot acorralado");
        }
      if(OrderType()==OP_BUY){
         //open sellstop
         lots *= 2;
         p++;
         lsNumOrder[p] = OrderSend("EURUSD",OP_SELLSTOP,lots,priceSells,10,priceSells+2*deltaTips+5*deltaTips,priceSells-deltaTips,"bot acorralado");
         }
 
   }
 }
 
 double Acorralado::getBalance(void){
   balance = 0;
   for(char z=0;z<p;z++){
      if(!OrderSelect(lsNumOrder[z],SELECT_BY_TICKET))
         Alert("Error Select getBalance, ",GetLastError());
      balance += OrderProfit()+OrderCommission()+OrderSwap();
      }
   return balance;
 }
 
 void Acorralado::closePendingOrder(void){
   if(OrderSelect(lsNumOrder[0],SELECT_BY_TICKET,MODE_HISTORY)){
      if(!OrderDelete(lsNumOrder[p]))
         Alert("Close Pending Order Error: ", GetLastError());
      }
   }