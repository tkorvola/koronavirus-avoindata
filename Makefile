JQ = jq
CURL = curl
MARKDOWN = markdown

HSURL = https://w3qa5ydb4l.execute-api.eu-west-1.amazonaws.com/prod/finnishCoronaData/v2
THLURL = https://sampo.thl.fi/pivot/prod/fi/epirapo/covid19case/fact_epirapo_covid19case.json?row=hcd-444832&column=dateweek2020010120201231-443702L

HSPARTS = recovered.json confirmed.json deaths.json
PDFS = thl.pdf hs.pdf

.PHONY: all clean

all: $(PDFS) README.html

clean:
	rm -f $(HSPARTS) $(PDFS) $(PDFS:%.pdf=%.r.Rout) \
		thldata.json hsdata.json README.html

$(PDFS): %.pdf: %.r
	R CMD BATCH $<

hs.pdf: $(HSPARTS)
thl.pdf: thldata.json

$(HSPARTS): %.json: hsdata.json
	$(JQ) .$* $< > $@

hsdata.json:
	$(CURL) -o $@ '$(HSURL)'

thldata.json:
	$(CURL) -o $@ '$(THLURL)'

%.html: %.md
	$(MARKDOWN) -o $@ $<
