CURL = curl -f
RBATCH = R CMD BATCH
MARKDOWN = markdown -f fencedcode

HSURL = https://w3qa5ydb4l.execute-api.eu-west-1.amazonaws.com/prod/finnishCoronaData/v2
THLURL = https://sampo.thl.fi/pivot/prod/fi/epirapo/covid19case/fact_epirapo_covid19case.json?column=dateweek2020010120201231-443702L
HOSPURL = https://w3qa5ydb4l.execute-api.eu-west-1.amazonaws.com/prod/finnishCoronaHospitalData
TESTURL = https://w3qa5ydb4l.execute-api.eu-west-1.amazonaws.com/prod/thlTestData

DATA = thldata.json hsdata.json hospdata.json testdata.json
PDFS = thl.pdf hs.pdf hosp.pdf test.pdf

.PHONY: all clean distclean

all: $(PDFS) README.html

clean: 
	rm -f $(DATA) $(PDFS) $(PDFS:%.pdf=%.r.Rout)

distclean: clean
	rm -f README.html

$(PDFS): %.pdf: %.r %data.json
	$(RBATCH) $<

test.pdf: hsdata.json

hsdata.json:
	$(CURL) -o $@ '$(HSURL)'

thldata.json:
	$(CURL) -o $@ '$(THLURL)'

hospdata.json:
	$(CURL) -o $@ '$(HOSPURL)'

testdata.json:
	$(CURL) -o $@ '$(TESTURL)'

%.html: %.md
	$(MARKDOWN) -o $@ $<
