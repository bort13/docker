# oh my zsh stuff
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="wezm+"
plugins=(git)

source $ZSH/oh-my-zsh.sh

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# AWS profile selection
# by Nate
aws-login() {
    local reset='\033[0m'
    local debug='\033[0;34m' # blue
    local error='\033[0;41m' # red background
    local success='\033[0;32m' # green
    local warn='\033[0;33m' # yellow
    local info='\033[0;36m' # cyan
    local info_b='\033[1;36m' # cyan bold

    echo "${debug}Fetching AWS profiles...${reset}"

    local profiles
    profiles=($(aws configure list-profiles))
    if [ ${#profiles[@]} -eq 0 ]; then
        echo "${error}No AWS profiles found.${reset}"
        return 1
    fi

    echo "${info_b}Profiles:${reset}"
    local i=1
    for p in "${profiles[@]}"; do
        echo "[$i] ${info}$p${reset}"
        i=$((i+1))
    done

    echo -n "${warn}Enter the number of the profile to use:${reset} "
    read choice

    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt ${#profiles[@]} ]; then
        echo "${error}Please enter a number from the above list.${reset}"
        return 1
    fi

    local selected_profile="${profiles[$((choice))]}"

    echo "${info}Logging in with profile: ${selected_profile}${reset}"
    if aws sso login --profile "$selected_profile"; then
        export AWS_PROFILE="$selected_profile"
        echo "${success}AWS_PROFILE set to $AWS_PROFILE${reset}"
        echo "${success}Login successful.${reset}"
    else
        echo "${error}AWS SSO login failed.${reset}"
        return 1
    fi
}

export PATH="$HOME/.local/bin:$PATH"
