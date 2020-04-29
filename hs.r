library(jsonlite)
library(ggplot2)
library(dplyr)

fromJSON("hsdata.json")$confirmed %>% mutate(date=as.POSIXct(date)) -> conf
count(conf, date, name="dn") %>% arrange(date) %>%
    mutate(n=cumsum(dn),
           days=as.double(difftime(date, date[1], units="d"))) -> conf.agg

#d.new <- "2020-03-12"
d.new <- "2020-03-28"
conf.new <- filter(conf.agg, date >= d.new)
conf.lm <- lm(log10(n) ~ days, conf.new)
conf.lm10 <- 10^(conf.lm$coefficients)
conf.lm2 <- lm(n ~ days, conf.new)

fromJSON("hsdata.json")$deaths %>% mutate(date=as.POSIXct(date)) -> dead
count(dead, date, name="dn") %>% arrange(date) %>%
    mutate(n=cumsum(dn),
           days=as.double(difftime(date, date[1], units="d"))) -> dead.agg

dd.new <- "2020-03-31"
dead.new <- filter(dead.agg, date >= dd.new)
dead.lm <- lm(log10(n) ~ days, dead.new)
dead.lm10 <- 10^(dead.lm$coefficients)
dead.lm2 <- lm(n ~ days, dead.new)

pdf("hs.pdf", title="HS")
print(qplot(days, n, data=conf.agg)
      + scale_y_log10() + annotation_logticks(sides="l")
      + geom_abline(slope=log10(1.1), intercept=0)
      + geom_abline(slope=log10(1.15), intercept=0, col="blue")
      + geom_abline(slope=log10(1.3), intercept=0, col="red")
      + geom_vline(xintercept=difftime(d.new, conf.agg$date[1], units="d"),
                   linetype="dotted")
      + ggtitle("Havaitut tartunnat; lähde: HS",
                subtitle=paste("Kasvusuorat 10, 15 ja 30 % / d.  Alkaa ",
                               conf.agg$date[1], ", raja ",
                               d.new, ", uusin ",
                               conf.agg$date[nrow(conf.agg)],
                               sep="")))
print(qplot(days, n, data=conf.new)
      + scale_y_log10() + annotation_logticks(sides="l")
      + geom_abline(slope=conf.lm$coefficients[2],
                    intercept=conf.lm$coefficients[1])
      + ggtitle("Havaitut tartunnat",
                subtitle=paste("Kasvu", 100 * (conf.lm10["days"] - 1),
                               "% / d alkaen", d.new)))
print(qplot(date, n, data=conf.new)
      + geom_smooth(method="lm")
      + ggtitle("Havaitut tartunnat",
                subtitle=paste("Kasvu", conf.lm2$coefficients["days"], "/ d")))

print(qplot(days, n, data=dead.agg)
      + scale_y_log10() + annotation_logticks(sides="l")
      + geom_abline(slope=log10(1.1), intercept=0)
      + geom_abline(slope=log10(1.15), intercept=0, col="blue")
      + geom_abline(slope=log10(1.3), intercept=0, col="red")
      + geom_vline(xintercept=difftime(dd.new, dead.agg$date[1], units="d"),
                   linetype="dotted")
      + ggtitle("Kuolleet",
                subtitle=paste("Kasvusuorat 10, 15 ja 30 % / d.  Alkaa ",
                               dead.agg$date[1], ", raja ",
                               dd.new, ", uusin ",
                               dead.agg$date[nrow(dead.agg)],
                               sep="")))
print(qplot(days, n, data=dead.new)
      + scale_y_log10() + annotation_logticks(sides="l")
      + geom_abline(slope=dead.lm$coefficients[2],
                    intercept=dead.lm$coefficients[1])
      + ggtitle("Kuolleet",
                subtitle=paste("Kasvu", 100 * (dead.lm10["days"] - 1),
                               "% / d alkaen", dd.new)))
print(qplot(date, n, data=dead.new)
      + geom_smooth(method="lm")
      + ggtitle("Kuolleet",
                subtitle=paste("Kasvu", dead.lm2$coefficients["days"], "/ d")))
dev.off()

summary(conf.lm)
summary(conf.lm2)

summary(dead.lm)
summary(dead.lm2)
