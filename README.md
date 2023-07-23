# iCloud Private Relay Egress IP Address List

![iCloud Private Relay](https://support.apple.com/library/content/dam/edam/applecare/images/en_US/icloud/icloud-private-relay-how-private-relay-works-path-through-relays.png)

This project provides a comprehensive list of auto-generated iCloud Private Relay egress IP addresses in various formats (iptables ipset, JSON, and TXT) for easy integration into your network infrastructure.

## What is iCloud Private Relay?

[iCloud Private Relay](https://developer.apple.com/support/prepare-your-network-for-icloud-private-relay) is a privacy-focused feature offered by Apple Inc. It enhances the security and privacy of your internet connections by providing an additional layer of encryption and anonymity when browsing the web. This feature routes your internet traffic through two separate servers, making it difficult for anyone, including Apple, to identify your IP address or the websites you visit.

## Purpose of this Repository

This repository aims to provide an up-to-date and automatically generated (from [original IP feed](https://mask-api.icloud.com/egress-ip-ranges.csv)) list of iCloud Private Relay egress IP addresses in various formats. By using these IP address lists, you can easily integrate iCloud Private Relay support into your network infrastructure, such as firewalls, proxy servers, or load balancers.

## Directory Structure

The repository is organized as follows:


- **ip-ranges.ipset**: IP address list in `ipset` format containing both IPv4 and IPv6 addresses.
- **ip-ranges.json**: IP address list in JSON format containing both IPv4 and IPv6 addresses.
- **ip-ranges.txt**: IP address list in plain text format containing both IPv4 and IPv6 addresses.
- **ipv4**: Subdirectory containing IPv4-specific IP address lists.
    - **ipv4-ranges.ipset**: IP address list in `ipset` format containing only IPv4 addresses.
    - **ipv4-ranges.json**: IP address list in JSON format containing only IPv4 addresses.
    - **ipv4-ranges.txt**: IP address list in plain text format containing only IPv4 addresses.
- **ipv6**: Subdirectory containing IPv6-specific IP address lists.
    - **ipv6-ranges.ipset**: IP address list in `ipset` format containing only IPv6 addresses.
    - **ipv6-ranges.json**: IP address list in JSON format containing only IPv6 addresses.
    - **ipv6-ranges.txt**: IP address list in plain text format containing only IPv6 addresses.

## How to Use

You can use any of the provided IP address lists based on your network infrastructure requirements. For example:

- If you use iptables with ipset, you can use the `ip-ranges.ipset` or the appropriate IPv4/IPv6 specific `ipset` files.
- For programmatic access, you may prefer the JSON format (`ip-ranges.json` or specific IPv4/IPv6 JSON files).
- The plain text format (`ip-ranges.txt` or specific IPv4/IPv6 text files) can be handy for manual configuration or quick reference.

## Updates and Maintenance

This repository is automatically updated at regular intervals to ensure the IP address lists remain up-to-date with the latest iCloud Private Relay egress IP addresses. The update process involves querying official sources and automated validation to provide accurate and reliable information.

## Contributing

Contributions to this project are welcome! If you have suggestions, improvements, or updates to the iCloud Private Relay egress IP address list, feel free to open an issue or submit a pull request.

## Disclaimer

This project is not affiliated with Apple Inc. The provided iCloud Private Relay egress IP address lists are generated based on available public information and might not cover all possible IP ranges used by iCloud Private Relay. Please use this information responsibly and verify it against official sources.

## License

This project is licensed under the [MIT License](LICENSE). Feel free to use the provided IP address lists for personal or commercial purposes, but please refer to the license file for more details.

Thank you for using the Auto-Generated iCloud Private Relay Egress IP Address List! If you find this project useful, consider giving it a star to show your support. If you encounter any issues or have any questions, don't hesitate to reach out. Happy coding!
