
#!/bin/bash

chmod +x "$0"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' 

echo -ne "\033]0;Talentum x Monad by @MeoMunDep\007"

print_green() {
    echo -e "${GREEN}$1${NC}"
}

print_yellow() {
    echo -e "${YELLOW}$1${NC}"
}

print_red() {
    echo -e "${RED}$1${NC}"
}

# Wine check and install
check_wine() {
    if ! command -v wine &> /dev/null; then
        print_red "Wine is not installed. Installing Wine..."
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo apt update && sudo apt install -y wine
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            brew install wine
        else
            print_red "Unsupported OS for automatic Wine installation. Please install it manually."
            exit 1
        fi
        print_green "Wine installation completed."
    else
        print_green "Wine is already installed."
    fi
}

check_wine

create_default_configs() {
    cat > configs.json << EOL
{
    "timeZone": "en-US",
    "skipInvalidProxy": false,
    "delayEachAccount": [5, 8],
    "timeToRestartAllAccounts": 300,
    "howManyAccountsRunInOneTime": 10,
    "doCheckin": true,
    "setUsername": true,
    "referralCode": ["D59EA", "1B079", "7753D", "90C45", "839D8"]
}
EOL
}

check_configs() {
    if ! command -v node &> /dev/null; then
        print_yellow "Node not installed. Skipping config check that depends on Node."
        return
    fi
    if ! node -e "try { const cfg = require('./configs.json'); if (!cfg.howManyAccountsRunInOneTime || typeof cfg.howManyAccountsRunInOneTime !== 'number' || cfg.howManyAccountsRunInOneTime < 1) throw new Error(); } catch { process.exit(1); }"; then
        print_red "Invalid configuration detected. Resetting to default values..."
        create_default_configs
        print_green "Configuration reset completed."
    fi
}

print_yellow "Checking configuration files..."
if [ ! -f configs.json ]; then
    create_default_configs
    print_green "Created configs.json with default values"
fi

check_configs

for file in privateKeys.txt proxies.txt; do
    if [ ! -f "$file" ]; then
        touch "$file"
        print_green "Created $file"
    fi
done

print_green "Configuration files have been checked."

print_green "Starting the bot using Wine..."
wine meomundep.exe
