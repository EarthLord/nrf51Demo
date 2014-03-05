#### Toolchain commands
####
GCC_INSTALL_ROOT	:= /home/prithvi/DevelopmentTools/gcc-arm-none-eabi-4_8-2013q4
GCC_VERSION			:= 4.8.3
GCC_PREFIX			:= arm-none-eabi

CC      := $(GCC_INSTALL_ROOT)/bin/$(GCC_PREFIX)-gcc
AS      := $(GCC_INSTALL_ROOT)/bin/$(GCC_PREFIX)-as
AR      := $(GCC_INSTALL_ROOT)/bin/$(GCC_PREFIX)-ar -r
LD      := $(GCC_INSTALL_ROOT)/bin/$(GCC_PREFIX)-ld
NM      := $(GCC_INSTALL_ROOT)/bin/$(GCC_PREFIX)-nm
OBJDUMP := $(GCC_INSTALL_ROOT)/bin/$(GCC_PREFIX)-objdump
OBJCOPY := $(GCC_INSTALL_ROOT)/bin/$(GCC_PREFIX)-objcopy
GDB     := $(GCC_INSTALL_ROOT)/bin/$(GCC_PREFIX)-gdb

MK	:= mkdir -p
RM	:= rm -rf

### General Variables
OUTPUT_NAME		= main
OUTPUT_DIR		= build
BIN_DIR			= bin
OBJ_DIR			= obj
SRC_DIR			= src
LINK_DIR		= link

### Device related stuff
###
BOARD			:= BOARD_PCA10000
CPU				:= cortex-m0
DEVICE 			:= NRF51
DEVICESERIES 	:= nrf51

### Programmer
###
JLINK_DIR 		= /opt/SEGGER/JLink/
JLINK 			= $(JLINK_DIR)JLinkExe
JLINKGDBSERVER	= $(JLINK_DIR)JLinkGDBServer

FLASH_START_ADDRESS	= 0
#SOFTDEVICE 			= lib/softdevice/s110_nrf51822_5.1.0_softdevice.hex

# Include directories
INCLUDEDIRS	 = $(shell find include -type d)
INCLUDEDIRS	+= $(GCC_INSTALL_ROOT)/lib/gcc/$(GCC_PREFIX)/$(GCC_VERSION)/include/
INCLUDEDIRS	+= $(GCC_INSTALL_ROOT)/lib/gcc/$(GCC_PREFIX)/$(GCC_VERSION)/include-fixed/
INCLUDEDIRS	+= $(GCC_INSTALL_ROOT)/$(GCC_PREFIX)/include/
 
### Source files
###

# Project Source
C_SRC  = $(shell find src -name *.c | awk -F/ '{print $$NF}')

### Assembly source files
ASSEMBLY_SRC = gcc_startup_$(DEVICESERIES).s

### Compiler related stuff
###
CFLAGS  = -ggdb	#info for the debugger
CFLAGS	+= -Og	#debugging friendly
CFLAGS	+= -mcpu=$(CPU)
CFLAGS	+= -mthumb
CFLAGS	+= -mabi=aapcs
CFLAGS	+= --std=gnu99
CFLAGS	+= -Wall
CFLAGS	+= -D$(DEVICE)
CFLAGS	+= -D$(BOARD)
CFLAGS	+= $(patsubst %,-I%, $(INCLUDEDIRS))

### Linker related stuff
###
LDDIRS 	 = $(GCC_INSTALL_ROOT)/$(GCC_PREFIX)/lib/armv6-m
LDDIRS 	+= $(GCC_INSTALL_ROOT)/lib/gcc/$(GCC_PREFIX)/$(GCC_VERSION)/armv6-m
LDDIRS	+= $(LINK_DIR)

LD_SCRIPT = $(LINK_DIR)/gcc_nrf51_blank_xxaa.ld

