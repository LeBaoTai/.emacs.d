(set-language-environment "UTF-8")
(setq default-input-method nil)

(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

(setq package-enable-at-startup nil)
(setq-default tab-width 2)
(setq display-line-numbers-type 'relative
      tab-always-indent nil
      whitespace-action '(cleanup auto-cleanup))

(setq-default fill-column 140
              indent-tabs-mode nil
              display-line-numbers-width 5
              tab-width 2)
(setq frame-inhibit-implied-resize t
    frame-resize-pixelwise t
    frame-title-format nil
    truncate-lines t
    truncate-partial-width-windows t
    package-enable-at-startup nil
    indicate-buffer-boundaries '((bottom . right))
    inhibit-splash-screen t
    inhibit-startup-buffer-menu t
    inhibit-startup-message t
    inhibit-startup-screen t
    inhibit-compacting-font-caches t
    initial-scratch-message nil
    load-prefer-newer noninteractive
    site-run-file nil)

;; UI Tweak
(setq visible-bell nil ;; set to non-nil to flash!
        ring-bell-function 'ignore
        large-file-warning-threshold (* 50 1024 1024) ;; change to 50 MiB
        use-short-answers t ;; y or n istead of yes or no
        confirm-kill-emacs 'y-or-n-p ;; confirm before quitting
        inhibit-startup-message t
        delete-by-moving-to-trash t)
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(fullscreen . maximized) default-frame-alist)
(push '(ns-use-native-fullscreen . t) default-frame-alist)
(push '(ns-transparent-titlebar . t) default-frame-alist)
(push '(vertical-scroll-bars . nil) default-frame-alist)

;;; Backups
;; Disable backup and lockfiles
(setq create-lockfiles nil
      make-backup-files nil
      version-control t ;; number each backup file
      backup-by-copying t ;; copy instead of renaming current file
      delete-old-versions t ;; clean up after itself
      kept-old-versions 5
      kept-new-versions 5
      tramp-backup-directory-alist backup-directory-alist)

;;; Auto-Saving, sessions...
;; Enable auto-save (use `recover-file' or `recover-session' to recover)
(setq auto-save-default t
      auto-save-include-big-deletions t
      auto-save-file-name-transforms
      (list (list "\\`/[^/]*:\\([^/]*/\\)*\\([^/]*\\)\\'"
                  ;; Prefix tramp autosaves to prevent conflicts with local ones
                  (concat auto-save-list-file-prefix "tramp-\\2") t)
            (list ".*" auto-save-list-file-prefix t)))

(setq window-combination-resize t)

;; Highlight current line
(global-hl-line-mode 1)

;; Revert buffer when the underlying file has changed
(global-auto-revert-mode 1)

;; display time
(require 'time)
(setq display-time-format "%Y-%m-%d %H:%M")
(display-time-mode 1) ; display time in modeline

;; Keep customization settings in a temporary file (thanks Ambrevar!)
(setq custom-file
      (if (boundp 'server-socket-dir)
          (expand-file-name "custom.el" server-socket-dir)
        (expand-file-name (format "emacs-custom-%s.el" (user-uid)) temporary-file-directory)))
(load custom-file t)

;; turn off backup file
(setq make-backup-files nil)
