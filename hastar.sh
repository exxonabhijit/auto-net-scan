#!/bin/bash

# Function to display subdomains with selection option
display_subdomains() {
    local subdomains=("$@")
    local selected_subdomains=()
    local selected_index=0
    local arrow="->"
    for subdomain in "${subdomains[@]}"; do
        local prefix="[+]"
        if [[ "${selected_subdomains[@]}" =~ "$subdomain" ]]; then
            prefix="[-]"
        fi
        if [[ $selected_index -eq $selected ]]; then
            echo -e "\033[1;32m${arrow} $prefix $subdomain\033[0m"
        else
            echo "   $prefix $subdomain"
        fi
        ((selected_index++))
    done
}

# Function to perform web identification on a domain using whatweb
perform_web_identification() {
    local domain="$1"
    # Check if whatweb is installed
    if ! command -v whatweb &>/dev/null; then
        echo "whatweb is not installed. Attempting to install..."
        # Attempt to install whatweb using apt
        if sudo apt install whatweb -y; then
            echo "whatweb installed successfully."
        else
            echo "Failed to install whatweb. Exiting."
            exit 1
        fi
    fi
    echo "Web identification for domain: $domain"
    # Perform web identification using whatweb
    sudo whatweb -v -a 3 "$domain" | sed 's/,/\n/g'
}

# Function to check if a host is up
check_host_up() {
    local host="$1"
    echo "Checking if host $host is up..."
    if sudo nmap -PR -sn "$host" -v &>/dev/null; then
        echo "Host $host is up."
        return 0
    else
        echo "Host $host is down."
        return 1
    fi
}

# Function to perform port scanning on a domain
perform_port_scanning() {
    local domain="$1"
    echo "Performing port scanning on domain: $domain"
    # Perform port scanning using nmap with advanced command (replace with your command)
    sudo nmap -PR -T4 -A "$domain" -v
}

# Function to find vulnerabilities using Nmap's default scripts
find_vulnerabilities() {
    local target="$1"
    echo "Finding vulnerabilities using Nmap's default scripts for target: $target"

    # Run Nmap with default scripts for vulnerability detection
    sudo nmap -Pn --script vuln $target -v

    # Run Nmap with Nmap-vulners scripts for vulnerability detection
    echo "-------------------------------------------------------------------------------------------------------------------"
    echo "Scanning Nmap-vulners External Script on "$target" START"
    echo "-------------------------------------------------------------------------------------------------------------------"
    sudo nmap -sV --script nmap-vulners/ $target -v
    echo "-------------------------------------------------------------------------------------------------------------------"
    echo "Scanning Nmap-vulners External Script on "$target" END"
    echo "-------------------------------------------------------------------------------------------------------------------"

    # Run Nmap with vulscan scripts for vulnerability detection
    echo "-------------------------------------------------------------------------------------------------------------------"
    echo "Scanning vulscan External Script on "$target" START"
    echo "-------------------------------------------------------------------------------------------------------------------"
    sudo nmap -sV --script=vulscan/vulscan.nse $target -v
    echo "-------------------------------------------------------------------------------------------------------------------"
    echo "Scanning Vulscan External Script on "$target" END"
    echo "-------------------------------------------------------------------------------------------------------------------"
}


# Function to display stylish shell banner
display_banner() {
    local domain="$1"
    echo "                                              "
    echo "      -------- "$domain" ---------            "
    echo "      _   _           _     _                 "
    echo " | | | |         | |   (_)                    "
    echo " | |_| | ___  ___| |_   _ ___   _   _ _ __    "
    echo " |  _  |/ _ \/ __| __| | / __| | | | | '_ \   "
    echo " | | | | (_) \__ \ |_  | \__ \ | |_| | |_) |  "
    echo " \_| |_/\___/|___/\__| |_|___/  \__,_| .__/   "
    echo "                                   | |        "
    echo "                                   |_|        "
    echo "                                              "
    echo "                                              "
    echo "                                              "
}

echo "                                                     "
echo "                                                     "
echo "  ██   ██  █████  ███████ ████████  █████  ██████    "
echo "  ██   ██ ██   ██ ██         ██    ██   ██ ██   ██   "
echo "  ███████ ███████ ███████    ██    ███████ ██████    "
echo "  ██   ██ ██   ██      ██    ██    ██   ██ ██   ██   "
echo "  ██   ██ ██   ██ ███████    ██    ██   ██ ██   ██   "
echo "                                                     "
echo "        ------- The God Of Demon -------             "
echo "                                                     "
echo "                                                     "
                                               
# Step 1: Asking the user to enter the target IP address or domain name
echo "Step 1: Please enter the target IP address or domain name:"
read target

# Print the entered target for confirmation
echo "You entered: $target"

# If step 1 run successfully
echo "--------------------------------------------------------------------------------------------------------------"
echo "******* Step 1 Completed Successfully *******"
echo "--------------------------------------------------------------------------------------------------------------"
# Step 2: Finding subdomains using Subfinder
echo "Step 2: Finding subdomains using Subfinder..."
subdomains=$(sudo subfinder -d $target -t 50 -max-time 5 -rl 100 -all -silent)

# Convert subdomains string to an array
IFS=$'\n' read -r -d '' -a subdomains_array <<<"$subdomains"

