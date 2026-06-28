# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:


{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [ "nvidia-drm.modeset=1" ];
  boot.blacklistedKernelModules = ["nouveau" ];
  
  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Ho_Chi_Minh";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."quanh" = {
    isNormalUser = true;
    description = "Dao Le Quoc Anh";
    shell = pkgs.fish;
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    alacritty
    fuzzel
    firefox
    waybar
    awww
    mako
    playerctl    
    tokyonight-gtk-theme
    yazi
    nautilus
    nixd
    steam-run
  ];

# Enable XDG Portal

xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    wlr.enable = true;    
    # Định tuyến rõ ràng cho Niri
    config = {
      niri = {
        default = pkgs.lib.mkForce [ "gtk" ];
      };
      common = {
        default = [ "gtk" ];
      };
    };
  };

#Config DM

#users.users.greeter.extraGroups = [ "video" "render" ];

services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # Đổi 'hyprland' thành tên Window Manager/Desktop bạn dùng (ví dụ: sway, bash)
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd niri";
        user = "greeter";
      };
    };
  };

  # 3. Trả cài đặt systemd của greetd về mặc định sạch sẽ
  systemd.services.greetd.serviceConfig = {
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };

# NIX-LD
programs.nix-ld = {
  enable = true;
  libraries = with pkgs; [
    # Thư viện cơ bản hệ thống
    stdenv.cc.cc
    zlib
    zstd
    glib

    # Thư viện đồ họa và kết xuất (Rất quan trọng cho Wayland)
    libglvnd
    mesa
    wayland
    libxkbcommon

    # Các cổng giao tiếp âm thanh và hệ thống
    alsa-lib
    pulseaudio
    pipewire
    systemd

    # Dự phòng XWayland cho các ứng dụng/game cũ chưa hỗ trợ Wayland gốc
    libX11
    libXext
    libXrender
    libXfixes
    libXcursor
    libXi
    libXrandr
  ];
};

#Font config
fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      font-awesome
      capitaine-cursors
    ];

    # THÊM ĐOẠN NÀY ĐỂ ĐÁ BAY DEJAVU, ÉP HỆ THỐNG DÙNG NERD FONT
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font" ];
        
        # (Tùy chọn) Nếu bạn muốn font hệ thống/trình duyệt cũng dùng font này luôn:
        sansSerif = [ "JetBrainsMono Nerd Font" ];
        serif = [ "JetBrainsMono Nerd Font" ];
      };
    };
  };

 #------------Nvidia Config----------------
hardware.graphics.enable = true;
services.xserver.videoDrivers = ["nvidia"];
hardware.nvidia = {
modesetting.enable = true;
powerManagement.enable = false;
powerManagement.finegrained = false;
open = false;
nvidiaSettings = true;
package = config.boot.kernelPackages.nvidiaPackages.stable;

};
environment.sessionVariables = {
WLR_NO_HARDWARE_CURSORS = "1";
GSK_RENDERER = "ngl";
GBM_BACKEND = "nvidia-drm";
__GLX_VENDOR_LIBRARY_NAME = "nvidia";
NIXOS_OZONE_WL = "1";
__GL_SHADER_DISK_CACHE_PATH = "/tmp";
GTK_USE_PORTAL = "1";
MOZ_ENABLE_WAYLAND = "1";
};

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  #------------------ my config sevice ------------------------
  programs.niri.enable = true;
  programs.dconf.enable = true;
  programs.fish.enable = true;
  services.gvfs.enable = true;
  system.stateVersion = "26.05"; # Did you read the comment?
  
  # MY SQL
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    ensureDatabases = [ "quanh_db" ];
    ensureUsers = [
      {
        name = "quanh";
        ensurePermissions = {
          "quanh_db.*" = "ALL PRIVILEGES";
        };
        # Trỏ tới file chứa mật khẩu local, không bao giờ lộ lên GitHub
       # passwordFile = "/etc/mysql-password-local";
      }
    ];
  };

  # HOME MANAGER -----------------------------
