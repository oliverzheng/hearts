HEADLESS_EMBER=headless-ember.js
EMBER=../lib/ember-0.9.8.1.min.js
COMPILE=compile.js
HANDLEBARS:=$(wildcard handlebars/*.handlebars)
OUTPUT=template.js

all: $(OUTPUT)

template.js: $(HEADLESS_EMBER) $(EMBER) $(COMPILE) $(HANDLEBARS)
	@echo -n 'Compiling handlebar templates to $(OUTPUT)... '
	@js -f $(HEADLESS_EMBER) -f $(EMBER) $(COMPILE) $(HANDLEBARS) > $(OUTPUT)
	@echo 'Done'

clean:
	rm -f $(OUTPUT)
