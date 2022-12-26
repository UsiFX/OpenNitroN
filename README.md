![OpenNitroN](https://raw.githubusercontent.com/UsiFX/OpenNitroN/main/etc/banners/frame_17.png)

# <div align=center> The NitroN: Open Edition </div>

<a href="https://app.codiga.io/hub/project/34591/OpenNitroN/dashboard">
  <img src="https://api.codiga.io/project/34591/score/svg" alt="Codescore">
</a>

<a href="https://app.codiga.io/hub/project/34591/OpenNitroN/dashboard">
  <img src="https://api.codiga.io/project/34591/status/svg" alt="Codequality">
</a>

<a href="https://github.com/UsiFX/OpenNitroN/fork">
  <img src="https://img.shields.io/github/forks/UsiFX/OpenNitroN.svg?logo=github" alt="Forks">
</a>

<a href="https://github.com/UsiFX/OpenNitroN/stargazers">
  <img src="https://img.shields.io/github/stars/UsiFX/OpenNitroN.svg?logo=github-sponsors" alt="Stars">
</a>

![GitHub All Releases](https://img.shields.io/github/downloads/UsiFX/openNitroN/total?label=Downloads%20on%20GitHub)

## Table of Contents

- [Overview](#overview)
- [Requirements](#requirements)
- [Installation](#installation)
- [Options](#options)
- [Reporting Issues](#reporting-issues)
- [License](#license)

## Overview
OpenNitroN (`nitrond`) is a two-way modular Universal kernel 
optimizer written in bash which is extensive.

What it means to be Universal two-way is that it is
an argument-based script and a menu-based script for Android and/or Linux platforms.

## Requirements
- A compatible Linux system
- SuperUser permissions

## Installation

**for linux:**

 - Debain-based (alternatives):
Download from Github Releases the __.deb__ file then install it via,
``` bash
$ sudo dpkg -i <file_directory>/<filename>.deb
```

 - Archlinux-based (alternatives):
NitronX is already in AUR Packages and you can install it via `yay`, via:
``` bash
$ yay -S nitronx
```

 - other:
The installer (`installer.sh`) simply clones this repository
in your home's Directory (`/home`) and creates copy of the executables
in `/usr/bin` for the daemon itself, and/or `/usr/include` for the header file
by simply run:
``` bash
 wget https://raw.githubusercontent.com/UsiFX/OpenNitroN/main/installer.sh && bash installer.sh install
```
it should output you the following:
``` bash
$ wget https://raw.githubusercontent.com/UsiFX/OpenNitroN/main/installer.sh && bash installer.sh install
usage: installer.sh [install] [uninstall]
```
use the script according to your opinion.

**for android:**
  - for developers:
if you wanna build the source code and have fun modifying it we have made it easier
by making a small build script.
just run it by:
```bash
bash smmt_builder.sh [OPTIONS]
```

replace [OPTIONS] with compiler arguments such as `--clean` & `--shellcheck`

  - for users:
go to release section and download latest official build from [here](https://www.pling.com/p/1627867/).

## Options
```
Usage: nitrond [OPTION] (e.g. nitrond --update)

Commands:
 auto         automatically change mode up on some scenarios
 cli          sort options into friendly-like TUI
 deviceinfo   shows device resource information
 clean        wipe stored nitron data

Options:
 -sg, --set-green       applies ultra power saving scenario
 -sr, --set-red         applies performance scenario
 -sy, --set-yellow      applies balance scenario
 -v, --version          prints license and version
 -h, --help             shows this help menu
 -m, --mode             prints current mode
 -d, --debug            saves shell debug instructions
```

## Reporting Issues

Found a problem? Want a new feature? Have a question?
First of all see if your issue, question or idea has [already been reported](https://github.com/UsiFX/OpenNitroN/issues?q=is%3Aissue). 
If don't, just open a [new clear and descriptive issue](https://github.com/UsiFX/OpenNitroN/issues/new/choose).

## License

```
nitronD (An Extensive Kernel tweaker)
Copyright (c) 2022-2023 UsiFX <xprjkts@gmail.com>

                       GNU GENERAL PUBLIC LICENSE
                        Version 3, 29 June 2007

Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
Everyone is permitted to copy and distribute verbatim copies
of this license document, but changing it is not allowed.
```

### Buy me a Coffee?

PAYPAL: `xprjkts@gmail.com`

KO-FI: `https://ko-fi.com/xprjkt`
