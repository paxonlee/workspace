FROM ubuntu:24.04

# oh-my-zsh
RUN apt-get update && apt-get install -y git wget zsh
RUN sh -c "$(wget -O- https://install.ohmyz.sh)" && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
    sed -i 's/plugins=(git)/plugins=(z git zsh-autosuggestions zsh-syntax-highlighting)/g' ~/.zshrc

# jujutsu
ARG JUJUTSU_VERSION=0.34.0
RUN wget https://github.com/jj-vcs/jj/releases/download/v${JUJUTSU_VERSION}/jj-v${JUJUTSU_VERSION}-x86_64-unknown-linux-musl.tar.gz && \
    mkdir -p /tmp/jj && \
    tar -xzf jj-v${JUJUTSU_VERSION}-x86_64-unknown-linux-musl.tar.gz -C /tmp/jj --strip-components=1 && \
    mv /tmp/jj/jj /usr/local/bin/jj && \
    rm -rf /tmp/jj jj-v${JUJUTSU_VERSION}-x86_64-unknown-linux-musl.tar.gz

# uv
RUN apt-get update && apt-get install -y curl
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
    
WORKDIR /root/projects

CMD ["zsh"]
