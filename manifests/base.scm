;; ~/.config/guix/base.scm
;; Возвращает объект <manifest>
(specifications->manifest
 '("coreutils" "git" "curl" "less" "vim" "tmux"))
