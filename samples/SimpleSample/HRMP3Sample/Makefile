TECSGEN = tecsgen
TARGET = spikert
# TARGET = most_simple_sample
BASE_DIR = .
GEN_DIR = $(BASE_DIR)/gen
# GEN_DIR = $(BASE_DIR)/gen_most_simple
TECSGEN_FLAGS =


all: $(TARGET)

$(TARGET):$(TECSGEN)

$(TECSGEN):
	#cd ../../..
	#source set_env.sh
	# $(TECSGEN) $(TECSGEN_FLAGS) most_simple_sample.cdl -I ./tecs_kernel
	# $(TECSGEN) $(TECSGEN_FLAGS) sample.cdl -I ./tecs_kernel
	$(TECSGEN) $(TECSGEN_FLAGS) spikert.cdl -I ./tecs_kernel

# simple: $(TARGET_SIMPLE)
# $(TARGET_SIMPLE):$(TECSGEN)

# $(TECSGEN):
# 	$(TECSGEN) $(TECSGEN_FLAGS) most_simple_sample.cdl

clean: 
	rm -r $(GEN_DIR)