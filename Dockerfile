FROM ubuntu:24.04

LABEL maintainer="SFoxDev <admin@sfoxdev.com>"

ENV VNC_PASSWORD="" \
    DEBIAN_FRONTEND="noninteractive" \
    LC_ALL="C.UTF-8" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8"

# Install core utilities and set up Google's repo securely
RUN apt-get update && \
    apt-get install -y wget gnupg2 curl ca-certificates && \
    mkdir -p /usr/share/keyrings && \
    curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-linux-signing-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-linux-signing-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-linux-signing-keyring.gpg] http://dl.google.com/linux/chrome-remote-desktop/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list && \
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

# Create user and configure desktop environment
RUN addgroup chrome-remote-desktop && \
    useradd -m -G chrome-remote-desktop,pulse-access -s /bin/bash chrome && \
    echo "chrome:chrome" | chpasswd && \
    mkdir -p /home/chrome/.config/chrome-remote-desktop /home/chrome/.fluxbox && \
    echo '\
session.screen0.toolbar.visible:        false\n\
session.screen0.fullMaximization:       true\n\
session.screen0.maxDisableResize:       true\n\
session.screen0.maxDisableMove:         true\n\
session.screen0.defaultDeco:            NONE\n\
' > /home/chrome/.fluxbox/init && \
    chown -R chrome:chrome /home/chrome

# Copy local configuration files (if any)
COPY conf/ /conf/

# Link scripts (optional customization)
RUN ln -s /crdonly /usr/local/sbin/crdonly || true && \
    ln -s /update /usr/local/sbin/update || true

# Expose VNC and RDP ports
EXPOSE 5900 3389

# Persist home directory
VOLUME ["/home/chrome"]

# Entrypoint and default command
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

