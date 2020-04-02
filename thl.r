library(rjstat)
library(ggplot2)

foo <- fromJSONstat("thldata.json")[[1]]
foo <- foo[!is.na(foo$value),]
thl <- with(foo, data.frame(
                     hcd=as.factor(hcd),
                     date=as.Date(dateweek2020010120201231),
                     value=as.integer(value)))
thl.all <- thl[thl$hcd == "Kaikki sairaanhoitopiirit",]
thl.all$hcd <- NULL
thl <- thl[thl$hcd != "Kaikki sairaanhoitopiirit",]
if (is.unsorted(thl.all$date)) thl.all <- thl.all[order(thl.all$date),]
thl.all <- transform(thl.all, n=cumsum(value),
                     days=as.double(date - min(date), units="days"))

pdf("thl.pdf", title="THL")
print(qplot(days, n, data=thl.all)
      + scale_y_log10() + annotation_logticks(sides="l")
      + geom_abline(slope=log10(1.1), intercept=0)
      + geom_abline(slope=log10(1.15), intercept=0, col="blue")
      + geom_abline(slope=log10(1.3), intercept=0, col="red")
      + ggtitle("Lähde: THL", subtitle="Suorat 10, 15 ja 30 % / d"))
d.new <- "2020-03-12"
thl.new <- thl.all[thl.all$date >= d.new,]
thl.lm <- lm(log10(n) ~ days, thl.new)
thl.lm10 <- 10^(thl.lm$coefficients)
print(qplot(days, n, data=thl.new)
      + scale_y_log10() + annotation_logticks(sides="l")
      + geom_abline(slope=thl.lm$coefficients[2],
                    intercept=thl.lm$coefficients[1])
      + ggtitle(paste("Kasvu", 100 * (thl.lm10["days"] - 1),
                      "% / d alkaen", d.new)))
dev.off()
