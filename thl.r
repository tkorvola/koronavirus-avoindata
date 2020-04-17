library(rjstat)
library(ggplot2)

foo <- fromJSONstat("thldata.json")[[1]]
foo <- foo[!is.na(foo$value),]
thl.all <- with(foo, data.frame(
                         date=as.Date(dateweek2020010120201231),
                         value=as.integer(value)))
if (is.unsorted(thl.all$date)) thl.all <- thl.all[order(thl.all$date),]
thl.all <- transform(thl.all, n=cumsum(value),
                     days=as.double(date - date[1], units="days"))
#d.new <- "2020-03-12"
d.new <- "2020-03-28"
thl.new <- thl.all[thl.all$date >= d.new,]
thl.lm <- lm(log10(n) ~ days, thl.new)
thl.lm10 <- 10^(thl.lm$coefficients)
thl.lm2 <- lm(n ~ days, thl.new)

pdf("thl.pdf", title="THL")
print(qplot(days, n, data=thl.all)
      + scale_y_log10() + annotation_logticks(sides="l")
      + geom_abline(slope=log10(1.1), intercept=0)
      + geom_abline(slope=log10(1.15), intercept=0, col="blue")
      + geom_abline(slope=log10(1.3), intercept=0, col="red")
      + geom_vline(xintercept=difftime(d.new, thl.all$date[1], units="d"),
                   linetype="dotted")
      + ggtitle("Lähde: THL",
                subtitle=paste("Kasvusuorat 10, 15 ja 30 % / d.  Alkaa ",
                               thl.all$date[1], ", raja ",
                               d.new, ", uusin ", thl.all$date[nrow(thl.all)],
                               sep="")))
print(qplot(days, n, data=thl.new)
      + scale_y_log10() + annotation_logticks(sides="l")
      + geom_abline(slope=thl.lm$coefficients[2],
                    intercept=thl.lm$coefficients[1])
      + ggtitle(paste("Kasvu", 100 * (thl.lm10["days"] - 1),
                      "% / d alkaen", d.new)))
print(qplot(date, n, data=thl.new)
      + geom_smooth(method="lm")
      + ggtitle(paste("Kasvu", thl.lm2$coefficients["days"], "/ d")))
dev.off()

summary(thl.lm)
summary(thl.lm2)
