# VSCode Ansible Development Container

This is a base container for [VSCode containerized development](https://code.visualstudio.com/docs/remote/containers) for Ansible development work.  It can be used or extended on a per-project basis for Ansible development and testing.  It is based off of Fedora to leverage modern package dependencies and it has a few configuration niceties that I have personally set for defaults including:

1. Fedora base image.
2. Installed packages (RPM) -- On top of the default Fedora packages
   * python3-devel 
   * python3-wheel 
   * oniguruma-devel 
   * gcc 
   * make 
   * git 
   * fish 
   * neofetch 
   * wget 
   * util-linux 
   * util-linux-user 
   * which 
   * vim 
   * powerline 
   * powerline-fonts 
   * vim-powerline
3. Installed packages (Pypi)
   * Ansible
   * Ansible Navigator
   * Ansible Lint
   * yamllint
4. Fish Shell as the default shell.
5. Prints system info on connecting (purely a cosmetic choice).

# Usage

This container can be directly used as a remote container for VSCode and Ansible development, but it can also be the base for other containers as well.

To use the container, follow the standard devcontainer deployment instructions of adding `.devcontainer/devcontainer.json` to your project.  You may then use the container image directly in the `devcontainer.json` file, or as a base to build on top of with a `Dockerfile`.

An example of using the container image directly could look like the following.  This example loads extensions, adds mount points from the host, and applies settings that are all isolated to the development environment.

```json
{
    "extensions": [
        "redhat.ansible",
        "richie5um2.vscode-sort-json",
        "zainchen.json",
        "ms-vscode.vscode-node-azure-pack",
        "ms-vscode.azure-account"
    ],
    "forwardPorts": [],
    "image": "quay.io/scottharwell/vscode-ansible:latest",
    "mounts": [
        "source=${localEnv:HOME}/.ssh,target=/home/vscode/.ssh,type=bind",
        "source=${localEnv:HOME}/.gitconfig,target=/home/vscode/.gitconfig,type=bind",
        "source=${localEnv:HOME}/.azure,target=/home/vscode/.azure,type=bind"
    ],
    "remoteUser": "vscode",
    "settings": {
        "diffEditor.renderSideBySide": true,
        "editor.suggestSelection": "first",
        "editor.tabSize": 4,
        "editor.wordWrap": "bounded",
        "editor.wordWrapColumn": 200,
        "explorer.confirmDelete": false,
        "explorer.confirmDragAndDrop": false,
        "files.exclude": {
            "**/.classpath": true,
            "**/.DS_Store": true,
            "**/.factorypath": true,
            "**/.git": true,
            "**/.project": true,
            "**/.settings": true,
            "**/*.js": {
                "when": "$(basename).ts"
            },
            "**/*.js.map": true
        },
        "telemetry.telemetryLevel": "off",
        "workbench.colorTheme": "Abyss"
    }
}
```

If you wish to build on top of this image, then you can remove the line `"image": "quay.io/scottharwell/vscode-ansible:latest",` and replace with the following.

```json
"build": {
   "dockerfile": "Dockerfile"
}
```

Then, in your `Dockerfile`, you can configure the container with other dependencies such as libraries and collections, such as the following example adding Azure collection content.

```Dockerfile
FROM quay.io/scottharwell/vscode-ansible:latest

ARG AZURE_COLLECTION_VERSION="v1.10.0"
ARG CONTAINER_USER="vscode"

# Ensure PIP is upgraded
RUN runuser -l ${CONTAINER_USER} -c "pip3 install pip --upgrade"

# Download Azure Collection Depedendencies - Note AZ CLI and collection have conflicting dependencies and cannot be installed together.
RUN runuser -l ${CONTAINER_USER} -c "git clone https://github.com/ansible-collections/azure.git /tmp/azure"
RUN runuser -l ${CONTAINER_USER} -c "cd /tmp/azure; git checkout ${AZURE_COLLECTION_VERSION}"
RUN runuser -l ${CONTAINER_USER} -c "pip3 install -r /tmp/azure/requirements-azure.txt"
RUN runuser -l ${CONTAINER_USER} -c "ansible-galaxy collection install azure.azcollection"
```