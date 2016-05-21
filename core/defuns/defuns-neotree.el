;;; defuns-neotree.el
;; for ../core-project.el

;;;###autoload
(defun doom/neotree ()
  "Toggle the neotree window"
  (interactive)
  (let ((in-neotree (and (neo-global--window-exists-p)
                         (window-live-p neo-global--buffer)
                         (eq (current-buffer) neo-global--buffer)))
        (path buffer-file-name))
    (if in-neotree
        (neotree-hide)
      (let ((project-root (doom/project-root)))
        (unless (and (neo-global--window-exists-p)
                     (f-same? (neo-global--with-window neo-buffer--start-node) project-root))
          (neotree-dir project-root))
        (neotree-find path project-root)))))

;;;###autoload
(defmacro doom/neotree-save (&rest body)
  `(let ((neo-p (neo-global--window-exists-p)))
     (when neo-p (neotree-hide))
     ,@body
     (when neo-p
       (save-selected-window
         (neotree-show)))))

;;;###autoload
(defun doom|neotree-close-on-window-change (&rest _)
  "Close neotree to prevent ensuing mindow buggery."
  (unless (and (neo-global--window-exists-p)
               (eq (current-buffer) (neo-global--get-buffer)))
    (neotree-hide)))

;;;###autoload
(defun doom*save-neotree (orig-fun &rest args)
  "Prevents messing up the neotree buffer on window changes"
  (doom/neotree-save (apply orig-fun args)))

;;;###autoload
(defun doom*neotree-create-node (orig-fun &rest args)
  "Don't ask for confirmation when creating files"
  (cl-letf (((symbol-function 'yes-or-no-p) (lambda (&rest _) t)))
    (apply orig-fun args)))

;;;###autoload
(defun doom*neotree-shorten-pwd (node)
  "Shorter pwd in neotree"
  (list (concat "  " (projectile-project-name))))

;;;###autoload
(defun doom*neo-theme (name)
  "Custom hybrid ascii theme with leading whitespace."
  (let ((n-insert-symbol (lambda (n)
                           (neo-buffer--insert-with-face
                            n 'neo-expand-btn-face))))
    (or (and (eq name 'open)  (funcall n-insert-symbol " -  "))
        (and (eq name 'close) (funcall n-insert-symbol " +  "))
        (and (eq name 'leaf)  (funcall n-insert-symbol "   ")))))

(provide 'defuns-neotree)
;;; defuns-neotree.el ends here
