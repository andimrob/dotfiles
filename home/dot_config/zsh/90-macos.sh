#                        ___  ____
#  _ __ ___   __ _  ___ / _ \/ ___|
# | '_ ` _ \ / _` |/ __| | | \___ \
# | | | | | | (_| | (__| |_| |___) |
# |_| |_| |_|\__,_|\___|\___/|____/

# hide/show all desktop icons (useful when presenting)
# -----------------------------------------------------------------------------
alias hidedesktop='defaults write com.apple.finder CreateDesktop -bool false && killall Finder'
alias showdesktop='defaults write com.apple.finder CreateDesktop -bool true && killall Finder'

# hide/show hidden files in Finder
# -----------------------------------------------------------------------------
alias hidefiles='defaults write com.apple.finder AppleShowAllFiles FALSE && killall Finder'
alias showfiles='defaults write com.apple.finder AppleShowAllFiles TRUE && killall Finder'

defaults write -g ApplePressAndHoldEnabled -bool false

# Set a blazingly fast keyboard repeat rate
# -----------------------------------------------------------------------------
defaults write NSGlobalDomain KeyRepeat -int 1 # normal minimum is 2 (30 ms)
defaults write NSGlobalDomain InitialKeyRepeat -int 15 # normal minimum is 15 (225 ms)

# Get macOS Software Updates, and update installed Ruby gems, Homebrew, npm, and their installed packages
alias update='sudo softwareupdate -i -a; brew update; brew upgrade; brew cleanup; npm install npm -g; npm update -g; sudo gem update --system; sudo gem update; sudo gem cleanup'

# IP addresses
alias localip="ipconfig getifaddr en0"

# Show active network interfaces
alias ifactive="ifconfig | pcregrep -M -o '^[^\t:]+:([^\n]|\n\t)*status: active'"

# Flush Directory Service cache
alias flush="dscacheutil -flushcache && killall -HUP mDNSResponder"

# Clean up LaunchServices to remove duplicates in the "Open With" menu
alias lscleanup="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user && killall Finder"


# Empty the Trash on all mounted volumes and the main HDD.
# Also, clear Apple's System Logs to improve shell startup speed.
# Finally, clear download history from quarantine. https://mths.be/bum
alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl; sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* 'delete from LSQuarantineEvent'"

# Disable Spotlight
alias spotoff="sudo mdutil -a -i off"
# Enable Spotlight
alias spoton="sudo mdutil -a -i on"

# PlistBuddy alias, because sometimes `defaults` just doesn't cut it
alias plistbuddy="/usr/libexec/PlistBuddy"
