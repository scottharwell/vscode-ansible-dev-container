FROM quay.io/fedora/fedora:37

ARG USERNAME=vscode
ARG USERID=1000
ARG GROUPID=1000
ARG OMF_INSTALL_PATH="https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install"
ARG VIMRC_PATH="https://github.com/amix/vimrc.git"

# Upgrade packages and install new packages
RUN dnf upgrade -y
RUN python3 -m ensurepip --upgrade
RUN dnf install -y python3-devel python3-wheel oniguruma-devel gcc make git fish neofetch wget util-linux util-linux-user which vim powerline powerline-fonts vim-powerline

# Create VSCode user
RUN groupadd --gid ${GROUPID} ${USERNAME}
RUN useradd --comment "VSCode User Account" --gid ${GROUPID} --uid ${USERID} -p ${USERNAME} -G wheel -s /usr/bin/fish -m ${USERNAME}

# Allow wheel to perform sudo actions with no password
RUN sed -e 's/^%wheel/#%wheel/g' -e 's/^# %wheel/%wheel/g' -i /etc/sudoers

# Set workdir to vscode home
WORKDIR /home/${USERNAME}

# Install Pypi packages for VSCode user
RUN runuser -l ${USERNAME} -c "mkdir -p /home/${USERNAME}/.local/bin"
RUN runuser -l ${USERNAME} -c "set -U fish_user_paths /home/${USERNAME}/.local/bin"
RUN runuser -l ${USERNAME} -c "python3 -m pip install --upgrade pip"
RUN runuser -l ${USERNAME} -c "pip3 install ansible ansible-navigator ansible-lint yamllint"

# Create Fish Shell configs
RUN runuser -l ${USERNAME} -c "mkdir -p /home/${USERNAME}/.config/fish"
COPY .config/fish /home/${USERNAME}/.config/fish
RUN chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.config

# Install OMF and Themes
RUN wget ${OMF_INSTALL_PATH} -P /tmp/
RUN chmod 755 /tmp/install
RUN runuser -l ${USERNAME} -c "/tmp/install --noninteractive --yes"
RUN runuser -l ${USERNAME} -c "omf install bobthefish"
RUN runuser -l ${USERNAME} -c "set -Ux theme_color_scheme solarized-dark"

# Install VIM Configs
RUN runuser -l ${USERNAME} -c "git clone --depth=1 ${VIMRC_PATH} /home/${USERNAME}/.vim_runtime"
RUN runuser -l ${USERNAME} -c "/home/${USERNAME}/.vim_runtime/install_awesome_vimrc.sh"
COPY .vim_runtime/my_configs.vim /home/${USERNAME}/.vim_runtime/my_configs.vim