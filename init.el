;;; init.el --- Load the full configuration -*- lexical-binding: t -*-
;;; Commentary:

;; This file bootstraps the configuration, which is divided into
;; a number of other files.

;;; Code:

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
(defconst *spell-check-support-enable* nil)
(electric-pair-mode t)
(add-hook 'prog-mode-hook #'show-paren-mode)
(column-number-mode t)
(global-auto-revert-mode t)
(delete-selection-mode t)
(setq inhibit-startup-message t)
(setq make-backup-files nil)
(add-hook 'prog-mode-hook #'hs-minor-mode)
(global-display-line-numbers-mode 1)
(when (display-graphic-p) (toggle-scroll-bar -1))
(setq display-line-numbers-type 'relative)
(add-to-list 'default-frame-alist '(width . 90))
(add-to-list 'default-frame-alist '(height . 55))
(global-set-key (kbd "RET") 'newline-and-indent)
;;; Adjust garbage collection thresholds during startup, and thereafter

(let ((normal-gc-cons-threshold (* 20 1024 1024))
   (init-gc-cons-threshold (* 128 1024 1024)))
 (setq gc-cons-threshold init-gc-cons-threshold)
 (add-hook 'emacs-startup-hook
      (lambda () (setq gc-cons-threshold normal-gc-cons-threshold))))

;;;miror list

(require 'package)
(add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/") t)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;;;glpbal keybind

(global-set-key (kbd "C-c '") 'comment-or-uncomment-region)
(global-set-key (kbd "C-c l a l") 'lsp-avy-lens);;;run test and debug

;;; use-package

 (eval-when-compile
 (require 'use-package))

;;; undo-tree

(use-package undo-tree
 :ensure t
 :init (global-undo-tree-mode)
 :custom
 (undo-tree-auto-save-history nil))

(use-package shell-pop
      :ensure t
      :config
      (setq shell-pop-shell-type 'shell)  ; use shell
      (setq shell-pop-window-height 20)         ; window height
      (setq shell-pop-window-width 80)          ; window width
      (define-key global-map (kbd "<f12>") 'shell-pop)) ;

;;;treemacs

(use-package treemacs
 :ensure t
 :defer t
 :config
 (treemacs-tag-follow-mode)
 :bind
 (:map global-map
    ("M-s"    . treemacs-select-window)
    ("C-x t 1"  . treemacs-delete-other-windows)
    ("C-x t t"  . treemacs)
    ("C-x t B"  . treemacs-bookmark)
    ;; ("C-x t C-t" . treemacs-find-file)
    ("C-x t M-t" . treemacs-find-tag))
 (:map treemacs-mode-map
	("/" . treemacs-advanced-helpful-hydra)))

(use-package treemacs-projectile
 :ensure t
 :after (treemacs projectile))

(use-package lsp-treemacs
 :ensure t
 :after (treemacs lsp))

;;;hydra

(use-package hydra
 :ensure t)

(use-package use-package-hydra
 :ensure t
 :after hydra)

;;;  ivy

(use-package counsel
 :ensure t)
(use-package ivy
 :ensure t
 :init
 (ivy-mode 1)
 (counsel-mode 1)
 :config
 (setq ivy-use-virtual-buffers t)
 (setq ivy-count-format "(%/%) ")  :bind
 ("C-s" . 'swiper-isearch)
 ("M-x" . 'counsel-M-x)
 ("C-x C-f" . 'counsel-find-file)
 ("M-y" . 'counsel-yank-pop)
 ("C-x b" . 'ivy-switch-buffer)
 ("C-c v" . 'ivy-push-view)
 ("C-c s" . 'ivy-switch-view)
 ("C-c V" . 'ivy-pop-view)
 ("C-x C-SPC" . 'counsel-mark-ring)
 ("<f1> f" . 'counsel-describe-function)
 ("<f1> v" . 'counsel-describe-variable)
 ("<f1> i" . 'counsel-info-lookup-symbol))

;;;  company

(use-package company
 :ensure t
 :init (global-company-mode)
 :config
 (setq company-minimum-prefix-length 1)
 (setq company-tooltip-align-annotations t)
   (setq company-idle-delay 0.0)
 (setq company-show-numbers t)
 (setq company-selection-wrap-around t)
 (setq company-transformers '(company-sort-by-occurrence)))

;;;highlight-symbol

(use-package highlight-symbol
 :ensure t
 :init (highlight-symbol-mode)
 :bind ("<f3>" . highlight-symbol))

;;;rainbow-delimiters

(use-package rainbow-delimiters
 :ensure t
 :hook (prog-mode . rainbow-delimiters-mode))

;;;yasnippet

(use-package yasnippet
 :ensure t
 :hook
 (prog-mode . yas-minor-mode)
 :config
 (yas-reload-all)
 ;; add company-yasnippet to company-backends
 (defun company-mode/backend-with-yas (backend)
  (if (and (listp backend) (member 'company-yasnippet backend))
   backend
   (append (if (consp backend) backend (list backend))
        '(:with company-yasnippet))))
 (setq company-backends (mapcar #'company-mode/backend-with-yas company-backends))
 ;; unbind <TAB> completion
 (define-key yas-minor-mode-map [(tab)]    nil)
 (define-key yas-minor-mode-map (kbd "TAB")  nil)
 (define-key yas-minor-mode-map (kbd "<tab>") nil)
 :bind
 (:map yas-minor-mode-map ("S-<tab>" . yas-expand)))

(use-package yasnippet-snippets
 :ensure t
 :after yasnippet)

;;;flycheck

(use-package flycheck
 :ensure t
 :config
 (setq truncate-lines nil) 
 :hook
 (prog-mode . flycheck-mode))

 ;;;lsp-mode

 (use-package lsp-mode
 :ensure t
 :init
 ;;set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
 (setq lsp-keymap-prefix "C-c l"
	lsp-file-watch-threshold 500)
 :hook  (lsp-mode . lsp-enable-which-key-integration) ; which-key integration
 :commands (lsp lsp-deferred)
 :config
 (setq lsp-completion-provider :none)
 (setq lsp-headerline-breadcrumb-enable t)
 :bind
 ("C-c l s" . lsp-ivy-workspace-symbol))

;;;lsp-ui

(use-package lsp-ui
 :ensure t
 :config
 (define-key lsp-ui-mode-map [remap xref-find-definitions] #'lsp-ui-peek-find-definitions)
 (define-key lsp-ui-mode-map [remap xref-find-references] #'lsp-ui-peek-find-references)
 (setq lsp-ui-doc-position 'top))

;;;dap-mode

(use-package dap-mode
 :ensure t
 :after lsp-mode
 :init (add-to-list 'image-types 'svg)
 :commands dap-debug
 :custom
 (dap-auto-configure-mode t)
 :hydra
 (dap-hydra
  (:color pink :hint nil :foreign-keys run)
  "
^Stepping^     ^Switch^         ^Breakpoints^     ^Debug^           ^Eval^
^^^^^^^^---------------------------------------------------------------------------------------------------------------
_n_: Next      _ss_: Session      _bb_: Toggle     _dd_: Debug         _ee_: Eval
_i_: Step in    _st_: Thread       _bd_: Delete     _dr_: Debug recent     _er_: Eval region
_o_: Step out    _sf_: Stack frame    _ba_: Add       _dl_: Debug last      _es_: Eval thing at point
_c_: Continue    _su_: Up stack frame   _bc_: Set condition  _de_: Edit debug template  _ea_: Add expression.
_r_: Restart frame _sd_: Down stack frame  _bh_: Set hit count  _ds_: Debug restart
_Q_: Disconnect   _sl_: List locals    _bl_: Set log message
         _sb_: List breakpoints
         _se_: List expressions
"
  ("n" dap-next)
  ("i" dap-step-in)
  ("o" dap-step-out)
  ("c" dap-continue)
  ("r" dap-restart-frame)
  ("ss" dap-switch-session)
  ("st" dap-switch-thread)
  ("sf" dap-switch-stack-frame)
  ("su" dap-up-stack-frame)
  ("sd" dap-down-stack-frame)
  ("sl" dap-ui-locals)
  ("sb" dap-ui-breakpoints)
  ("se" dap-ui-expressions)
  ("bb" dap-breakpoint-toggle)
  ("ba" dap-breakpoint-add)
  ("bd" dap-breakpoint-delete)
  ("bc" dap-breakpoint-condition)
  ("bh" dap-breakpoint-hit-condition)
  ("bl" dap-breakpoint-log-message)
  ("dd" dap-debug)
  ("dr" dap-debug-recent)
  ("ds" dap-debug-restart)
  ("dl" dap-debug-last)
  ("de" dap-debug-edit-template)
  ("ee" dap-eval)
  ("ea" dap-ui-expressions-add)
  ("er" dap-eval-region)
  ("es" dap-eval-thing-at-point)
  ("q" nil "quit" :color blue)
  ("Q" dap-disconnect "Disconnect" :color blue))
 :config
 (dap-ui-mode 1)
 (defun dap-hydra ()
	(interactive)
	"Run `dap-hydra/body'."
	(dap-hydra/body)))

;;;rust language

(load-file (expand-file-name "rust.el" user-emacs-directory))

;;;python language

(load-file (expand-file-name "python.el" user-emacs-directory))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
