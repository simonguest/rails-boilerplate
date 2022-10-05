FROM ubuntu:bionic

# Additional required packages
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm5 libgdbm-dev git

# Set the non-root user for the container and switch
ARG UID
ARG GID
RUN apt-get -y install sudo
RUN groupadd -g ${GID} dev \
    && useradd -r -u ${UID} -g dev --shell /bin/bash --create-home dev \
    && echo 'dev ALL=NOPASSWD: ALL' >> /etc/sudoers \
    && chown -R dev /usr/local
USER dev

# Install rbenv
RUN sudo apt-get -y install rbenv \
    && mkdir -p "$(rbenv root)"/plugins \
    && git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build

# Install Ruby 2.7.5
RUN rbenv install 2.7.5 \
    && echo -n '\n# rbenv init\neval "$(rbenv init -)"\n' >> ~/.bashrc \
    && rbenv global 2.7.5 \
    && sudo rm /usr/bin/ruby \
    && sudo ln -s /home/dev/.rbenv/versions/2.7.5/bin/ruby /usr/bin/ruby

# Install Node 14.17.1
RUN sudo apt-get -y install nodejs npm \
    && npm install -g n \
    && n 14.17.1

# Install Yarn 1.22.5
RUN npm i -g yarn@1.22.5

# # Install MySQL Native Client
RUN sudo apt-get -y install libsqlite3-dev libmysqlclient-dev mysql-client-core-5.7

# Add Ruby binaries to path
RUN echo -n '\n# Add Ruby binaries on path\nexport PATH=$PATH:/home/dev/.rbenv/versions/2.7.5/bin\n' >> ~/.bashrc

# Install debugging tools
RUN sudo apt-get -y install gdb rsync lsof

# Install rbspy
RUN cd /home/dev \
    && if [ $(uname -m) = "aarch64" ]; then curl -L "https://github.com/rbspy/rbspy/releases/download/v0.12.1/rbspy-aarch64-musl.tar.gz" -o "rbspy.tar.gz"; else curl -L "https://github.com/rbspy/rbspy/releases/download/v0.12.1/rbspy-x86_64-musl.tar.gz" -o "rbspy.tar.gz"; fi \
    && tar -xvf ./rbspy.tar.gz \
    && chmod +x ./rbspy*musl \
    && sudo cp ./rbspy*musl /usr/local/bin

# Make temporary directory and do a bundle install
RUN sudo mkdir -p /app/src
COPY src/Gemfile /app/src/.
COPY src/Gemfile.lock /app/src/.
COPY src/.ruby-version /app/src/.
RUN sudo chown -R dev /app
RUN cd /app/src \
    && eval "$(rbenv init -)" \
    && bundle config set force_ruby_platform true \
    && bundle install

