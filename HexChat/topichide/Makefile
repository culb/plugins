CC = gcc
FILENAME = topichide
NAMELIB  = lib-hexchat-topichide.so
FLAGSC   = -Wall -Werror -fPIC -export-dynamic -O3 
FLAGSLD  = -shared
OBJECTS  = $(FILENAME).o

#Location of hexchat-plugin.c
INCLUDE = $(HOME)/hexchat-master/src/common

all: $(NAMELIB)

%.o: %.c Makefile
	@echo "Creating objects"
	@$(CC) $(FLAGSC) -I$(INCLUDE) -c $<
#	@echo "Creating objects complete"

$(NAMELIB): $(OBJECTS)
	@echo "Creating shared library"
	@$(CC) $(FLAGSC) $(FLAGSLD) $(OBJECTS) -o $@
#	@echo "Creating shared library complete"

install: $(NAMELIB)
	@echo "Installing $(NAMELIB)"
	@install $< $(HOME)/.config/hexchat/addons/$(NAMELIB)
#	@echo "Installing $(NAMELIB) complete"

clean:
	@echo "Cleaning plugin topichide"
	@rm -rf *.o *.so
#	@echo "Cleaning plugin topichide complete"

.default: all

.phony: clean install
