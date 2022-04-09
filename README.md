# GLIDO
**G**NU/**L**inux **I**SO **Do**wnloader

Download a GNU/Linux ISO directly from terminal and auto check it's authenticity and integrity.



## Contents
- [Available distros to download](#available-distros-to-download)
- [Usage](#usage)
- [List of available options](#list-of-available-options)
- [Example usage](#example-usage)
- [Roadmap](#roadmap)
- [Contributing](#contributing)



## Available distros to download

**Distro** | **Version**
--- | ---
[Arch Linux](https://archlinux.org/) | 2022.04.05
[Debian](https://www.debian.org/) | 11.3.0
[Endeavour OS](https://endeavouros.com/) | 22.1
[Fedora Workstation](https://getfedora.org/) | 35
[Kali Linux](https://www.kali.org/) | 2022.1
[Linux Mint](https://linuxmint.com/) | 20.03
[Pop!_OS](https://pop.system76.com/) | 21.10
[Pop!_OS LTS](https://pop.system76.com/) | 20.04
[Ubuntu](https://ubuntu.com/) | 21.10
[Ubuntu LTS](https://ubuntu.com/) | 20.04.4



## Usage
To use this script

**1. Clone this repo:**
```sh
git clone https://github.com/the-weird-aquarian/GLIDO.git
```

**2. Move into the project directory:**
```sh
cd GLIDO
```

**3. Give executable permissions to the script:**
```sh
chmod +x glido
```

**4. Run the script:**
```sh
./glido -d <directory name> -n <distro name>
```



## List of available options
```sh
 -h       Print usage
 -l       Show available distro list
 -d       Directory path to download the ISO.
 -n       Distro name (from available list)
```



## Example usage:
- To show available distro list:
```sh
./glido -l
```
- To download Linux Mint ISO:
```sh
./glido -d /home/user/Desktop -n linuxmint
```



## Roadmap
- More distros will be added soon.
- Currently only 64-bit ISO are downloaded. ARM ISO will be added in future.



## Contributing
Any contribution to the project will be highly appreciated.
