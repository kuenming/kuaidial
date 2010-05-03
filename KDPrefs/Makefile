#Toolchain, gVim

NAME=KDPrefs

IPHONEIP=192.168.1.99

IPHONESDK=/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS2.2.sdk
IPHONESDKINC=$(IPHONESDK)/usr/include

MACSDK=/Developer/SDKs/MacOSX10.5.sdk
MACSDKINC=$(MACSDK)/usr/include

SYSROOT=/Developer/dat/sys
SYSROOTINC=$(SYSROOT)/usr/include

TOOLCHAIN=/Developer/dat/toolchain
TOOLCHAININC=$(TOOLCHAIN)/include

CLASSDUMP=/Developer/dat/class-dump

CC=/usr/bin/arm-apple-darwin9-gcc
CXX=/usr/bin/arm-apple-darwin9-g++
LD=$(CXX)

CFLAGS=-I$(TOOLCHAININC) -I$(CLASSDUMP)

LDFLAGS=-lobjc -bind_at_load \
		-framework CoreFoundation \
		-framework Foundation \
		-framework UIKit \
		-isysroot $(SYSROOT) \
		-F$(IPHONESDK)/System/Library/Frameworks \
		-F$(IPHONESDK)/System/Library/PrivateFrameworks

OBJS=main.o \
	 KDPrefs.o \
	 KDPrefsApp.o \
	 KDPrefsViewController.o \
	 KDPrefsViewControllerNext.o

all: $(NAME)

upload: all install

$(NAME): $(OBJS)
	$(LD) $(LDFLAGS) $(CFLAGS) -o $@ $^

%.o: %.m
	$(CXX) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

install: uninstall
	scp $(NAME) root@$(IPHONEIP):/Applications/KuaiDial.app/$(NAME)
	ssh root@$(IPHONEIP) chmod 755 /Applications/KuaiDial.app/$(NAME)
	ssh root@$(IPHONEIP) chown root:wheel /Applications/KuaiDial.app/$(NAME)
	ssh root@$(IPHONEIP) ldid -S /Applications/KuaiDial.app/$(NAME)

uninstall:
	ssh root@$(IPHONEIP) rm -f /Applications/KuaiDial.app/$(NAME)

clean:
	rm -f *.o $(NAME)

