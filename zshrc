#  Zshrc


function debugPrint() {
	[[ -f $HOME/.zsh/debug && "${ZSH_NO_DEBUG}" != "1" ]] && echo -e $@
}

[[ -f $HOME/.zsh/debug && "${ZSH_NO_DEBUG}" != "1" ]] && echo -n " (debug mode)"
[[ "${ZSH_PRIVACY_MODE}" == "1" ]] && echo -n " (privacy mode)"

### Import config
debugPrint "=> Importing settings  ..."

# Aliases
debugPrint "- Setting up aliases ..."
if [ -f ~/.zsh_aliases ]; then
	. ~/.zsh_aliases
fi

if [ -f ~/.zsh_functions ]; then
	. ~/.zsh_funcions
fi

if [ -f ~/.profile ]; then
	. ~/.profile
fi

### /etc/profile ###
if [[ -f /etc/profile ]] ; then
	debugPrint "=> Importing /etc/profile ..."
	source /etc/profile
fi

autoload is-at-least

## Uncomment the following line to disable bi-weekly auto-update checks.
#DISABLE_AUTO_UPDATE="true"

### ENVIRONMENT VARIABLES ###
debugPrint "=> Setting up environment variables ..."

##Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
	export EDITOR='vim'
else
	export EDITOR='vim'
fi

#if [[ "${EDITOR}" == "" ]] ; then
	#debugPrint "  -> Falling back to vim"
	#export EDITOR="vim"
#fi

#### Setting Path
if [[ -d $HOME/bin/ ]] ; then
	debugPrint "- Adding $HOME/bin/ to PATH ..."
	export PATH="$PATH:$HOME/bin/"
fi
## Darwin specific
if [[ "$OSTYPE" == "darwin"* ]] ; then
	#debugPrint -n "- Updating PATH for OSX"
	#export PATH="/usr/local/bin:/usr/local/sbin:$PATH"

	if [[ -f "/opt/local/bin/port" ]] ; then
		debugPrint -n " (+macports)"
		export PATH="/opt/local/sbin:/opt/local/bin:$PATH"
	fi

	if [[ -f "/sw/bin/fink" ]] ; then
		debugPrint -n " (+fink)"
		export PATH="/sw/sbin:/sw/bin:$PATH"
	fi

	if [[ -f "/usr/local/bin/brew" ]] ; then
		debugPrint -n " (+brew)"
		export PATH="/usr/local/bin/usr/local/sbin:$PATH"
	fi

	debugPrint -n ", DISPLAY"
	export DISPLAY=:0.0
	export LC_ALL="C"
	export LANG="C"

	if ! which wget 2>&1 >/dev/null ; then
		debugPrint -n ", fake-wget wrapper"
		function wget() {
		curl -o "`basename $1`" "$1"
		}
	fi
	alias eject="diskutil eject"
	debugPrint ""
fi


#### Prompt
debugPrint "- Setting up prompt (PS1) ..."

if is-at-least 4.3.9 ; then
	autoload -U colors && colors
	local USERCOLOR
	USERCOLOR="%F{yellow}"
	if [[ "$UID" == "0" ]] ; then
		USERCOLOR="%F{red}" # RED prompt for root
	fi

	local HOSTCOLOR
	if [[ -f $HOME/.zsh/hostcolor ]] ; then
		HOSTCOLOR="%F{`cat $HOME/.zsh/hostcolor`}"
	else
		HOSTCOLOR="%F{green}"
	fi

	export PS1="$USERCOLOR%n%b%f @ $HOSTCOLOR%m%b%f %~ %(?..[%?] )%# " 

	if [[ "${ZSH_PRIVACY_MODE}" == "1" ]] ; then
		export RPROMPT="%B%F{red}privacy mode%f%b"
	else
		export RPROMPT=""
	fi
else
	if [[ "$UID" == "0" ]] ; then
	        export PS1="$(print '%{\e[1;31m%}')%n $(print '%{\e[0m%}')@$(print '%{\e[1;32m%}') %m $(print '%{\e[0m%}')%~ %(?..[%?] )%# " # RED user for root
	else    
	        export PS1="$(print '%{\e[1;33m%}')%n $(print '%{\e[0m%}')@$(print '%{\e[1;32m%}') %m $(print '%{\e[0m%}')%~ %(?..[%?] )%# " # BLUE user else
	fi
