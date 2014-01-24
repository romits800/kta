

DIRS = src,ext/ucaml/src

.PHONY: all clean

# Init submodules if needed and make native version. 
# The resulting executable can be found under /bin and /library (symlinks)
all:    ext native


# Compile native version
native: bin 
	ocamlbuild -Is $(DIRS) ptc.native 
	@mv -f ptc.native bin/ptc

# Compile byte code version
byte: 	bin 
	ocamlbuild -Is $(DIRS) ptc.byte	
	@mv -f ptc.byte bin/ptc


# If ucaml content does not exist, init and update submodules
ext:
	@mkdir ext
	@mkdir ext/ucaml
	git submodule init
	git submodule update
	cd ext/ucaml; git checkout master

bin:	
	@mkdir bin


# Update git sub modules
update:
	cd ext/ucaml; git checkout master; git pull


# Clean all submodules and the main Modelyze source
clean:
	@ocamlbuild -clean	
	@rm -rf bin
	@rm -rf doc/api
	@echo "Finished cleaning up."
