TARGET  = unintel
OUTDIR ?= bin

unintel:
	@mkdir -p $(OUTDIR)
	@echo "Building $(TARGET)"
	@swift build --configuration release --arch arm64
	@cp .build/release/$(TARGET) $(OUTDIR)/$(TARGET)
