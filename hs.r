library(jsonlite)
library(ggplot2)

conf <- transform(fromJSON("confirmed.json"), date=as.POSIXct(date))
reco <- transform(fromJSON("recovered.json"), date=as.POSIXct(date))

conf.agg <- aggregate(dn ~ date, transform(conf, dn=1), sum)
if (is.unsorted(conf.agg$date)) conf.agg <- conf.agg[order(conf.agg$date),]
conf.agg <- transform(conf.agg, n=cumsum(dn),
                      days=as.double(difftime(date, min(date), units="d")))

print(qplot(days, n, data=conf.agg)
      + scale_y_log10() + annotation_logticks(sides="l")
      + geom_abline(slope=log10(1.1), intercept=0)
      + geom_abline(slope=log10(1.15), intercept=0, col="blue")
      + geom_abline(slope=log10(1.3), intercept=0, col="red"))
conf.new <- conf.agg[conf.agg$date >= "2020-03-15",]
conf.lm <- lm(log10(n) ~ days, conf.new)
print(qplot(days, n, data=conf.new)
      + scale_y_log10() + annotation_logticks(sides="l")
      + geom_abline(slope=conf.lm$coefficients[2],
                    intercept=conf.lm$coefficients[1]))
summary(conf.lm)
10^(conf.lm$coefficients)
