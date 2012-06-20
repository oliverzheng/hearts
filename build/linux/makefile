# JAVASCRIPT
SCRIPTS_DIR=../../scripts
COFFEESCRIPT_DIR=$(SCRIPTS_DIR)/coffeescript
JS_DIR=$(SCRIPTS_DIR)/js

# CSS
STYLES_DIR=../../styles
SASS_DIR=$(STYLES_DIR)/sass
CSS_DIR=$(STYLES_DIR)/css

# TEMPLATES
TEMPLATES_DIR=../../templates

all: js css template

js:
	coffee -co $(JS_DIR) $(COFFEESCRIPT_DIR)

css:
	compass compile $(STYLES_DIR)

template:
	@make -sC $(TEMPLATES_DIR)

clean:
	rm -rf $(JS_DIR) $(CSS_DIR)
	@make -sC $(TEMPLATES_DIR) clean
