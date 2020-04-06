CURL = curl -f
JQ = jq
MARKDOWN = markdown

HSURL = https://w3qa5ydb4l.execute-api.eu-west-1.amazonaws.com/prod/finnishCoronaData/v2
THLURL = https://sampo.thl.fi/pivot/prod/fi/epirapo/covid19case/fact_epirapo_covid19case.json?column=dateweek2020010120201231-443702L
HOSPURL = https://w3qa5ydb4l.execute-api.eu-west-1.amazonaws.com/prod/finnishCoronaHospitalData

DATA = thldata.json hsdata.json hospdata.json
HSPARTS = recovered.json confirmed.json deaths.json
HOSPPARTS = hospitalised.json
PARTS = $(HSPARTS) $(HOSPPARTS)
PDFS = thl.pdf hs.pdf hosp.pdf

.PHONY: all clean distclean

all: $(PDFS) README.html

clean: 
	rm -f $(DATA) $(PARTS) $(PDFS) $(PDFS:%.pdf=%.r.Rout)

distclean: clean
	rm -f README.html

$(PDFS): %.pdf: %.r
	R CMD BATCH $<

hs.pdf: $(HSPARTS)
thl.pdf: thldata.json
hosp.pdf: $(HOSPPARTS)

$(PARTS): %.json:
	$(JQ) .$* $< > $@

$(HSPARTS): hsdata.json
$(HOSPPARTS): hospdata.json

hsdata.json:
	$(CURL) -o $@ '$(HSURL)'

thldata.json:
	$(CURL) -o $@ '$(THLURL)'

hospdata.json:
	$(CURL) -o $@ '$(HOSPURL)'

%.html: %.md
	$(MARKDOWN) -o $@ $<
