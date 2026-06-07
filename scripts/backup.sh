#!/usr/bin/env bash
# backup.sh - versatile backup for a selection of directories, or custom choice

DATE=$(date +%m.%d.%Y)

prompt() {
  local message="$1"
  shift
  local options=("$@")
  local choice

  echo "$message" >&2 # send prompt to stderr so it doesn't interfere with return value
  select choice in "${options[@]}"; do
    if [[ -n "$choice" ]]; then
      echo "$choice" # goes to stdout
      return 0
    else
      echo "Invalid choice. Please try again." >&2
    fi
  done
}

# welcome art

cat <<"EOF"

                                                                  
                ▄▄                                                
                ██                                  ██            
  ██   ██ ▄█▀█▄ ██ ▄████ ▄███▄ ███▄███▄ ▄█▀█▄      ▀██▀▀ ▄███▄ ██ 
  ██ █ ██ ██▄█▀ ██ ██    ██ ██ ██ ██ ██ ██▄█▀       ██   ██ ██    
   ██▀██  ▀█▄▄▄ ██ ▀████ ▀███▀ ██ ██ ██ ▀█▄▄▄ ▄▄    ██   ▀███▀ ██ 
                                             ▄█▀                  
                                                                  
                                                      
  ▄▄                                            ▄▄    
  ██                ▄▄                          ██    
  ████▄  ▀▀█▄ ▄████ ██ ▄█▀ ██ ██ ████▄    ▄█▀▀▀ ████▄ 
  ██ ██ ▄█▀██ ██    ████   ██ ██ ██ ██    ▀███▄ ██ ██ 
  ████▀ ▀█▄██ ▀████ ██ ▀█▄ ▀██▀█ ████▀ ██ ▄▄▄█▀ ██ ██ 
                                 ██                   
                                 ▀▀                   

EOF

# check if the script is running on any of my devices, if not,
# follow conventional filesystem standards so other people can use it
if [ -d /home/y2k ]; then
  USER="y2k"
  echo "Sup y2k, dirs are configured for you."
else
  USER="anon"
  echo -e "Yo anon, dirs are configured for standard xdg-user-dirs,\n  (which you probably have)\nIf you have an unconventional filesystem structure\n(like me) then pick Custom in\nthe following prompts."
fi

