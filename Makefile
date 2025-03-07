TARGET_CODESIGN = $(shell which ldid)

BUNDLE = com.mizole.shortshellTS
SHORTSHELLTMP = $(TMPDIR)/shortshell
SHORTSHELL_STAGE_DIR = $(SHORTSHELLTMP)/stage
SHORTSHELL_APP_DIR 	= $(SHORTSHELLTMP)/Build/Products/Release-iphoneos/ShortShell.app
SHORTSHELL_HELPER_PATH 	= $(SHORTSHELLTMP)/Build/Products/Release-iphoneos/ShortShellHelper
GIT_REV=$(shell git rev-parse --short HEAD)

package:
	/usr/libexec/PlistBuddy -c "Set :REVISION shortshell" "ShortShell/Info.plist"

	@set -o pipefail; \
		xcodebuild -jobs $(shell sysctl -n hw.ncpu) -project 'ShortShell.xcodeproj' -scheme ShortShell -configuration Release -arch arm64 -sdk iphoneos -derivedDataPath $(SHORTSHELLTMP) \
		CODE_SIGNING_ALLOWED=NO DSTROOT=$(SHORTSHELLTMP)/install ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES=NO PRODUCT_BUNDLE_IDENTIFIER="$(BUNDLE)"
	@set -o pipefail; \
		xcodebuild -jobs $(shell sysctl -n hw.ncpu) -project 'ShortShell.xcodeproj' -scheme ShortShellHelper -configuration Release -arch arm64 -sdk iphoneos -derivedDataPath $(SHORTSHELLTMP) \
		CODE_SIGNING_ALLOWED=NO DSTROOT=$(SHORTSHELLTMP)/install ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES=NO PRODUCT_BUNDLE_IDENTIFIER="$(BUNDLE)"
	@rm -rf Payload
	@rm -rf $(SHORTSHELL_STAGE_DIR)/
	@mkdir -p $(SHORTSHELL_STAGE_DIR)/Payload
	@mv $(SHORTSHELL_APP_DIR) $(SHORTSHELL_STAGE_DIR)/Payload/ShortShell.app

	@echo $(SHORTSHELLTMP)
	@echo $(SHORTSHELL_STAGE_DIR)

	@mv $(SHORTSHELL_HELPER_PATH) $(SHORTSHELL_STAGE_DIR)/Payload/ShortShell.app//ShortShellHelper
	@$(TARGET_CODESIGN) -Sentitlements.xml $(SHORTSHELL_STAGE_DIR)/Payload/ShortShell.app/
	@$(TARGET_CODESIGN) -Sentitlements.xml $(SHORTSHELL_STAGE_DIR)/Payload/ShortShell.app//ShortShellHelper
	
	@rm -rf $(SHORTSHELL_STAGE_DIR)/Payload/ShortShell.app/_CodeSignature

	@ln -sf $(SHORTSHELL_STAGE_DIR)/Payload Payload

	@rm -rf packages
	@mkdir -p packages

	@zip -r9 packages/ShortShell.tipa Payload