LDFLAGS = -Xlinker
LDFLAGS += -Map=$(BIN_DIR)/$(OUTPUT_NAME).map
LDFLAGS += -mcpu=$(CPU) 
LDFLAGS += -mthumb 
LDFLAGS += -mabi=aapcs 
LDFLAGS += -T$(LD_SCRIPT)
LDFLAGS	+= -D$(DEVICE)
LDFLAGS	+= -D$(BOARD)
LDFLAGS	+= $(patsubst %,-L%, $(LDDIRS))

# Sorting removes duplicates
BUILD_DIRS := $(sort $(OBJ_DIR) $(OUTPUT_DIR) $(BIN_DIR) )

# Make a list of source paths
C_SRC_DIRS = $(shell find src -type d) 
ASSEMBLY_SRC_DIRS = $(shell find src -type d)

# Object files
C_OBJ 			= $(addprefix $(OBJ_DIR)/, $(C_SRC:.c=.o))
ASSEMBLY_OBJ 	= $(addprefix $(OBJ_DIR)/, $(ASSEMBLY_SRC:.s=.o))

# Set source lookup paths
vpath %.c $(C_SRC_DIRS)
vpath %.s $(ASSEMBLY_SRC_DIRS)

# Include automatically previously generated dependencies
-include $(addprefix $(OBJ_DIR)/, $(C_OBJ:.o=.d))

### Rules
###
# Default build target
.PHONY : all
all : release

