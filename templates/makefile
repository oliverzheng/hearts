HEADLESS_EMBER=headless-ember.js
EMBER=../lib/ember-0.9.8.1.min.js
COMPILE=compile.js
HANDLEBARS_DIR=handlebars
HANDLEBARS:=$(wildcard $(HANDLEBARS_DIR)/*.handlebars)
JS_DIR=javascript
JS=$(HANDLEBARS:$(HANDLEBARS_DIR)/%.handlebars=$(JS_DIR)/%.js)
OUTPUT=template.js
UNAME:=$(shell uname)

all: $(OUTPUT)

$(OUTPUT): $(HEADLESS_EMBER) $(EMBER) $(COMPILE) $(JS)
	cat $(JS) > $@

$(JS_DIR)/%.js: $(HANDLEBARS_DIR)/%.handlebars
	@mkdir -p $(JS_DIR)
	cat $< | js -f $(HEADLESS_EMBER) -f $(EMBER) $(COMPILE) `wc -l $<` > $@

ifeq ($(UNAME), Linux)
watch:
	@echo 'Watching for changes in handlebars...'
	@while inotifywait -qq -e close_write -e move_self $(HANDLEBARS); do make -s; done
endif
ifeq ($(UNAME), Darwin)
watch:
	@echo 'Watching for changes in handlebars...'
	@while kqwait $(HANDLEBARS); do make -s; done
endif

clean:
	rm -rf $(OUTPUT) $(JS_DIR)
