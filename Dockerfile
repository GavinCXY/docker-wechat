FROM ricwang/docker-wechat:base

RUN curl -O "https://ime-sec.gtimg.com/202412171647/aae9bc28a2d6f3faba5c58dfb83af525/pc/dl/gzindex/1680521603/sogoupinyin_4.2.1.145_amd64.deb"

RUN apt update && \
    apt install -y fcitx qtbase5-dev libqt5qml5 libqt5quick5 libqt5quickwidgets5 qml-module-qtquick2 lsb-release && \
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

VOLUME /root/.xwechat
VOLUME /root/xwechat_files
VOLUME /root/downloads

# 配置微信版本号
RUN set-cont-env APP_VERSION "$(grep -o 'Unpacking wechat ([0-9.]*)' /tmp/wechat_install.log | sed 's/Unpacking wechat (\(.*\))/\1/')"
