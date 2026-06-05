ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0

INSTALL_TARGET_PROCESSES = Albion Online

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = minimaptweak

minimaptweak_FILES = Tweak.xm MinimapView.m
minimaptweak_CFLAGS = -fobjc-arc
minimaptweak_FRAMEWORKS = UIKit CoreGraphics Foundation QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 'Albion Online' 2>/dev/null || true"
