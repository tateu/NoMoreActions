include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = NoMoreActions
NoMoreActions_FILES = NoMoreActions.mm NMAApplicationController.mm
NoMoreActions_INSTALL_PATH = /Library/PreferenceBundles
NoMoreActions_FRAMEWORKS = UIKit CoreGraphics
NoMoreActions_PRIVATE_FRAMEWORKS = Preferences
NoMoreActions_LIBRARIES = applist
NoMoreActions_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/NoMoreActions.plist$(ECHO_END)
