(define-module (cablecar configs)
  #:use-module (gnu services)
  #:use-module (rde packages)
  #:use-module (rde features)
  #:use-module (rde features base)
  #:use-module (rde features wm)
  #:use-module (rde features xdisorg)
  #:use-module (rde features xdg)
  #:use-module (rde features version-control)
  #:use-module (rde features fontutils)
  #:use-module (rde features terminals)
  #:use-module (rde features tmux)
  #:use-module (rde features shells)
  #:use-module (rde features shellutils)
  #:use-module (rde features ssh)
  #:use-module (rde features emacs)
  #:use-module (rde features emacs-xyz)
  #:use-module (rde features linux)
  #:use-module (rde features bittorrent)
  #:use-module (rde features docker)
  #:use-module (rde features video)
  #:use-module (rde features finance)
  #:use-module (rde features markup)
  #:use-module (rde features mail)
  #:use-module (rde features networking)
  #:use-module (gnu services)
  #:use-module (gnu services desktop)
  #:use-module (gnu services sddm)
  #:use-module (gnu system)
  #:use-module (gnu system keyboard)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system mapped-devices)
  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader grub)
  #:use-module (gnu packages)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (rde packages)
  #:use-module (rde packages emacs)
  #:use-module (rde packages emacs-xyz)
  #:use-module (gnu packages fonts)
  #:use-module (guix gexp)
  #:use-module (guix inferior)
  #:use-module (guix channels)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (ice-9 match)
  #:use-module (cablecar configs)
  #:use-module (cablecar utils)
  #:export (%base-features))


(define* %base-features
  (append
   (list
    (feature-custom-services
     #:system-services
     (list
      ;;(service mate-desktop-service-type)
      (service sddm-service-type)))

    (feature-base-services)
    (feature-desktop-services)
    (feature-docker)
    (feature-pipewire)
    (feature-fonts
     #:font-monospace (font "Iosevka" #:size 18 #:weight 'regular)
     #:font-packages (list font-iosevka font-fira-mono))
    (feature-zsh
     #:enable-zsh-autosuggestions? #t)
    (feature-bash)
    (feature-direnv)
    (feature-git)
    (feature-ssh)
    (feature-xdg
     #:xdg-user-directories-configuration
     (home-xdg-user-directories-configuration
      (music "$HOME/music")
      (videos "$HOME/vids")
      (pictures "$HOME/pics")
      (documents "$HOME/docs")
      (download "$HOME/dl")
      (desktop "$HOME")
      (publicshare "$HOME")
      (templates "$HOME")))
    (feature-base-packages
     ;; #:system-packages
     ;; (append
     ;;  (list cablecar-emacs-exwm)
     ;;  (pkgs "emacs-desktop-environment"))
     #:home-packages
     (append
      (pkgs-vanilla
       "icecat" "nyxt"
       "ungoogled-chromium" "ublock-origin-chromium")
      (pkgs
       "arandr"
       "alsa-utils" "youtube-dl" "imv"
       "obs" "obs-wlrobs"
       "recutils"
       "fheroes2"
       "feh"
       "hicolor-icon-theme" "adwaita-icon-theme" "gnome-themes-extra"
       "ripgrep" "curl" "make")))
    (feature-sway
    ;; #:xwayland? #t
    #:extra-config
    `(
      ;; FIXME: Use absolute path, move to feature-network, fix permissions issue
      (exec nm-applet --indicator)
      (bindsym
       --locked $mod+Shift+t exec
       ,(file-append (@ (gnu packages music) playerctl) "/bin/playerctl")
       play-pause)

      (bindsym
       --locked $mod+Shift+n exec
       ,(file-append (@ (gnu packages music) playerctl) "/bin/playerctl")
       next)

      (bindsym $mod+Shift+o move workspace to output left)
      (bindsym $mod+Ctrl+o focus output left)
      (input type:touchpad
             ;; TODO: Move it to feature-sway or feature-mouse?
             (;; (natural_scroll enabled)
              (tap enabled)))
      (bindsym $mod+Shift+Return exec emacs)))
   (feature-sway-run-on-tty
    #:sway-tty-number 2)
   (feature-sway-screenshot)
   ;; (feature-sway-statusbar
   ;;  #:use-global-fonts? #f)
   (feature-waybar
    #:waybar-modules
    (list
     (waybar-sway-workspaces)
     ;; (waybar-sway-window)
     (waybar-tray)
     (waybar-idle-inhibitor)
     ;; (waybar-temperature)
     (waybar-sway-language)
     (waybar-microphone)
     (waybar-volume)
     (waybar-battery #:intense? #f)
     (waybar-clock)))
   (feature-swayidle)
   (feature-swaylock
    #:swaylock (@ (gnu packages wm) swaylock-effects)
    ;; The blur on lock screen is not privacy-friendly.
    #:extra-config '(;; (screenshots)
                     ;; (effect-blur . 7x5)
                     (clock))))
   (feature-emacs-appearance)
   (feature-emacs-faces)
   (feature-emacs-tramp)
   (feature-emacs-completion
    #:mini-frame? #f
    #:marginalia-align 'right)

   (feature-emacs-corfu
    #:corfu-doc-auto #f)
   (feature-emacs-vertico)
   (feature-emacs-project)
   (feature-emacs-perspective)
   (feature-emacs-input-methods)
   (feature-emacs-which-key)
   (feature-emacs-keycast #:turn-on? #f)

   (feature-emacs-dired)
   (feature-emacs-eshell)
   (feature-emacs-monocle)
   (feature-emacs-pdf-tools)
   (feature-emacs-nov-el)

   ;; TODO: Revisit <https://en.wikipedia.org/wiki/Git-annex>
   (feature-emacs-git
    #:project-directory "~/src")
   ;; TODO: <https://www.labri.fr/perso/nrougier/GTD/index.html#table-of-contents>
   (feature-emacs-org
    #:org-directory "~/docs"
    #:org-indent? #f
    #:org-capture-templates
    `(("t" "Todo" entry (file+headline "" "Tasks") ;; org-default-notes-file
       "* TODO %?\nSCHEDULED: %t\n%U\n%a\n" :clock-in t :clock-resume t)))
   (feature-emacs-org-roam
    ;; TODO: Rewrite to states
    #:org-roam-directory "~/docs/notes")
   (feature-emacs-org-agenda
    #:org-agenda-files '("~/docs/todo.org"))
   (feature-emacs-smartparens
    #:show-smartparens? #t)
   (feature-emacs-geiser)
   (feature-emacs-guix)
   (feature-emacs-tempel
    #:default-templates? #t
    #:templates `(fundamental-mode
                  ,#~""
                  (t (format-time-string "%Y-%m-%d"))))

   (feature-emacs
    #:default-application-launcher? #t
    #:additional-elisp-packages
    (append
     (list emacs-dirvish)
     (strings->packages
      "emacs-elfeed" "emacs-hl-todo"
      "emacs-yasnippet"
      ;; "emacs-company"
      "emacs-consult-dir"
      ;; "emacs-all-the-icons-completion" "emacs-all-the-icons-dired"
      "emacs-kind-icon"
      "emacs-nginx-mode" "emacs-yaml-mode"
      ;; "emacs-lispy"
      "emacs-ytdl"
      "emacs-multitran"
      "emacs-minimap"
      "emacs-ement"
      "emacs-restart-emacs"
      "emacs-org-present")))
   ))
