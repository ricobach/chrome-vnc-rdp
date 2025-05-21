FROM ubuntu:24.04
MAINTAINER SFoxDev <admin@sfoxdev.com>

ENV VNC_PASSWORD="" \
    DEBIAN_FRONTEND="noninteractive" \
    LC_ALL="C.UTF-8" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8"

# Add Google signing key and Chrome sources
ADD https://dl.google.com/linux/linux_signing_key.pub /tmp/linux_signing_key.pub

RUN apt-get update && \
    apt-get install -y wget gnupg2 curl && \
    install -m 644 /tmp/linux_signing_key.pub /usr/share/keyrings/google-linux-signing-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-linux-signing-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" \
        > /etc/apt/sources.list.d/google-chrome.list && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-linux-signing-keyring.gpg] http://dl.google.com/linux/chrome-remote-desktop/deb/ stable main" \
        >> /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y \
        google-chrome-stable \
        chrome-remote-desktop \
        fonts-takao \
        pulseaudio \
        supervisor \
        x11vnc \
        fluxbox \
        mc \
        xfce4 \
        xrdp && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/cache/* /var/log/apt/*

# Add user and prepare environment
RUN addgroup chrome-remote-desktop && \
    useradd -m -G chrome-remote-desktop,pulse-access -s /bin/bash chrome && \
    echo "chrome:chrome" | chpasswd && \
    ln -s /crdonly /usr/local/sbin/crdonly && \
    ln -s /update /usr/local/sbin/update && \
    mkdir -p /home/chrome/.config/chrome-remote-desktop /home/chrome/.fluxbox && \
    echo ' \
session.screen0.toolbar.visible:        false\n\
session.screen0.fullMaximization:       true\n\
session.screen0.maxDisableResize:       true\n\
session.screen0.maxDisableMove: true\n\
session.screen0.defaultDeco:    NONE\n\
' >> /home/chrome/.fluxbox/init && \
    chown -R chrome:chrome /home/chrome/.config /home/chrome/.fluxbox

ADD conf/ /

VOLUME ["/home/chrome"]

EXPOSE 5900 3389

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

