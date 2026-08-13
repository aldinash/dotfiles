[[ $- == *i* ]] || return 0

setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

autoload -Uz compinit && compinit

for plugin in \
  /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh; do
  [[ -r "$plugin" ]] && source "$plugin" && break
done
unset plugin

for plugin in \
  /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh; do
  [[ -r "$plugin" ]] && source "$plugin" && break
done
unset plugin

if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh)"
fi
if [[ "${TERM:-}" != "dumb" ]] && command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

if [[ "$(uname -s)" == "Darwin" ]]; then
  javahome() {
    export JAVA_HOME="$(/usr/libexec/java_home -v "$1")" || return
    java -version
  }
  alias j11='javahome 11'
  alias j17='javahome 17'
  alias j21='javahome 21'
fi
