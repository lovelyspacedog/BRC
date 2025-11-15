#!/usr/bin/env bash

# This script is USER CUSTOMIZABLE and won't be overwritten by updates.

case "${1^^}" in
    "--NON-INTERACTIVE"|"-1")
        # This section runs before the interactive shell is started.
        # It's used to set up the shell environment.

        return 0
        ;;
    "--TAIL"|"-3")
        # This section runs at the very end of the shell startup.
        # It's used to set up the shell environment.

        export SHELL_MOMMYS_LITTLE="script puppy/pup/puppy/cub/dog/doggie/mutt"
        export SHELL_MOMMYS_PRONOUNS="their/his"
        export SHELL_MOMMYS_ROLES="alpha/daddy/papa/master"
        export SHELL_MOMMYS_COLOR="\e[36m"
        export SHELL_MOMMYS_ONLY_NEGATIVE=true
        return 0
        ;;
    "--INTERACTIVE"|"-2"|*)
        # This section runs immediately after the interactive shell is started.
        # It's used to set up the shell environment.

        return 0
        ;;
esac
