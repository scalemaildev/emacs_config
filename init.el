;; ----------
;; This is John Conway's Emacs config
;; Started: 12/20/2018
;; Last Update: 07/12/2021
;;
;; WINDOWS SETUP:
;; 1. Run Emacs
;; 2. Pin icon to taskbar
;; 3. Right click icon -> right click Emacs -> properties -> point to runemacs.exe
;; ----------

;; ----------
;; Global Settings
;; ----------
(setq inhibit-startup-message t)

(setq confirm-kill-emacs 'yes-or-no-p)

(setq ns-use-native-fullscreen t)
(set-frame-parameter nil 'fullscreen 'fullboth)

(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(set-fringe-mode 5)
(menu-bar-mode -1)

(setq show-paren-delay 0)
(show-paren-mode 1)

(global-display-line-numbers-mode t)
;; exceptional modes
(dolist (mode '(org-mode-hook
		term-mode-hook
		eshell-mode-hook
		shell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(setq make-backup-files nil)
(setq auto-save-default nil)

(setq ring-bell-function 'ignore) ;; SHUT UP

(add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
(add-to-list 'default-frame-alist '(ns-appearance . dark))
(setq ns-use-proxy-icon  nil)
(setq frame-title-format nil)

(set-face-attribute 'default nil :font "Mononoki" :height 125)

;; ----------
;; Package Management
;; ----------
(require 'package)
(setq package-enable-at-startup nil)
(setq package-archives '(("org"   . "http://orgmode.org/elpa/")
                         ("gnu"   . "http://elpa.gnu.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure 't)

;; --------
;; Theme
;; --------
(use-package doom-themes
  :config
  (load-theme 'doom-nord t))

;; ---------
;; General Packages
;; ---------
;; Helm
(use-package helm
  :init
  (setq helm-M-x-fuzzy-match t
	helm-mode-fuzzy-match t
	helm-buffers-fuzzy-matching t
	helm-recentf-fuzzy-match t
	helm-locate-fuzzy-match t
	helm-semantic-fuzzy-match t
	helm-imenu-fuzzy-match t
	helm-completion-in-region-fuzzy-match t
	helm-candidate-number-list 150
	helm-split-window-inside-p t
	helm-move-to-line-cycle-in-source t
	helm-echo-input-in-header-line t
	helm-autoresize-max-height 0
	helm-autoresize-min-height 20)
  :config
  (helm-mode t))

;; Projectile
(use-package projectile
  :config
  (projectile-mode t))

;; Helm-Projectile
(use-package helm-projectile
  :init
  (setq helm-projectile-fuzzy-match t)
  :config
  (helm-projectile-on))

;; All The Icons
(use-package all-the-icons)
(unless (member "all-the-icons" (font-family-list))
  (all-the-icons-install-fonts t))

;; Magit
(use-package magit
  :bind
  (("C-c m m" . magit)))

;; Flycheck
(use-package flycheck)

;; Beacon
(use-package beacon
  :init
  (beacon-mode t))

;; Company
(use-package company)

;; Dimmer
(use-package dimmer
  :init
  (dimmer-mode))

;; Which Key
(use-package which-key
  :init (which-key-mode)
  :diminish (which-key-mode)
  :config
  (setq which-key-idle-delay 0.3))

;; Spaceline
(use-package spaceline
  :init
  (spaceline-helm-mode))
(use-package spaceline-all-the-icons
  :after spaceline
  :config (spaceline-all-the-icons-theme))

;; Shell-Pop
(use-package shell-pop
  :config
  (defcustom shell-pop-cleanup-buffer-at-process-exit t
  "If non-nil, cleanup the shell's buffer after its process exits.")
  (defun shell-pop--set-exit-action ()
  (if (string= shell-pop-internal-mode "eshell")
      (add-hook 'eshell-exit-hook 'shell-pop--kill-and-delete-window nil t)
    (let ((process (get-buffer-process (current-buffer))))
      (when process
        (set-process-sentinel
         process
         (lambda (_proc change)
           (when (string-match-p "\\(?:finished\\|exited\\)" change)
	     (run-hooks 'shell-pop-process-exit-hook)
             (when shell-pop-cleanup-buffer-at-process-exit
               (kill-buffer))
             (if (one-window-p)
                 (switch-to-buffer shell-pop-last-buffer)
               (delete-window))))))))))
(push (cons "\\*shell\\*" display-buffer--same-window-action) display-buffer-alist)
(global-set-key (read-kbd-macro "C-c t") 'shell-pop)

;; Exec Path From Shell
(use-package exec-path-from-shell)
(when (memq window-system '(mac ns x))
  (exec-path-from-shell-initialize))

;; Rainbow Delimiters
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; ----------
;; Languages
;; ----------
;; 

;; ----------
;; Keybinds (General)
;; ----------
(use-package general
  :config
  (general-define-key
   ;; Buffers
   "C-c v" '(split-window-below :which-key "split buffer down")
   "C-c r" '(split-window-right :which-key "split buffer right")
   "C-c l"  '(helm-buffers-list :which-key "buffers list")
   ;; Windows
   "C-c f" '(windmove-right :which-key "move right")
   "C-c b" '(windmove-left :which-key "move left")
   "C-c p" '(windmove-up :which-key "move up")
   "C-c n" '(windmove-down :which-key "move down")
   "C-c k" '(delete-window :which-key "delete window")
   ;; Goto
   "C-c g" '(goto-line :which-key "goto line")
   ;; Quit
   "<escape>" 'keyboard-escape-quit
   ;; Helm
   "C-c m p r"  '(helm-show-kill-ring :which-key "show kill ring")
   "M-x" 'helm-M-x
   "C-c m f " '(helm-find-files :which-key "helm find files")
   ;; Projectile
   "C-c m p f" '(projectile-find-file :which-key "projectile find file")
   ;; Beacon
   "C-'" '(beacon-blink :which-key "blink beacon")
   ;; General Compiling
   "C-c m c" '(compile :which-key "general compile")
   "C-c m r" '(recompile :which-key "general recompile")
   ))
