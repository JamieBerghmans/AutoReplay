export ARCHS = armv7 arm64 arm64e

include ~/theos/makefiles/common.mk

TWEAK_NAME = AutoReplay
AutoReplay_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
