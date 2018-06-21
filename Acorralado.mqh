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
input double deltaOrders = 5;
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
  void               closeWhenFirstOrderTakeProfit();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Acorralado::Acorralado(string robotName)
  {
   name = robotName;
   
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
   
   //set parameters for 0.06, 0.12, etc lots
   
   if(firstOrderOP == OP_BUY)
      priceBuys = priceSells + deltaOrders*0.001;
   else
      priceSells = priceBuys - deltaOrders*0.0001;
    
   }
 
 void Acorralado::setPendingOrder(void){
      if(OrderSelect(lsNumOrder[p],SELECT_BY_TICKET,MODE_TRADES)){
         
         
      if(OrderType()==OP_SELL){
         //open buystop
         lots *= 2;
         p++;
         lsNumOrder[p] = OrderSend("EURUSD",OP_BUYSTOP,lots,priceBuys,10,
                        priceBuys-2*deltaTips,priceBuys+deltaTips-deltaStTp,"bot acorralado");
        }
      if(OrderType()==OP_BUY){
         //open sellstop
         lots *= 2;
         p++;
         lsNumOrder[p] = OrderSend("EURUSD",OP_SELLSTOP,lots,priceSells,10,
                        priceSells+2*deltaTips,priceSells-deltaTips+deltaStTp,"bot acorralado");
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
      if(p==2 && balance >= 1 )
         closePendingOrder();
      if(p>2 && balance >= panicProfit )
         closePendingOrder();
   return balance;
 }
 
 void Acorralado::closePendingOrder(void){
   double priceOP;
   if(botIsOpen){
        if(!OrderDelete(lsNumOrder[p]))
            Print("**- OrderDelete error: ", GetLastError());
         for(int z=p-1;z>=0;z--){
            if(OrderSelect(lsNumOrder[z],SELECT_BY_TICKET)){
                   if(OrderType()==OP_BUY)
                     priceOP = Bid;
                   else
                     priceOP = Ask;
                       
                   OrderClose(lsNumOrder[z],OrderLots(),priceOP,10);
                     
            
               }//if
            }//for
         
            
         botIsOpen = false;
         Print("bot: ",name, ", was shutdown, balance is: ", balance);
         }
     
      
   }
 
 void Acorralado::closeWhenFirstOrderTakeProfit(){
 //check previuos OPs when one order Take Profit
      if(OrderSelect(lsNumOrder[0],SELECT_BY_TICKET)){
         //Comment("Last Order is Open, no MODE_HISTORY: ", GetLastError());
         if(StringFind(OrderComment(),"[tp]")>0){
            //Print(" --* Comment first order, profit <3.5: ", OrderComment());
         OrderDelete(lsNumOrder[1]);
         botIsOpen = false;
         }
     }    
  
 }