if [ "$USER" = "y2k" ]; then
  # install type
  BACKUP_TYPE=$(prompt "Select backup type:" "Bash Scripts" "Pictures" "Junts" "Vault" "Videos" "Custom")

  if [ "$BACKUP_TYPE" = "Bash Scripts" ]; then
    mkdir -p -v /storage/backups/automated/bash/scripts/$DATE
    cp -r ~/stuff/dev/bash/scripts/* -t /storage/backups/automated/bash/scripts/$DATE
    echo "Copied bash scripts :)"
  fi

  if [ "$BACKUP_TYPE" = "Pictures" ]; then
    mkdir -p -v /storage/backups/automated/pictures/$DATE
    cp -r ~/stuff/pictures/* -t /storage/backups/automated/pictures/$DATE
    echo "Copied pictures :)"
  fi

  if [ "$BACKUP_TYPE" = "Junts" ]; then
    mkdir -p -v /storage/backups/automated/junts/$DATE
    cp -r ~/stuff/junts/* -t /storage/backups/automated/junts/$DATE
    echo "Copied junts :)"
  fi

  if [ "$BACKUP_TYPE" = "Vault" ]; then
    mkdir -p -v /storage/backups/automated/vault/$DATE
    cp -r ~/stuff/vault/* -t /storage/backups/automated/vault/$DATE
    echo "Copied obsidian vault :)"
  fi

  if [ "$BACKUP_TYPE" = "Videos" ]; then
    mkdir -p -v /storage/backups/automated/videos/$DATE
    cp -r ~/stuff/videos/* -t /storage/backups/automated/videos/$DATE
    echo "Copied videos :)"
  fi

  if [ "$BACKUP_TYPE" = "Custom" ]; then
    read -r -e -p $'Enter the directory you would like to backup: \n NOTE: Begin with root directory only! \n            ( /home/user/ not ~/ ) \n       Also, no trailing / at the end! \n ' TARGET_DIR
    if [ -z "$TARGET_DIR" ]; then
      echo "Error: Directory cannot be empty. Please try again."
      exit 1
    elif [ -d "$TARGET_DIR" ]; then
      echo "Directory set."
    else
      echo "Error: Directory not found. Please try again."
      exit 1
    fi

    read -r -e -p "Please enter your desired name for this directory: " TARGET_DIR_NAME
    if [ -z "$TARGET_DIR_NAME" ]; then
      echo "Error: Directory name cannot be empty. Please try again."
      exit 1
    else
      echo "Directory name set to: $TARGET_DIR_NAME"
    fi

    mkdir -p -v /storage/backups/$TARGET_DIR_NAME/$DATE
    cp -r $TARGET_DIR/* -t /storage/backups/$TARGET_DIR_NAME/$DATE
    echo "Copied $TARGET_DIR to /storage/backups/ as $TARGET_DIR_NAME :)"
  fi
else
  # result backup dir
  read -r -e -p "Enter your desired directory for the resulting backup files: " BACKUP_DIR
  if [ -z "$BACKUP_DIR" ]; then
    echo "Error: Directory cannot be empty. Please try again."
    exit 1
  elif [ -d "$BACKUP_DIR" ]; then
    echo "Directory set."
  else
    echo "Error: Directory not found. Please try again."
    exit 1
  fi

  # install type
  BACKUP_TYPE=$(prompt "Select backup type:" ".config" "Desktop" "Documents" "Downloads" "Music" "Pictures" "Public" "Templates" "Videos" "Custom")

  if [ "$BACKUP_TYPE" = ".config" ]; then
    mkdir -p -v $BACKUP_DIR/.config/$DATE
    cp -r ~/.config/* -t $BACKUP_DIR/.config/$DATE
    echo "Copied .config :)"
  fi

  if [ "$BACKUP_TYPE" = "Desktop" ]; then
    mkdir -p -v $BACKUP_DIR/Desktop/$DATE
    cp -r ~/Desktop/* -t $BACKUP_DIR/Desktop/$DATE
    echo "Copied Desktop :)"
  fi

  if [ "$BACKUP_TYPE" = "Documents" ]; then
    mkdir -p -v $BACKUP_DIR/Documents/$DATE
    cp -r ~/Documents/* -t $BACKUP_DIR/Documents/$DATE
    echo "Copied Documents :)"
  fi

  if [ "$BACKUP_TYPE" = "Downloads" ]; then
    mkdir -p -v $BACKUP_DIR/Downloads/$DATE
    cp -r ~/Downloads/* -t $BACKUP_DIR/Downloads/$DATE
    echo "Copied Downloads :)"
  fi

  if [ "$BACKUP_TYPE" = "Music" ]; then
    mkdir -p -v $BACKUP_DIR/Music/$DATE
    cp -r ~/Music/* -t $BACKUP_DIR/Music/$DATE
    echo "Copied Music :)"
  fi

  if [ "$BACKUP_TYPE" = "Pictures" ]; then
    mkdir -p -v $BACKUP_DIR/Pictures/$DATE
    cp -r ~/Pictures/* -t $BACKUP_DIR/Pictures/$DATE
    echo "Copied Pictures :)"
  fi

  if [ "$BACKUP_TYPE" = "Public" ]; then
    mkdir -p -v $BACKUP_DIR/Public/$DATE
    cp -r ~/Public/* -t $BACKUP_DIR/Public/$DATE
    echo "Copied Public :)"
  fi

  if [ "$BACKUP_TYPE" = "Templates" ]; then
    mkdir -p -v $BACKUP_DIR/Templates/$DATE
    cp -r ~/Templates/* -t $BACKUP_DIR/Templates/$DATE
    echo "Copied Templates :)"
  fi

  if [ "$BACKUP_TYPE" = "Videos" ]; then
    mkdir -p -v $BACKUP_DIR/Videos/$DATE
    cp -r ~/Videos/* -t $BACKUP_DIR/Videos/$DATE
    echo "Copied Videos :)"
  fi

  if [ "$BACKUP_TYPE" = "Custom" ]; then
    read -r -e -p "Enter the directory you would like to backup: (NO TRAILING /) " TARGET_DIR
    if [ -z "$TARGET_DIR" ]; then
      echo "Error: Directory cannot be empty. Please try again."
      exit 1
    elif [ -d "$TARGET_DIR" ]; then
      echo "Directory set."
    else
      echo "Error: Directory not found. Please try again."
      exit 1
    fi

    read -r -e -p "Please enter your desired name for this directory: " TARGET_DIR_NAME
    if [ -z "$TARGET_DIR_NAME" ]; then
      echo "Error: Directory name cannot be empty. Please try again."
      exit 1
    else
      echo "Directory name set to: $TARGET_DIR_NAME"
    fi

    mkdir -p -v $BACKUP_DIR/$TARGET_DIR_NAME/$DATE
    cp -r $TARGET_DIR/* -t $BACKUP_DIR/$TARGET_DIR_NAME/$DATE
    echo "Copied $TARGET_DIR to $BACKUP_DIR as $TARGET_DIR_NAME :)"
  fi
fi
