{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Lista rzeczy do zainstalowania ręcznie:
  # - wootility

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "dinosaur";
  home.homeDirectory = "/home/dinosaur";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  targets.genericLinux.enable = true;
  targets.genericLinux.gpu.nvidia = {
    enable = true;
    version = "580.105.08";
    sha256 = "sha256-2cboGIZy8+t03QTPpp3VhHn6HQFiyMKMjRdiV2MpNHU=";
    #   nix store prefetch-file \
    #   https://download.nvidia.com/XFree86/Linux-x86_64/580.105.08/NVIDIA-Linux-x86_64-580.105.08.run

    # pacman -Q nvidia-utils
  };

  home.stateVersion = "25.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.nvidia.acceptLicense = true;

  # Shels
  home.shell.enableShellIntegration = true;
  home.shell.enableFishIntegration = true;

  programs.vscode.enable = true;

  programs.gpg.enable = true;

  programs.git.enable = true;
  programs.git.settings = {

    user.name = "janusz-bit";
    user.email = "janusz-bit@proton.me";
  };

  services.syncthing.enable = true;

  programs.fish = {
    enable = true;

    # 1. Wtyczki (odpowiednik conf.d/done.fish)
    plugins = [
      {
        name = "done";
        src = pkgs.fishPlugins.done.src;
      }
    ];

    # 2. Aliasy (przeniesione z cachyos-config.fish)
    shellAliases = {
      # Eza zamiast ls
      ls = "eza -al --color=always --group-directories-first --icons=always";
      la = "eza -a --color=always --group-directories-first --icons=always";
      ll = "eza -l --color=always --group-directories-first --icons=always";
      lt = "eza -aT --color=always --group-directories-first --icons=always";
      "l." = "eza -a | grep -e '^\.'";

      # Nawigacja
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      # Inne narzędzia
      grep = "grep --color=auto";
      cat = "bat";
      hw = "hwinfo --short";

      # Specyficzne dla Arch/CachyOS (zostaw tylko jeśli masz te komendy w systemie)
      update = "sudo cachyos-rate-mirrors && sudo pacman -Syu";
      cleanup = "sudo pacman -Rns (pacman -Qtdq)";
    };

    # 3. Funkcje (przeniesione z cachyos-config.fish)
    functions = {
      backup = "cp $argv $argv.bak";
      # Funkcja copy z pliku jest nieco bardziej złożona,
      # w Nix łatwiej zdefiniować ją tak lub pominąć:
      copy = ''
        set count (count $argv | tr -d \n)
        if test "$count" = 2; and test -d "$argv[1]"
            set from (echo $argv[1] | string trim -r /)
            set to (echo $argv[2])
            command cp -r $from $to
        else
            command cp $argv
        end
      '';
    };

    # 4. Inicjalizacja i zmienne (przeniesione z)
    interactiveShellInit = ''
      # Ustawienia wtyczki 'done'
      set -U __done_min_cmd_duration 10000
      set -U __done_notification_urgency_level low

      # Powitanie fastfetch
      function fish_greeting
          fastfetch
      end

      # Kolorowe man pages przy użyciu bat
      set -x MANROFFOPT "-c"
      set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"

      # Fix dla Javy (jeśli używasz)
      set -x _JAVA_AWT_WM_NONREPARENTING 1
    '';
  };

  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    hello
    nil
    nixd

    kdePackages.kleopatra

    eza # Wymagane przez aliasy 'ls'
    fastfetch # Używane w fish_greeting
    bat # Używane do kolorowania man pages
    hwinfo # Używane przez alias 'hw'
    fzf # Opcjonalnie, często przydatne w fish

    kdePackages.breeze # styl wyświetlania

    bootdev-cli

    yay

    qbittorrent-enhanced

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/dinosaur/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {

    EDITOR = "code";

    # Kluczowe dla aplikacji Electron z Nixpkgs (VS Code, Discord)
    NIXOS_OZONE_WL = "1";

    # Qt
    QT_QPA_PLATFORM = "wayland";

    # GTK
    GDK_BACKEND = "wayland";

    # Firefox
    MOZ_ENABLE_WAYLAND = "1";

    # SDL (Gry)
    SDL_VIDEODRIVER = "wayland";

    # Java (Fix dla renderingu GUI w tiling WM)
    _JAVA_AWT_WM_NONREPARENTING = "1";

    QT_STYLE_OVERRIDE = "breeze";
  };

  # Co to robi:
  #  - entryAfter ["writeBoundary"]: Uruchamia skrypt dopiero po tym, jak Home Manager zapisze wszystkie pliki konfiguracyjne.
  #  - $DRY_RUN_CMD: Zapewnia, że komenda nie wykona się podczas testowania (home-manager build), a tylko przy faktycznej zmianie (switch).
  #  - ln -sf ...: Tworzy (lub odświeża) link symboliczny, dzięki któremu KDE widzi aplikacje.

  home.activation = {
    linkDesktopApplications = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD mkdir -p $HOME/.local/share/applications
      $DRY_RUN_CMD ln -sf $HOME/.nix-profile/share/applications $HOME/.local/share/applications/nix-apps
    '';
  };

  #   **Cause:**
  # On non-NixOS systems ("Generic Linux"), the desktop environment (KDE Plasma) looks for application shortcuts (`.desktop` files)
  # in `/usr/share/applications` and `~/.local/share/applications`.
  # Home Manager installs them into the Nix store (`~/.nix-profile/share/applications`), which KDE doesn't see by default.

  # **Solution:**
  # Create a symbolic link to bridge the two locations. This is the most reliable fix for Arch/CachyOS.

  # 1.  **Run this command in your terminal:**

  #     ```bash
  #     mkdir -p ~/.local/share/applications
  #     ln -sf ~/.nix-profile/share/applications ~/.local/share/applications/nix-apps
  #     ```

  # 2.  **Force KDE to refresh its menu cache:**

  #     ```bash
  #     kbuildsycoca6
  #     ```

  #     *(If that command is not found, try `kbuildsycoca5`)*.

  # The apps should appear immediately. You only need to do this once; Home Manager will update the content inside that folder automatically.

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
