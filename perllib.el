(if (< emacs-minor-version 3)
 (require 'perldoc "perldoc" t))
;; cperl-mode par d\x{00E9}fault
(autoload 'cperl-mode "cperl-mode" "cperl-mode" t)
(defalias 'perl-mode 'cperl-mode)

(setq interpreter-mode-alist (append interpreter-mode-alist
			      '(("miniperl" . perl-mode))))

(setq auto-mode-alist
 (cons '("\\.pl$" . perllib-perl-prolog-or-formalog-prolog-mode-resolution) auto-mode-alist))

(setq auto-mode-alist
 (cons '("\\.dat$" . perllib-perl-data-dump-or-not-resolution) auto-mode-alist))

(setq auto-mode-alist
 (cons '("\\.t$" . cperl-mode) auto-mode-alist))

;; Activer toutes les options
;(setq cperl-hairy t)

(defun perllib-perl-prolog-or-formalog-prolog-mode-resolution ()
 "Determine if the current file is a perl or prolog file, and load the appropriate mode"
 (interactive)
 (let ((type (perllib-perl-prolog-or-formalog-prolog-file)))
  (cond 
   ((string= type "perl") (cperl-mode))
   ((string= type "prolog") (prolog-mode))
   ((string= type "formalog-prolog") (formalog-prolog)))))

;; auto-mode-alist
  
(defun perllib-perl-prolog-or-formalog-prolog-file ()
 ""
 (interactive)
 (if flp-running
  (if (null flp-source-files)
   (flp-list-source-files))
  (see "Start FLP to allow formalog-prolog-mode to be chosen" 0.1))
 (if (flp-source-file-p buffer-file-name)
  "formalog-prolog"
  (perllib-perl-or-prolog-file)))

(defun perllib-perl-or-prolog-file ()
 ""
 (interactive)
 (save-excursion
  (beginning-of-buffer)
  (mark)
  (end-of-line)
  (let ((first-line (buffer-substring-no-properties (mark) (point))))
   (if (or
	(and
	 (string-match-p "^\#\!" first-line)
	 (string-match-p "[pP][eE][rR][lL]" first-line)
	 ) 
	(= (length first-line) 0)
	)
    "perl"
    "prolog"))))

(defun perllib-perl-data-dump-or-not-resolution ()
 "Determine if the current file is a perl or prolog file, and load the appropriate mode"
 (interactive)
 (let ((type (perllib-perl-data-dump-or-not-file)))
  (cond 
   ((string= type "perl") (cperl-mode)))))

(defun perllib-perl-data-dump-or-not-file ()
 ""
 (interactive)
 (save-excursion
  (beginning-of-buffer)
  (mark)
  (end-of-line)
  (let ((first-line (buffer-substring-no-properties (mark) (point))))
   (if (string-match-p "\\$VAR1 = \\[" first-line)
    "perl"
    "other"))))

(defun perllib-cpan-search ()
 "Search CPAN for something"
 (interactive)
 ;; just load the cpan page and submit the search
 (let* ((search (read-from-minibuffer "CPAN Search? ")))
  (w3m)
  (w3m-view-this-url-1 "http://search.cpan.org" nil t)
  (w3m-next-form)
  (eval (append (list 'perllib-w3m-form-input) (cdr (butlast (w3m-action))) (list search)))
  (w3m-next-form)
  (w3m-next-form)
  (widget-button-press (point))))

(defun perllib-w3m-form-input (form id name type width maxlength input)
  (save-excursion
    (let* ((fvalue (w3m-form-get form id)))
      (w3m-form-put form id name input)
      (w3m-form-replace input))))

(defun perllib-get-the-name-of-all-subroutines-in-current-file ()
 ""
 (interactive)
 (save-excursion
  (mark-whole-buffer)
  ;; generate-new-buffer
  ;; get-buffer-create
  (let* ((buffername "fdskjfdksjfd")
	 (text (buffer-substring-no-properties (point) (mark)))
	 (buffer (get-buffer buffername))) 
   (kill-buffer buffer)
   (set-buffer (get-buffer-create buffername))
   (mark-whole-buffer)   
   (insert text)
   (shell-command-on-region (point) (mark) "grep -E \"^sub\" | sed -e 's/sub //' | sed -e 's/ {//'"))))
