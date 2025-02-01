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

(get-buffer-create "*mate-circle*")

(defun hello (drinkers)
  (interactive
   (list
    ;; (while t
    ;;   )
    (let
        ((drinkers-wip (list)))
      (setq drinkers-wip (append (read-string "Insert mate drinker name: ") drinkers-wip))
      )
    )
   )
  ;; (message drinkers)
  )


(provide 'mate-circle) ;;; mate-circle.el ends here
