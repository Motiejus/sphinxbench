REBAR ?= $(shell which rebar || echo ./rebar)
REBAR_URL ?= https://github.com/downloads/basho/rebar/rebar

.PHONY: clean compile test escriptize all

all: compile escriptize

results:
	deps/basho_bench/priv/summary.r -i tests/current

escriptize: $(REBAR)
	$(REBAR) escriptize skip_deps=true

compile: $(REBAR)
	$(REBAR) get-deps compile

clean:
	$(REBAR) clean

./rebar:
	erl -noshell -s inets start -s ssl start \
        -eval 'httpc:request(get, {"$(REBAR_URL)", []}, [], [{stream, "./rebar"}])' \
        -s inets stop -s init stop
	chmod +x ./rebar
