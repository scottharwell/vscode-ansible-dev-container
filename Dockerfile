FROM quay.io/fedora/fedora:35

ARG USERNAME=vscode
ARG USERID=1000
ARG GROUPID=1000
ARG OMF_INSTALL_PATH="https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install"
ARG VIMRC_PATH="https://github.com/amix/vimrc.git"

RUN python3 -m ensurepip --upgrade
RUN dnf install -y python3-devel python3-wheel oniguruma-devel gcc make git fish neofetch wget util-linux util-linux-user which vim powerline powerline-fonts vim-powerline
RUN python3 -m pip install --upgrade pip
RUN pip3 install ansible ansible-navigator ansible-lint

RUN groupadd --gid ${GROUPID} ${USERNAME}
RUN useradd --comment "VSCode User Account" --gid ${GROUPID} --uid ${USERID} -p ${USERNAME} -s /usr/bin/fish -m ${USERNAME}

WORKDIR /home/${USERNAME}

RUN runuser -l ${USERNAME} -c "mkdir -p /home/${USERNAME}/.config/fish"
COPY .config/fish /home/${USERNAME}/.config/fish
RUN chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}
RUN wget ${OMF_INSTALL_PATH} -P /tmp/
RUN chmod 755 /tmp/install
RUN runuser -l ${USERNAME} -c "/tmp/install --noninteractive --yes"
RUN runuser -l ${USERNAME} -c "omf install bobthefish"

RUN runuser -l ${USERNAME} -c "git clone --depth=1 ${VIMRC_PATH} /home/${USERNAME}/.vim_runtime"
RUN runuser -l ${USERNAME} -c "/home/${USERNAME}/.vim_runtime/install_awesome_vimrc.sh"
COPY .vim_runtime/my_configs.vim /home/${USERNAME}/.vim_runtime/my_configs.vim