fi



### ZSH SETTINGS ###
debugPrint "\n=> ZSH settings ..."

# ZKBD, for keyboard purposes :)
autoload zkbd

# Patch by Pierre-Hugues HUSSON <phhusson@free.fr>
local ZKBD_FILE
if is-at-least 4.3.6 ; then
	ZKBD_FILE=$TERM-${DISPLAY:-$VENDOR-$OSTYPE}
else
	ZKBD_FILE=$TERM-$VENDOR-$OSTYPE
fi

debugPrint "- Setting up ZKBD ($ZKBD_FILE) ..."

[[ ! -d $HOME/.zkbd/ ]] && mkdir $HOME/.zkbd/
if [[ (! -f $HOME/.zkbd/$ZKBD_FILE) && (! -f /etc/zsh/zkbd/$ZKBD_FILE) ]] ; then
	debugPrint "  -> If keys don't work, type zkbd to configure them"
fi

if [[ -f $HOME/.zkbd/$ZKBD_FILE ]] ; then
	debugPrint "  -> Loading local one."
	source $HOME/.zkbd/$ZKBD_FILE
elif [[ -f /etc/zsh/zkbd/$ZKBD_FILE ]] ; then
	debugPrint "  -> Loading global one."
	source /etc/zsh/zkbd/$ZKBD_FILE
fi

bindkey -e # Force emacs mode when EDITOR="vim"

# Add standard bindings (zsh doesn't read inputrc)
bindkey "\e[1~" beginning-of-line
bindkey "\e[2~" quoted-insert
bindkey "\e[3~" delete-char
bindkey "\e[4~" end-of-line
bindkey "\e[5~" beginning-of-history
bindkey "\e[6~" end-of-history
bindkey "\e[7~" beginning-of-line
bindkey "\e[8~" end-of-line
bindkey "\e[H" beginning-of-line
bindkey "\e[F" end-of-line
bindkey "\eOH" beginning-of-line
bindkey "\eOF" end-of-line
bindkey "\e\e[C" forward-word
bindkey "\e\e[D" backward-word
bindkey "\e[1;5C" forward-word
bindkey "\e[1;5D" backward-word

bindkey '^?' backward-delete-char 

# And override them with zkbd ones (if present)
[[ -n ${key[Home]}    ]]  && bindkey  "${key[Home]}"    beginning-of-line
[[ -n ${key[End]}     ]]  && bindkey  "${key[End]}"     end-of-line
[[ -n ${key[Insert]}  ]]  && bindkey  "${key[Insert]}"  overwrite-mode
[[ -n ${key[Delete]}  ]]  && bindkey  "${key[Delete]}"  delete-char
[[ -n ${key[Up]}      ]]  && bindkey  "${key[Up]}"      up-line-or-history
[[ -n ${key[Down]}    ]]  && bindkey  "${key[Down]}"    down-line-or-history
[[ -n ${key[Left]}    ]]  && bindkey  "${key[Left]}"    backward-char
[[ -n ${key[Right]}   ]]  && bindkey  "${key[Right]}"   forward-char

# Completion
debugPrint "- Completion ..."
#echo -n "Waiting, computing completion list ... "
zmodload zsh/complist
autoload -U compinit
compinit

_force_rehash() {
  (( CURRENT == 1 )) && rehash
  return 1	# Because we didn't really complete anything
}
zstyle ':completion:::::' completer _complete _list _oldlist _expand _ignored _match _correct _approximate _prefix _force_rehash
#zstyle -e ':completion:*:approximate:*' max-errors 'reply=( $(( ($#PREFIX + $#SUFFIX) / 3 )) )'

# Esthetic tweaks
zstyle ':completion:*:descriptions' format "- %d -"
zstyle ':completion:*:corrections' format "- %d - (errors %e})"
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^l*)' insert-sections true
zstyle ':completion:*' menu select
zstyle ':completion:*' verbose yes

# Remove parent directory from completion (cd ../<TAB>)
zstyle ':completion:*:cd:*' ignore-parents parent pwd

