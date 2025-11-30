# hops

**hops** is a simple network inspection tool written in Bash.

<img width="720" alt="hops v1.0.2" src="https://github.com/user-attachments/assets/993da948-6cfb-4867-b6c9-38d07f0dc1b0" />

It resolves IPv4/IPv6 addresses, performs rDNS (PTR) lookups, lists nameservers (NS), and traces network hops with ASN and organization information via dig, traceroute, rdap, and Team Cymru's whois.

## Features

- IPv4 and IPv6 resolution  
- rDNS (PTR) lookup  
- Nameserver (NS) listing with IP and ASN  
- Traceroute enriched with ASN/Org  
- Colored output (True Color 24-bit) readable in terminal  
- JSON export for integration with other systems (e.g., <code>jq</code>)  
- Licensed under GPLv3+

## Installation

### Standard installation
```
sudo make install
```

Installs:
- Binary: `/usr/local/bin/hops`  
- Manpage: `/usr/local/share/man/man1/hops.1`

### Custom installation
```
make install PREFIX=/opt/hops
```

### For packaging
```
make install DESTDIR=./pkg
```

## Dependencies

`hops` depends on the following tools already present in Unix-like systems:

- dig  
- traceroute  
- whois  
- awk, grep, timeout (basic utilities)

Check with:
```
make check
```

## Usage

```
hops [option] <domain>
```

### Options
- <code>-d</code>       → Show IPv4 and IPv6  
- <code>-d4</code>      → Show IPv4 only  
- <code>-d6</code>      → Show IPv6 only  
- <code>-ns</code>      → Show nameservers  
- <code>-a</code>       → Show hops (traceroute)  
- <code>-ptr</code>     → Show reverse DNS (PTR)  
- <code>-json</code>    → JSON output  
- <code>-v</code>       → Show version  
- <code>-h</code>       → Show help  

### Examples
```
hops example.com
hops -d example.com
hops -ns example.com
hops -json example.com
```

## Packaging

Generate tarball and checksum (SHA-256):
```
make dist
```

This creates:
- hops-vX.X.X.tar.gz  
- hops-vX.X.X.tar.gz.sha256  

Verify integrity:
```
make verify
```

## Documentation

Manpage available:
```
man hops
```

## License

Distributed under the GNU General Public License v3 or later (GPLv3+).

See the *COPYING* file or visit: https://www.gnu.org/licenses/gpl-3.0.html

## Contributions

Pull requests are welcome! For larger changes, open an issue first to discuss what you would like to modify.