# Display subdomains with index numbers
echo "Subdomains found:"
index=0
for subdomain in "${subdomains_array[@]}"; do
    echo "[$index] $subdomain"
    ((index++))
done
echo "--------------------------------------------------------------------------------------------------------------"
echo "******* Step 2 Completed Successfully *******"
echo "--------------------------------------------------------------------------------------------------------------"
# Step 3: Asking the user to perform web identification on default target or selected subdomains
echo "Step 3: Do you want to perform web identification on the default target (Y/N)?"
read response

if [[ "$response" == "Y" || "$response" == "y" ]]; then
    # Perform web identification on default target
    echo "Performing web identification on the default target: $target"
    # Perform web identification on the default target
    perform_web_identification "$target"
    echo "---------------------------------------------------------------------------------------------------------------------------"
    echo "******* Step 3  Web Identification For "$target" Completed Successfully *******"
    echo "---------------------------------------------------------------------------------------------------------------------------"

    # Step 4: Check if the host is up using nmap
    echo "Step 4: Checking if the host is up using nmap..."
    if check_host_up "$target"; then
        echo "-------------------------------------------------------------------------------------------------------------------"
        echo "Stylish Banner for Host $target"
        echo "-------------------------------------------------------------------------------------------------------------------"

        # Display stylish shell banner
        display_banner "$target"
        echo "-------------------------------------------------------------------------------------------------------------------"
        echo "******* Step 4 Host Up checking Completed Successfully *******"
        echo "-------------------------------------------------------------------------------------------------------------------"

        # Step 5: Perform port scanning on the host
        echo "Step 5: Performing port scanning on host $target..."
        perform_port_scanning "$target"
        echo "-------------------------------------------------------------------------------------------------------------------"
        echo "******* Step 5 Port Scanning With Aggressive Scan Completed Successfully *******"
        echo "-------------------------------------------------------------------------------------------------------------------"

        # Step 6: Find vulnerabilities using Nmap's scripts
        echo "Step 6: Performing vulnerability detection using Nmap's default scripts..."
        find_vulnerabilities "$target"
        echo "-------------------------------------------------------------------------------------------------------------------"
        echo "******* Step 6 Vulnerability Detection Completed Successfully *******"
        echo "-------------------------------------------------------------------------------------------------------------------"

    else
        # If the host is down, display a message
        echo "-------------------------------------------------------------------------------------------------------------------"
        echo "Host $target is Down. Cannot Display Banner or Perform Port Scanning."
        echo "-------------------------------------------------------------------------------------------------------------------"
    fi

else
    # Ask user to select subdomains for web identification
    echo "Step 3: Please enter the index numbers of the subdomains you want to perform web identification on (separated by spaces):"
    read -a selected_indices

    # Extract selected subdomains based on index numbers provided
    selected_subdomains=()
    for index in "${selected_indices[@]}"; do
        selected_subdomains+=("${subdomains_array[index]}")
    done

    # Display selected subdomains
    echo "Selected subdomains:"
    for subdomain in "${selected_subdomains[@]}"; do
        echo "$subdomain"
    done

    # Perform web identification on selected subdomains
    echo "Performing web identification on selected subdomains..."
    for subdomain in "${selected_subdomains[@]}"; do
        perform_web_identification "$subdomain"
        echo "--------------------------------------------------------------------------------------------------------------------------"
        echo "******* Web Identification for target "${selected_subdomains[@]}" Completed Successfully *******"
        echo "--------------------------------------------------------------------------------------------------------------------------"
    done
    echo "--------------------------------------------------------------------------------------------------------------------------"
    echo "******* Step 3 Web Identification Completed Successfully *******"
    echo "--------------------------------------------------------------------------------------------------------------------------"

    # Step 4: Check if the hosts are up using nmap
    echo "----------------------------------------------------------------------------------------------------------------------"
    echo "Step 4: Checking if the hosts are up using nmap..."
    for subdomain in "${selected_subdomains[@]}"; do
        if check_host_up "$subdomain"; then
            echo "--------------------------------------------------------------------------------------------------------------"
            echo "Stylish Banner for Host $subdomain"

            # Display stylish shell banner
            display_banner "$subdomain"
            echo "--------------------------------------------------------------------------------------------------------------"
            echo "******* Step 4 Host Up checking Completed Successfully *******"
            echo "--------------------------------------------------------------------------------------------------------------"

            # Step 5: Perform port scanning on the host
            echo "Step 5: Performing port scanning on host $subdomain..."
            perform_port_scanning "$subdomain"
            echo "--------------------------------------------------------------------------------------------------------------"
            echo "******* Step 5 Port Scanning Completed Successfully *******"
            echo "--------------------------------------------------------------------------------------------------------------"

            # Step 6: Find vulnerabilities using Nmap's scripts
            echo "Step 6: Performing vulnerability detection using Nmap's default scripts..."
            find_vulnerabilities "$subdomain"
            echo "--------------------------------------------------------------------------------------------------------------"
            echo "******* Step 6 Vulnerability Detection Completed Successfully *******"
            echo "--------------------------------------------------------------------------------------------------------------"

        else
            echo "--------------------------------------------------------------------------------------------------------------"
            echo "Host $subdomain is Down. Cannot Display Banner or Perform Port Scanning."
            echo "--------------------------------------------------------------------------------------------------------------"
        fi
    done

fi
