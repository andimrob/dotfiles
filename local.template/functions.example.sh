# Local Functions Example
# Copy this to ../local/functions.sh and customize

# Work-specific helper functions
# work_db_reset() {
#   echo "Resetting work database..."
#   cd ~/src/work-project
#   bundle exec rake db:drop db:create db:migrate db:seed
# }

# Project switcher
# project() {
#   case "$1" in
#     work)
#       cd ~/src/work-project
#       ;;
#     personal)
#       cd ~/src/personal-project
#       ;;
#     *)
#       echo "Unknown project: $1"
#       ;;
#   esac
# }

# Custom git workflow helpers
# work_branch() {
#   git checkout -b "$USER/$(date +%Y%m%d)/$1"
# }
