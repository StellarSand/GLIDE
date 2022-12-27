# GLIDE
**G**NU/**L**inux **I**SO **D**ownload**e**r

Download latest GNU/Linux ISO directly from terminal and auto check its authenticity and integrity.



## Contents
- [Available distros to download](#available-distros-to-download)
- [Usage](#usage)
- [List of available options](#list-of-available-options)
- [Example usage](#example-usage)
- [Roadmap](#roadmap)
- [Contributing](#contributing)



## Available distros to download
All downloaded files are always the latest ones.

- [Arch Linux](https://archlinux.org/)
- [CentOS Stream](https://www.centos.org/)
- [Debian](https://www.debian.org/)
- [Endeavour OS](https://endeavouros.com/)
- [Fedora Workstation](https://getfedora.org/)
- [Kali Linux](https://www.kali.org/)
- [Linux Mint](https://linuxmint.com/)
- [Manjaro](https://manjaro.org/)
- [Ubuntu](https://ubuntu.com/)
- [Ubuntu LTS](https://ubuntu.com/)



## Usage
To use this script

**1. Clone this repo:**
```
git clone https://github.com/the-weird-aquarian/GLIDE.git
```

**2. Move into the project directory:**
```
cd GLIDE
```

**3. Give executable permissions to the script:**
```
chmod +x glide
```

**4. Run the script:**
```
./glide -n <distro name>
```



## List of available options
```
 -h       Print usage
 -l       Show available distro list
 -d       Change default download directory
 -n       Distro name (from available list)
```



## Example usage
- To show available distro list:
```
./glide -l
```
- To download Linux Mint ISO:
```
./glide -n linuxmint
```



## Roadmap
- More distros will be added soon.
- Currently only 64-bit ISO are downloaded. ARM ISO will be added in the future.



## Contributing
Pull requests can be submitted [here](https://github.com/the-weird-aquarian/GLIDE/pulls). Any contribution to the project will be highly appreciated.
