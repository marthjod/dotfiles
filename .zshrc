# shell
#
autoload -Uz promptinit
promptinit
prompt adam1

autoload -Uz compinit
compinit

setopt histignorealldups sharehistory
setopt correct
setopt extendedglob

HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
# GNU
# eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# os
export EDITOR=vim

alias -r grep='grep --color=auto'
alias -r egrep'egrep --color=auto'

alias -r sfv="sift -n --exclude-dirs .git --exclude-dirs vendor"
#alias -r sf="rg --line-number --with-filename"
alias -r sf="sift -n --exclude-dirs .git"
alias -r sfiv="sfv -i"
alias -r sfi="sift -n -i --exclude-dirs .git"
#alias -r sfi="rg --line-number --ignore-case --with-filename"
alias -r dc='cd'
alias -r l='ls -alh'

function f {
    local what=$1

    find -iname "*$what*" | grep "$what"
}

# python
export PYTHONSTARTUP=~/.pystartup
alias -r py='python'
export PATH="/home/martin/.pyenv/bin:$PATH"
alias -r svba='source venv/bin/activate'

# golang
export GOPATH=$HOME/src/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

# git
alias -r gis='git status'
alias -r gst='git stash'
alias -r gsp='git stash pop'
# alias -r gg='gitg 2>&1 >/dev/null&'
alias -r gg='smerge -n . 2>&1 >/dev/null&'
alias -r gri='git rebase -i HEAD~5'
alias -r gr='git rebase'
alias -r gc='git checkout'
alias -r gcb='git checkout -b'
alias -r gpr='git pull -r'
alias -r gl='git log'
alias -r glp='git log -p'

# Adapted from code found at <https://gist.github.com/1712320>.

setopt prompt_subst
autoload -U colors && colors # Enable colors in prompt

# Modify the colors and symbols in these variables as desired.
GIT_PROMPT_SYMBOL="%{$fg[blue]%}±"
GIT_PROMPT_PREFIX="%{$fg[green]%}[%{$reset_color%}"
GIT_PROMPT_SUFFIX="%{$fg[green]%}]%{$reset_color%}"
GIT_PROMPT_AHEAD="%{$fg[red]%}ANUM%{$reset_color%}"
GIT_PROMPT_BEHIND="%{$fg[cyan]%}BNUM%{$reset_color%}"
GIT_PROMPT_MERGING="%{$fg_bold[magenta]%}⚡︎%{$reset_color%}"
GIT_PROMPT_UNTRACKED="%{$fg_bold[red]%}■%{$reset_color%}"
GIT_PROMPT_MODIFIED="%{$fg_bold[yellow]%}●%{$reset_color%}"
GIT_PROMPT_STAGED="%{$fg_bold[green]%}●%{$reset_color%}"

# Show Git branch/tag, or name-rev if on detached head
parse_git_branch() {
  (git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD) 2> /dev/null
}

# Show different symbols as appropriate for various Git repository states
parse_git_state() {

  # Compose this value via multiple conditional appends.
  local GIT_STATE=""

  local NUM_AHEAD="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_AHEAD" -gt 0 ]; then
    GIT_STATE=$GIT_STATE${GIT_PROMPT_AHEAD//NUM/$NUM_AHEAD}
  fi

  local NUM_BEHIND="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_BEHIND" -gt 0 ]; then
    GIT_STATE=$GIT_STATE${GIT_PROMPT_BEHIND//NUM/$NUM_BEHIND}
  fi

  local GIT_DIR="$(git rev-parse --git-dir 2> /dev/null)"
  if [ -n $GIT_DIR ] && test -r $GIT_DIR/MERGE_HEAD; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_MERGING
  fi

  if [[ -n $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_UNTRACKED
  fi

  if ! git diff --quiet 2> /dev/null; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_MODIFIED
  fi

  if ! git diff --cached --quiet 2> /dev/null; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_STAGED
  fi

  if [[ -n $GIT_STATE ]]; then
    echo "$GIT_PROMPT_PREFIX$GIT_STATE$GIT_PROMPT_SUFFIX"
  fi

}

# If inside a Git repository, print its branch and state
git_prompt_string() {
  local git_where="$(parse_git_branch)"
  [ -n "$git_where" ] && echo "$GIT_PROMPT_SYMBOL$(parse_git_state)$GIT_PROMPT_PREFIX%{$fg[yellow]%}${git_where#(refs/heads/|tags/)}$GIT_PROMPT_SUFFIX"
}

# Set the right-hand prompt
RPS1='$(git_prompt_string)'

# feature branches
function gp {
    out="`git push 2>&1`"
   echo $out | grep -q "git push"
   if [ $? -eq 0 ]; then
        cmd="`echo $out | grep git | perl -pe 's/.*(git push --set-upstream.+)/$1/'`"
        read "response?$cmd [y/n] "
        if [[ "$response" =~ ^[yY]$ ]]; then
            eval $cmd
        fi
    else
        echo $out
    fi
}

alias gethash="git rev-parse --short=8 HEAD | tr -d '\n' | xclip -selection c"

alias -g jq.="| jq -R 'fromjson? | .'"  

if [ -x "/usr/bin/kubectl" ]; then
    source <(kubectl completion zsh)
fi

# gcloud
alias -r sshi="ssh -o StrictHostKeyChecking=no 2>/dev/null"
alias -r scpi="scp -o StrictHostKeyChecking=no 2>/dev/null"
alias -r gcv="gcloud compute instances"
#alias -r gcvl='gcv list --format "table(name:sort=1, zone, machineType, scheduling.preemptible.yesno(yes=true, no=''), networkInterfaces[].networkIP.notnull().list():label=INTERNAL_IP, networkInterfaces[].accessConfigs[0].natIP.notnull().list():label=EXTERNAL_IP, status, metadata.items[DBRole], metadata.items[Cluster], metadata.items[Seednode])"'
#alias -r gcvl='gcv list --format "table(name:sort=1, zone.basename(), machineType.machine_type().basename(), scheduling.preemptible.yesno(yes=true, no=''), networkInterfaces[].networkIP.notnull().list():label=INTERNAL_IP, networkInterfaces[].accessConfigs[0].natIP.notnull().list():label=EXTERNAL_IP, status, metadata.items[DBRole], metadata.items[Cluster], metadata.items[Seednode])"'
alias -r gcssh="gcloud compute ssh"

function gcvl {
    local pattern=$1
    if [ -z "${pattern}" ]; then pattern="."; fi
    gcv list --format "table(name:sort=1, zone, machineType, scheduling.preemptible.yesno(yes=true, no=''), networkInterfaces[].networkIP.notnull().list():label=INTERNAL_IP, networkInterfaces[].accessConfigs[0].natIP.notnull().list():label=EXTERNAL_IP, status, metadata.items[DBRole], metadata.items[Cluster], metadata.items[Seednode])" | grep $pattern
}


alias -r grm="git checkout master && git pull --rebase && git checkout - && git rebase master && git checkout master && git rebase -"

autoload -U +X bashcompinit && bashcompinit


