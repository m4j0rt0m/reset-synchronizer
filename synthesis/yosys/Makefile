###################################################################
# Project:                                                        #
# Description:      RTL Synthesis with Yosys - Makefile           #
#                                                                 #
# Template written by Abraham J. Ruiz R.                          #
#   https://github.com/m4j0rt0m/rtl-develop-template-syn-yosys    #
###################################################################

MKFILE_PATH           = $(abspath $(firstword $(MAKEFILE_LIST)))
TOP_DIR               = $(shell dirname $(MKFILE_PATH))

### directories ###
OUTPUT_DIR            = $(TOP_DIR)/build
SCRIPTS_DIR           = $(TOP_DIR)/scripts

### makefile includes ###
include $(SCRIPTS_DIR)/funct.mk
include $(SCRIPTS_DIR)/default.mk

### project configuration ###
PROJECT              ?=
TOP_MODULE           ?=
RTL_SYN_CLK_SRC      ?=

### sources wildcards ###
VERILOG_SRC          ?=
VERILOG_HEADERS      ?=
PACKAGE_SRC          ?=
MEM_SRC              ?=
RTL_PATHS            ?=

### synthesis configuration ###
RTL_SYN_Y_TARGET     := $(or $(RTL_SYN_Y_TARGET),$(DEFAULT_RTL_SYN_Y_TARGET))
RTL_SYN_Y_DEVICE     := $(or $(RTL_SYN_Y_DEVICE),$(DEFAULT_RTL_SYN_Y_DEVICE))
RTL_SYN_Y_CLK_MHZ    := $(or $(RTL_SYN_Y_CLK_MHZ),$(DEFAULT_RTL_SYN_Y_CLK_MHZ))

### synthesis objects ###
SYN_DIR               = $(OUTPUT_DIR)/$(TOP_MODULE)
RPT_OBJ               = $(SYN_DIR)/$(PROJECT).rpt
RTL_OBJS              = $(VERILOG_SRC) $(PACKAGE_SRC) $(VERILOG_HEADERS) $(MEM_SRC)

### yosys synthesis cli flags ###
YOSYS_SYN             = yosys
YOSYS_SYN_INC_FLAGS   = $(addprefix -I, $(RTL_PATHS))
YOSYS_SYN_FLAGS       = -p "read_verilog -sv -formal $(YOSYS_SYN_INC_FLAGS) $(VERILOG_SRC) $(PACKAGE_SRC); synth_$(RTL_SYN_Y_TARGET) -top $(TOP_MODULE) -blif $@"
YOSYS_PNR             = arachne-pnr
YOSYS_PNR_FLAGS       = $< -d $(subst hx,,$(subst lp,,$(RTL_SYN_Y_DEVICE))) -o $@
YOSYS_TIME_STA        = icetime
YOSYS_TIME_STA_FLAGS  = -tmd $(RTL_SYN_Y_DEVICE) -c $(RTL_SYN_Y_CLK_MHZ) -o $(SYN_DIR)/$(TOP_MODULE).v -r $@ $<
#WIP...
#YOSYS_SYN_SHOW_FLAGS  = -stretch -width -prefix $(SYN_DIR)/$(TOP_MODULE) -format png

all: rtl-synth

#H# rtl-synth       : Run RTL synthesis with Yosys
rtl-synth: print-rtl-srcs $(RPT_OBJ)

#H# veritedium      : Run veritedium AUTO features
veritedium:
	@$(foreach SRC,$(VERILOG_SRC),$(call veritedium-command,$(SRC)))

%.blif: $(RTL_OBJS)
	$(MAKE) veritedium
	mkdir -p $(SYN_DIR)
	$(YOSYS_SYN) $(YOSYS_SYN_FLAGS)

%.asc: %.blif
	$(YOSYS_PNR) $(YOSYS_PNR_FLAGS)

%.rpt: %.asc
	$(YOSYS_TIME_STA) $(YOSYS_TIME_STA_FLAGS)

#H# print-rtl-srcs  : Print RTL sources
print-rtl-srcs:
	$(call print-srcs-command)

#H# clean           : Remove build directory
clean:
	rm -rf build/*

#H# help            : Display help
help: Makefile
	@echo -e "\nRTL Synthesis Help - Yosys\n"
	@sed -n 's/^#H#//p' $<
	@echo ""

.PHONY: all rtl-synth veritedium print-rtl-srcs clean help
