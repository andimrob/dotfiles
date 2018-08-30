#  _                   _
# (_)_ __  _ __  _   _| |_ _ __ ___
# | | '_ \| '_ \| | | | __| '__/ __|
# | | | | | |_) | |_| | |_| | | (__
# |_|_| |_| .__/ \__,_|\__|_|  \___|
#         |_|
# Inspired by https://www.topbug.net/blog/2017/07/31/inputrc-for-humans/

$include /etc/inputrc
"\C-p":history-search-backward
"\C-n":history-search-forward

set colored-stats on
set completion-prefix-display-length 3
set mark-symlinked-directories on
set visible-stats on

# Make Tab autocomplete regardless of filename case
set completion-ignore-case on

# Do not autocomplete hidden files unless the pattern explicitly begins with a dot
set match-hidden-files off

# List all matches in case multiple possible completions are possible
set show-all-if-ambiguous on
set show-all-if-unmodified on

TAB: menu-complete
