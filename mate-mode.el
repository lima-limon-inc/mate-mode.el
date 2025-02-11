;;; mate-mode.el --- A small emacs package to manage who's turn it is in the mate circle  -*- lexical-binding: t; -*-

;; Copyright (C) 2025  Tomas Fabrizio Orsi

;; Author: Tomas Fabrizio Orsi <torsi@fi.uba.ar>
;; Keywords: convenience

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; 🧉

;;; Code:
(defvar mate-circle--mate-buffer-name "*mate-mode*")

(defun mate-circle--prompt-for-drinker ()
  (read-string "Insert mate drinker name: ")
  )

(defun mate-circle--prompt-for-drinkers ()
  (let
      (
       (drinkers-wip (list))
       (current-drinker "")
       )
    (while (not
            (string-equal
             (setq current-drinker (mate-circle--prompt-for-drinker))
             ""))
      (setq drinkers-wip (append  drinkers-wip (list current-drinker)))
      )
    drinkers-wip
    )
  )

(defun mate-circle--get-drinkers (include-user)
  "Prompts the user for a list of mate drinkers. If INCLUDE-USER is
non-nil, then the machine's user will be included as well"
  (let
      (
       (user (if include-user (list (concat user-login-name " 💧")) nil))
       )
    (append user (mate-circle--prompt-for-drinkers))
  )
  )


(define-derived-mode mate-circle-mode text-mode "Mate Circle"
  "\nA mode for keeping track of who's turn it is to drink mate."
  (hack-dir-local-variables-non-file-buffer))

(setf mate-circle--mate-emoji-cons (cons "🧉" "●"))

(defun mate-circle--mate-emoji ()
  (if (display-graphic-p)
      (car mate-circle--mate-emoji-cons)
    (cdr mate-circle--mate-emoji-cons)
    )
  )

(setf mate-circle--no-more-emoji-cons (cons "⛔" "X"))

(defun mate-circle--no-more-emoji ()
  (if (display-graphic-p)
      (car mate-circle--no-more-emoji-cons)
    (cdr mate-circle--no-more-emoji-cons)
    )
  )


(defun mate-circle--format-drinker (drinker has-mate)
  (let
      (
       (drinker drinker)
       (has-mate-symbol (if has-mate (mate-circle--mate-emoji) " "))
       )
    (format "- [%s] %s\n" has-mate-symbol drinker)
    )
  )


(defun mate-circle--insert-drinkers (drinkers new-buffer)
  (let
      (
       (has-mate new-buffer)
       )
    (mapc
     (lambda (drinker)
       (progn
         (insert (mate-circle--format-drinker drinker has-mate)))
         (setq has-mate nil)
       )
     drinkers)
    )
  )

(defun mate-circle--create-mate-buffer (drinkers new-buffer)
  "Create the mate circle if it does not already exist"
  (with-current-buffer (get-buffer-create mate-circle--mate-buffer-name)
    (end-of-buffer)
    (when new-buffer
      (erase-buffer)
      (insert "The Mate List: \n")
      (mate-circle-mode)
      )
    (mate-circle--insert-drinkers drinkers new-buffer)
    )
  )

(defun mate-mode-start-mate-circle (drinkers)
  (interactive
   (list
    (mate-circle--get-drinkers t)
    )
   )
  (mate-circle--create-mate-buffer drinkers t)
  (setq mate-mode--current-drinker-timer nil)
  )

(defun mate-mode-add-new-drinker (drinker)
  (interactive
   (list
    (mate-circle--prompt-for-drinker)
    )
   )
  (mate-circle--create-mate-buffer (list drinker) nil)
  )

(defun mate-circle--replace-in-line (regexp replacement)
  (let
      (
       (line-start (progn (beginning-of-line) (point)))
       (line-end (progn (end-of-line) (point)))
       )
    (replace-regexp-in-region regexp replacement line-start line-end)
    )
  )

(defun mate-circle--next-mate-drinker ()
  (let
      (
       (max-lines (count-lines (point-min) (point-max)))
       (current-line (line-number-at-pos))
       )
    ;; When it fails to find someone at the bottom, go to the top and
    ;; start looking again
    (when (not (re-search-forward (rx "- [" (or " ") "] ") nil t))
      (progn
        (goto-char 0)
        (re-search-forward (rx "- [" (or " ") "] "))
        )
      )
    )
  )

(defun mate-circle--get-drinker-in-line ()
  (let
      (
       (line-content (string-trim-right (thing-at-point 'line t)))
       )

    (replace-regexp-in-string (rx "- [" (or "🧉" "●") "] ")
                              ""
                              line-content
                              )
    )
  )

(defun mate-circle--pass-mate ()
  (goto-char (mate-circle--find-current-drinker ))
  (mate-circle--replace-in-line (rx (or "🧉" "●")) " ")
  (mate-circle--next-mate-drinker)
  (mate-circle--replace-in-line (rx "- [ ] ") (format "- [%s] " (mate-circle--mate-emoji)))
  (mate-circle--get-drinker-in-line)
  )

(defun mate-circle--find-current-drinker ()
  (goto-char 0)
  (re-search-forward (rx (or "🧉" "●")))
  )

(defun mate-mode-next-mate-drinker ()
  (interactive)
  (let
      ((current-drinker
        (save-excursion
          (with-current-buffer (get-buffer-create mate-circle--mate-buffer-name)
              (mate-circle--pass-mate)
            )
          )))
    (setq mate-mode--current-drinker-timer (run-at-time "7 seconds" nil (lambda () (message (format "Che, no es microfono %s" current-drinker)))))
    (message (format "It's %s's turn for mate" current-drinker))
    )
  )

(defun mate-circle--no-more-mate ()
  (goto-char (mate-circle--find-current-drinker ))
  (mate-circle--replace-in-line (rx (or "🧉" "●")) (mate-circle--no-more-emoji))
  (mate-circle--next-mate-drinker)
  (mate-circle--replace-in-line (rx "- [ ] ") (format "- [%s] " (mate-circle--mate-emoji)))
  (mate-circle--get-drinker-in-line)
  )

(defun mate-mode-no-more-mate ()
  (interactive)
  (let
      ((current-drinker
        (save-excursion
          (with-current-buffer (get-buffer-create mate-circle--mate-buffer-name)
              (mate-circle--no-more-mate)
            )
          )))
    (message (format "It's %s's turn for mate" current-drinker))
    )
  )

(defun mate-mode-whos-turn-it-is ()
  (interactive)
  (let
      ((current-drinker
        (save-excursion
          (with-current-buffer (get-buffer-create mate-circle--mate-buffer-name)
            (mate-circle--find-current-drinker)
            (mate-circle--get-drinker-in-line)
            )
          )))
    (message (format "It's %s's turn for mate" current-drinker))
    )
  )

(provide 'mate-mode) ;;; mate-mode.el ends here