clean : 
	$(RM) $(OUTPUT_DIR)/*
	$(RM) $(OBJ_DIR)/*
	$(RM) $(BIN_DIR)/*
	- $(RM) JLink.log
	- $(RM) .gdbinit

.PHONY: release
release :  $(OUTPUT_DIR)/$(OUTPUT_NAME).bin $(OUTPUT_DIR)/$(OUTPUT_NAME).hex

$(BUILD_DIRS) : 
	@echo 
	@echo "Creating directories"
	- $(MK) $@

# Create objects from C source files
$(OBJ_DIR)/%.o : %.c
	@echo
	@echo "Build header dependencies for file: " $<
	$(CC) $(CFLAGS) -M $< -MF "$(@:.o=.d)" -MT $@
	@echo
	@echo "Compiling: " $<
	$(CC) $(CFLAGS) -c -o $@ $<

## Assemble .s files
$(OBJ_DIR)/%.o : %.s
	@echo
	@echo "Compiling: " $<
	$(CC) $(patsubst %,-I%, $(INCLUDEDIRS)) -c -o $@ $<


## Link C and assembler objects to an .elf file
$(OUTPUT_DIR)/$(OUTPUT_NAME).elf : $(BUILD_DIRS) $(C_OBJ) $(ASSEMBLY_OBJ)
	@echo
	@echo "Linking object files: " 
	$(CC) $(LDFLAGS) $(C_OBJ) $(ASSEMBLY_OBJ) -o $(OUTPUT_DIR)/$(OUTPUT_NAME).elf

## Create binary .bin file from the .elf file
$(OUTPUT_DIR)/$(OUTPUT_NAME).bin : $(OUTPUT_DIR)/$(OUTPUT_NAME).elf
	@echo
	@echo "Create binary(.bin) file from: " $<
	$(OBJCOPY) -O binary $(OUTPUT_DIR)/$(OUTPUT_NAME).elf $(OUTPUT_DIR)/$(OUTPUT_NAME).bin

## Create binary .hex file from the .elf file
$(OUTPUT_DIR)/$(OUTPUT_NAME).hex : $(OUTPUT_DIR)/$(OUTPUT_NAME).elf
	@echo
	@echo "Create binary(.hex) file from: " $<
	$(OBJCOPY) -O ihex $(OUTPUT_DIR)/$(OUTPUT_NAME).elf $(OUTPUT_DIR)/$(OUTPUT_NAME).hex

## Program device
upload: rm.jlink upload.jlink #stopdebug
	@echo "Starting uploading"
	$(JLINK) $(OUTPUT_DIR)/upload.jlink
	@echo "Done uploading"

rm.jlink:
	-rm -rf $(OUTPUT_DIR)/upload.jlink
		
upload.jlink:
	echo "device nrf51822\nspeed 1000\nw4 4001e504 1\nloadbin $(PWD)/$(OUTPUT_DIR)/$(OUTPUT_NAME).bin $(FLASH_START_ADDRESS)\nr\ng\nqc\n" > $(OUTPUT_DIR)/upload.jlink
		  
upload-softdevice: upload-softdevice.jlink stopdebug
	@echo
	@echo "Convert from hex to binary. Split original hex in two to avoid huge (>250 MB) binary file with just 0s. "
	$(OBJCOPY) -Iihex -Obinary --remove-section .sec3 $(SOFTDEVICE) $(OUTPUT_DIR)/_mainpart.bin
	$(OBJCOPY) -Iihex -Obinary --remove-section .sec1 --remove-section .sec2 $(SOFTDEVICE) $(OUTPUT_DIR)/_uicr.bin
	$(JLINK) $(OUTPUT_DIR)/upload-softdevice.jlink

upload-softdevice.jlink:
	@echo
	@echo "Do magic. Write to NVMC to enable erase, do erase all and erase UICR, reset, enable writing, load mainpart bin, load uicr bin. Reset."
	@echo " Resetting in between is needed to disable the protections. "
	echo "w4 4001e504 1\nloadbin \"$(OUTPUT_DIR)/_mainpart.bin\" 0\nloadbin \"$(OUTPUT_DIR)/_uicr.bin\" 0x10001000\nr\ng\nexit\n" > $(OUTPUT_DIR)/upload-softdevice.jlink

recover: recover.jlink erase-all.jlink pin-reset.jlink
	$(JLINK) $(OUTPUT_DIR)/recover.jlink
	$(JLINK) $(OUTPUT_DIR)/erase-all.jlink
	$(JLINK) $(OUTPUT_DIR)/pin-reset.jlink

recover.jlink:
	echo "si 0\nt0\nsleep 1\ntck1\nsleep 1\nt1\nsleep 2\nt0\nsleep 2\nt1\nsleep 2\nt0\nsleep 2\nt1\nsleep 2\nt0\nsleep 2\nt1\nsleep 2\nt0\nsleep 2\nt1\nsleep 2\nt0\nsleep 2\nt1\nsleep 2\nt0\nsleep 2\nt1\nsleep 2\ntck0\nsleep 100\nsi 1\nr\nexit\n" > $(OUTPUT_DIR)/recover.jlink

pin-reset.jlink:
	echo "device nrf51822\nw4 4001e504 2\nw4 40000544 1\nr\nexit\n" > $(OUTPUT_DIR)/pin-reset.jlink

erase-all: erase-all.jlink
	$(JLINK) $(OUTPUT_DIR)/erase-all.jlink

erase-all.jlink:
	echo "device nrf51822\nw4 4001e504 2\nw4 4001e50c 1\nw4 4001e514 1\nr\nexit\n" > $(OUTPUT_DIR)/erase-all.jlink

startdebug: stopdebug debug.jlink .gdbinit
	$(JLINKGDBSERVER) -single -if swd -speed 1000 -port $(GDB_PORT_NUMBER) &
	sleep 1
	$(GDB) $(ELF)

stopdebug:
	-killall $(JLINKGDBSERVER)

.gdbinit:
	echo "target remote localhost:$(GDB_PORT_NUMBER)\nmonitor flash download = 1\nmonitor flash device = nrf51822\nbreak main\nmon reset\n" > .gdbinit

debug.jlink:
	echo "Device nrf51822" > $(OUTPUT_DIR)/debug.jlink
		  
.PHONY: upload upload-softdevice erase-all startdebug stopdebug
