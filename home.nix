{ pkgs
, config
, hostname
, ...
}: {
  programs.git = {
    enable = true;
    userName = "Marshall Beddoe";
    userEmail = "mbeddoe@gmail.com";
    extraConfig = {
      merge.ff = true;
      pull.rebase = true;
      fetch.prune = true;
      core.editor = "vim";
      push.autoSetupRemote = true;
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    plugins = [
      {
        name = "zsh-nix-shell";
        src = pkgs.zsh-nix-shell;
        file = "share/zsh-nix-shell/nix-shell.plugin.zsh";
      }
    ];
    shellAliases = {
      ls = "${pkgs.coreutils}/bin/ls --color -sFhb --group-directories-first";
      l = "${pkgs.coreutils}/bin/ls -a --color -sFhb --group-directories-first";

      nixfmt = ''find . -type f -name "*.nix" -exec nixpkgs-fmt {} \;'';
      lcd = ''() { cd ~$1; }'';
#      rebuild = "echo 'Rebuilding ${HOSTNAME}' && pushd ~/git/gimli; sudo nixos-rebuild switch --flake .#${HOSTNAME}; popd";
    };

    initContent = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
      alias ll='eza -la'

      HOSTNAME=$(hostname)
      alias rebuild="echo 'Rebuilding $HOSTNAME' && pushd ~/git/gimli; sudo nixos-rebuild switch --flake .#$HOSTNAME; popd"

      # Named directories
      hash -d g=~/git
      hash -d s=~/git/gimli/src
      hash -d hm=~/git/home-manager

      eval "$(${pkgs.coreutils}/bin/dircolors)"

      bindkey -e
    '';
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  home.packages = with pkgs; [
    zsh-powerlevel10k
    zsh-nix-shell
    eza
    fzf
    black
    tree
    fd
    tmux
    nixpkgs-fmt
    btop
    (pkgs.vim_configurable.customize {
      name = "vim";
      vimrcConfig = {
        customRC = "source ${config.home.homeDirectory}/.vimrc";
        packages.myVimPackage = with pkgs.vimPlugins; {
          start = [ vim-nix nerdtree jellybeans-vim tcomment_vim ];
          opt = [ ];
        };
      };
    })
  ];

  home.file.".vimrc".source = ./dotfiles/vimrc;
  home.file.".p10k.zsh".source = ./dotfiles/p10k.zsh;
  # TODO: Make alacritty config conditional. Not needed on Arch.
  home.file.".alacritty.toml".source = ./dotfiles/alacritty.toml;
  home.file.".tmux.conf".source = ./dotfiles/tmux.conf;

  home.sessionVariables = {
    DIRENV_LOG_FORMAT = "";
    FZF_DEFAULT_COMMAND = "fd --type f --exclude .git";
    FZF_ALT_C_COMMAND = "fd --type d --hidden --exclude .git";
  };

  home.stateVersion = "25.05";
}
