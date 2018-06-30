//+------------------------------------------------------------------+
//|                                                   Acorralado.mqh |
//|                                  Copyright 2018, Gustavo Carmona |
//|                                           http://www.awtt.com.ar |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Gustavo Carmona"
#property link      "http://www.awtt.com.ar"
#property version   "1.00"
#property strict

input double panicProfit = -1;

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
   int firstOrderOP;
   int magicNumber;
   
public:
                     Acorralado(string robotName, int robotMagicNumber);
                    ~Acorralado();
  void               setInitialValues();
  void               setInitialOrder(int OP);                    
  void               setPendingOrder();                    
  void               closePendingOrder();                    
  double             getBalance();
  bool               getBotIsOpen(){ return botIsOpen;}
  int                getTicketLastExecutedOrder(){ return lsNumOrder[p-1];}
  void               closeWhenFirstOrderTakeProfit();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Acorralado::Acorralado(string robotName, int robotMagicNumber)
  {
   name = robotName;
   magicNumber = robotMagicNumber;
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
   balance = 0;
   botIsOpen = true;
   

   }

void Acorralado::setInitialOrder(int OP){
   double price, st, tp;
   setInitialValues();
   deltaTips = 40*0.0001;
   deltaStTp = 5*0.00001;
   deltaOrders = 40*0.0001;
   lots = 0.01;
   firstOrderOP = OP;
   
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
   
   OrderSend("EURUSD",OP,lots,price,10,st,tp,name,magicNumber);
   lots += 0.02;
   
   if(OP==OP_BUY){   
      st = priceSells+2*deltaTips;
      tp = priceSells-deltaTips + deltaStTp;
      OrderSend("EURUSD",OP_SELLSTOP,lots,priceSells,10,st,tp,name,magicNumber);
  }else{
      st = priceBuys-2*deltaTips;
      tp = priceBuys+deltaTips - deltaStTp;
      OrderSend("EURUSD",OP_BUYSTOP,lots,priceBuys,10,st,tp,name,magicNumber);
      }
   
   //set parameters for 0.06, 0.12, etc lots
   
   if(firstOrderOP == OP_BUY)
      priceBuys = priceSells + deltaOrders;
   else
      priceSells = priceBuys - deltaOrders;
    
   }
 
 void Acorralado::setPendingOrder(void){
      int a=OrdersTotal()-1;
      while(a>=0){
      
         if(OrderSelect(a,SELECT_BY_POS){
            if(OrderMagicNumber()==magicNumber){   
                         
               if(OrderType()==OP_SELL){
                  //open buystop
                  lots *= 2;
                  OrderSend("EURUSD",OP_BUYSTOP,lots,priceBuys,10,
                           priceBuys-2*deltaTips,priceBuys+deltaTips-deltaStTp,name,magicNumber);
                 }
               if(OrderType()==OP_BUY){
                  //open sellstop
                  lots *= 2;
                  OrderSend("EURUSD",OP_SELLSTOP,lots,priceSells,10,
                            priceSells+2*deltaTips,priceSells-deltaTips+deltaStTp,name,magicNumber);
                  }
                  a = -1;
            }else{
               a--; }
         }//while
   
 }
 
 double Acorralado::getBalance(void){
   balance = 0;
   for(char z=0;z<p;z++){
      if(!OrderSelect(lsNumOrder[z],SELECT_BY_TICKET))
         Alert("Error Select getBalance, ",GetLastError());
      balance += OrderProfit()+OrderCommission()+OrderSwap();
      }
      if(p==2 && balance >= 1 )
         closePendingOrder();
      if(p>2 && balance >= panicProfit )
         closePendingOrder();
   return balance;
 }
 
 void Acorralado::closePendingOrder(void){
   double priceOP;
   if(botIsOpen){
      int a=OrdersTotal()-1;
      while(a>=0){
      
         if(OrderSelect(a,SELECT_BY_POS){
            if(OrderMagicNumber()==magicNumber){   
                         
               if(OrderType()==OP_SELL){
                  OrderClose(OrderTicket(),OrderLots(),Ask,10);
                  a = -1;
                  }
               if(OrderType()==OP_BUY){
                  OrderClose(OrderTicket(),OrderLots(),Bid,10);
                  a = -1;
                  }
               if(OrderType()==OP_BUYSTOP || OrderType()==OP_SELLSTOP){   
                  OrderDelete(OrderTicket());
                  a = -1;
                  }
            }else{
               a--; }
         }//while 
       
       }//if botidopen
 }
 
 void Acorralado::closeWhenFirstOrderTakeProfit(){
 //check previuos OPs when one order Take Profit
     int a=OrdersHistoryTotal()-1;
     int b = a-10;
      while(b>=0 && b<=a){
      
         if(OrderSelect(a,SELECT_BY_POS,MODE_HISTORY){
            if(OrderMagicNumber()==magicNumber){
               if(StringFind(OrderComment(),"[tp]")>0){
                  //close all open orders
                  closePendingOrder();
                  a=-1
                  botIsOpen = false;
                  }
                  }
                  }
          
         a--;
         }
     }    
  
 }