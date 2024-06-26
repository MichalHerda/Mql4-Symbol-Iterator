//+-----------------------------------------------------------------------------------+
//|                                                                symbolIterator.mq4 |
//|                                                      Copyright 2024, Michal Herda |
//+-----------------------------------------------------------------------------------+
#property copyright "Copyright 2024, Michal Herda"
#property version   "1.00"
#property strict
//------------------------------------------------------------------------------------
struct dataForWrite
  {
   string            symbolName;
   bool              risingTrend;
   int               trendDuration;
   double            priceRatio;
   double            trendStrength;
   double            consolidationFactor;
  };
//------------------------------------------------------------------------------------
enum sortingKey
  {
   trendDuration,
   priceRatio,
   trendStrength,
  };
//------------------------------------------------------------------------------------
enum sortType
  {
   bubble,
   selection,
  };   
//------------------------------------------------------------------------------------
struct dataForSort
  {
   string            symbolName;
   double            sortingData;
  };
//------------------------------------------------------------------------------------
extern int barsNo = 30;
extern int movingAveragePeriod = 100;
extern ENUM_TIMEFRAMES timeFrame = PERIOD_H1;
extern string allFileName = "allData.txt";
extern string sortFileName = "sortData.txt";
extern sortingKey sortingData = trendDuration;
extern sortType usedSorting = selection;
//------------------------------------------------------------------------------------
dataForWrite dataArray[];
dataForSort sortingDataArray[];
//------------------------------------------------------------------------------------
double getAllTimeMinimumPrice(string symbol) 
   {
    int lowestMonthlyBarIdx = iLowest(symbol, PERIOD_MN1, MODE_LOW);
    
    return iLow(symbol, PERIOD_MN1, lowestMonthlyBarIdx);    
   }
//------------------------------------------------------------------------------------
double getAllTimeMaximumPrice(string symbol) 
   {
    int highestMonthlyBarIdx = iHighest(symbol, PERIOD_MN1, MODE_LOW);
    
    return iHigh(symbol, PERIOD_MN1, highestMonthlyBarIdx);    
   }   
//------------------------------------------------------------------------------------
double getSpan(string symbol) 
   {
    double minimum = getAllTimeMinimumPrice(symbol);   
    double maximum = getAllTimeMaximumPrice(symbol);
    
    return maximum - minimum;
   }
//------------------------------------------------------------------------------------   
double getPriceRatio(double lowestPrice, double highestPrice, double currentPrice)
  {

   double span = highestPrice - lowestPrice;
   double calculatedPrice = currentPrice - lowestPrice;
   if( (span != 0) && (highestPrice > lowestPrice) )
      {
       return (calculatedPrice / span) * 100;
      }
   else
       return 0;    

  }
//------------------------------------------------------------------------------------
bool isRisingTrend(string symbol, ENUM_TIMEFRAMES tf, int period)
  {
   double movAveBar1 = iMA(symbol, tf, period, 1, MODE_SMA, PRICE_CLOSE, 0);
   double movAveBar2 = iMA(symbol, tf, period, 2, MODE_SMA, PRICE_CLOSE, 0);

   return movAveBar1 > movAveBar2;
  }
//------------------------------------------------------------------------------------
int getGreenBarsNo(string symbol, ENUM_TIMEFRAMES tf, int period)
  {

   int green = 0;
   for(int j = 1; j <= period; j++)
     {
      if((iClose(symbol, tf,  j - 1)) > ((iOpen(symbol, tf, j))))
        {
         green++;
        }
     }

   return green;
  }
//------------------------------------------------------------------------------------
int getRedBarsNo(string symbol, ENUM_TIMEFRAMES tf, int period)
  {

   int red = 0;
   for(int j = 1; j <= period; j++)
     {
      if((iClose(symbol, tf,  j - 1)) < ((iOpen(symbol, tf, j))))
        {
         red++;
        }
     }

   return red;
  }
//------------------------------------------------------------------------------------
int getTrendDuration(string symbol, ENUM_TIMEFRAMES tf, int period, double movAveBar1, double movAveBar2)
  {

   int trendDuration = 0;
   while(movAveBar1 > movAveBar2)
     {
      movAveBar1 = iMA(symbol, tf, period, trendDuration + 1, MODE_SMA, PRICE_CLOSE, 0);
      movAveBar2 = iMA(symbol, tf, period, trendDuration + 2, MODE_SMA, PRICE_CLOSE, 0);
      trendDuration++;
     }

   return trendDuration;
  }
//------------------------------------------------------------------------------------
double getTrendStrength(string symbol, ENUM_TIMEFRAMES tf, int period, int trendDuration, double highestPrice, double lowestPrice)
  {

   double trendOpenPrice = iOpen(symbol, tf, trendDuration);
   double trendClosePrice = iClose(symbol, tf, 1);

   double span = highestPrice - lowestPrice;

   if(span != 0)
     {
      return ((trendClosePrice - trendOpenPrice) / span) * 100;
     }
   else
      return 0;
  }
