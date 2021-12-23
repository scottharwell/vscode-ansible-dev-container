# VSCode Ansible Container

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
4. Fish Shell as the default shell.
5. Prints system info on connecting (purely a cosmetic choice).