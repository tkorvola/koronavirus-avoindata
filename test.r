library(jsonlite)
library(ggplot2)
library(dplyr)

conf <- transform(fromJSON("hsdata.json")$confirmed, date=as.POSIXct(date))
conf.agg <- aggregate(dn ~ date, transform(conf, dn=1), sum)
if (is.unsorted(conf.agg$date)) conf.agg <- conf.agg[order(conf.agg$date),]
conf.agg <- transform(conf.agg, n=cumsum(dn),
                      days=as.double(difftime(date, date[1], units="d")))

tests <- (fromJSON("testdata.json")$tested
    %>% transform(date=as.POSIXct(date)) %>% rename(tested=value))

tc <- merge(tests, conf.agg, by="date", all=TRUE)
tc$dn[is.na(tc$dn)] <- 0
tc <- filter(tc, dn != 0 | tested != 0)
tc.sane <- filter(tc, dn <= tested)
tc.lm <- lm(dn ~ tested + n, tc.sane)

pdf("test.pdf", title="Testing")
plot(tc.sane[, c("days", "tested", "n", "dn")])
## print(qplot(date, tested, data=tc) + geom_point(aes(y=dn), colour="red")
##       + scale_y_log10())
dev.off()

summary(tc.lm)
