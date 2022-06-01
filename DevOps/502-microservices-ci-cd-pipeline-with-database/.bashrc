# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions

# export PS1="\[\e[31m\]\u\[\e[32m\]@\h-\w:\[\e[36m\]\\$\[\e[m\]"

# parse_git_branch() {
#  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
# }
# export PS1="\[\e[36m\]\u@\h \W\[\033[32m\]\$(parse_git_branch)\[\033[00m\] $ "

parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

export PS1="\[\e[31m\]\u\[\e[33m\]@\h \W\[\033[32m\]\$(parse_git_branch)\[\033[00m\] $ "

# git remote set-url origin https://token@url
bu hatayı alanlar için eğer repo private ise cd .git / cat config url kısmına token eklerseniz sorun düzeliyor