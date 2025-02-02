;;; mate-circle.el --- A small emacs package to manage who's turn it is in the mate circle  -*- lexical-binding: t; -*-

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
(defvar mate-circle--mate-buffer-name "*mate-circle*")

(defun mate-circle--prompt-for-drinkers ()
  (let
      (
       (drinkers-wip (list))
       (current-drinker "")
       )
    (while (not
            (string-equal
             (setq current-drinker (read-string "Insert mate drinker name: "))
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


(defun mate-circle--mate-emoji ()
  (if (display-graphic-p) "🧉" "●")
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


(defun mate-circle--insert-drinkers (drinkers)
  (let
      (
       (has-mate t)
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

(defun mate-circle--create-mate-buffer (drinkers)
  "Create the mate circle if it does not already exist"
  (with-current-buffer (get-buffer-create mate-circle--mate-buffer-name)
    (erase-buffer)
    (insert "The Mate List: \n")
    (mate-circle-mode)
    (mate-circle--insert-drinkers drinkers)
    )
  )

(defun start-mate-circle (drinkers)
  (interactive
   (list
    (mate-circle--get-drinkers t)
    )
   )
  (mate-circle--create-mate-buffer drinkers)
  ;; drinkers
  )


(provide 'mate-circle) ;;; mate-circle.el ends here
