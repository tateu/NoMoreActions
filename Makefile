export GO_EASY_ON_ME = 1

export ARCHS = armv7 arm64
export SDKVERSION = 8.1
export TARGET = iphone:clang:latest:8.0

PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)
# THEOS_PACKAGE_DIR_NAME =

include $(THEOS)/makefiles/common.mk
# _THEOS_INTERNAL_CFLAGS += -w

TWEAK_NAME = NoMoreActions
NoMoreActions_FILES = Tweak.xm
# NoMoreActions_FRAMEWORKS =
# UIKit CoreGraphics CoreFoundation QuartzCore AudioToolbox AVFoundation
# NoMoreActions_PRIVATE_FRAMEWORKS =
# NoMoreActions_LIBRARIES =
# NoMoreActions_CODESIGN_FLAGS = -SEntitlements.plist
NoMoreActions_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += NoMoreActions
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard"
