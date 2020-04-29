library(jsonlite)
library(ggplot2)
library(magrittr)
library(dplyr)

fromJSON("hsdata.json")$confirmed %>% mutate(date=as.POSIXct(date)) -> conf
count(conf, date, name="dn") %>% arrange(date) %>%
    mutate(n=cumsum(dn),
           days=as.double(difftime(date, date[1], units="d"))) -> conf.agg

(fromJSON("testdata.json")$tested %>% mutate(date=as.POSIXct(date))
    %>% rename(tested=value)) -> tests

tc <- full_join(tests, conf.agg, by="date")
tc$dn[is.na(tc$dn)] <- 0
tc %<>% filter(dn != 0 | tested != 0)

d.new <- "2020-03-28"
tc %>% filter(date >= d.new) -> tc.new
tc.lm <- lm(dn ~ tested + n, tc)
tc.lm2 <- lm(dn ~ tested + n, tc.new)

pdf("test.pdf", title="Testing")
print(qplot(date, tested, data=tc[tc$tested > 0,])
      + scale_y_log10() + annotation_logticks(sides="l")
      + geom_vline(xintercept=as.POSIXct(d.new), linetype="dotted")
      + ggtitle(paste("Raja", d.new)))
plot(tc[, c("days", "tested", "n", "dn")],
     main=paste("Kaikki:", min(tc$date), "-", max(tc$date)))
## print(qplot(date, tested, data=tc) + geom_point(aes(y=dn), colour="red")
##       + scale_y_log10())
plot(tc.new[, c("days", "tested", "n", "dn")], main=paste("Alkaen", d.new))
dev.off()

summary(tc.lm)
summary(tc.lm2)