//------------------------------------------------------------------------------------
double getMinimumPrice(string symbol, ENUM_TIMEFRAMES tf, int period)
   {
     
      int lowestBarIdx = iLowest(symbol, tf, MODE_LOW, 0, period);
      Print("lowest value on bar: ", lowestBarIdx," of given period.");
      
      return iLow(symbol, tf, lowestBarIdx);
            
   }  
//------------------------------------------------------------------------------------
double getMaximumPrice(string symbol, ENUM_TIMEFRAMES tf, int period)
   {
     
      int highestBarIdx = iHighest(symbol, tf, MODE_LOW, 0, period);
      Print("highest value on bar: ", highestBarIdx," of given period.");
      
      return iHigh(symbol, tf, highestBarIdx);
            
   }  
//------------------------------------------------------------------------------------
double getConsolidationFactor(string symbol, ENUM_TIMEFRAMES tf, int period) 
   {
      double minimumPeriodPrice = getMaximumPrice(symbol, tf, period);
      double maximumPeriodPrice = getMinimumPrice(symbol, tf, period);
      
      double consolidationFactor = 0;
      return consolidationFactor;
         
   }
//------------------------------------------------------------------------------------
void fillDataArrayWithElements(string symbolName, bool risingTrend, int trendDuration, double priceRatio, double trendStrength)
  {

   dataForWrite arrayElement;
   arrayElement.symbolName = symbolName;
   arrayElement.risingTrend = risingTrend;
   arrayElement.trendDuration = trendDuration;
   arrayElement.priceRatio = priceRatio;
   arrayElement.trendStrength = trendStrength;

   ArrayResize(dataArray, ArraySize(dataArray) + 1);
   dataArray[ArraySize(dataArray) - 1] = arrayElement;
  }
//------------------------------------------------------------------------------------
void fillSortingDataArrayWithElements(sortingKey structElement)
  {

   int arraySize = ArraySize(dataArray);

   for(int i  = ArraySize(sortingDataArray) - 1; i > 0 ; i--)
     {
      sortingDataArray[i].symbolName = "";
      sortingDataArray[i].sortingData = 0;
      ArrayResize(sortingDataArray, ArraySize(sortingDataArray) - 1);
     }

   dataForSort arrayElement;
   //int fileHandle = FileOpen(sortFileName, FILE_WRITE);

   //if(fileHandle != INVALID_HANDLE)
   //  {

      for(int i = 0; i < arraySize; i++)
        {

         Print(i, ": ", "sorting data:", structElement, "symbolName: ", dataArray[i].symbolName);
         arrayElement.symbolName  = dataArray[i].symbolName;

         switch(structElement)
              {   
               case trendDuration:
                  arrayElement.sortingData = dataArray[i].trendDuration;
                  break;
   
               case priceRatio:
                  arrayElement.sortingData = dataArray[i].priceRatio;
                  break;
   
               case trendStrength:
                  arrayElement.sortingData = dataArray[i].trendStrength;
                  break;
   
               default:
                  Print("enumeration error");
                  break;
              }
              
         ArrayResize(sortingDataArray, ArraySize(sortingDataArray) + 1);
         sortingDataArray[ArraySize(sortingDataArray) - 1] = arrayElement;
         //FileWrite(fileHandle, "symbol: ", sortingDataArray[i].symbolName, "  ", EnumToString(structElement), ": ", sortingDataArray[i].sortingData);
         Print("sorting data value: ", sortingDataArray[i].sortingData);
        }
//      FileClose(fileHandle);
//     }
//   else
//     {
//      Print("sortFile opening failed!");
//     }
  }
//------------------------------------------------------------------------------------
void bubbleSorting()
  {

   dataForSort temp;
   bool swapped;

   for(int j = 0; j < ArraySize(sortingDataArray) - 1; j++)
     {
      swapped = false;
      for(int i = 0; i < ArraySize(sortingDataArray) - 1 - j; i++)
        {         
         if(sortingDataArray[i].sortingData < sortingDataArray[i+1].sortingData)
           {
            temp = sortingDataArray[i];
            sortingDataArray[i] = sortingDataArray[i+1];
            sortingDataArray[i+1] = temp;
            swapped = true;
           }
           
        }
        if (swapped == false) break;
     }
   for(int k=0; k < ArraySize(sortingDataArray); k++)
     {
      Print(k, ": ", sortingDataArray[k].symbolName, ": ", sortingDataArray[k].sortingData);
     }
  }
//------------------------------------------------------------------------------------
void selectionSorting()
   {
   
    dataForSort temp;
    
    for(int j = 0; j < ArraySize(sortingDataArray) - 1; j++)
      {
       int minimumIdx = j;
       for(int i = j + 1; i < ArraySize(sortingDataArray); i++) 
         {
          if(sortingDataArray[i].sortingData > sortingDataArray[minimumIdx].sortingData) minimumIdx = i;
         }  
         
       if(minimumIdx != j) 
         {
          temp = sortingDataArray[minimumIdx];
          sortingDataArray[minimumIdx] = sortingDataArray[j];
          sortingDataArray[j] = temp;
         }   
      }
   }
