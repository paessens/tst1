#' download and read a table of FX fixings from ECB (website)

fx <- fread('https://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist.zip')

str(fx) # ist dasselbe wie
fx|>str() # dies ist 'piping', das eine Verkettung von Funktionen erlaubt

#' read a spreadsheet
evt <- read_xlsx('data/events2.xlsx',detect_dates=TRUE)|>setDT(key='date')

tail(evt)

#' convert data into time-series-objects, subset (filter) and plot together
events <- xts(evt$event,evt$date)['2000::2026-02']
USD.EUR <- fx[Date > '1999-12-31', .(Date,USD)]|>as.xts.data.table()
USD.EUR|>plot(grid.ticks.lty="dotted",lwd=1,col='navy',log=FALSE,ylim=c(.8,1.7))
addEventLines(events,col="#FF5733",lty=1.5,lwd=1.5, srt=90, pos=2,offset=.3,on=0)

#' write data to spreadsheet -- baut that is trivial
usd <- fx[Date > '1999-12-31', .(Date,USD)]
usd|>write_xlsx('testing.xlsx',as_table=TRUE)


#' database creation
db <- duckdb(dbdir ="data/my.duckdb")
co <- dbConnect(db)
co|>dbWriteTable('Fixing',fx, overwrite=TRUE)
co|>dbDisconnect()

#' check database
db|>dbConnect() -> co
co|>show()
co|>dbListTables()
co|>dbListFields('Fixing')

#' simple query
co|>dbReadTable('Fixing') -> simp
simp|>head()

#' sql query, first: select all as a test
co|>dbGetQuery("SELECT * FROM Fixing") -> tst1
tst1|>str()

co|>dbDisconnect()
