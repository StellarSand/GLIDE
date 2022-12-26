# GLIDE
**G**NU/**L**inux **I**SO **D**ownload**e**r

Download a GNU/Linux ISO directly from terminal and auto check it's authenticity and integrity.



## Contents
- [Available distros to download](#available-distros-to-download)
- [Usage](#usage)
- [List of available options](#list-of-available-options)
- [Example usage](#example-usage)
- [Roadmap](#roadmap)
- [Contributing](#contributing)



## Available distros to download

Distro | Version
--- | ---
[Arch Linux](https://archlinux.org/) | 2022.12.01
[CentOS Stream](https://www.centos.org/) | 9
[Debian](https://www.debian.org/) | 11.6.0
[Endeavour OS](https://endeavouros.com/) | 22.1
[Fedora Workstation](https://getfedora.org/) | 37
[Kali Linux](https://www.kali.org/) | 2022.4
[Linux Mint](https://linuxmint.com/) | 21.1
[Ubuntu](https://ubuntu.com/) | 22.10
[Ubuntu LTS](https://ubuntu.com/) | 22.04.1



## Usage
To use this script

**1. Clone this repo:**
```sh
git clone https://github.com/the-weird-aquarian/GLIDE.git
```

**2. Move into the project directory:**
```sh
cd GLIDE
```

**3. Give executable permissions to the script:**
```sh
chmod +x glide
```

**4. Run the script:**
```sh
./glide -n <distro name>
```



## List of available options
```
 -h       Print usage
 -l       Show available distro list
 -d       Change default download directory
 -n       Distro name (from available list)
```



## Example usage:
- To show available distro list:
```sh
./glide -l
```
- To download Linux Mint ISO:
```sh
./glide -n linuxmint
```



## Roadmap
- More distros will be added soon.
- Currently only 64-bit ISO are downloaded. ARM ISO will be added in future.



## Contributing
- The versions file is located at [conf/versions](https://github.com/the-weird-aquarian/GLIDE/blob/main/conf/versions).
- Pull requests can be submitted [here](https://github.com/the-weird-aquarian/GLIDE/pulls)

Any contribution to the project will be highly appreciated.
