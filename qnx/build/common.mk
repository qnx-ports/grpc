ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

NAME=grpc

DIST_BASE=$(PRODUCT_ROOT)/..

#$(INSTALL_ROOT_$(OS)) is pointing to $QNX_TARGET
#by default, unless it was manually re-routed to
#a staging area by setting both INSTALL_ROOT_nto
#and USE_INSTALL_ROOT
grpc_INSTALL_ROOT ?= $(INSTALL_ROOT_$(OS))

grpc_VERSION = 1.59.1

#choose Release or Debug
CMAKE_BUILD_TYPE ?= Release

#set the following to FALSE if generating .pinfo files is causing problems
GENERATE_PINFO_FILES ?= TRUE

#override 'all' target to bypass the default QNX build system
ALL_DEPENDENCIES = grpc_all
.PHONY: grpc_all install check clean

CFLAGS += $(FLAGS) -D__EXT_QNX -D_QNX_SOURCE

define PINFO
endef
PINFO_STATE=Experimental
USEFILE=

CMAKE_ARGS = -DCMAKE_TOOLCHAIN_FILE=$(PROJECT_ROOT)/qnx.nto.toolchain.cmake \
			 -DCMAKE_INSTALL_PREFIX=$(grpc_INSTALL_ROOT)/$(CPUVARDIR)/usr \
			 -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
			 -DCMAKE_SYSTEM_PROCESSOR=$(CPUVARDIR) \
			 -DEXTRA_CMAKE_C_FLAGS="$(CFLAGS)" \
			 -DEXTRA_CMAKE_CXX_FLAGS="$(CFLAGS)" \
			 -DEXTRA_CMAKE_ASM_FLAGS="$(FLAGS)" \
			 -DEXTRA_CMAKE_LINKER_FLAGS="$(LDFLAGS)" \
			 -DCPU=$(CPU) \
			 -DCMAKE_CXX_STANDARD=14 \
			 -DBUILD_SHARED_LIBS=ON \
             -DCMAKE_NO_SYSTEM_FROM_IMPORTED=ON \
             -DgRPC_BUILD_GRPC_RUBY_PLUGIN=OFF \
             -DgRPC_BUILD_GRPC_PYTHON_PLUGIN=OFF \
             -DgRPC_BUILD_GRPC_PHP_PLUGIN=OFF \
             -DgRPC_BUILD_GRPC_OBJECTIVE_C_PLUGIN=OFF \
             -DgRPC_BUILD_GRPC_NODE_PLUGIN=OFF \
             -DgRPC_BUILD_GRPC_CSHARP_PLUGIN=OFF \
             -DgRPC_BUILD_GRPC_CPP_PLUGIN=ON \
			 -DgRPC_SSL_PROVIDER=package \
			 -DUSE_QNX_BUILTIN_SSL="ON" \
			 -DgRPC_BUILD_TESTS="ON" \
			 -DgRPC_INSTALL_INCLUDEDIR=$(grpc_INSTALL_ROOT)/usr/include/grpc \
			 -DgRPC_INSTALL_SHAREDIR=$(grpc_INSTALL_ROOT)/share/grpc

include $(MKFILES_ROOT)/qtargets.mk

MAKE_ARGS ?= -j $(firstword $(JLEVEL) 1)

ifndef NO_TARGET_OVERRIDE
grpc_all:
	@mkdir -p build
	@echo "========================cmake $(CMAKE_ARGS) $(DIST_BASE)"
	@cd build && cmake $(CMAKE_ARGS) $(DIST_BASE)
	@cd build && make VERBOSE=1 all $(MAKE_ARGS)

install check: grpc_all
	@echo Installing...
	@cd build && make VERBOSE=1 install $(MAKE_ARGS)
	@echo Done.

clean iclean spotless:
	rm -rf build

uninstall:
endif

#everything down below deals with the generation of the PINFO
#information for shared objects that is used by the QNX build
#infrastructure to embed metadata in the .so files, for example
#data and time, version number, description, etc. Metadata can
#be retrieved on the target by typing 'use -i <path to openblas .so file>'.
#this is optional: setting GENERATE_PINFO_FILES to FALSE will disable
#the insertion of metadata in .so files.
ifeq ($(GENERATE_PINFO_FILES), TRUE)
#the following rules are called by the cmake generated makefiles,
#in order to generate the .pinfo files for the shared libraries
%.so$(grpc_VERSION):
	$(ADD_PINFO)
	$(ADD_USAGE)

endif
