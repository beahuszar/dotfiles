# env variables
export ZSH="$HOME/.oh-my-zsh"
export USE_GKE_GCLOUD_AUTH_PLUGIN=True
export PATH="$HOME/.local/bin:$PATH"

ZSH_THEME="af-magic"
source $ZSH/oh-my-zsh.sh

# plugins
plugins=(git)

# aliases
[ -f ~/.bash_aliases ] && source ~/.bash_aliases

# History settings
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

setopt APPEND_HISTORY # add new commands instead of overwriting
setopt SHARE_HISTORY # share history across terminals
setopt HIST_IGNORE_ALL_DUPS # remove duplicate entries
setopt HIST_REDUCE_BLANKS # clean extra spaces
setopt HIST_VERIFY # show expanded history entry before execution

# Prefix-based history search with up/down arrows
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
