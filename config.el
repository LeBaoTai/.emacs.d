(defvar elpaca-installer-version 0.5)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
			:ref nil
			:files (:defaults (:exclude "extensions"))
			:build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
 (build (expand-file-name "elpaca/" elpaca-builds-directory))
 (order (cdr elpaca-order))
 (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (< emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
  (if-let ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
	   ((zerop (call-process "git" nil buffer t "clone"
				 (plist-get order :repo) repo)))
	   ((zerop (call-process "git" nil buffer t "checkout"
				 (or (plist-get order :ref) "--"))))
	   (emacs (concat invocation-directory invocation-name))
	   ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
				 "--eval" "(byte-recompile-directory \".\" 0 'force)")))
	   ((require 'elpaca))
	   ((elpaca-generate-autoloads "elpaca" repo)))
      (kill-buffer buffer)
    (error "%s" (with-current-buffer buffer (buffer-string))))
((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (load "./elpaca-autoloads")))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; Install use-package support
(elpaca elpaca-use-package
  ;; Enable :elpaca use-package keyword.
  (elpaca-use-package-mode)
  ;; Assume :elpaca t unless otherwise specified.
  (setq elpaca-use-package-by-default t))

;; Block until current queue processed.
(elpaca-wait)

;;When installing a package which modifies a form used at the top-level
;;(e.g. a package which adds a use-package key word),
;;use `elpaca-wait' to block until that package has been installed/configured.
;;;For example:
;;(use-package general :demand t)
;;(elpaca-wait)

;;Turns off elpaca-use-package-mode current declartion
;;Note this will cause the declaration to be interpreted immediately (not deferred).
;;Useful for configuring built-in emacs features.
;;(use-package emacs :elpaca nil :config (setq ring-bell-function #'ignore))

;; Don't install anything. Defer execution of BODY
;;(elpaca nil (message "deferred"))

;; Expands to: (elpaca evil (use-package evil :demand t))
(use-package evil
    :init      ;; tweak evil's configuration before loading it
    (setq evil-want-integration t) ;; This is optional since it's already set to t by default.
    (setq evil-want-keybinding nil)
    (setq evil-vsplit-window-right t)
    (setq evil-split-window-below t)
    (setq evil-insert-state-cursor '((bar . 2) "orange")
          evil-normal-state-cursor '(box "orange"))
    (setq evil-normal-state-tag   (propertize "[Normal]" 'face '((:background "#EF7C8E" :foreground "black")))
        evil-emacs-state-tag    (propertize "[Emacs]" 'face '((:background "#DDFFE7" :foreground "black")))
        evil-insert-state-tag   (propertize "[Insert]" 'face '((:background "#29A0B1") :foreground "#1E3551"))
        evil-motion-state-tag   (propertize "[Motion]" 'face '((:background "#003060") :foreground "white"))
        evil-visual-state-tag   (propertize "[Visual]" 'face '((:background "#887BB0" :foreground "black")))
        evil-operator-state-tag (propertize "[Operator]" 'face '((:background "yellow") :foreground "#1E3551")))

    (evil-mode))

  (use-package evil-collection
    :after evil
    :config
    (setq evil-collection-mode-list '(dashboard dired ibuffer))
    (evil-collection-init))
  (use-package evil-tutor)

(use-package general
  :config
  (general-evil-setup)

  ;; set up 'SPC' as the global leader key
  (general-create-definer lbt/leader-keys
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix "SPC" ;; set leader
    :global-prefix "C-SPC") ;; access leader in insert mode

  (general-create-definer lbt/major-leader-keys
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix "|"
    :global-prefix "M-,")

  (lbt/leader-keys
    "SPC" '(counsel-M-x :wk "Counsel M-x")
    "f f" '(find-file :wk "Find file")
    "f c" '((lambda () (interactive) (find-file "~/.emacs.d/config.org")) :wk "Edit emacs config")
    "f r" '(counsel-recentf :wk "Find recent files")
    "/" '(comment-line :wk "Comment lines"))

  (lbt/leader-keys
    "m" '(:ignore t :wk "Org")
    "m a" '(org-agenda :wk "Org agenda")
    "m e" '(org-export-dispatch :wk "Org export dispatch")
    "m i" '(org-toggle-item :wk "Org toggle item")
    "m t" '(org-todo :wk "Org todo")
    "m B" '(org-babel-tangle :wk "Org babel tangle")
    "m T" '(org-todo-list :wk "Org todo list"))

  (lbt/leader-keys
    "m b" '(:ignore t :wk "Tables")
    "m b -" '(org-table-insert-hline :wk "Insert hline in table"))

  (lbt/leader-keys
    "m d" '(:ignore t :wk "Date/deadline")
    "m d t" '(org-time-stamp :wk "Org time stamp"))

  (lbt/leader-keys
    ;; buffer
    "b" '(:ignore t :wk "buffer")
    "b b" '(switch-to-buffer :wk "Switch buffer")
    "b i" '(ibuffer :wk "Ibuffer")
    "b k" '(kill-this-buffer :wk "Kill this buffer")
    "b n" '(next-buffer :wk "Next buffer")
    "b p" '(previous-buffer :wk "Previous buffer")
    "b r" '(revert-buffer :wk "Reload buffer")
    "b s" '(save-buffer :wk "Save buffer"))

  (lbt/leader-keys
    ;; Evaluate
    "e" '(:ignore t :wk "Eshell/Evaluate")    
    "e b" '(eval-buffer :wk "Evaluate elisp in buffer")
    "e d" '(eval-defun :wk "Evaluate defun containing or after point")
    "e e" '(eval-expression :wk "Evaluate and elisp expression")
    "e h" '(counsel-esh-history :which-key "Eshell history")
    "e l" '(eval-last-sexp :wk "Evaluate elisp expression before point")
    "e r" '(eval-region :wk "Evaluate elisp in region")
    "e s" '(eshell :which-key "Eshell"))

 (lbt/leader-keys
    "h" '(:ignore t :wk "Help")
    "h f" '(describe-function :wk "Describe function")
    "h v" '(describe-variable :wk "Describe variable")
    ;;"h r r" '((lambda () (interactive) (load-file "~/.config/emacs/init.el")) :wk "Reload emacs config"))
    "h r r" '(reload-init-file :wk "Reload emacs config"))

  (lbt/leader-keys
    "t" '(:ignore t :wk "Toggle")
    "t l" '(display-line-numbers-mode :wk "Toggle line numbers")
    "t t" '(treemacs :wk "Toggle treemacs")
    "t v" '(vterm-toggle :wk "Toggle vterm"))

  (lbt/leader-keys
    "w" '(:ignore t :wk "Windows")
    ;; Window splits
    "w c" '(evil-window-delete :wk "Close window")
    "w n" '(evil-window-new :wk "New window")
    "w s" '(evil-window-split :wk "Horizontal split window")
    "w v" '(evil-window-vsplit :wk "Vertical split window")
    ;; Window motions
    "w h" '(evil-window-left :wk "Window left")
    "w j" '(evil-window-down :wk "Window down")
    "w k" '(evil-window-up :wk "Window up")
    "w l" '(evil-window-right :wk "Window right")
    "w w" '(evil-window-next :wk "Goto next window")
    ;; Move Windows
    "w H" '(buf-move-left :wk "Buffer move left")
    "w J" '(buf-move-down :wk "Buffer move down")
    "w K" '(buf-move-up :wk "Buffer move up")
    "w L" '(buf-move-right :wk "Buffer move right"))

  
  (lbt/leader-keys
    "l" '(:ignore t :wk "LSP")
    "l r" '(lsp-workspace-restart :wk "LSP restart")
    ;; ui
    "l d" '(lsp-ui-doc-toggle :wk "Toggle doc frame")
    "l f" '(lsp-ui-flycheck-list :wk "Open fly check list")
    ;; tremacs
    "l s" '(lsp-treemacs-symbols :wk "Open treemacs symbol")
    "l e" '(lsp-treemacs-errors-list :wk "Open treemacs errors list"))

  (lbt/leader-keys
    "p" '(:ignore t :wk "Projectile")
    ;; projectile
    "p s" '(projectile-save-project-buffers :wk "Save all buffers in project")
    "p f" '(projectile--find-file :wk "Find file in project")
    "p r" '(projectile-remove-known-project :wk "Remove know project")
    "p a" '(projectile-add-known-project :wk "Add know project")
    "p k" '(projectile-kill-buffers :wk "Kill all buffers")
    "p s" '(projectile-switch-project :wk "Switch project")

    ;; popwin
    "p v" '(+popwin:vterm :wk "Popup terminal"))

  (lbt/major-leader-keys
    ;; treemacs mode
    "r f" '(treemacs-rename-file :wk "Treemacs rename file")
    "r w" '(treemacs-rename-workspace :wk "Treemacs rename workspace")
    "r p" '(treemacs-rename-project :wk "Treemacs rename project")
    "r P" '(treemacs-remove-project-from-workspace :wk "Remove project from workspace")
    "r m" '(treemacs-reset-marks :wk "Reset marked file(remove mark)")

    "a p" '(treemacs-add-project-to-workspace :wk "Add project to workspace")
    "a f" '(treemacs-create-file :wk "Add file")
    "a m" '(treemacs-mark-or-unmark-path-at-point :wk "Add or remove mark")

    "d f" '(treemacs-delete-file :wk "Delete file")
    "d m" '(treemacs-delete-marked-files :wk "Delete all marked file")

    "m f" '(treemacs-move-file :wk "Move file")
    "m m" '(treemacs-move-marked-files :wk "Move all marked files")
    "m p" '(treemacs-move-marked-paths :wk "Move all marked paths")

    "s d" '(treemacs-select-directory :wk "Select directory"))
  )

(add-to-list 'load-path "~/.emacs.d/lisp/")

(use-package all-the-icons
:ensure t
:if (display-graphic-p))

(use-package all-the-icons-dired
:hook (dired-mode . (lambda () (all-the-icons-dired-mode t))))

(require 'windmove)

;;;###autoload
(defun buf-move-up ()
"Swap the current buffer and the buffer above the split.
If there is no split, ie now window above the current one, an
error is signaled."
;;  "Switches between the current buffer, and the buffer above the
;;  split, if possible."
(interactive)
(let* ((other-win (windmove-find-other-window 'up))
(buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No window above this one")
    ;; swap top with this one
    (set-window-buffer (selected-window) (window-buffer other-win))
    ;; move this one to top
    (set-window-buffer other-win buf-this-buf)
    (select-window other-win))))

;;;###autoload
(defun buf-move-down ()
"Swap the current buffer and the buffer under the split.
If there is no split, ie now window under the current one, an
error is signaled."
(interactive)
(let* ((other-win (windmove-find-other-window 'down))
(buf-this-buf (window-buffer (selected-window))))
    (if (or (null other-win) 
            (string-match "^ \\*Minibuf" (buffer-name (window-buffer other-win))))
        (error "No window under this one")
    ;; swap top with this one
    (set-window-buffer (selected-window) (window-buffer other-win))
    ;; move this one to top
    (set-window-buffer other-win buf-this-buf)
    (select-window other-win))))

;;;###autoload
(defun buf-move-left ()
"Swap the current buffer and the buffer on the left of the split.
If there is no split, ie now window on the left of the current
one, an error is signaled."
(interactive)
(let* ((other-win (windmove-find-other-window 'left))
(buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No left split")
    ;; swap top with this one
    (set-window-buffer (selected-window) (window-buffer other-win))
    ;; move this one to top
    (set-window-buffer other-win buf-this-buf)
    (select-window other-win))))

;;;###autoload
(defun buf-move-right ()
"Swap the current buffer and the buffer on the right of the split.
If there is no split, ie now window on the right of the current
one, an error is signaled."
(interactive)
(let* ((other-win (windmove-find-other-window 'right))
(buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No right split")
    ;; swap top with this one
    (set-window-buffer (selected-window) (window-buffer other-win))
    ;; move this one to top
    (set-window-buffer other-win buf-this-buf)
    (select-window other-win))))

(set-face-attribute 'default nil
  :font "JetBrains Mono"
  :height 115
  :weight 'medium)
(set-face-attribute 'variable-pitch nil
  :font "SpaceMono Nerd Font"
  :height 120
  :weight 'medium)
(set-face-attribute 'fixed-pitch nil
  :font "JetBrains Mono"
  :height 115
  :weight 'medium)
;; Makes commented text and keywords italics.
;; This is working in emacsclient but not emacs.
;; Your font must have an italic face available.
(set-face-attribute 'font-lock-comment-face nil
  :slant 'italic)
(set-face-attribute 'font-lock-keyword-face nil
  :slant 'italic)

;; This sets the default font on all graphical frames created after restarting Emacs.
;; Does the same thing as 'set-face-attribute default' above, but emacsclient fonts
;; are not right unless I also add this method of setting the default font.
(add-to-list 'default-frame-alist '(font . "JetBrains Mono-11"))

;; Uncomment the following line if line spacing needs adjusting.
(setq-default line-spacing 0.12)

(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "<C-wheel-up>") 'text-scale-increase)
(global-set-key (kbd "<C-wheel-down>") 'text-scale-decrease)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(global-visual-line-mode t)
(column-number-mode)
;; Enable line numbers for some modes
(dolist (mode '(text-mode-hook
                prog-mode-hook
                conf-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 1))))

;; Override some modes which derive from the above
(dolist (mode '(org-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(use-package counsel
:after ivy
:config (counsel-mode))

(use-package ivy
:bind
;; ivy-resume resumes the last Ivy-based completion.
(("C-c C-r" . ivy-resume)
("C-x B" . ivy-switch-buffer-other-window))
:custom
(setq ivy-use-virtual-buffers t)
(setq ivy-count-format "(%d/%d) ")
(setq enable-recursive-minibuffers t)
:config
(ivy-mode))

(use-package all-the-icons-ivy-rich
:ensure t
:init (all-the-icons-ivy-rich-mode 1))

(use-package ivy-rich
:after ivy
:ensure t
:init (ivy-rich-mode 1) ;; this gets us descriptions in M-x.
:custom
(ivy-virtual-abbreviate 'full
ivy-rich-switch-buffer-align-virtual-buffer t
ivy-rich-path-style 'abbrev))

(use-package projectile
:ensure t
:init
(projectile-mode))



(use-package toc-org
    :commands toc-org-enable
    :init (add-hook 'org-mode-hook 'toc-org-enable))

(add-hook 'org-mode-hook 'org-indent-mode)
(use-package org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

(electric-indent-mode -1)
(setq org-edit-src-content-indentation 0)

(eval-after-load 'org-indent '(diminish 'org-indent-mode))

(require 'org-tempo)

(use-package rainbow-delimiters
:defer t
:hook (prog-mode . rainbow-delimiters-mode))

(use-package info-colors
:commands info-colors-fnontify-node
:hook (Info-selection . info-colors-fontify-node)
:hook (Info-mode      . mixed-pitch-mode))

(defun reload-init-file ()
  (interactive)
  (load-file user-init-file)
  (load-file user-init-file))

(use-package popwin
:ensure t
:init (popwin-mode))

(use-package eshell-syntax-highlighting
:after esh-mode
:config
(eshell-syntax-highlighting-global-mode +1))

;; eshell-syntax-highlighting -- adds fish/zsh-like syntax highlighting.
;; eshell-rc-script -- your profile for eshell; like a bashrc for eshell.
;; eshell-aliases-file -- sets an aliases file for the eshell.

(setq eshell-rc-script (concat user-emacs-directory "eshell/profile")
    eshell-aliases-file (concat user-emacs-directory "eshell/aliases")
    eshell-history-size 5000
    eshell-buffer-maximum-lines 5000
    eshell-hist-ignoredups t
    eshell-scroll-to-bottom-on-input t
    eshell-destroy-buffer-when-process-dies t
    eshell-visual-commands'("bash" "fish" "htop" "ssh" "top" "zsh"))

(use-package vterm
:config
(setq term-prompt-regexp "^[^#$%>\n]*[#$%>] *")  ;; Set this to match your custom shell prompt
(setq vterm-shell "zsh")                       ;; Set this to customize the shell to launch
(setq vterm-max-scrollback 10000)
(with-eval-after-load 'popwin
    (defun +popwin:vterm ()
    (interactive)
    (popwin:display-buffer-1
    (or (get-buffer "*vterm*")
        (save-window-excursion
            (call-interactively 'vterm)))
    :default-config-keywords '(:position :bottom :height 16)))))

(use-package vterm-toggle
:after vterm
:config
(setq vterm-toggle-fullscreen-p nil)
(setq vterm-toggle-scope 'project)
(add-to-list 'display-buffer-alist
            '((lambda (buffer-or-name _)
                    (let ((buffer (get-buffer buffer-or-name)))
                    (with-current-buffer buffer
                        (or (equal major-mode 'vterm-mode)
                            (string-prefix-p vterm-buffer-name (buffer-name buffer))))))
                (display-buffer-reuse-window display-buffer-same-window)
                ;; (display-buffer-reuse-window display-buffer-in-direction)
                ;; display-buffer-in-direction/direction/dedicated is added in emacs27
                ;; (direction . side)
                ;;(dedicated . t) ;dedicated is supported in emacs27
                (reusable-frames . visible)
                (window-height . 0.3))))

(use-package sudo-edit
  :config
    (lbt/leader-keys
      "fu" '(sudo-edit-find-file :wk "Sudo find file")
      "fU" '(sudo-edit :wk "Sudo edit file")))

(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")
(load-theme 'aurora t)

(use-package moody
:config
(setq x-underline-at-descent-line t)
(moody-replace-mode-line-buffer-identification)
(moody-replace-vc-mode))

(use-package minions
:config
(setq minions-mode-line-lighter ""
        minions-mode-line-delimiters '("" . ""))
(minions-mode 1))

(use-package rustic
;; uncomment for less flashiness
;; (setq lsp-eldoc-hook nil)
;; (setq lsp-enable-symbol-highlighting nil)
;; (setq lsp-signature-auto-activate nil)
:hook (rustic-mode-local-vars . rustic-setup-lsp)
:hook (rustic-mode . lsp-deferred)
:config
(setq   rustic-babel-format-src-block nil
        rustic-format-trigger         nil
        rustic-format-on-save         t)
:init
(add-hook 'rustic-mode-hook 'rk/rustic-mode-hook)
(add-hook 'rustic-mode-hook
        (lambda ()
            (setq indent-tabs-mode nil)
            (setq tab-width 2)
            (setq rust-indent-offset 2))))
(defun rk/rustic-mode-hook ()
;; so that run C-c C-c C-r works without having to confirm, but don't try to
;; save rust buffers that are not file visiting. Once
;; https://github.com/brotzeit/rustic/issues/253 has been resolved this should
;; no longer be necessary.
(when buffer-file-name
    (setq-local buffer-save-without-query t))
(add-hook 'before-save-hook 'lsp-format-buffer nil t))

;; rustfmt
(setq rustic-lsp-server 'rust-analyzer)

(use-package prettier-js
:defer t
:after (rjsx-mode web-mode typescript-mode)
:hook (rjsx-mode . prettier-js-mode)
:hook (js-mode . prettier-js-mode)
:hook (typescript-mode . prettier-js-mode)
:config
(setq prettier-js-args '("--trailing-comma" "all" "--bracket-spacing" "true")))

(use-package typescript-mode
:defer t
:hook (typescript-mode     . rainbow-delimiters-mode)
:hook (typescript-mode     . lsp-deferred)
:hook (typescript-mode     . prettier-js-mode)
:hook (typescript-tsx-mode . rainbow-delimiters-mode)
:hook (typescript-tsx-mode . lsp-deferred)
:hook (typescript-tsx-mode . prettier-js-mode)
:hook (typescript-tsx-mode . eglot-ensure)
:commands typescript-tsx-mode
:after flycheck
:init
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . typescript-tsx-mode))
(add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-mode))
:config
(setq typescript-indent-level 2)
(with-eval-after-load 'flycheck
    (flycheck-add-mode 'javascript-eslint 'web-mode)
    (flycheck-add-mode 'javascript-eslint 'typescript-mode)
    (flycheck-add-mode 'javascript-eslint 'typescript-tsx-mode)
    (flycheck-add-mode 'typescript-tslint 'typescript-tsx-mode))
(when (fboundp 'web-mode)
    (define-derived-mode typescript-tsx-mode web-mode "TypeScript-TSX"))
(autoload 'js2-line-break "js2-mode" nil t))

(add-to-list 'load-path "~/.emacs.d/lisp/smartparens")
(use-package smartparens
:defer t
:hook (prog-mode . smartparens-mode))

(use-package flycheck
  :ensure t)

(use-package lsp-mode
    :init
    ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
    (setq lsp-keymap-prefix "C-c l")
    :hook (;; replace XXX-mode with concrete major-mode(e. g. python-mode)
            (rustic-mode  . lsp-deferred)
            (c++-mode  . lsp-deferred)
            (typescript-mode . lsp-deferred)
            ;; if you want which-key integration
            (lsp-mode . lsp-enable-which-key-integration)
            (lsp-mode . lsp-ui-mode))
    :commands (lsp lsp-deferred)
    :custom
    ;; what to use when checking on-save. "check" is default, I prefer clippy
    (lsp-eldoc-render-all t)
    (lsp-eldoc-enable-hover nil)
    (lsp-idle-delay 0.5)
    ;; enable / disable the hints as you prefer:
    (lsp-inlay-hint-enable t)
    ;; These are optional configurations. See https://emacs-lsp.github.io/lsp-mode/page/lsp-rust-analyzer/#lsp-rust-analyzer-display-chaining-hints for a full list

    ;; RUST
    (lsp-rust-analyzer-display-lifetime-elision-hints-enable "skip_trivial")
    (lsp-rust-analyzer-cargo-watch-command "clippy")
    (lsp-rust-analyzer-display-lifetime-elision-hints-enable "always")
    (lsp-rust-analyzer-display-chaining-hints t)
    (lsp-rust-analyzer-display-lifetime-elision-hints-use-parameter-names nil)
    (lsp-rust-analyzer-display-closure-return-type-hints t)
    (lsp-rust-analyzer-display-parameter-hints nil)
    (lsp-rust-analyzer-display-reborrow-hints nil)

    ;; TS
    (lsp-javascript-display-return-type-hints t)
    (lsp-javascript-display-variable-type-hints t)
    :config
    (add-hook 'lsp-mode-hook 'lsp-ui-mode))

(use-package lsp-ui 
:commands lsp-ui-mode
:custom
;; side line
(lsp-ui-sideline-show-hover t)
;; peek
(lsp-ui-peek-always-show t)
;; doc
(lsp-ui-doc-enable nil)
(lsp-ui-doc-position 'at-point))

;; auto complete
(use-package company
:ensure
:custom
(company-idle-delay 0.1) ;; how long to wait until popup
(company-minimum-prefix-length 2)
(company-toolsip-limit 14)
(company-tooltip-align-annotations t)
(company-require-match 'never)
    (company-global-modes '(not erc-mode message-mode help-mode gud-mode))
(company-frontends
    '(company-pseudo-tooltip-frontend ; always show candidates in overlay tooltip
      company-echo-metadata-frontend)) ; show selected candidate docs in echo area
(company-backends '(company-capf))
(company-auto-commit nil)
(company-auto-complete-chars nil)
(company-dabbrev-other-buffers nil)
(company-dabbrev-ignore-case nil)
(company-dabbrev-downcase nil); (company-begin-commands nil) ;; uncomment to disable popup
:bind
(:map company-active-map
        ("C-n". company-select-next)
        ("C-p". company-select-previous)
        ("M-<". company-select-first)
        ("M->". company-select-last)))


(use-package yasnippet
:ensure
:config
(yas-reload-all)
(add-hook 'prog-mode-hook 'yas-minor-mode)
(add-hook 'text-mode-hook 'yas-minor-mode))

(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)

(use-package lsp-treemacs :commands lsp-treemacs-errors-list)

(use-package magit
:custom
(magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(use-package which-key
  :init
    (which-key-mode 1)
  :config
  (setq which-key-side-window-location 'bottom
  which-key-sort-order #'which-key-key-order-alpha
  which-key-sort-uppercase-first nil
  which-key-add-column-padding 1
  which-key-max-display-columns nil
  which-key-min-display-lines 6
  which-key-side-window-slot -10
  which-key-side-window-max-height 0.4
  which-key-idle-delay 0.1
  which-key-max-description-length 25
  which-key-allow-imprecise-window-fit nil
  which-key-separator " → " ))
