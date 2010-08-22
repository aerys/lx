include Makefile.rules

MODELS_XML=$(shell find $(LX_APPLICATION)/src/models -name '*.xml')
MODELS_PHP=$(MODELS_XML:.xml=.php)
LX_PROJECT=$(LX_APPLICATION)/$(LX_OUT)/lx-project.php

# Colors
RST=\033[00m
BLACK=\033[0;30m
DK_GREY=\033[1;30m
RED=\033[0;31m
LT_RED=\033[1;31m
GREEN=\033[0;32m
LT_GREEN=\033[1;32m
BROWN=\033[0;33m
YELLOW=\033[1;33m
BLUE=\033[0;34m
LT_BLUE=\033[1;34m
PURPLE=\033[0;35m
LT_PURPLE=\033[1;35m
CYAN=\033[0;36m
LT_CYAN=\033[1;36m
LT_GRAY=\033[0;37m
WHITE=\033[1;37m
PINK=\033[1;35m
DK_PINK=\033[0;35m
ORANGE=\033[0;33m

all: chmod reload
	@echo $(MODELS_XML)

clean: clean_models
	@echo -n "Cleaning up /$(LX_OUT)..."
	@rm -rf ${LX_APPLICATION}/$(LX_OUT)/*.php
	@echo " $(GREEN)OK$(RST)"

distclean: clean
	@rm -rf ${LX_APPLICATION}/Makefile.rules

clean_models:
	@echo -n "Cleaning up /$(LX_OUT)/models..."
	@rm -rf ${LX_APPLICATION}/$(LX_OUT)/models/*.php
	@echo " $(GREEN)OK$(RST)"

%.php: %.xml
	@echo -n "Generating model '$(ORANGE)$(basename $(notdir $@))$(RST)'..."
	@cd ${LX_ROOT}/php/src/scripts && php lx-orm.php $< lx-php-orm.xsl > $(LX_APPLICATION)/$(LX_OUT)/models/$(notdir $@)
	@echo " $(GREEN)OK$(RST)"

$(LX_PROJECT):
	@echo -n "Generating '$(ORANGE)$(notdir $(LX_PROJECT))$(RST)'..."
	@cd $(LX_ROOT)/php/src/scripts && php lx-project.php $(LX_APPLICATION)/lx-project.xml > $@
	@echo " $(GREEN)OK$(RST)"

project: $(LX_PROJECT)

models: $(MODELS_PHP)

reload: clean $(LX_PROJECT) models
	@echo "$(LT_GREEN)The application is ready!$(RST)"

chmod:
	chgrp -R www-data *
	chmod -R 770 *
