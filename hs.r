library(jsonlite)
library(ggplot2)

conf <- transform(fromJSON("confirmed.json"), date=as.POSIXct(date))

conf.agg <- aggregate(dn ~ date, transform(conf, dn=1), sum)
if (is.unsorted(conf.agg$date)) conf.agg <- conf.agg[order(conf.agg$date),]
conf.agg <- transform(conf.agg, n=cumsum(dn),
                      days=as.double(difftime(date, min(date), units="d")))
d.new <- "2020-03-12"
conf.new <- conf.agg[conf.agg$date >= d.new,]
conf.lm <- lm(log10(n) ~ days, conf.new)
conf.lm10 <- 10^(conf.lm$coefficients)
conf.lm2 <- lm(n ~ days, conf.new)

pdf("hs.pdf", title="HS")
print(qplot(days, n, data=conf.agg)
      + scale_y_log10() + annotation_logticks(sides="l")
      + geom_abline(slope=log10(1.1), intercept=0)
      + geom_abline(slope=log10(1.15), intercept=0, col="blue")
      + geom_abline(slope=log10(1.3), intercept=0, col="red")
      + geom_vline(xintercept=difftime(d.new, min(conf.agg$date), units="d"),
                   linetype="dotted")
      + ggtitle("Lähde: HS",
                subtitle=paste("Kasvusuorat 10, 15 ja 30 % / d.  Käännekohta ",
                               d.new, ", uusin ", max(conf.agg$date),
                               sep="")))
print(qplot(days, n, data=conf.new)
      + scale_y_log10() + annotation_logticks(sides="l")
      + geom_abline(slope=conf.lm$coefficients[2],
                    intercept=conf.lm$coefficients[1])
      + ggtitle(paste("Kasvu", 100 * (conf.lm10["days"] - 1),
                      "% / d alkaen", d.new)))
print(qplot(date, n, data=conf.new)
      + geom_smooth(method="lm")
      + ggtitle(paste("Kasvu", conf.lm2$coefficients["days"], "/ d")))
dev.off()
