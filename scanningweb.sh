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
    if ! command -v whatweb &> /dev/null; then
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
    whatweb -v -a 3 "$domain" | sed 's/,/\n/g'
}

# Step 1: Asking the user to enter the target IP address or domain name
echo "Step 1: Please enter the target IP address or domain name:"
read target

# Print the entered target for confirmation
echo "You entered: $target"

# If step 1 run successfully
echo "-------------------------------------------------------------------------------------------------"
echo "******* Step 1 Completed Successfully *******"
echo "-------------------------------------------------------------------------------------------------"
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
echo "-------------------------------------------------------------------------------------------------"
echo "******* Step 2 Completed Successfully *******"
echo "-------------------------------------------------------------------------------------------------"
# Step 3: Asking the user to perform web identification on default target or selected subdomains
echo "Step 3: Do you want to perform web identification on the default target (Y/N)?"
read response

if [[ "$response" == "Y" || "$response" == "y" ]]; then
    # Perform web identification on default target
    echo "Performing web identification on the default target: $target"
    # Perform web identification on the default target
    perform_web_identification "$target"
echo "-------------------------------------------------------------------------------------------------"
echo "******* Step 3  Web Identification For "$target" Completed Successfully *******"
echo "-------------------------------------------------------------------------------------------------"
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
echo "-------------------------------------------------------------------------------------------------"
echo "******* Web Identification for target "${selected_subdomains[@]}" Completed Successfully *******"
echo "-------------------------------------------------------------------------------------------------"
    done
echo "-------------------------------------------------------------------------------------------------"
echo "******* Step 3 Web Identification Completed Successfully *******"
echo "-------------------------------------------------------------------------------------------------"
fi


