library(rjstat)
library(ggplot2)

foo <- fromJSONstat("thldata.json")[[1]]
foo <- foo[!is.na(foo$value),]
thl.all <- with(foo, data.frame(
                         date=as.Date(dateweek2020010120201231),
                         value=as.integer(value)))
if (is.unsorted(thl.all$date)) thl.all <- thl.all[order(thl.all$date),]
thl.all <- transform(thl.all, n=cumsum(value),
                     days=as.double(date - min(date), units="days"))
d.new <- "2020-03-12"
thl.new <- thl.all[thl.all$date >= d.new,]
thl.lm <- lm(log10(n) ~ days, thl.new)
thl.lm10 <- 10^(thl.lm$coefficients)

pdf("thl.pdf", title="THL")
print(qplot(days, n, data=thl.all)
      + scale_y_log10() + annotation_logticks(sides="l")
      + geom_abline(slope=log10(1.1), intercept=0)
      + geom_abline(slope=log10(1.15), intercept=0, col="blue")
      + geom_abline(slope=log10(1.3), intercept=0, col="red")
      + geom_vline(xintercept=difftime(d.new, min(thl.all$date), units="d"),
                   linetype="dotted")
      + ggtitle("Lähde: THL",
                subtitle=paste("Kasvusuorat 10, 15 ja 30 % / d.  Käännekohta",
                               d.new)))
print(qplot(days, n, data=thl.new)
      + scale_y_log10() + annotation_logticks(sides="l")
      + geom_abline(slope=thl.lm$coefficients[2],
                    intercept=thl.lm$coefficients[1])
      + ggtitle(paste("Kasvu", 100 * (thl.lm10["days"] - 1),
                      "% / d alkaen", d.new)))
dev.off()