# ignore completion functions
zstyle ':completion:*:functions' ignored-patterns '_*'

# completion caching
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path ~/.zsh/compcache

# add colors
export LS_COLORS="no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:tw=30;42:ow=34;42:st=37;44"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# add hosts (from asyd)
if [[ -f ~/.zsh/hosts ]] ; then
	zstyle ':completion:*' hosts $(<~/.zsh/hosts)
fi

#echo "Done !"

# History
debugPrint -n "- Setting up history ..."
if [[ "${ZSH_PRIVACY_MODE}" != "1" ]] ; then
	export HISTFILE=$HOME/.zsh_history
	export HISTSIZE=10000
	export SAVEHIST=10000
	export LISTMAX=10000
	debugPrint ""
else
	export HISTFILE=/dev/null
	export HISTSIZE=0
	export SAVEHIST=0
	export LISTMAX=0
	debugPrint " in privacy mode."
fi

# ZSH options
debugPrint "- Setting up ZSH options ..."

# a neat time output (maybe need more testing)
export TIMEFMT="%J  %U user %S system %P cpu %*E total %Mk maxmem"

# history things
#setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_VERIFY

setopt AUTO_CD

setopt CORRECT # try to correct spelling

setopt NOBEEP

setopt EXTENDED_GLOB

setopt AUTOPUSHD
setopt PUSHD_MINUS
setopt PUSHD_TO_HOME
setopt PUSHD_IGNORE_DUPS

setopt AUTO_LIST

setopt AUTO_PARAM_KEYS

setopt AUTO_PARAM_SLASH
setopt AUTO_REMOVE_SLASH

setopt COMPLETE_ALIASES
setopt EQUALS
setopt EXTENDED_GLOB
setopt MAIL_WARNING
setopt MAGIC_EQUAL_SUBST
setopt NUMERICGLOBSORT

setopt AUTOMENU
setopt EXTENDEDGLOB
setopt COMPLETEINWORD
setopt NO_ALWAYSTOEND

setopt INTERACTIVECOMMENTS

# Terminal titlebar trick
function title {
	if [[ $TERM == "screen" ]]; then
		# Use these two for GNU Screen:
		print -nR $'\033k'$1$'\033'\\\

		print -nR $'\033]0;'$2$'\a'
	elif [[ $TERM == "xterm" || $TERM == "xterm-color" || $TERM == "rxvt" ]]; then
		# Use this one instead for XTerms:
		print -nR $'\033]0;'$*$'\a'
	fi
}
  
function precmd {
	title zsh "$PWD"
}
  
function preexec {
	emulate -L zsh
	local -a cmd; cmd=(${(z)1})
	title $cmd[1]:t "$cmd[2,-1]"
}

### SYSTEM DEPENDENT TRICKS ###
debugPrint "\n=> System dependent tricks ..."

# Java path
if [[ "$OSTYPE" == "linux-gnu" ]] ; then
	debugPrint "- JVM autodetection ..."
	
	if [[ -h /etc/alternatives/java ]] ; then
		JAVA_HOME=$(stat --printf="%N" /etc/alternatives/java | awk -F" -> " '{print $2}' | sed s/\`// | sed s/\'// | sed "s/jre\/bin\/java//")

		if [[ -d /usr/lib/jvm/`basename $JAVA_HOME` ]] ; then
			export JAVA_HOME
			debugPrint "	JVM found at $JAVA_HOME"
		else
			unset JAVA_HOME
			debugPrint "	/!\ Error while parsing /etc/alternatives/java symlink"
		fi
	else
-		debugPrint "	The autodetection needs Java and /etc/alternatives"
	fi
fi

# Autocomplete for Ubuntu (>= Feisty) -- disabled because conflicts with titlebar.
#if [[ -f /etc/zsh_command_not_found ]] ; then
#	debugPrint "- Setting ZSH 'command not found' hook ..." 
#	debugPrint "	/!\ WARNING : This conflicts with titlebar settings"
#	. /etc/zsh_command_not_found
#fi

# User's config file
debugPrint "\n=> Loading user's config file ..."
[[ -f ~/.zsh/user.zshrc ]] && source ~/.zsh/user.zshrc
