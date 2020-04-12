#                        ___  ____
#  _ __ ___   __ _  ___ / _ \/ ___|
# | '_ ` _ \ / _` |/ __| | | \___ \
# | | | | | | (_| | (__| |_| |___) |
# |_| |_| |_|\__,_|\___|\___/|____/

# hide/show all desktop icons (useful when presenting)
alias hidedesktop='defaults write com.apple.finder CreateDesktop -bool false && killall Finder'
alias showdesktop='defaults write com.apple.finder CreateDesktop -bool true && killall Finder'

# hide/show hidden files in Finder
alias hidefiles='defaults write com.apple.finder AppleShowAllFiles FALSE && killall Finder'
alias showfiles='defaults write com.apple.finder AppleShowAllFiles TRUE && killall Finder'

defaults write -g ApplePressAndHoldEnabled -bool false
