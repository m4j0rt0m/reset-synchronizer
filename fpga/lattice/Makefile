###################################################################
# Project:                                                        #
# Description:      Lattice FPGA Board Test - Makefile            #
#                                                                 #
# Template written by Abraham J. Ruiz R.                          #
#   https://github.com/m4j0rt0m/rtl-develop-template-fpga-lattice #
###################################################################

MKFILE_PATH                 = $(abspath $(firstword $(MAKEFILE_LIST)))
TOP_DIR                     = $(shell dirname $(MKFILE_PATH))

### directories ###
SOURCE_DIR                  = $(TOP_DIR)/src
OUTPUT_DIR                  = $(TOP_DIR)/build
SCRIPTS_DIR                 = $(TOP_DIR)/scripts

### makefile includes ###
include $(SCRIPTS_DIR)/funct.mk
include $(SCRIPTS_DIR)/default.mk

### fpga test configuration ###
FPGA_TOP_MODULE            ?=
FPGA_VIRTUAL_PINS          ?=
FPGA_BOARD_TEST            ?=
FPGA_CLOCK_SRC             ?=

### external sources wildcards ###
EXT_VERILOG_SRC            ?=
EXT_VERILOG_HEADERS        ?=
EXT_PACKAGE_SRC            ?=
EXT_MEM_SRC                ?=
EXT_INCLUDE_DIRS           ?=
EXT_RTL_PATHS              ?=

### fpga rtl directories ###
RTL_DIRS                    = $(wildcard $(shell find $(SOURCE_DIR) -type d \( -iname rtl \)))
INCLUDE_DIRS                = $(wildcard $(shell find $(SOURCE_DIR) -type d \( -iname include \)))
PACKAGE_DIRS                = $(wildcard $(shell find $(SOURCE_DIR) -type d \( -iname package \)))
MEM_DIRS                    = $(wildcard $(shell find $(SOURCE_DIR) -type d \( -iname mem \)))

### sources wildcards ###
VERILOG_SRC                 = $(EXT_VERILOG_SRC) $(wildcard $(shell find $(RTL_DIRS) -type f \( -iname \*.v -o -iname \*.sv -o -iname \*.vhdl \)))
VERILOG_HEADERS             = $(EXT_VERILOG_HEADERS) $(wildcard $(shell find $(INCLUDE_DIRS) -type f \( -iname \*.h -o -iname \*.vh -o -iname \*.svh -o -iname \*.sv -o -iname \*.v \)))
PACKAGE_SRC                 = $(EXT_PACKAGE_SRC) $(wildcard $(shell find $(PACKAGE_DIRS) -type f \( -iname \*.sv \)))
MEM_SRC                     = $(EXT_MEM_SRC) $(wildcard $(shell find $(MEM_DIRS) -type f \( -iname \*.bin -o -iname \*.hex \)))
RTL_PATHS                   = $(EXT_RTL_PATHS) $(RTL_DIRS) $(INCLUDE_DIRS) $(PACKAGE_DIRS) $(MEM_DIRS)

### include flags ###
INCLUDES_FLAGS              = $(addprefix -I, $(INCLUDE_DIRS)) $(addprefix -I, $(EXT_INCLUDE_DIRS))

### synthesis objects ###
BUILD_DIR                   = $(OUTPUT_DIR)/$(FPGA_TOP_MODULE)
RTL_OBJS                    = $(VERILOG_SRC) $(PACKAGE_SRC) $(VERILOG_HEADERS) $(MEM_SRC)
BLIF_OBJ                    = $(BUILD_DIR)/$(PROJECT).blif
ASC_OBJ                     = $(BUILD_DIR)/$(PROJECT).asc
BIN_OBJ                     = $(BUILD_DIR)/$(PROJECT).bin
RPT_OBJ                     = $(BUILD_DIR)/$(PROJECT).rpt
BUILD_OBJS                  = $(BLIF_OBJ) $(ASC_OBJ) $(BIN_OBJ)

### lattice fpga flags ###
LATTICE_TARGET             := $(or $(LATTICE_TARGET),$(DEFAULT_LATTICE_TARGET))
LATTICE_DEVICE             := $(or $(LATTICE_DEVICE),$(DEFAULT_LATTICE_DEVICE))
LATTICE_PACKAGE            := $(or $(LATTICE_PACKAGE),$(DEFAULT_LATTICE_PACKAGE))
LATTICE_CLOCK_MHZ          := $(or $(LATTICE_CLOCK_MHZ),$(DEFAULT_LATTICE_CLOCK_MHZ))