//------------------------------------------------------------------------------------
void sort(sortType usedSorting)
   {
    switch(usedSorting)
      {
       case bubble:
         Print("start bubble sorting");
         bubbleSorting();
         break;
         
       case selection:
         Print("start selection sorting");
         selectionSorting();
         break;
         
       default:
         Print("no sorting selected");
         break;      
      }
   }
//------------------------------------------------------------------------------------
void writeSortedArray(sortingKey structElement)
  {

   int arraySize = ArraySize(sortingDataArray);
   int fileHandle = FileOpen(sortFileName, FILE_WRITE);

   for(int i = 0; i < arraySize; i++)
     {
      if(fileHandle != INVALID_HANDLE)
        {
         FileWrite(fileHandle, "symbol: ", sortingDataArray[i].symbolName, EnumToString(structElement), ": ", sortingDataArray[i].sortingData);
        }
      else
        {
         Print("sortFile opening failed!");
        }
     }
   FileClose(fileHandle);
  }
//------------------------------------------------------------------------------------
int OnInit()
  {

   int availableSymbols = SymbolsTotal(false);
   Print("available symbols no: ", availableSymbols);

   int fileHandle = FileOpen(allFileName, FILE_WRITE);

   for(int i = 0; i < availableSymbols; i++)
     {
      string name = SymbolName(i, false);
      int barsGlobalNo = Bars(name, timeFrame);
      if(fileHandle != INVALID_HANDLE)
        {

         double movAveBar1 = iMA(name, timeFrame, barsNo, 1, MODE_SMA, PRICE_CLOSE, 0);
         double movAveBar2 = iMA(name, timeFrame, barsNo, 2, MODE_SMA, PRICE_CLOSE, 0);

         int lowestPriceBarIdx = iLowest(name, PERIOD_MN1, MODE_LOW, barsGlobalNo);
         int highestPriceBarIdx = iHighest(name, PERIOD_MN1, MODE_HIGH, barsGlobalNo);
         double lowestPrice = iLow(name, PERIOD_MN1, lowestPriceBarIdx);
         double highestPrice = iHigh(name, PERIOD_MN1, highestPriceBarIdx);
         double currentAsk = SymbolInfoDouble(name, SYMBOL_ASK);
         double priceRatio = getPriceRatio(lowestPrice, highestPrice, currentAsk);
         bool currentTrend = isRisingTrend(name, timeFrame, movingAveragePeriod);
         int trendDuration = getTrendDuration(name, timeFrame, barsNo, movAveBar1, movAveBar2);
         double trendStrength = getTrendStrength(name, timeFrame, barsNo, trendDuration, highestPrice, lowestPrice);

         fillDataArrayWithElements(name, currentTrend, trendDuration, priceRatio, trendStrength);

         //Print("symbol: ", name, " period: ", barsNo, " TF: ", timeFrame, " green: ", getGreenBarsNo(name, timeFrame, barsNo), " red: ", getRedBarsNo(name, timeFrame, barsNo));
         //Print("symbol: ", name, " lowest price: ", lowestPrice, " highest price: ", highestPrice, " current price: ",currentAsk, " price ratio: ", priceRatio,
         //"is rising trend: ", currentTrend) ;

         //FileWrite(fileHandle, "symbol: ", name, " period: ", barsNo, " TF: ", timeFrame, " green: ", green, " red: ", red);
         FileWrite(fileHandle, "symbol: ", name, " lowest price: ", lowestPrice, " highest price: ", highestPrice, " current price: ", currentAsk, " price ratio: ", priceRatio,
                   "is rising trend: ", currentTrend);

        }
      else
        {
         Print("allFile opening failed!");
        }
     }

   FileClose(fileHandle);
   fillSortingDataArrayWithElements(sortingData);

   Print("all data array size: ", ArraySize(dataArray));


   for(int i = 0; i < ArraySize(dataArray); i++)
     {
      Print("Element ", i, ": symbolName = ", dataArray[i].symbolName, ", risingTrend = ", dataArray[i].risingTrend, ", trendDuration = ", dataArray[i].trendDuration,
            ", priceRatio = ", dataArray[i].priceRatio, ", trendStrength = ",dataArray[i].trendStrength);
     }

   //bubbleSorting();
   //selectionSorting();
   sort(usedSorting);
   writeSortedArray(sortingData);

   return(INIT_SUCCEEDED);
  }
//------------------------------------------------------------------------------------
void OnDeinit(const int reason)
  {

  }
//------------------------------------------------------------------------------------
void OnTick()
  {


  }
//------------------------------------------------------------------------------------
void OnTimer()
  {

  }
//------------------------------------------------------------------------------------   

//+----------------------------------------------------------------------------------+
