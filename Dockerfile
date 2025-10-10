FROM ubuntu:questing

# system packages
RUN apt-get update && apt-get install -y curl git openssh-server python3-pip wget zsh
RUN pip3 install --upgrade --break-system-packages --ignore-installed pip cryptography>=42.0.0 setuptools>=78.1.1
RUN apt-get remove -y python3-pip python3-cryptography python3-setuptools || true

# oh-my-zsh
RUN sh -c "$(wget -O- https://install.ohmyz.sh)" && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
    sed -i 's/plugins=(git)/plugins=(z git zsh-autosuggestions zsh-syntax-highlighting)/g' ~/.zshrc

# jujutsu
ARG JUJUTSU_VERSION=0.34.0
ARG TARGETARCH
RUN ARCH=$([ "$TARGETARCH" = "amd64" ] && echo "x86_64" || echo "aarch64") && \
    wget https://github.com/jj-vcs/jj/releases/download/v${JUJUTSU_VERSION}/jj-v${JUJUTSU_VERSION}-${ARCH}-unknown-linux-musl.tar.gz && \
    mkdir -p /tmp/jj && \
    tar -xzf jj-v${JUJUTSU_VERSION}-${ARCH}-unknown-linux-musl.tar.gz -C /tmp/jj --strip-components=1 && \
    mv /tmp/jj/jj /usr/local/bin/jj && \
    rm -rf /tmp/jj jj-v${JUJUTSU_VERSION}-${ARCH}-unknown-linux-musl.tar.gz

# uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# ssh
RUN mkdir -p /var/run/sshd && \
    sed -i '/#\?PermitRootLogin/s/.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# start script
RUN echo "/usr/sbin/sshd" >> /start.sh && \
    echo 'echo "root:${PASSWORD:-docker}" | chpasswd' >> /start.sh && \
    echo "exec zsh" >> /start.sh && \
    chmod +x /start.sh

WORKDIR /root/projects
CMD ["zsh", "/start.sh"]
