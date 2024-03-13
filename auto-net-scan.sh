#!/bin/bash

# Step 1: Take IP address or domain name of the application as input
read -p "Enter the IP address or domain name of the application: " target

# Echoing the input for validation (optional)
echo "Target IP address or domain name: $target"

# Placeholder for confirmation message
echo "Step 1 completed successfully."

# Step 2: Allow the user to enter custom subdomains
echo "Step 2: Enter custom subdomains (if any). Press Enter to skip."
read -p "Enter custom subdomains separated by space: " custom_subdomains

# Concatenate custom subdomains with subdomains found by Sublist3r
all_subdomains="$custom_subdomains"

# Determine if the user wants to find subdomains using Sublist3r
read -p "Do you want to find subdomains using Sublist3r? (Yes/No): " find_subdomains

# Convert the input to lowercase for case-insensitive comparison
find_subdomains=$(echo "$find_subdomains" | tr '[:upper:]' '[:lower:]')

if [ "$find_subdomains" == "yes" ]; then
    echo "Performing subdomain enumeration with Sublist3r..."
    # Utilize Sublist3r to enumerate subdomains associated with the target domain
    # Save the discovered subdomains for later processing
    sublist3r_output=$(sublist3r -v -b -d $target -e google,yahoo,bing)

    # Extract subdomains from the output and remove unwanted characters
    sublist3r_subdomains=$(echo "$sublist3r_output" | grep -Eo '[a-zA-Z0-9._-]+\.([a-zA-Z]{2,})' | sed 's/92m//g')

    # Add Sublist3r subdomains to the list of all subdomains
    all_subdomains="$all_subdomains $sublist3r_subdomains"

    echo "Subdomain enumeration with Sublist3r completed."
fi

# Display all subdomains
echo "All subdomains:"
echo "$all_subdomains"

echo "Step 2 completed successfully."

# Step 3: Perform host discovery with Nmap
echo "Performing host discovery with Nmap for $target..."
nmap_output=$(nmap -sn $target)

# Check if any hosts are up
if echo "$nmap_output" | grep -q "Host is up"; then
    echo "Host is up. Proceeding with port scanning..."
    
    # Step 4: Port scanning options
    echo "Step 4: Port scanning options"

    # Available Nmap scan options
    echo "Available Nmap scan options:"
    echo "1. Quick scan (-T4)"
    echo "2. Intense scan (-T4 -A)"
    echo "3. Intense scan, all TCP ports (-T4 -A -p-)"
    echo "4. Intense scan, all UDP ports (-T4 -A -sU)"
    echo "5. Intense scan, all TCP and UDP ports (-T4 -A -p- -sU)"
    echo "6. Full port scan (-p-)"
    echo "7. SYN scan (-sS)"
    echo "8. Version detection (-sV)"
    echo "9. OS detection (-O)"
    echo "10. Service version detection (-sV -sC)"
    echo "11. Custom scan"

    # Prompt the user to choose scan options
    read -p "Choose scan option(s) separated by space, or enter '11' for custom scan: " scan_options

    # Perform the selected scan(s)
    case $scan_options in
        1) nmap -v -T4 $target ;;
        2) nmap -v -T4 -A $target ;;
        3) nmap -v -T4 -A -p- $target ;;
        4) nmap -v -T4 -A -sU $target ;;
        5) nmap -v -T4 -A -p- -sU $target ;;
        6) nmap -v -p- $target ;;
        7) nmap -v -sS $target ;;
        8) nmap -v -sV $target ;;
        9) nmap -v -O $target ;;
        10) nmap -v -sV -sC $target ;;
        11) read -p "Enter custom Nmap command: " custom_scan
            eval $custom_scan ;;
        *) echo "Invalid option. Exiting." 
           exit 1 ;;
    esac

else
    echo "No hosts are up. Exiting script."
    exit 1
fi

# Add additional steps as needed

