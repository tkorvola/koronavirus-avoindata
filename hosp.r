library(jsonlite)
library(ggplot2)
library(tidyr)

hosp <- transform(fromJSON("hospdata.json")$hospitalised,
                  area=as.factor(area), date=as.POSIXct(date))
hosp.all <- hosp[hosp$area == "Finland",]
hosp.all$area <- NULL
hosp.l <- pivot_longer(hosp.all, -date, "var")

pdf("hosp.pdf", title="Hospitalised")
print(ggplot(hosp.l, aes(date, value, colour=var, shape=var))
      + geom_line() + geom_point()
      + ggtitle("Hospitalised"))
dev.off()
