# Setup

This is a public repo that provides a script which allows a new employee such as yourself to quickly
get basic development tools installed on a fresh Macbook. There are three steps to getting a
development environment setup:

* Install system level tools
* Add SSH keys to Github
* Clone the repository and install development tools

Follow the steps in the sections below.

# 1. Join Constructable on Github

Send John a Slack message with your Github username and ask to be added to the Constructable Github
organization.

# 2. Run the system setup script

This script installs basic system utilities like Homebrew and Git and sets up SSH keys so the you
can get access to private repositories. To run the setup script, execute the following command from
a terminal:

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/constructable-ai/setup/main/setup-system.sh)"
```

Press enter to close the terminal when the script finishes.

# 3. Add your SSH key to Github

The setup script will copy an SSH key to your clipboard. Visit this Github URL:
https://github.com/settings/keys

Click on the "New SSH Key" button and supply your newly generated SSH key. Specify a title that will help you
identify which computer you generated the SSH keys for and specify "Authentication" as the key type.

# 4. Run the development setup script

Open a new terminal and run the development setup script:

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/constructable-ai/setup/main/setup-development.sh)"
```

Press enter to close the terminal when the script finishes.

# 5. Start the server

Open a new Terminal and change directory to the CPM project directory

```shell
cd ~/cpm
```

Start the development server

```shell
foreman start
```

In your browser, you can now access the development server at:
http://localhost:5173
