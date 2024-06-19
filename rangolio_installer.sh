#!/bin/bash

# Function to check the existence of a command
command_exists() {
    command -v "$1" &> /dev/null
}

# Detect the package manager and install necessary packages
detect_package_manager() {
    if command_exists apt-get; then
        echo "Detected package manager: APT (Debian, Ubuntu, etc.)"
        sudo apt-get update
        sudo apt-get install -y python3 python3-pip python3-venv git npm curl xterm python
    elif command_exists dnf; then
        echo "Detected package manager: DNF (Fedora)"
        sudo dnf check-update
        sudo dnf install -y python3 python3-pip python3-venv git npm curl xterm
    elif command_exists zypper; then
        echo "Detected package manager: Zypper (openSUSE)"
        sudo zypper refresh
        sudo zypper install -y python3 python3-pip python3-venv git npm curl xterm
    elif command_exists pacman; then
        echo "Detected package manager: Pacman (Arch)"
        sudo pacman -Syu
        sudo pacman -S --noconfirm python python-pip python-venv git npm curl xterm
    else
        echo "Package manager not detected. Unsupported OS or package manager."
        exit 1
    fi
}

# Install Node.js using NVM
install_nodejs() {
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install v18.20.3
  }
  
  # Set up the viewable UI
setup_viewable_ui() {
  cd rangolio/frontend/viewable-ui/
  npm install
  npm run build:server
  npm run build:ghpages
}
 
  # Set up the editable UI
setup_editor_ui() {
  cd ../editable-ui/
  npm install
  npm run build
}
  
  # Set up the backend
setup_editor_backend() {
  cd ../../backend
  mkdir -p templates
  python3 -m venv .env
  source .env/bin/activate
  pip install -r requirements.txt
  python manage.py collectstatic --no-input
  cp static/index.html templates/
  python manage.py makemigrations
  python manage.py migrate
}

create_run_script() {
  RUN_SCRIPT="$PWD/start_editor.sh"
  echo "#!/bin/bash" > $RUN_SCRIPT
  echo "cd $PWD" >> $RUN_SCRIPT
  echo "source .env/bin/activate" >> $RUN_SCRIPT
  echo "xterm -e \"bash -c 'source .env/bin/activate; python manage.py runserver'\" &" >> $RUN_SCRIPT
  echo "sleep 5" >> $RUN_SCRIPT
  echo "xdg-open http://127.0.0.1:8000/" >> $RUN_SCRIPT
  chmod +x $RUN_SCRIPT
}
  
  # Create a desktop entry
create_desktop_entry() {
  DESKTOP_ENTRY="[Desktop Entry]
  Name=Rangolio Manage Content
  Exec=$PWD/start_editor.sh
  Icon=$PWD/icons/png/256x256.png
  Type=Application
  Terminal=false
  Categories=Development;"
  
  mkdir -p "$HOME/.local/share/applications"
  echo "$DESKTOP_ENTRY" > "$HOME/.local/share/applications/rangolio-manage-content.desktop"
  chmod +x "$HOME/.local/share/applications/rangolio-manage-content.desktop"
}
  
main() {
  echo "Installing OS Dependencies"
  detect_package_manager
  install_nodejs
  
  echo "Cloning Rangolio"
  git clone https://github.com/barunespadhy/rangolio.git

  echo "Setting up Rangolio UI"
  setup_viewable_ui
  setup_editor_ui
    
  echo "Setting up Rangolio Editor Functions"
  setup_editor_backend
  
  echo "Create menu entry"
  create_run_script
  create_desktop_entry
}
  
main
  
exit 0
  
