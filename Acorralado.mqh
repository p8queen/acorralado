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
   string name;
   int lsNumOrder[10];
   char p;
   double deltaTips, lots, deltaStTp;
   double priceBuys, priceSells;
   double balance;
   bool botIsOpen;
   
public:
                     Acorralado(string robotName);
                    ~Acorralado();
  void               setInitialValues();
  void               setInitialOrder(int OP);                    
  void               setPendingOrder();                    
  void               closePendingOrder();                    
  double             getBalance();
  bool               getBotIsOpen(){ return botIsOpen;}
  int                getTicketLastExecutedOrder(){ return lsNumOrder[p-1];}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Acorralado::Acorralado(string robotName)
  {
   name = robotName;
   setInitialValues();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Acorralado::~Acorralado()
  {
  }
//+------------------------------------------------------------------+
void Acorralado::setInitialValues(void){
   ArrayInitialize(lsNumOrder, -1);
   p=0;
   deltaTips = 30*0.0001;
   deltaStTp = 2*0.0001;
   balance = 0;
   botIsOpen = true;

   }

void Acorralado::setInitialOrder(int OP){
   double price, st, tp;
   lots = 0.01;
   if(OP==OP_BUY){
      price = Ask;
      priceBuys = price;
      st = priceBuys - 2*deltaTips;
      tp = priceBuys + deltaTips - deltaStTp;
      priceSells = priceBuys - deltaTips;
      }
   else{
      price = Bid;
      priceSells = price;
      st = priceSells + 2*deltaTips;
      tp = priceSells - deltaTips + deltaStTp;
      priceBuys = priceSells + deltaTips;
      }
   
   lsNumOrder[p] = OrderSend("EURUSD",OP,lots,price,10,st,tp,"bot acorralado");
   p++;
   lots += 0.02;
   
   if(OP==OP_BUY){   
      st = priceSells+2*deltaTips;
      tp = priceSells-deltaTips + deltaStTp;
      lsNumOrder[p] = OrderSend("EURUSD",OP_SELLSTOP,lots,priceSells,10,st,tp,"bot acorralado");
  }else{
      st = priceBuys-2*deltaTips;
      tp = priceBuys+deltaTips - deltaStTp;
      lsNumOrder[p] = OrderSend("EURUSD",OP_BUYSTOP,lots,priceBuys,10,st,tp,"bot acorralado");
      }
   
    
   }
 
 void Acorralado::setPendingOrder(void){
      if(OrderSelect(lsNumOrder[p],SELECT_BY_TICKET,MODE_TRADES)){
         
         
      if(OrderType()==OP_SELL){
         //open buystop
         lots *= 2;
         p++;
         lsNumOrder[p] = OrderSend("EURUSD",OP_BUYSTOP,lots,priceBuys,10,priceBuys-2*deltaTips,priceBuys+deltaTips-deltaStTp,"bot acorralado");
        }
      if(OrderType()==OP_BUY){
         //open sellstop
         lots *= 2;
         p++;
         lsNumOrder[p] = OrderSend("EURUSD",OP_SELLSTOP,lots,priceSells,10,priceSells+2*deltaTips,priceSells-deltaTips+deltaStTp,"bot acorralado");
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
   if(botIsOpen){
      
      if(priceBuys + deltaTips < Bid || priceSells - deltaTips > Bid){
         if(!OrderDelete(lsNumOrder[p]))
            Print("Close Pending Order Error: ", GetLastError());
         botIsOpen = false;
         Print("bot: ",name, ", was shutdown, balance is: ", balance);
         }
      
      }
   }
 
 