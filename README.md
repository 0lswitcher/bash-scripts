
<p align="center">
  <img src="md-assets/bash.png"
   style="width: 25%; height: 25%">
</p>

<br>

[![Typing SVG](https://readme-typing-svg.demolab.com?font=Fira+Code&size=100&duration=2500&pause=1000&color=B277F7&center=true&vCenter=true&width=1920&height=100&lines=0lswitcher's+Bash+Scripts)](https://git.io/typing-svg)

<h1></h1>

<p align="center"><br>
  My personal collection of bash scripts I use on a regular basis.<br>
  <br>
  Kinda lazy sometimes so POSIX compliance is dependant on how much effort I felt like putting in that day.<br>
  <br>
  All code is licensed under the <a href="LICENSE">Unlicense License</a>. (do whatever u want idc)
</p>

<h1></h1>

<div align="center">

<br>

<a href="#scripts-overview"><kbd>&emsp;<br>&emsp;Scripts Overview&emsp;<br>&emsp;</kbd></a>&ensp;&ensp;
<a href="#key-info"><kbd>&emsp;<br>&emsp;Key Info&emsp;<br>&emsp;</kbd></a>&ensp;&ensp;
<a href="#license"><kbd>&emsp;<br>&emsp;License&emsp;<br>&emsp;</kbd></a>&ensp;&ensp;
<a href="#contributing"><kbd>&emsp;<br>&emsp;Contributing&emsp;<br>&emsp;</kbd></a>&ensp;&ensp;

</div>

> [!TIP]
> **Updates:** \
> Check out the new [`pywal-to-glance.sh`](scripts/pywal-to-glance.sh) script! \
> Check out the new [`pywal-to-kando.sh`](scripts/pywal-to-kando.sh) script! \
> Check out the new [`pywal-wrapper.sh`](scripts/pywal-wrapper.sh) script! \
> Check out the new [`colorscheme-picker.sh`](scripts/colorscheme-picker.sh) script! (Replaces previous `theme-picker.sh` script) \
> Check out the new [`workspace-previews-wrapper.sh`](scripts/workspace-previews-wrapper.sh) script! \
> \
> Replaced all instances of `swww` w/ `awww` due to LGFae (*the creator of `swww`*) renaming the project. \
> The story behind this is both hilarious and tragic-and I highly encourage you to go read the blog post \
> regarding the renaming: [Renaming swww](https://www.lgfae.com/posts/2025-10-29-RenamingSwww.html)

> [!WARNING]
> Please refrain from using nix-bootstrap.sh on a machine you care about until I verify this build \
> on multiple machines. As of now consider it in beta. Thanks!

---

## Repository Structure
```
bash-scripts/
├── md-assets/ 
├── scripts/
|  ├── awww-as-theme.sh 
|  ├── background-picker.sh 
|  ├── backup.sh
|  ├── colorscheme-picker.sh
|  ├── cya-downloads.sh
|  ├── got-git?.sh
|  ├── kando-wrapper.sh
|  ├── nix-bootstrap.sh 
|  ├── pywal-to-glance.sh
|  ├── pywal-to-kando.sh
|  ├── pywal-to-spicetify.sh 
|  ├── pywal-wrapper.sh
|  ├── random-background.sh 
|  ├── swww-as-theme.sh 
|  ├── workspace-previews-capture.sh 
|  ├── workspace-previews-popup.sh 
|  └── workspace-previews-wrapper.sh
├── themes/
|  ├── base16-apathy.png 
|  ├── base16-apathy.sh
|  ├── base16-ashes.png
|  ├── base16-ashes.sh
|  ├── base16-atalier-estuary.png
|  ├── base16-atalier-estuary.sh
|  ├── base16-codeschool.png
|  ├── base16-codeschool.sh
|  ├── base16-dracula.png
|  ├── base16-dracula.sh
|  ├── base16-greenscreen.png
|  ├── base16-greenscreen.sh
|  ├── base16-gruvbox-hard.png
|  ├── base16-gruvbox-hard.sh
|  ├── base16-gruvbox-medium.png
|  ├── base16-gruvbox-medium.sh
|  ├── base16-harmonic.png
|  ├── base16-harmonic.sh
|  ├── base16-icy.png
|  ├── base16-icy.sh
|  ├── base16-materia.png
|  ├── base16-materia.sh
|  ├── base16-material-palenight.png
|  ├── base16-material-palenight.sh
|  ├── base16-mellow-purple.png
|  ├── base16-mellow-purple.sh
|  ├── base16-mocha.png
|  ├── base16-mocha.sh
|  ├── base16-monokai.png
|  ├── base16-monokai.sh
|  ├── base16-nord.png
|  ├── base16-nord.sh
|  ├── base16-ocean.png
|  ├── base16-ocean.sh
|  ├── base16-rebecca.png
|  ├── base16-rebecca.sh
|  ├── dkeg-amiox.png
|  └── dkeg-amiox.sh
├── LICENSE 
└── README.md 
```

<a id="scripts-overview"></a>

## Script's Overview

| Script          | Description | Required Dependencies |
|-----------------|-------------|------------|
| [awww-as-theme.sh](scripts/swww-as-theme.sh) | Converts current background / wallpaper into Pywal theme | awww, current-awww-img (reference background-picker.sh, you can easily generate this yourself any way you desire) |
| [background-picker.sh](scripts/background-picker.sh) | Background / wallpaper picker | fzf, feh, awww |
| [backup.sh](scripts/backup.sh) | Backup files and directories easily | none |
| [colorscheme-picker.sh](scripts/colorscheme-picker.sh) | Colorscheme / Theme Picker | fzf, feh, pywal, themes folder |
| [cya-downloads.sh](scripts/cya-downloads.sh) | Say goodbye to dumb Downloads folders appearing in your $HOME dir | none |
| [got-git?.sh](scripts/got-git?.sh) | Check which dirs are git repos and show their status | git |
| [kando-wrapper.sh](scripts/kando-wrapper.sh) | Conditionally launch kando pie menu (fix for hyprland boot) | kando, hyprland |
| [nix-bootstrap.sh](scripts/nix-bootstrap.sh) | Bootstrap NixOS w/ lots of options | none |
| [pywal-to-glance.sh](scripts/pywal-to-glance.sh) | Converts current Pywal theme to a Glance server dashboard theme | pywal, glance |
| [pywal-to-kando.sh](scripts/pywal-to-kando.sh) | Converts current Pywal theme to a Kando pie menu theme | pywal, jq, kando |
| [pywal-to-spicetify.sh](scripts/pywal-to-spicetify.sh) | Converts current Pywal theme to a Spicetify theme | pywal, jq, spotify, spicetify |
| [pywal-wrapper.sh](scripts/pywal-wrapper.sh) | Execute theme changes | pywal, waypaper* (SEE NOTE AHEAD!) |
| [random-background.sh](scripts/random-background.sh) | Random background / wallpaper picker | awww |
| [swww-as-theme.sh](scripts/swww-as-theme.sh) | Converts current background / wallpaper into Pywal theme | current-swww-img (reference background-picker.sh, you can easily generate this yourself any way you desire) |
| [workspace-previews-capture.sh](scripts/workspace-previews-capture.sh) | Mini workspace previews (capturer) | hyprland, hyprshot, workspace-previews-popup.sh |
| [workspace-previews-popup.sh](scripts/workspace-previews-popup.sh) | Mini workspace previews (display popups) | feh, workspace-previews-capture.sh |
| [workspace-previews-wrapper.sh](scripts/workspace-previews-wrapper.sh) | Mini workspace previews (wrapper) | workspace-previews-capture.sh, workspace-previews-popup.sh |

<a id="key-info"></a>

> [!TIP]
> Read below for important information regarding each script.

# AWWW as theme
This script works great in tandem with `pywal-wrapper.sh`, simply run that script on line 7 and now you're theming everything w/ one script. \
Very useful for when you don't have a wallpaper setter capable of running post commands.

# SWWW as theme
This script is largely deprecated in favor of `awww-as-theme.sh` , due to LGFae (*the creator of `swww`*) \
renaming the project to `awww`. The story behind this is both hilarious and tragic-and I highly encourage \
you to go read the blog post regarding the renaming: [Renaming swww](https://www.lgfae.com/posts/2025-10-29-RenamingSwww.html)

I'll keep the script here for now for those who's distro's have not yet packaged awww, but this will be \
going within the next few commits once everyone has had time to migrate. 

# Background Picker
Line 80 appends a file with the current selected background. This can be used for a number of things, I personally used it in the ~~`swww-as-theme.sh`~~ `awww-as-theme.sh` script.

# Backup
Checks to see if I'm running the script, if not it runs in a configuration with standard `xdg-usr-dirs` and options designed more around general usage. \
Also contains a custom option so you can backup whatever you want to wherever you want.

# Colorscheme Picker
Custom colorscheme picker using fzf and feh. \
Shows 19+ pywal colorschemes to choose from, with easy expandability. \
Line 75 runs `pywal-wrapper.sh` , which executes the desired theme change across many programs.  
- *Read ahead to Pywal Wrapper for more information*

# Cya Downloads
This checks for both Capitalized (Downloads) and lowercase (downloads) folders hanging out in $HOME. \
Moves any files within to a desired location (with confirmation) before deleting the folders. \
Run manually, or schedule to run on a regular basis!

# Got Git?
~~The `$BASE_DIR` var is used for the directory that holds the majority of your github repositories, (typically if you're a dev) and the `$EXTRA_DIRS` var is used for seperate directories that have git initialized at root. (Typically for dotfiles or other GNU Stow managed repositories.)~~\
Removed `$EXTRA_DIRS` in favor of symlinking any seperate repo's to `$BASE_DIR`

# Kando Wrapper
Relaunches the kando pie menu on first boot, since Hyprland fails to on launch. \
Hacky fix, but works for now. Will likely become obsolete in future Kando/Hyprland releases.

# Nix(OS) Bootstrap
A complete NixOS system bootstrap designed to be ran post .iso installation and drive formatting. \
Allows for online or even offline installation the if repo files are held on usb or already on your system. \
<br>
Currently has 3 configuration profiles:
> `Server`, `Minimal`, and `Full`. \
> (Ranked in order of smallest to largest final size) 

And 2 hardware profiles:
>`Desktop`, `Laptop` \
(Does not effect `hardware-configuration.nix`, only additional dotfiles.)

Which configures the following:
> - username
> - hostname
> - `configuration.nix`
>   - `environment.systemPackages`
>   - `environment.sessionVariables`
>   - `programs`
>   - `services`
>   - `system.stateVersion`
> - dotfiles
>   - hyprland
>   - waybar
>   - theming
>   - lots n lots more
> - `$HOME` directory 
> - wallpapers *(optional)*

For a more verbose writeup on `nix-bootstrap.sh`, please visit [my nixfiles repository](https://github.com/0lswitcher/nixfiles)

# Pywal to Glance (Self-Hosted Server Dashboard)
Updates your glance server dashboard default colorscheme with your pywal theme. \
If your server is hosted on a headless machine that you SSH into like me, you'll need to have the filsystem mounted \
with `SSHFS` instead of temporarily accessing w/ `SFTP` so that the script can read your `glance.yml` file. \
\
Please set the `GLANCE_CONFIG` variable to your `glance.yml` before launching.

# Pywal to Kando
Converts pywal theme to kando theme. \
**Should be** compatible with all Kando installation methods (APT, Flatpak, nixpkgs, AUR, etc.)

# Pywal to Spicetify
Converts pywal theme to modified 'text' spicetify theme. \
I'm biased, but it looks especially great with my custom theme: [SpotNeoTify](https://github.com/0lswitcher/spotneotify).  
> [!TIP]
> SpotNeoTify is now available on the Spicetify Marketplace!  
  
Compatible with most Spotify installation methods, excluding Snap and Homebrew. \
To use with either of these installation methods, please manually configure the file paths. \
I'll update the script to check for these methods automatically soon!

# Pywal Wrapper
What allows the newly set theme to be smoothly updated across all programs in real time. \
Written to be quick but conditional, so programs only refresh or relaunch if they were already open. \
If you don't have some of the programs or scripts inside, it will still run just fine. \
All you need is pywal, and any wallpaper selector that can run post-selection commands. \
Designed to run with waypaper, but can be easily configured.
> *A front-end-less version is coming soon, essentially functioning as a combination  
of `background-picker.sh` and `colorscheme-picker.sh` , I just need to update my current version.*

**USAGE:** \
`~/.config/waypaper/config.ini`
```
[Settings]
...
post_command = bash -lc '/root/path/to/pywal-wrapper.sh'
```


# Random Background
Sets a random background. \
Nothing too special to note besides the usual synchronization w/ other scripts.

# Theme Picker
I have removed this script for now in favor of using `waypaper` as a front-end to launch \
`pywal-wrapper.sh` post wallpaper selection, but I am rewriting it so those who don't \
have a wallpaper selector capable of running post-selection commands can still have the fast transitions.\
\
Until then, please set your wallpaper however you desire, then run `awww-as-theme.sh`.

# Workspace Previews (Capture & Popup)
I missed the mini workspace preview feature of most XFCE based distros, so I made something that would work for Hyprland.  
These two scripts (`workspace-previews-capture.sh` & `workspace-previews-popup.sh`) depend on each other to work properly.

> [!WARNING]
> If you have multiple monitors, this script will likely fuck with your copy and paste abilities.  
> Hyprshot simply needs some extra configuration to not copy the screenshot to the system clipboard.  
> Hope this helps!


<a id="license"></a>

## License
This repository is licensed under the [Unlicense License](LICENSE). (do whatever u want idc)

<a id="contributing"></a>

## Contributing
1. Fork the repo  
2. Create a branch for your feature/fix  
3. Submit a pull request  

---

<p align="center">
  <sub>all built with ❤️  by 0lswitcher</sub>
</p>
