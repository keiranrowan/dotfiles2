;;; init.el --- Emacs Configuration.                         -*- lexical-binding: t; -*-

;; Copyright (C) 2023

;; Author:  Keiran Rowan
;; Keywords: init config emacs

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This code contains my personalized Emacs configuration.

;;; Code:
(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
(setq gnutls-alogrithm-priority "NORMAL:-VERS-TLS1.3")

(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

(dolist (package '(use-package))
   (unless (package-installed-p package)
     (package-install package)))

(require 'use-package)
(setq use-package-always-ensure t)

;;; Garbage Collector
(use-package gcmh
  :diminish gcmh-mode
  :config
  (setq gcmh-idle-delay 5
        gcmh-high-cons-threshold (* 16 1024 1024))  ; 16mb
  (gcmh-mode 1))

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-percentage 0.1)))

(add-hook 'emacs-startup-hook
          (lambda ()
            (message "Emacs ready in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))

;;; Emacs Configuration
(use-package emacs
  :init
  ;; User Profile
  (setq user-full-name "Keiran Rowan"
        user-mail-address "rowank@collierschools.com")
  ;; General Settings
  (setq inhibit-startup-screen t
        initial-scratch-message nil
        sentence-end-double-space nil
        ring-bell-function 'ignore
        frame-resize-pixelwise t)
  (setq use-short-answers t)
  (setq confirm-kill-emacs 'yes-or-no-p)
  (setq-default tab-width 4)
  (setq-default fill-column 80)
  (setq line-move-visual t)
  (when (window-system)
    (tool-bar-mode 0)
    (menu-bar-mode 0))
  (global-display-line-numbers-mode)
  (setq indent-tabs-mode 'nil)
  (setq read-process-output-max (* 1024 1024))
  (delete-selection-mode t)
  (recentf-mode)
  (setq custom-safe-themes t)
  (winner-mode t)
  ;; Zoom
  (global-set-key (kbd "C-=") 'text-scale-increase)
  (global-set-key (kbd "C--") 'text-scale-decrease)
  ;; Unicode
  (set-charset-priority 'unicode)
  (setq locale-coding-system 'utf-8
        coding-system-for-read 'utf-8
        coding-system-for-write 'utf-8)
  (set-terminal-coding-system 'utf-8)
  (set-keyboard-coding-system 'utf-8)
  (set-selection-coding-system 'utf-8)
  (prefer-coding-system 'utf-8)
  (setq default-process-coding-system '(utf-8-unix . utf-8-unix))
  ;;; File Backups
  (setq create-lockfiles nil
        make-backup-files nil
        version-control t     ; number each backup file
        backup-by-copying t   ; instead of renaming current file (clobbers links)
        delete-old-versions t ; clean up after itself
        kept-old-versions 5
        kept-new-versions 5
        backup-directory-alist (list (cons "." (concat user-emacs-directory ".backup/"))))
  ;;; Theme
  (mapc #'disable-theme custom-enabled-themes)
  (load-theme 'spacemacs-light t)
  ;;; Trash
  (setq trash-directory "~/.trash")
  (setq delete-by-moving-to-trash t)
  ;;; Font
  (set-frame-font "Monoid-10:antialias=none:spacing=m" nil t))
  
;;; Editor Config
(use-package editorconfig
  :config
  (editorconfig-mode 1))

;;; Centered Cursor Mode
(use-package centered-cursor-mode
  :config
  (global-centered-cursor-mode))

;;; Which Key
(use-package which-key
  :diminish which-key-mode
  :init
  (which-key-mode)
  (which-key-setup-minibuffer)
  :config
  (setq which-key-idle-delay 0.3)
  (setq which-key-sort-order 'which-key-key-order-alpha
        which-key-min-display-lines 3
        which-key-max-display-columns nil))

;;; Tabspaces
(use-package tabspaces
  :hook (after-init . tabspaces-mode)
  :commands (tabspaces-switch-or-create-workspaces
	     tabspaces-open-or-create-project-and-workspace)
  :custom
  (tabspaces-use-filtered-buffers-as-default t)
  (tabspaces-default-tab "Default")
  (tabspaces-remove-to-default t)
  (tabspaces-include-buffers '("*scratch*"))
  (tabspaces-session t)
  (tabspaces-session-auto-restore t))

;;; Company
(use-package company
  :config
  (setq company-idle-delay
	(lambda () (if (company-in-string-or-comment) nil 0.3)))
  (setq company-require-match nil)
  (setq company-frontends '(company-pseudo-tooltip-unless-just-one-frontend-with-delay
			    company-preview-frontend
			    company-echo-metadata-frontend))
  (setq company-backends '(company-capf
			   company-dabbrev-code
			   company-keywords))
  (setq company-tooltip-align-annotations t)
  (setq company-tooltip-limit 5)
  (setq company-tooltip-flip-when-above t)
  (setq company-files-exclusions '(".git/"))
  (global-company-mode 1))

(global-set-key (kbd "<backtab>")
		(lambda ()
		  (interactive)
		  (let ((company-tooltip-idle-delay 0.0))
		    (company-complete)
		    (and company-candidates
			 (company-call-frontends 'post-command)))))

;;; Flycheck
(use-package flycheck
  :init (global-flycheck-mode))

;;; Web Mode
(use-package web-mode
  :config
  (add-to-list 'auto-mode-alist '("\\.html?\\'"))
  (setq web-mode-code-indent-offset 4)
  (setq web-mode-markup-indent-offset 4)
  (setq web-mode-css-indent-offset 4)
  (setq web-mode-enable-css-colorization t)
  (setq web-mode-enable-heredoc-fontification t)
  (setq web-mode-enable-current-column-highlight t)
  (setq web-mode-enable-current-column-highlight t)
  (setq web-mode-engines-alist
	'(("django" . "\\.html.twig\\'")
	  ("go" . "\\.tmpl\\'")
	  ("lsp" . "\\.lsp\\'"))))

;;; JS Mode
(use-package js2-mode
  :config
  (add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
  (add-to-list 'auto-mode-alist '("\\.jsx?\\'" . js2-jsx-mode))
  (add-to-list 'interpreter-mode-alist '("node" . js2-jsx-mode)))

;;; PHP Mode
(use-package php-mode
  :config
  (add-to-list 'auto-mode-alist '("\\.php\\'" . php-mode)))

;;; Haskell Mode
(use-package haskell-mode)

;;; JSON Mode
(use-package json-mode)

;;; YAML Mode
(use-package yaml-mode)

;;; TOML Mode
(use-package toml-mode)

;;; LSP Mode
(use-package lsp-mode
  :init
  (setq lsp-keymap-prefix "C-c l")
  :hook
  ((php-mode . lsp)
   (js2-mode . lsp)
   (lsp-mode . lsp-enable-which-key-integration))
  :commands lsp)
(use-package lsp-ui
  :hook
  (lsp-mode .lsp-ui-mode)
  :commands lsp-ui-mode)
(use-package lsp-ivy
  :commands lsp-ivy-workspace-symbol)
(use-package dap-mode)

;;; Ivy
(use-package ivy
  :diminish ivy-mode
  :config
  (setq ivy-initial-inputs-alist nil)
  (setq ivy-use-virtual-buffers t)
  (setq enable-recursive-minibuffers t)
  (setq-default ivy-height 10)
  (ivy-mode 1))
(use-package ivy-rich
  :after ivy
  :init
  (setq ivy-rich-path-style 'abbrev)
  (setcdr (assq t ivy-format-functions-alist) #'ivy-format-function-line)
  :config
  (ivy-rich-mode 1))

;;; Counsel
(use-package counsel
  :config
  (counsel-mode 1)
  (global-set-key (kbd "M-x") 'counsel-M-x)
  (global-set-key (kbd "C-x C-f") 'counsel-find-file)
  (global-set-key (kbd "C-x b") 'counsel-buffer-or-recentf)
  (global-set-key (kbd "<f1> f") 'counsel-describe-function)
  (global-set-key (kbd "<f1> v") 'counsel-describe-variable)
  (global-set-key (kbd "<f1> o") 'counsel-describe-symbol)
  (global-set-key (kbd "<f1> l") 'counsel-find-library)
  (global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol)
  (global-set-key (kbd "<f2> u") 'counsel-unicode-char)
  (global-set-key (kbd "C-x l") 'counsel-locate)
  (global-set-key (kbd "C-S-o") 'counsel-rhythmbox)
  (define-key minibuffer-local-map (kbd "C-r") 'counsel-minibuffer-history))

;;; Swiper
(use-package swiper
  :config
  (global-set-key "\C-s" 'swiper)
  (global-set-key (kbd "C-c C-r") 'ivy-resume)
  (global-set-key (kbd "<f6>") 'ivy-resume))

;;; Magit
(use-package magit)

;;; Org Mode
(use-package org
  :pin gnu)


;;; General (Keybindings)
(use-package general
  :config
  (general-override-mode 1)
  (general-override-local-mode 1)
  (general-create-definer my-leader-def
	:prefix "C-c")
  (my-leader-def
	;; Top level functions
	"." '(counsel-find-file :wk "find file")

	;; Applications
	"a" '(nil :wk "apps")
	"ao" '(org-agenda :wk "org-agenda")
	"am" '(mu4e :wk "mu4e")
	"ac" '(calc :wk "calc")
	"ag" '(nil :wk "games")
	"ag5" '(5x5 :wk "5x5")
	"agb" '(black-box :wk "blackbox")
	"agB" '(bubbles :wk "bubbles")
	"agd" '(doctor :wk "doctor")
	"agf" '(fortune :wk "fortune")
	"agg" '(gomoku :wk "gomoku")
	"agh" '(hanoi :wk "tower of hanoi")
	"agl" '(life :wk "game of life")
	"agp" '(pong :wk "pong")
	"ags" '(snake :wk "snake")
	"agt" '(tetris :wk "tetris")
	;; Buffers
	"b" '(nil :wk "buffer")
	"bb" '(counsel-switch-buffer :wk "switch buffers")
	"bd" '(kill-buffer :wk "delete buffer")
	"br" '(revert-buffer :wk "revert buffer")
    ;; DAP Mode
    "d" '(nil :wk "dap")
    "dd" '(dap-debug :wk "debug")
    "db" '(dap-breakpoint-toggle :wk "breakpoint toggle")
    "dB" '(dap-breakpoints-list :wk "breakpoint list")
    "dc" '(dap-continue :wk "continue")
    "dn" '(dap-next :wk "next")
    "de" '(dap-eval-thing-at-point :wk "eval")
    "di" '(dap-step-in :wk "step in")
    "dl" '(dap-debug-last :wk "step in")
    "dq" '(dap-disconnect :wk "quit")
    "dr" '(dap-ui-repl :wk "repl")
    "dh" '(dap-hydra :wk "hydra")
	;; Files
	"f" '(nil :wk "files")
	"fb" '(counsel-bookmark :wk "bookmarks")
    "fd" '((lambda () (interactive) (delete-file (buffer-file-name))) :wk "delete file")
	"ff" '(counsel-find-file :wk "find file")
	"fr" '(counsel-recentf :wk "recent files")
	"fR" '(rename-file :wk "rename file")
	"fs" '(save-buffer :wk "save file")
	;; Git
	"g" '(nil :wk "git")
    "gs" '(magit-status :wk "git status")
	;; Help
	"h" '(nil :wk "help")
    "he" '(view-echo-area-messages :wk "view output")
	"hv" '(counsel-describe-variable :wk "describe variable")
	"hb" '(counsel-descbinds :wk "describe keybinds")
	"hM" '(describe-mode :wk "describe mode")
	"hf" '(counsel-describe-function :wk "describe function")
	"hF" '(counsel-describe-face :wk "describe face")
	"hk" '(describe-key :wk "describe key")
    "hK" '(describe-keymap :wk "describe keymap")
    "hl" '(view-lossage :wk "view lossage")
    "hL" '(find-library :wk "find library")
    "hp" '(describe-package :wk "describe package")
    ;; LSP Mode
    "l" '(nil :wk "lsp")
    "li" '(lsp-organize-imports :wk "optimize")
    "la" '(lsp-execute-code-action :wk "code action")
    "lf" '(lsp-find-references :wk "find references")
    "lr" '(lsp-rename :wk "rename")
    "ld" '(lsp-describe-thing-at-point :wk "describe")
    ;; Org Mode
    "o" '(nil :wk "org")
    ;; Projectile
    "p" '(nil :wk "projectile")
    ;; Search
    "s" '(nil :wk "search")
	;; Toggles
	"t" '(nil :wk "toggles")
	"tt" '(toggle-truncate-lines :wk "truncate lines")
	"tv" '(visual-line-mode :wk "visual line mode")
	"tn" '(display-line-numbers-mode :wk "display line numbers")
	"ta" '(mixed-pitch-mode :wk "variable pitch mode")
	"ty" '(counsel-load-theme :wk "load theme")
	"tR" '(read-only-mode :wk "read only mode")
	"tI" '(toggle-input-method :wk "toggle input method")
	"tr" '(display-fill-column-indicator-mode :wk "fill column indicator")
	;; Window
    "w" '(nil :wk "window")
    "wl" '(windmove-right :wk "move right")
    "wh" '(windmove-left :wk "move left")
    "wk" '(windmove-up :wk "move up")
    "wj" '(windmove-down :wk "move down")
    "wr" '(winner-redo :wk "redo")
    "wd" '(delete-window :wk "delete")
    "w=" '(balance-windows-area :wk "balance")
    "wD" '(kill-buffer-and-window :wk "kill buffer and window")
    "wu" '(winner-undo :wk "undo")
    "wr" '(winner-redo :wk "redo")
    "wm" '(delete-other-windows :wk "maximize")
    
	"z" '(nil :wk "system")
	"!" '(nil :wk "commands")
	))
;;; Zone Mode
(use-package zone
  :config
  (zone-when-idle 120))
  
  
(provide 'init)
;;; init.el ends here