# home.enableNixpkgsReleaseCheck = false;
 home-manager.useGlobalPkgs = true;
 home-manager.useUserPackages = true; 
 home-manager.users.quanh = { pkgs, ... }: {
 home.packages = with pkgs; [
  fastfetch
  pear-desktop
  libnotify
  cava
  btop
  antigravity
  git
  nodejs
  gh
  uv
  python314
  pkg-config
  glib
  openssl
    
];
  home.sessionPath = [
    "$HOME/.npm-global/bin"
  ];
  fonts.fontconfig.enable = true;
  
  home.stateVersion = "26.05";
  home.sessionVariables = {
    GTK_THEME = "Tokyonight-Dark";
    UV_PYTHON_PREFERENCE = "system";
    UV_PYTHON_DOWNLOADS = "never";
  };
  gtk = {
      enable = true;
    };
  programs.waybar = {
  enable = true;
 # systemd.enable = true;
 # systemd.targets = [ "niri.service" ];
  style = ''
  * {
    font-family: "JetBrainsMono Nerd Font", "Noto Sans CJK", sans-serif;
    font-size: 15px;
    font-weight: 500;
    min-height: 0;
  }

  window#waybar {
    background: rgba(26, 27, 38, 0.85);
    border-bottom: 3px solid #7aa2f7;
    color: #c0caf5;
    box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.4);
    border-radius: 12px;
    border: 1px solid rgba(122, 162, 247, 0.2);
    margin-top: 8px;
    margin-left: 10px;
    margin-right: 10px;
    padding: 6px 10px;
  }

  /* Workspace highlight Tokyo Night */
  #workspaces button {
    padding: 6px 14px;
    margin: 5px 4px;
    border-radius: 9px;
    color: #565f89;
  }

  #workspaces button.active {
    color: #7aa2f7;
    background: rgba(122, 162, 247, 0.25);
    border-bottom: 3px solid #7aa2f7;
  }

  /* Padding modules */
  #pulseaudio, #network, #cpu, #memory, #temperature, #desktop-battery, #clock {
    padding: 0 20px;
    margin: 0 4px;
  }

  #memory {
    padding: 0 20px;
  }

  #clock              { color: #bb9af7; }
  #desktop-battery    { color: #9ece6a; }
  #cpu                { color: #ff9e64; }
  #memory             { color: #73daca; }
  #network            { color: #7aa2f7; }
  #pulseaudio         { color: #a9b1d6; }
  #temperature        { color: #f7768e; }


#network,
#pulseaudio,
#cpu,
#memory,
#desktop-battery,
#tray {
    /* Giảm padding bên trái và bên phải xuống còn 6px (mặc định thường là 10px-15px) */
    padding-left: 9px;
    padding-right: 9px;
    
    /* Thu hẹp khoảng cách lề ngoài giữa các cục module */
    margin-left: 2px;
    margin-right: 2px;
}


'';

  settings = [{
    height = 42;
    layer = "top";
    position = "top";
    spacing = 6;
    margin-top = 8;
    margin-left = 12;
    margin-right = 12;
    margin-bottom = 0;
    modules-left = [ "niri/workspaces" "mpris"  ];
    modules-center = [  "clock"  ];
    modules-right = [ "network" "pulseaudio" "cpu" "memory" "temperature" "tray" ];

   "niri/workspaces" = {
      format = "{icon}";
      format-icons = {
        "1" = "1"; "2" = "2"; "3" = "3"; "4" = "4"; "5" = "5";
        "6" = "6"; "7" = "7"; "8" = "8"; "9" = "9";
        active = "󰮯";
        default = "󰊠";
      };
      persistent-workspaces = {
        "*" = 9;
      };
    };

   
    clock = {
      format = " {:%H:%M}";
    };

    cpu = {
      format = "  {usage}%";
    };

    memory = {
      format = "  {percentage}%";
    };

    # Nhiệt độ CPU (giữ theo config của bạn)
    temperature = {
      interval = 5;
      hwmon-path = "/sys/class/hwmon/hwmon1/temp1_input";
      format = " {temperatureC}°C";
      format-critical = " {temperatureC}°C";
      critical-threshold = 85;
    };
    mpris = {
      # Đích danh tên player hiển thị trong playerctl -l (Phân biệt chữ hoa chữ thường)
      player = "YoutubeMusic"; 
      format = "   {player_icon} {artist} - {title}";
      format-paused = "{status_icon} <i>{artist} - {title}</i>";
      
      # Định nghĩa icon tương ứng với tên chính xác của ứng dụng
      player-icons = {
        default = " ";
        YoutubeMusic = "<span size='150%'><span color='#ff7a93'>󰎆 </span></span>"; # Phải viết hoa chữ Y và M giống hệt kết quả playerctl -l
      };
      status-icons = {
        paused = "<span size='150%'><span color='#ff7a93'> </span></span>";
      };
      max-length = 60;
    };
 
    network = {
      interval = 5;
      format-ethernet = "󰈁 {ipaddr}";
      format-wifi = "󰖩 {essid} ({signalStrength}%)";
      format-disconnected = "󰤭";
    };

   pulseaudio = {
      format = "{icon}  {volume}%";      # Icon sound trước %
      format-muted = "󰝟 Muted";
      format-icons = {
        default = [ "" "" "" ];
      };
      on-click = "pavucontrol";
    };

   "desktop-battery" = {
      format = "  ";
      tooltip = false;
    };

    tray = {
      icon-size = 15;
      spacing = 12;
    };
  }];
};

