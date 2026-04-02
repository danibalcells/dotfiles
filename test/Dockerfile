FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
    git curl zsh vim sudo locales \
    build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev libffi-dev \
    liblzma-dev libncursesw5-dev xz-utils tk-dev \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8
ENV HOME=/home/testuser

RUN useradd -m -s /bin/zsh testuser
USER testuser
WORKDIR /home/testuser

COPY --chown=testuser:testuser . /home/testuser/.dotfiles

RUN cd /home/testuser/.dotfiles && ./install.sh

COPY --chown=testuser:testuser test/test.sh /home/testuser/test.sh
RUN chmod +x /home/testuser/test.sh
CMD ["/home/testuser/test.sh"]
