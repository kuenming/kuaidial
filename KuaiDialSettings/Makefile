NAME=KuaiDialSettings

IPHONEIP=192.168.1.3

IPHONESDK=/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS2.2.sdk
IPHONESDKINC=$(IPHONESDK)/usr/include

MACSDK=/Developer/SDKs/MacOSX10.5.sdk
MACSDKINC=$(MACSDK)/usr/include

SYSROOT=/dat/sys
SYSROOTINC=$(SYSROOT)/usr/include

TOOLCHAIN=/dat/toolchain
TOOLCHAININC=$(TOOLCHAIN)/include

CLASSDUMP=/dat/class-dump

CC=/dat/pre/bin/arm-apple-darwin9-gcc
CXX=/dat/pre/bin/arm-apple-darwin9-g++
LD=$(CXX)

CFLAGS=-I$(SYSROOTINC) -I$(TOOLCHAININC) -I$(CLASSDUMP)

LDFLAGS=-lobjc -lsqlite3 -dynamiclib \
		-framework CoreFoundation \
		-framework Foundation \
		-framework UIKit \
		-framework CoreTelephony \
		-framework CoreMedia \
		-framework Celestial \
		-framework AddressBook \
		-framework AudioToolbox \
		-framework Preferences \
		-isysroot $(SYSROOT) \
		-F$(IPHONESDK)/System/Library/Frameworks \
		-F$(IPHONESDK)/System/Library/PrivateFrameworks \
		-multiply_defined suppress

OBJS=KuaiDialSettings.o

all: $(NAME)

upload: all install

$(NAME): $(OBJS)
	$(LD) $(LDFLAGS) $(CFLAGS) -o $@ $^

%.o: %.m
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

install: uninstall
	scp $(NAME) root@$(IPHONEIP):/System/Library/PreferenceBundles/KuaiDialSettings.bundle
	ssh root@$(IPHONEIP) chmod 755 /System/Library/PreferenceBundles/KuaiDialSettings.bundle/$(NAME)
	ssh root@$(IPHONEIP) ldid -S /System/Library/PreferenceBundles/KuaiDialSettings.bundle/$(NAME)

uninstall:
	ssh root@$(IPHONEIP) rm -f /System/Library/PreferenceBundles/KuaiDialSettings.bundle/$(NAME)

clean:
	rm -f *.o $(NAME)

