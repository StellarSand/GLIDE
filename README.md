# GLIDE
**G**NU/**L**inux **I**SO **D**ownload**e**r

GLIDE is a command line tool that allows you to easily download the latest ISO images for various GNU/Linux distributions directly from the terminal. It also automatically checks the authenticity and integrity of the downloaded files to ensure that you are getting a genuine and unmodified copy of the operating system.



## Contents
- [Available distros to download](#available-distros-to-download)
- [Installation](#installation)
- [Usage](#usage)
- [Uninstall](#uninstall)
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
- [Zorin OS](https://zorin.com/os/)



## Installation
**1. Clone this repo:**
```
git clone https://github.com/StellarSand/GLIDE.git
```

**2. Move into the project directory:**
```
cd GLIDE
```

**3. Give executable permissions to the install script:**
```
chmod +x install.sh
```

**4. Run the install script:**
```
./install.sh
```



## Usage
Using GLIDE is easy, once installed.

```
glide <distro name>
```

Downloading to a specific directory can be done using the `-d` or `--directory` option
```
glide <distro name> -d <directory>
```

**Examples:**
- To show available distro list:
```
glide -l
```

- To download Linux Mint ISO:
```
glide linuxmint
```

- To download Linux Mint ISO to specific directory:
```
glide linuxmint -d /home/user/Desktop
```



## Uninstall
If GLIDE has been installed, you can remove it by:

**1. Clone this repo (if not done already):**
```
git clone https://github.com/StellarSand/GLIDE.git
```

**2. Move into the project directory:**
```
cd GLIDE
```

**3. Give executable permissions to the uninstall script:**
```
chmod +x uninstall.sh
```

**4. Run the uninstall script:**
```
./uninstall.sh
```



## Roadmap
- More distros will be added soon.
- Currently only 64-bit ISO are downloaded. ARM ISO will be added in the future.



## Contributing
Pull requests can be submitted [here](https://github.com/StellarSand/GLIDE/pulls). Any contribution to the project will be highly appreciated.
