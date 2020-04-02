JQ = jq
CURL = curl

HSURL = https://w3qa5ydb4l.execute-api.eu-west-1.amazonaws.com/prod/finnishCoronaData
THLURL = https://sampo.thl.fi/pivot/prod/fi/epirapo/covid19case/fact_epirapo_covid19case.json?row=hcd-444832&column=dateweek2020010120201231-443702L

HSTARGETS = recovered.json confirmed.json deaths.json

.PHONY: all clean

all: $(HSTARGETS) thldata.json

clean:
	rm $(HSTARGETS) thldata.json hsdata.json

$(HSTARGETS): %.json: hsdata.json
	$(JQ) .$* $< > $@

hsdata.json:
	$(CURL) -o $@ '$(HSURL)'

thldata.json:
	$(CURL) -o $@ '$(THLURL)'
