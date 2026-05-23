#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

# Colored prompt with git branch
parse_git_branch() {
    git branch 2>/dev/null | grep '^\*' | sed 's/* / /'
}
PS1='\[\e[38;5;141m\]\u\[\e[0m\]@\[\e[38;5;117m\]\h\[\e[0m\] \[\e[38;5;228m\]\w\[\e[38;5;212m\]$(parse_git_branch)\[\e[0m\] \$ '
export EDITOR=nvim
export VISUAL=nvim
alias vim="nvim"
alias vi="nvim"