### rtl yosys synthesis flags ###
LATTICE_SYN                 = yosys
LATTICE_SYN_INC_FLAGS       = $(addprefix -I, $(RTL_PATHS))
LATTICE_SYN_FLAGS           = -p "read_verilog -sv -formal $(LATTICE_SYN_INC_FLAGS) $(VERILOG_SRC) $(PACKAGE_SRC); proc; opt; proc; synth_$(LATTICE_TARGET) -top $(FPGA_TOP_MODULE) -blif $@"
LATTICE_PNR                 = arachne-pnr
LATTICE_PNR_FLAGS           = $< -d $(subst hx,,$(subst lp,,$(LATTICE_DEVICE))) -o $@
LATTICE_PCK                 = icepack
LATTICE_PCK_FLAGS           = -v $< $@
LATTICE_TIME_STA            = icetime
LATTICE_TIME_STA_FLAGS      = -tmd $(LATTICE_DEVICE) -c $(LATTICE_CLOCK_MHZ) -o $(BUILD_DIR)/$(PROJECT).v -r $@ $<
LATTICE_PROG                = iceprog
LATTICE_PROG_FLAGS          = $(BIN_OBJ)
LATTICE_PINOUT_PCF          = $(SCRIPTS_DIR)/$(FPGA_TOP_MODULE)_set_pinout.pcf
#WIP...
#LATTICE_SYN_SHOW_FLAGS      = -stretch -width -prefix $(BUILD_DIR)/$(PROJECT) -format png

### linter flags ###
LINT                        = verilator
LINT_SV_FLAGS               = +1800-2017ext+sv -sv
LINT_W_FLAGS                = -Wall -Wno-IMPORTSTAR -Wno-fatal
LINT_FLAGS                  = --lint-only --top-module $(FPGA_TOP_MODULE) $(LINT_SV_FLAGS) $(LINT_W_FLAGS) --quiet-exit --error-limit 200 $(PACKAGE_SRC) $(INCLUDES_FLAGS)

all: lattice-project

ifeq ($(FPGA_BOARD_TEST),yes)
lattice-project: veritedium rtl-bin rtl-report lattice-flash-fpga
else
lattice-project: veritedium rtl-report
endif

#H# rtl-synth          : Run RTL synthesis with Yosys
rtl-bin: $(BIN_OBJ)

#H# rtl-report         : Generate report
rtl-report: $(RPT_OBJ)

#H# veritedium         : Run veritedium AUTO features
veritedium:
	$(foreach SRC,$(VERILOG_SRC),$(call veritedium-command,$(SRC)))

#H# lint               : Run the verilator linter for the RTL code
lint: print-rtl-srcs
	@if [[ "$(FPGA_TOP_MODULE)" == "" ]]; then\
		echo -e "$(_error_)[ERROR] No defined top module!$(_reset_)";\
	else\
		echo -e "$(_info_)\n[INFO] Linting using $(LINT) tool$(_reset_)";\
		$(LINT) $(LINT_FLAGS) $(VERILOG_SRC) --top-module $(FPGA_TOP_MODULE);\
	fi

#H# lattice-flash-fpga : Program the BIN file into the connected Lattice FPGA
lattice-flash-fpga: $(BIN_OBJ) $(RTL_OBJS)
	@$(LATTICE_PROG) $(LATTICE_PROG_FLAGS)

%.blif: $(RTL_OBJS)
	@mkdir -p $(BUILD_DIR)
	@$(LATTICE_SYN) $(LATTICE_SYN_FLAGS)

%.asc: %.blif
	@if [[ "$(FPGA_VIRTUAL_PINS)" == "yes" ]]; then\
		$(LATTICE_PNR) $(LATTICE_PNR_FLAGS);\
	else\
		$(LATTICE_PNR) -p $(LATTICE_PINOUT_PCF) $(LATTICE_PNR_FLAGS);\
	fi

%.rpt: %.asc
	@if [[ "$(FPGA_VIRTUAL_PINS)" == "yes" ]]; then\
		$(LATTICE_TIME_STA) $(LATTICE_TIME_STA_FLAGS);\
	else\
		$(LATTICE_TIME_STA) -p $(LATTICE_PINOUT_PCF) $(LATTICE_TIME_STA_FLAGS);\
	fi

%.bin: %.asc
	@$(LATTICE_PCK) $(LATTICE_PCK_FLAGS)

#H# print-rtl-srcs     : Print RTL sources
print-rtl-srcs:
	$(call print-srcs-command)

#H# clean              : Clean build directory
clean:
	rm -rf build/*

#H# help               : Display help
help: Makefile
	@echo -e "\nFPGA Test Help - Lattice\n"
	@sed -n 's/^#H#//p' $<
	@echo ""

.PHONY: all lattice-project rtl-bin rtl-report veritedium lint lattice-flash-fpga print-rtl-srcs clean help
