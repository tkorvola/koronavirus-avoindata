library(jsonlite)
library(ggplot2)
library(tidyr)

hosp <- transform(fromJSON("hospdata.json")$hospitalised,
                  area=as.factor(area), date=as.POSIXct(date))
hosp.all <- hosp[hosp$area == "Finland",]
hosp.all$area <- NULL
if (is.unsorted(hosp.all$date)) hosp.all <- hosp.all[order(hosp.all$date),]
hosp.l <- pivot_longer(hosp.all, -date, "var")
hosp.all <- transform(hosp.all, days=as.double(date - date[1], units="days"))
d.new <- "2020-03-31"
hosp.new <- hosp.all[hosp.all$date >= d.new,]
dead.lm <- lm(log10(dead) ~ days, hosp.new)
dead.lm10 <- 10^(dead.lm$coefficients)
dead.lm2 <- lm(dead ~ days, hosp.new)

pdf("hosp.pdf", title="Hospitalised")
print(ggplot(hosp.l, aes(date, value, colour=var, shape=var))
      + geom_line() + geom_point()
      + ggtitle("Sairaalassa (kulloinkin) & kuolleet (kumulatiivinen)"))
print(qplot(days, dead, data=hosp.all)
      + scale_y_log10() + annotation_logticks(sides="l") 
      + geom_abline(slope=log10(1.1), intercept=0)
      + geom_abline(slope=log10(1.15), intercept=0, col="blue")
      + geom_abline(slope=log10(1.3), intercept=0, col="red")
      + geom_vline(xintercept=difftime(d.new, hosp.all$date[1], units="d"),
                   linetype="dotted")
      + ggtitle("Kuolleet",
                subtitle=paste("Kasvusuorat 10, 15 & 30 % / d.  Alkaa ",
                               hosp.all$date[1], ", raja ", d.new,
                               ", uusin ", hosp.all$date[nrow(hosp.all)],
                               sep="")))
print(qplot(days, dead, data=hosp.new) 
      + scale_y_log10() + annotation_logticks(sides="l") 
      + geom_abline(slope=dead.lm$coefficients[2],
                    intercept=dead.lm$coefficients[1])
      + ggtitle(paste("Kasvu", 100 * (dead.lm10["days"] - 1),
                      "% / d alkaen", d.new)))
print(qplot(date, dead, data=hosp.new)
      + geom_smooth(method="lm")
      + ggtitle(paste("Kasvu", dead.lm2$coefficients["days"], "/ d")))
dev.off()

summary(dead.lm)
summary(dead.lm2)
