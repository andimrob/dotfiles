# Work-Specific Configuration Example
# Copy this to ../local/work.sh and customize for your work setup

# Source company bootstrap if available
# [ -f "$HOME/.bootstrap/env.sh" ] && source "$HOME/.bootstrap/env.sh"

# Work-specific aliases
# alias edit-retail="${EDITOR:-vi} ~/src/retail"
# alias code-retail="code ~/src/retail"
# alias cur-retail="cursor ~/src/retail"

# Work database shortcuts
# alias murder-retail="psql -c 'select pg_terminate_backend(pg_stat_activity.pid) from pg_stat_activity where pg_stat_activity.datname = '\''retail_development'\'' and pid <> pg_backend_pid()'"

# Work-specific bundler shortcuts
# alias bxr-rb="cd ~/src/retail && bundle exec rspec \$(git diff --name-only | rg 'spec\.rb$' | tr '\n', ' ')"
# alias create-user='bundle exec rake create_user'

# Work project navigation
# alias retail='cd ~/src/retail'
