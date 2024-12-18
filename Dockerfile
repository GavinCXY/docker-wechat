FROM ricwang/docker-wechat:base

RUN curl -O "https://ime-sec.gtimg.com/202412181642/25fb362e5f9efa46c0f3aaef58b237cb/pc/dl/gzindex/1680521603/sogoupinyin_4.2.1.145_amd64.deb"

RUN apt update && \
    apt install -y fcitx qtbase5-dev libqt5qml5 libqt5quick5 libqt5quickwidgets5 qml-module-qtquick2 lsb-release whiptail libgsettings-qt1 libpulse-dev && \
    # 清理工作
    apt clean && \
    rm -rf /var/lib/apt/lists/*

RUN dpkg -i sogoupinyin_4.2.1.145_amd64.deb && rm sogoupinyin_4.2.1.145_amd64.deb
    
# 下载微信安装包
RUN curl -O "https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.deb" && \
    dpkg -i WeChatLinux_x86_64.deb 2>&1 | tee /tmp/wechat_install.log && \
    rm WeChatLinux_x86_64.deb

RUN echo '#!/bin/sh' > /startapp.sh && \
    echo 'exec /usr/bin/wechat' >> /startapp.sh && \
    chmod +x /startapp.sh

RUN cp /usr/share/applications/fcitx.desktop /etc/xdg/autostart/

RUN cat > /root/.config/fcitx/config <<-'EOF'
[Hotkey]
# Enumerate when press trigger key repeatedly
EnumerateWithTriggerKeys=True
# Skip first input method while enumerating
EnumerateSkipFirst=False

[Hotkey/TriggerKeys]
0=Shift+Shift_L
1=Zenkaku_Hankaku
2=Hangul

[Hotkey/AltTriggerKeys]
0=Shift_L

[Hotkey/EnumerateForwardKeys]
0=Control+Shift_L

[Hotkey/EnumerateBackwardKeys]
0=Control+Shift_R

[Hotkey/EnumerateGroupForwardKeys]
0=Super+space

[Hotkey/EnumerateGroupBackwardKeys]
0=Shift+Super+space

[Hotkey/ActivateKeys]
0=Hangul_Hanja

[Hotkey/DeactivateKeys]
0=Hangul_Romaja

[Hotkey/PrevPage]
0=Up

[Hotkey/NextPage]
0=Down

[Hotkey/PrevCandidate]
0=Shift+Tab

[Hotkey/NextCandidate]
0=Tab

[Hotkey/TogglePreedit]
0=Control+Alt+P

[Behavior]
# Active By Default
ActiveByDefault=False
# Share Input State
ShareInputState=No
# Show preedit in application
PreeditEnabledByDefault=True
# Show Input Method Information when switch input method
ShowInputMethodInformation=True
# Show Input Method Information when changing focus
showInputMethodInformationWhenFocusIn=False
# Show compact input method information
CompactInputMethodInformation=True
# Show first input method information
ShowFirstInputMethodInformation=True
# Default page size
DefaultPageSize=5
# Override Xkb Option
OverrideXkbOption=False
# Custom Xkb Option
CustomXkbOption=
# Force Enabled Addons
EnabledAddons=
# Force Disabled Addons
DisabledAddons=
# Preload input method to be used by default
PreloadInputMethod=True
EOF

RUN cat > /root/.config/fcitx/profile <<-'EOF'
[Groups/0]
# Group Name
Name=Default
# Layout
Default Layout=us
# Default Input Method
DefaultIM=keyboard-us

[Groups/0/Items/0]
# Name
Name=pinyin
# Layout
Layout=

[Groups/0/Items/1]
# Name
Name=keyboard-us
# Layout
Layout=

[GroupOrder]
0=Default
EOF

ENV GTK_IM_MODULE=fcitx
ENV QT_IM_MODULE=fcitx
ENV XMODIFIERS=@im=fcitx
ENV LANG=zh_CN.UTF-8

VOLUME /root/.xwechat
VOLUME /root/xwechat_files
VOLUME /root/downloads

# 配置微信版本号
RUN set-cont-env APP_VERSION "$(grep -o 'Unpacking wechat ([0-9.]*)' /tmp/wechat_install.log | sed 's/Unpacking wechat (\(.*\))/\1/')"
