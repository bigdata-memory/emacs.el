;; selectively copied from https://github.com/howardabrams/dot-files/blob/master/emacs.org
;; put following commented code into .emacs if exists for init.el loading at startup
;; ;; please don't use the following setting if env variable http_proxy etc. correctly set up
;;(setq url-proxy-services
;;   '(("no_proxy" . "^\\(localhost\\|10\\..*\\|192\\.168\\..*\\)")
;;     ("http" . "proxy.com:8080")
;;     ("https" . "proxy.com:8080")
;;     ("ftp" . "proxy.com:8080")
;;    )
;;)
;; ;; (setq url-gateway-method 'socks)
;; ;; (setq socks-server '("Default server" "127.0.0.1" 1080 5))
;; (setq custom-file "~/.emacs.d/init.el")
;; (when (file-exists-p custom-file)
;;   (load custom-file))
;; ;; put the following commented code into .bashrc
;; ;; alias e="emacsclient -a \"\" -c -t "


(setq gc-cons-threshold 50000000)

(setq gnutls-min-prime-bits 4096)

(require 'package)

(setq package-archives '(("gnu"       . "http://elpa.gnu.org/packages/")
                         ("melpa"     . "http://melpa.org/packages/")
                        ))

(package-initialize)
(package-refresh-contents)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
  (when (file-exists-p custom-file)
    (load custom-file :noerror))

(require 'use-package)

(require 'cl)

(use-package dash
  :ensure t
  :config (eval-after-load "dash" '(dash-enable-font-lock)))

(use-package s
  :ensure t)

(use-package f
  :ensure t)

;(setq-default tab-width 4)
;(setq-default indent-tabs-mode nil)
(setq-default c-default-style "linux")
(setq-default c-basic-offset 4)

(setq-default tab-always-indent 'complete)

(fset 'yes-or-no-p 'y-or-n-p)

(setq scroll-conservatively 10000
      scroll-preserve-screen-position t)

(setq disabled-command-function nil)

(setq initial-scratch-message "") ;; Uh, I know what Scratch is for
(setq visible-bell t)             ;; Get rid of the beeps

(when (window-system)
  (tool-bar-mode 0)               ;; Toolbars were only cool with XEmacs
  (when (fboundp 'horizontal-scroll-bar-mode)
    (horizontal-scroll-bar-mode -1))
  (scroll-bar-mode -1))            ;; Scrollbars are waste screen estate

;(set-face-background 'region "blue3")

;; GNU Global Tags
(use-package ggtags
  :ensure t
  :commands ggtags-mode
  :diminish ggtags-mode
  :bind (("M-*" . pop-tag-mark)
         ("C-c t s" . ggtags-find-other-symbol)
         ("C-c t h" . ggtags-view-tag-history)
         ("C-c t r" . ggtags-find-reference)
         ("C-c t f" . ggtags-find-file)
         ("C-c t c" . ggtags-create-tags))
  :init
  (add-hook 'c-mode-common-hook
            #'(lambda ()
                (when (derived-mode-p 'c-mode 'c++-mode 'java-mode)
                  (ggtags-mode 1)))))

(use-package whitespace
  :ensure t
  :init
  (global-whitespace-mode)
  :config
  (setq whitespace-style '(face
                           trailing
                           tabs
                           spaces
                           empty
                           space-mark
                           tab-mark
                           ))
  (setq whitespace-display-mappings
        '((space-mark ?\u3000 [?\u25a1])
          ;; WARNING: the mapping below has a problem.
          ;; When a TAB occupies exactly one column, it will display the
          ;; character ?\xBB at that column followed by a TAB which goes to
          ;; the next TAB column.
          ;; If this is a problem for you, please, comment the line below.
          (tab-mark ?\t [?\u00BB ?\t] [?\\ ?\t])))
  ;; only full-width space
  (setq whitespace-space-regexp "\\(\u3000+\\)")
  (defvar my/bg-color "#232323")
  (set-face-attribute 'whitespace-trailing nil
                      :background my/bg-color
                      :foreground "DeepPink"
                      :underline t)
  (set-face-attribute 'whitespace-tab nil
                      :background my/bg-color
                      :foreground "LightSkyBlue"
                      :underline nil)
  (set-face-attribute 'whitespace-space nil
                      :background my/bg-color
                      :foreground "GreenYellow"
                      :weight 'bold)
  (set-face-attribute 'whitespace-empty nil
                      :background my/bg-color))

(use-package which-key
  :ensure t
  :defer 10
  :diminish which-key-mode
  :config

  ;; Replacements for how KEY is replaced when which-key displays
  ;;   KEY → FUNCTION
  ;; Eg: After "C-c", display "right → winner-redo" as "▶ → winner-redo"
  (setq which-key-key-replacement-alist
        '(("<\\([[:alnum:]-]+\\)>" . "\\1")
          ("left"                  . "◀")
          ("right"                 . "▶")
          ("up"                    . "▲")
          ("down"                  . "▼")
          ("delete"                . "DEL") ; delete key
          ("\\`DEL\\'"             . "BS") ; backspace key
          ("next"                  . "PgDn")
          ("prior"                 . "PgUp"))

        ;; List of "special" keys for which a KEY is displayed as just
        ;; K but with "inverted video" face... not sure I like this.
        which-key-special-keys '("RET" "DEL" ; delete key
                                 "ESC" "BS" ; backspace key
                                 "SPC" "TAB")

        ;; Replacements for how part or whole of FUNCTION is replaced:
        which-key-description-replacement-alist
        '(("Prefix Command" . "prefix")
          ("\\`calc-"       . "") ; Hide "calc-" prefixes when listing M-x calc keys
          ("\\`projectile-" . "𝓟/")
          ("\\`org-babel-"  . "ob/"))

        ;; Underlines commands to emphasize some functions:
        which-key-highlighted-command-list
        '("\\(rectangle-\\)\\|\\(-rectangle\\)"
          "\\`org-"))

  ;; Change what string to display for a given *complete* key binding
  ;; Eg: After "C-x", display "8 → +unicode" instead of "8 → +prefix"
  (which-key-add-key-based-replacements
    "C-x 8"   "unicode"
    "C-c T"   "toggles-"
    "C-c p s" "projectile-search"
    "C-c p 4" "projectile-other-buffer-"
    "C-x a"   "abbrev/expand"
    "C-x r"   "rect/reg"
    "C-c /"   "engine-mode-map"
    "C-c C-v" "org-babel")

  (which-key-mode 1))

(use-package fancy-narrow
  :ensure t
  :config
  (defun ha/highlight-block ()
    "Highlights a 'block' in a buffer defined by the first blank
     line before and after the current cursor position. Uses the
     'fancy-narrow' mode to high-light the block."
    (interactive)
    (let (cur beg end)
      (setq cur (point))
      (setq end (or (re-search-forward  "^\s*$" nil t) (point-max)))
      (goto-char cur)
      (setq beg (or (re-search-backward "^\s*$" nil t) (point-min)))
      (fancy-narrow-to-region beg end)
      (goto-char cur)))

  (defun ha/highlight-section (num)
    "If some of the buffer is highlighted with the `fancy-narrow'
     mode, then un-highlight it by calling `fancy-widen'.

     If region is active, call `fancy-narrow-to-region'.

     If NUM is 0, highlight the current block (delimited by blank
     lines). If NUM is positive or negative, highlight that number
     of lines.  Otherwise, called `fancy-narrow-to-defun', to
     highlight current function."
    (interactive "p")
    (cond
     ((fancy-narrow-active-p)  (fancy-widen))
     ((region-active-p)        (fancy-narrow-to-region (region-beginning) (region-end)))
     ((= num 0)                (ha/highlight-block))
     ((= num 1)                (fancy-narrow-to-defun))
     (t                        (progn (ha/expand-region num)
                                      (fancy-narrow-to-region (region-beginning) (region-end))
                                      (setq mark-active nil)))))

  :bind (("C-M-+" . ha/highlight-section)
         ("C-<f12>" . ha/highlight-section)))


(use-package fancy-narrow
  :ensure t
  :config
  (defun ha/highlight-block ()
    "Highlights a 'block' in a buffer defined by the first blank
     line before and after the current cursor position. Uses the
     'fancy-narrow' mode to high-light the block."
    (interactive)
    (let (cur beg end)
      (setq cur (point))
      (setq end (or (re-search-forward  "^\s*$" nil t) (point-max)))
      (goto-char cur)
      (setq beg (or (re-search-backward "^\s*$" nil t) (point-min)))
      (fancy-narrow-to-region beg end)
      (goto-char cur)))

  (defun ha/highlight-section (num)
    "If some of the buffer is highlighted with the `fancy-narrow'
     mode, then un-highlight it by calling `fancy-widen'.

     If region is active, call `fancy-narrow-to-region'.

     If NUM is 0, highlight the current block (delimited by blank
     lines). If NUM is positive or negative, highlight that number
     of lines.  Otherwise, called `fancy-narrow-to-defun', to
     highlight current function."
    (interactive "p")
    (cond
     ((fancy-narrow-active-p)  (fancy-widen))
     ((region-active-p)        (fancy-narrow-to-region (region-beginning) (region-end)))
     ((= num 0)                (ha/highlight-block))
     ((= num 1)                (fancy-narrow-to-defun))
     (t                        (progn (ha/expand-region num)
                                      (fancy-narrow-to-region (region-beginning) (region-end))
                                      (setq mark-active nil)))))

  :bind (("C-M-+" . ha/highlight-section)
         ("C-<f12>" . ha/highlight-section)))


(defun narrow-or-widen-dwim (p)
  "If the buffer is narrowed, it widens.  Otherwise, it narrows intelligently.
Intelligently means: region, subtree, or defun, whichever applies
first.

With prefix P, don't widen, just narrow even if buffer is already
narrowed."
  (interactive "P")
  (declare (interactive-only))
  (cond ((and (buffer-narrowed-p) (not p)) (widen))
        ((region-active-p)
         (narrow-to-region (region-beginning) (region-end)))
        ((derived-mode-p 'org-mode) (org-narrow-to-subtree))
        (t (narrow-to-defun))))

(global-set-key (kbd "C-x n x") 'narrow-or-widen-dwim)

(use-package ace-window
  :ensure t
  :init
    (setq aw-keys '(?a ?s ?d ?f ?j ?k ?l ?o))
    (global-set-key (kbd "C-x o") 'ace-window)
    :diminish ace-window-mode)

(use-package avy
  :ensure t
  :init (setq avy-background t))


;; (global-set-key (kbd "s-h") 'avy-goto-char-timer)
;; (global-set-key (kbd "s-j") 'avy-goto-char-timer)
;; (global-set-key (kbd "s-H") 'avy-pop-mark)
;; (global-set-key (kbd "s-J") 'avy-pop-mark)
;; (global-set-key (kbd "A-h") 'avy-goto-char-timer)
;; (global-set-key (kbd "A-j") 'avy-goto-char-timer)
;; (global-set-key (kbd "A-H") 'avy-pop-mark)
;; (global-set-key (kbd "A-J") 'avy-pop-mark)
(global-set-key (kbd "M-g '") 'avy-goto-char-timer)

(defun unfill-paragraph ()
  "Convert a multi-line paragraph into a single line of text."
  (interactive)
  (let ((fill-column (point-max)))
    (fill-paragraph nil)))

;; Handy key definition
(define-key global-map "\M-Q" 'unfill-paragraph)

(use-package projectile
  :ensure t
  :init (projectile-global-mode 0)
  :bind (("C-c p s" . projectile-ag)
         ("C-c p g" . projectile-grep)
         ("C-c p R" . projectile-regenerate-tags)))

(use-package perspective
  :ensure t
  :bind ("C-x x x" . persp-switch-last)
  :init (persp-mode +1)

  (use-package persp-projectile
    :ensure t
    :bind ("C-x x P" . projectile-persp-switch-project))

  :config
    (setq persp-interactive-completion-function #'ido-completing-read)
    (persp-turn-off-modestring))

(use-package ido
  :ensure t
  :init  (setq ido-enable-flex-matching t
               ido-ignore-extensions t
               ido-use-virtual-buffers t
               ido-everywhere t)
  :config
  (ido-mode 1)
  (ido-everywhere 1)
  (add-to-list 'completion-ignored-extensions ".pyc"))


(use-package flx-ido
   :ensure t
   :init (setq ido-enable-flex-matching t
               ido-use-faces nil)
   :config (flx-ido-mode 1))

(use-package ido-vertical-mode
  :ensure t
  :init               ; I like up and down arrow keys:
  (setq ido-vertical-define-keys 'C-n-C-p-up-and-down)
  :config
  (ido-vertical-mode 1))

(defun ido-sort-mtime ()
  "Reorder the IDO file list to sort from most recently modified."
  (setq ido-temp-list
        (sort ido-temp-list
              (lambda (a b)
                (ignore-errors
                  (time-less-p
                   (sixth (file-attributes (concat ido-current-directory b)))
                   (sixth (file-attributes (concat ido-current-directory a))))))))
  (ido-to-end  ;; move . files to end (again)
   (delq nil (mapcar
              (lambda (x) (and (char-equal (string-to-char x) ?.) x))
              ido-temp-list))))

(add-hook 'ido-make-file-list-hook 'ido-sort-mtime)
(add-hook 'ido-make-dir-list-hook 'ido-sort-mtime)

(defadvice ido-find-file (after find-file-sudo activate)
  "Find file as root if necessary."
  (unless (and buffer-file-name
               (file-writable-p buffer-file-name))
    (let* ((file-name (buffer-file-name))
           (file-root (if (string-match "/ssh:\\([^:]+\\):\\(.*\\)" file-name)
                          (concat "/ssh:"  (match-string 1 file-name)
                                  "|sudo:" (match-string 1 file-name)
                                  ":"      (match-string 2 file-name))
                        (concat "/sudo:localhost:" file-name))))
      (find-alternate-file file-root))))

(use-package smex
  :ensure t
  :init (smex-initialize)
  :bind ("M-x" . smex)
  ("M-X" . smex-major-mode-commands))

(use-package helm
  :ensure t
  :init
  (use-package helm-config))   ;; Binds C-x c to the helm bidness.

(use-package helm-swoop
  :ensure t
  :init
  ;; If this value is t, split window inside the current window
  (setq helm-swoop-split-with-multiple-windows t
        ;; If you prefer fuzzy matching
        helm-swoop-use-fuzzy-match t)
  :bind
  (("M-s s" . helm-swoop)  ;; overbind M-i ?
   ("M-s S" . helm-multi-swoop)))

(use-package recentf
  :ensure t
  :init
  (setq recentf-max-menu-items 25
        recentf-auto-cleanup 'never
        recentf-keep '(file-remote-p file-readable-p))
  (recentf-mode 1)
  (let ((last-ido "~/.emacs.d/ido.last"))
    (when (file-exists-p last-ido)
      (delete-file last-ido)))

  :bind ("C-c f r" . recentf-open-files))

(use-package flyspell
  :ensure t
  :diminish flyspell-mode
  :init
  (add-hook 'prog-mode-hook 'flyspell-prog-mode)

  (dolist (hook '(text-mode-hook org-mode-hook))
    (add-hook hook (lambda () (flyspell-mode 1))))

  (dolist (hook '(change-log-mode-hook log-edit-mode-hook org-agenda-mode-hook))
    (add-hook hook (lambda () (flyspell-mode -1))))

  :config
  (setq ispell-program-name "/usr/bin/aspell"
        ispell-local-dictionary "en_US"
        ispell-dictionary "american" ; better for aspell
        ispell-extra-args '("--sug-mode=ultra" "--lang=en_US")
        ispell-list-command "--list"
        ispell-local-dictionary-alist '(("en_US" "[[:alpha:]]" "[^[:alpha:]]" "['‘’]"
                                      t ; Many other characters
                                      ("-d" "en_US") nil utf-8))))

(use-package linum
  :ensure t
  :init
  (add-hook 'prog-mode-hook 'linum-mode)
  (add-hook 'linum-mode-hook (lambda () (set-face-attribute 'linum nil :height 110)))

  :config
  (defun linum-fringe-toggle ()
    "Toggles the line numbers as well as the fringe."    (interactive)
    (cond (linum-mode (fringe-mode '(0 . 0))
                      (linum-mode -1))
          (t          (fringe-mode '(8 . 0))
                      (linum-mode 1))))
  (setq linum-format "%4d \u2502 ")
  :bind (("A-C-k"   . linum-mode)
         ("s-C-k"   . linum-mode)
         ("A-C-M-k" . linum-fringe-toggle)
         ("s-C-M-k" . linum-fringe-toggle)))

(use-package linum-relative
  :ensure t
  :config
  (defun linum-new-mode ()
    "If line numbers aren't displayed, then display them.
     Otherwise, toggle between absolute and relative numbers."
    (interactive)
    (if linum-mode
        (linum-relative-toggle)
      (linum-mode 1)))

  :bind ("A-k" . linum-new-mode)
  ("s-k" . linum-new-mode))   ;; For Linux

(use-package comment-dwim-2
  :ensure t
  :bind ("M-;" . comment-dwim-2))

(use-package smartscan
  :ensure t
  :bind ("M-n" . smartscan-symbol-go-forward)
  ("M-p" . smartscan-symbol-go-backward))

(add-hook 'before-save-hook 'delete-trailing-whitespace)

(use-package flycheck
  :ensure t
  :init
  (add-hook 'after-init-hook 'global-flycheck-mode)
  :config
  (setq-default flycheck-disabled-checkers '(emacs-lisp-checkdoc)))

(use-package gitconfig-mode
  :ensure t)

(use-package gitignore-mode
  :ensure t)

;(use-package zenburn-theme
;  :ensure t
;  :config
;  (load-theme 'zenburn t)
;  )

(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown"))

;;;
;;; Configuration for editing html, js and css
;;;

(use-package web-mode
  :ensure t
  :mode (("\\.html$" . web-mode)
         ("\\.jsx?$" . web-mode)) ;; auto-enable for .js/.jsx files
  :init
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq js-indent-level 2)
  (setq web-mode-enable-auto-pairing t)
  (setq web-mode-enable-auto-expanding t)
  (setq web-mode-enable-css-colorization t)
  (add-hook 'web-mode-hook 'electric-pair-mode))

(use-package web-beautify
  :ensure t
  :commands (web-beautify-css
             web-beautify-css-buffer
             web-beautify-html
             web-beautify-html-buffer
             web-beautify-js
             web-beautify-js-buffer))

(defun surround-html (start end tag)
   "Wraps the specified region (or the current 'symbol / word'
 with a properly formatted HTML tag."
   (interactive "r\nsTag: " start end tag)
   (save-excursion
     (narrow-to-region start end)
     (goto-char (point-min))
     (insert (format "<%s>" tag))
     (goto-char (point-max))
     (insert (format "</%s>" tag))
     (widen)))

;; (define-key html-mode-map (kbd "C-c C-w") 'surround-html)

(use-package emmet-mode
  :ensure t
  :diminish (emmet-mode . "ε")
  :bind* (("C-)" . emmet-next-edit-point)
          ("C-(" . emmet-prev-edit-point))
  :commands (emmet-mode
             emmet-next-edit-point
             emmet-prev-edit-point)
  :init
  (setq emmet-indentation 2)
  (setq emmet-move-cursor-between-quotes t)
  :config
  ;; Auto-start on any markup modes
  (add-hook 'sgml-mode-hook 'emmet-mode)
  (add-hook 'web-mode-hook 'emmet-mode))

(use-package nginx-mode
  :ensure t
  :commands (nginx-mode))

(use-package json-mode
  :ensure t
  :mode "\\.json\\'"
  :config
  (bind-key "{" #'paredit-open-curly json-mode-map)
  (bind-key "}" #'paredit-close-curly json-mode-map))

;(use-package highlight-indentation
;  :init
;  (progn
;    (defun set-hl-indent-color ()
;      (set-face-background 'highlight-indentation-face "#e3e3d3"))
;    (add-hook 'python-mode-hook 'highlight-indentation-mode)
;    (add-hook 'python-mode-hook 'set-hl-indent-color)))

(use-package tuareg
   :ensure t
   :config
   (add-hook 'tuareg-mode-hook #'electric-pair-local-mode)
   ;; (add-hook 'tuareg-mode-hook 'tuareg-imenu-set-imenu)
   (setq auto-mode-alist
       (append '(("\\.ml[ily]?$" . tuareg-mode)
          ("\\.topml$" . tuareg-mode))
          auto-mode-alist)))
;; Merlin configuration
(use-package merlin
   :ensure t
   :config
   (add-hook 'tuareg-mode-hook 'merlin-mode)
   (add-hook 'merlin-mode-hook #'company-mode)
   (setq merlin-error-after-save nil))
;; utop configuration
(use-package utop
   :ensure t
   :config
   (autoload 'utop-minor-mode "utop" "Minor mode for utop" t)
   (add-hook 'tuareg-mode-hook 'utop-minor-mode))

;; (use-package css-eldoc
;;   :ensure t
;;   :config
;;   (progn
;;     (add-hook 'css-mode-hook 'turn-on-css-eldoc)
;;     (add-hook 'scss-mode-hook 'turn-on-css-eldoc)
;;     (add-hook 'less-css-mode-hook 'turn-on-css-eldoc)))

(use-package org
  :ensure t
  :bind ("C-c l" . org-store-link)
        ("C-c a" . org-agenda)
        ("C-c c" . org-capture)
  :config (progn
            (setq org-babel-load-languages '((shell . t) (emacs-lisp . t) (dot . t) (python . t)))
            (setq org-catch-invisible-edits 'show-and-error)
            (setq org-cycle-separator-lines 0)
            (setq org-directory "~/org")

            (setq org-default-notes-file (expand-file-name "inbox.org" org-directory))
            (setq org-default-calendar-file (expand-file-name "schplaf.org" org-directory))
            (setq org-default-gtd-file (expand-file-name "gtd.org" org-directory))
            (setq org-default-someday-file (expand-file-name "someday.org" org-directory))
            (setq org-default-tickler-file (expand-file-name "tickler.org" org-directory))
            (setq org-agenda-files `(,org-default-notes-file
                                     ,org-default-calendar-file
                                     ,org-default-gtd-file
                                     ,org-default-tickler-file))

            (setq org-refile-targets `((,org-default-notes-file :level . 1)
                                       (,org-default-gtd-file :maxlevel . 3)
                                       (,org-default-someday-file :level . 1)
                                       (,org-default-tickler-file :maxlevel . 2)))

            (setq org-capture-templates
                  '(("t" "Todo" entry (file+headline org-default-notes-file "Inbox") "* TODO %?%i")
                    ("l" "Todo + link" entry (file+headline org-default-notes-file "Inbox") "* TODO %? %a")
                    ("p" "Appt" entry (file org-default-calendar-file) "* %?\n%^T")
                    ("T" "Tickler" entry (file+headline org-default-tickler-file "Tickler") "* %i%? \nSCHEDULED: %^t")))

             (setq org-todo-keywords
                '(
                  (sequence "IDEA(i)" "TODO(t)" "STARTED(s)" "NEXT(n)" "WAITING(w)" "|" "DONE(d)")
                  (sequence "|" "CANCELED(c)" "DELEGATED(l)" "SOMEDAY(f)")
                 ))
              (setq org-todo-keyword-faces
                '(("IDEA" . (:foreground "GoldenRod" :weight bold))
                 ("NEXT" . (:foreground "IndianRed1" :weight bold))
                 ("STARTED" . (:foreground "OrangeRed" :weight bold))
                 ("WAITING" . (:foreground "coral" :weight bold))
                 ("CANCELED" . (:foreground "LimeGreen" :weight bold))
                 ("DELEGATED" . (:foreground "LimeGreen" :weight bold))
                 ("SOMEDAY" . (:foreground "LimeGreen" :weight bold))))))

(provide 'init-web)
;;; init-web.el ends here

;; (setq w32-alt-is-meta nil)

(use-package virtualenvwrapper
  :ensure t)

;; pip install --user rope flake8 importmagic autopep8 yapf ipdb ipython virtualenv virtualenvwrapper
(setq python-shell-interpreter "ipython"
      python-shell-interpreter-args "-i --simple-prompt")

(use-package elpy
  :ensure t
  :init
  (elpy-enable))

(global-visual-line-mode t)
(setq column-number-mode t)
(show-paren-mode 1)

(setq python-shell-interpreter "python3")
(setq flycheck-python-pycompile-executable "python3"
      flycheck-python-pylint-executable "python3"
      flycheck-python-flake8-executable "python3")

(defun my-frame-tweaks (&optional frame)
  "My personal frame tweaks."
  (unless frame
    (setq frame (selected-frame)))
  (when frame
    (with-selected-frame frame
      (tool-bar-mode -1)
      (menu-bar-mode -1)
      (setq display-time-format "%I:%M:%S")
      (setq display-time-day-and-date t)
      (display-time-mode 1)
      (load-theme 'tango-dark))))

;; For the case that the init file runs after the frame has been created.
;; Call of emacs without --daemon option.
(my-frame-tweaks)
;; For the case that the init file runs before the frame is created.
;; Call of emacs with --daemon option.
(add-hook 'after-make-frame-functions #'my-frame-tweaks t)