programs.fuzzel = {
 enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=14";
        dpi-aware = "yes";
        width = 40;
        horizontal-pad = 20;
        vertical-pad = 15;
        inner-pad = 10;
        image-size-ratio = 0.2;
      };

      colors = {
        # Định dạng: RRGGBBAA (Thêm 2 ký tự cuối để chỉnh độ trong suốt)
        # e6 tương đương ~90% opacity, giúp hiệu ứng blur hoạt động tốt
        background = "1a1b26e6";       # Tokyo Night BG
        text = "c0caf5ff";             # Chữ mặc định (Foreground)
        match = "ff9e64ff";            # Ký tự trùng khớp khi gõ (Orange)
        selection = "283457ff";        # Màu nền của dòng được chọn
        selection-text = "c0caf5ff";   # Màu chữ của dòng được chọn
        selection-match = "ff9e64ff";  # Ký tự trùng khớp trên dòng được chọn
        border = "7aa2f7ff";           # Màu viền (Blue)
      };

      border = {
        width = 2;
        radius = 15;                   # Bo tròn góc (Tăng/giảm tùy sở thích)
      };
    };
};

programs.alacritty = {
  enable = true;
  settings = {
    window = {
      decorations = "None";
      opacity = 0.90; # Hạ opacity xuống để thấy hiệu ứng blur
      padding = { x = 12; y = 12; };
    };
    font = {
      normal = {
        family = "JetBrainsMono Nerd Font"; # Thay tên font của bạn vào đây
        style = "Regular";
      };
      bold = {
        family = "JetBrainsMono Nerd Font";
        style = "Bold";
      };
      italic = {
        family = "JetBrainsMono Nerd Font";
        style = "Italic";
      };
      size = 14.0; # Tùy chỉnh cỡ chữ
    };
    colors = {
      primary = {
        background = "#1a1b26";
        foreground = "#a9b1d6";
      };
      normal = {
        black   = "#32344a";
        red     = "#f7768e";
        green   = "#9ece6a";
        yellow  = "#e0af68";
        blue    = "#7aa2f7";
        magenta = "#bb9af7";
        cyan    = "#7dcfff";
        white   = "#a9b1d6";
      };
      bright = {
        black   = "#444b6a";
        red     = "#ff7a93";
        green   = "#b9f27c";
        yellow  = "#ff9e64";
        blue    = "#7da6ff";
        magenta = "#bb9af7";
        cyan    = "#0db9d7";
        white   = "#acb0d0";
      };
    };
  };
};

home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Amber"; # Màu trắng tinh tế (Nếu thích màu đen, đổi thành "Bibata-Modern-Amber")
      size = 24;
    };

    # Thêm cấu hình GTK để đảm bảo các ứng dụng nhận diện tốt
    gtk = {
     # enable = true;
      cursorTheme = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Ice";
        size = 24;
      };
      theme = {
      name = "Tokyonight-Dark";
      package = pkgs.tokyonight-gtk-theme;
   
     };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    # Đắp bộ Icon vào đây
    iconTheme = {
      name = "Tela-circle-dark"; # Hoặc "Papirus-Dark"
      package = pkgs.tela-circle-icon-theme; # Hoặc pkgs.papirus-icon-theme
    };
    };
     dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
    };


services.mako = {
      enable = true;
      
      # Gom toàn bộ thuộc tính giao diện vào block settings theo đúng chuẩn Home Manager mới
      settings = {
        layer = "top";
        anchor = "top-right";
        margin = "16,16,10";
        padding = "14";
        width = 340;
        max-visible = 5; # Đổi từ maxVisible thành max-visible
        font = "JetBrainsMono Nerd Font 10";
        background-color = "#1a1b26da"; # Đuôi da tạo độ kính mờ trong suốt
        text-color = "#a9b1d6";
        border-size = 2;
        border-color = "#7aa2f7";
        border-radius = 12;
        shadow-color = "#00000000";
        icon-path = "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark";
      };
      
      # Cấu hình khẩn cấp nâng cao giữ nguyên ngoài rìa settings
     extraConfig = ''
        # Khoảng cách 10px giữa thông báo trên và thông báo dưới
        margin=0,0,10 

        [urgency=high]
        border-color=#f7768e
        text-color=#f7768e
        default-timeout=0
      '';
    };

  programs.fish = {
  enable = true;
};
  programs.starship = {
  enable = true;
  enableFishIntegration = true; # Tự động kích hoạt cho Fish Shell

  # Tùy chỉnh nhẹ cấu hình cho gọn gàng và hiện đại
  settings = {
    add_newline = false; # Không tạo dòng trống mỗi khi gõ lệnh mới
    
    # Định dạng cách hiển thị thư mục
    directory = {
      style = "bold cyan";
      truncate_to_repo = false;
    };

    # Tùy chỉnh ký tự prompt (Đẹp, gọn)
    character = {
      success_symbol = "[❯](bold green) ";
      error_symbol = "[❯](bold red) ";
    };

    # Ẩn bớt mấy cái thông tin rác như phiên bản package nếu bạn không cần
    package.disabled = true;
    nodejs.disabled = true;
    python.disabled = true;
  };
};


programs.man.enable = false;

};
    








  
}
