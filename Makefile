export THEOS ?= $(HOME)/theos
PACKAGE_VERSION = 1.0.0
BUILD_NUMBER ?= $(shell date +%s)

ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0

INSTALL_TARGET_PROCESSES = Albion Online

GO_EASY_ON_ME = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = minimaptweak

minimaptweak_FILES = Tweak.xm MinimapView.m
minimaptweak_CFLAGS = -fobjc-arc
minimaptweak_FRAMEWORKS = UIKit CoreGraphics Foundation QuartzCore
minimaptweak_PRIVATE_FRAMEWORKS = GraphicsServices

# Debug symbols for GitHub Actions
ifeq ($(CI), true)
  minimaptweak_CFLAGS += -DCI_BUILD=1
endif

include $(THEOS_MAKE_PATH)/tweak.mk

before-package::
	@echo "📦 Building Minimap Tweak v$(PACKAGE_VERSION)"
	@echo "🔧 Build number: $(BUILD_NUMBER)"
	@echo "🤖 CI: $(CI)"

after-package::
	@echo "✅ Build complete!"
	@ls -la packages/

after-install::
	install.exec "killall -9 'Albion Online' 2>/dev/null || true"

clean::
	rm -rf .theos packages *.deb *.dylib