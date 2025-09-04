
<p align="center">
  <img src="https://github.com/0lswitcher/bash-scripts/blob/main/md-assets/bash.png"
   style="width: 25%; height: 25%">
</p>

[![Typing SVG](https://readme-typing-svg.demolab.com?font=Fira+Code&size=100&duration=2500&pause=1000&color=B277F7&center=true&vCenter=true&width=1920&height=100&lines=0lswitcher's+Bash+Scripts)](https://git.io/typing-svg)

<h1></h1>

<p align="center">
  My personal collection of bash scripts I use on a regular basis.<br>
  <br>
  Kinda lazy sometimes so POSIX compliance is dependant on how much effort I felt like putting in that day.<br>
  <br>
  All code is licensed under the <a href="LICENSE">Unlicense License</a>. (do whatever u want idc)
</p>

---

## Repository Structure
```
bash-scripts/
├── md-assets/ 
├── scripts/
|  ├── background-picker.sh 
|  ├── cya-downloads.sh
|  ├── pywal-to-spicetify.sh 
|  ├── random-background.sh 
|  ├── swww-as-theme.sh 
|  ├── theme-picker.sh 
|  ├── workspace-previews-capture.sh 
|  └── workspace-previews-popup.sh 
├── LICENSE 
└── README.md 
```

---

## Script's Overview

| Script          | Description | Required Dependencies |
|-----------------|-------------|------------|
| [background-picker.sh](scripts/background-picker.sh) | Background / wallpaper picker | fzf, feh, swww |
| [theme-picker.sh](scripts/theme-picker.sh) | Theme picker | fzf, feh, pywal |
| [cya-downloads.sh](scripts/cya-downloads.sh) | Say goodbye to dumb Downloads folders appearing in your $HOME dir | none |
| [pywal-to-spicetify.sh](scripts/pywal-to-spicetify.sh) | Converts current Pywal theme to a Spicetify theme | pywal, spicetify, cat |
| [random-background.sh](scripts/random-background.sh) | Random background / wallpaper picker | swww |
| [swww-as-theme.sh](scripts/swww-as-theme.sh) | Converts current background / wallpaper into Pywal theme | current-swww-img (reference background-picker.sh, you can easily generate this yourself any way you desire) |
| [workspace-previews-capture.sh](scripts/workspace-previews-capture.sh) | Mini workspace previews (capturer) | hyprland, hyprshot |
| [workspace-previews-popup.sh](scripts/workspace-previews-popup.sh) | Mini workspace previews (display popups) | feh, cat, workspace-previews-capture.sh |

---

> [!TIP]
> Read below for important information regarding each script.

# Background Picker
Line 80 appends a file with the current selected background. This can be used for a number of things, I personally used it in the swww-as-theme.sh script.

# Theme Picker
Similar to background-picker.sh, Line 66 appends a file with the current selected theme. This can be used for a number of things, feel free to experiment!.

# Cya Downloads
This checks for both Capitalized (Downloads) and lowercase (downloads) folders hanging out in $HOME. Moves any files within to a desired location (with confirmation) before deleting the folders. Run manually, or schedule to run on a regular basis!

# Pywal to Spicetify
Applies changes and restarts Spicetify/Spotify by default on run. This script is the reason I still theme hop. It's just fun to watch everything change when used in tandem with my other theming scripts.

# Random Background
Last line of the script sends a notification relaying the selected wallpaper. If you don't have a notification daemon configured, feel free to comment this line out.

# SWWW as theme
This script works great in tandem with pywal-to-spicetify.sh, simply run that script on line 7 and now you're killin two birds w one stone.

# Workspace Previews (Capture & Popup)
I missed the mini workspace preview feature of most XFCE based distros, so I made something that would work for Hyprland.  
These two scripts (workspace-previews-capture.sh & workspace-previews-popup.sh) depend on each other to work properly.

> [!WARNING]
> If you have multiple monitors, this script will likely fuck with your copy and paste abilities. Hyprshot simply needs some extra configuration to not copy the screenshot to the system clipboard. Hope this helps!

---

## License
This repository is licensed under the [Unlicense License](LICENSE). (do whatever u want idc)

---

## Contributing
1. Fork the repo  
2. Create a branch for your feature/fix  
3. Submit a pull request  

---

<p align="center">
  <sub>all built with ❤️  by 0lswitcher</sub>
</p>
