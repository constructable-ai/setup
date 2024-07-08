# Setup

This is a public repo that provides a script which allows a new employee to quickly get basic development
tools installed on a fresh Macbook. There are three steps to getting a development environment setup:

* Install system level tools
* Add SSH keys to Github
* Clone the repository and install development tools

Follow the steps in the sections below.

# Join the Constructable Github organization

Send John a Slack message with your Github username and ask to be added to the Constructable Github
organization.

# Run the system setup script

It installs Homebrew, Git, and sets up SSH keys so the employee can
get access to private repositories. To run the setup script, execute the following command from a terminal:

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/constructable-ai/setup/main/setup-system.sh)"
```

# Add your SSH key to Github

The setup script will copy an SSH key to your clipboard. Visit this Github URL:
https://github.com/settings/keys

Click on the "New SSH Key" button and supply your newly generated SSH key.

# Run the development environment setup script

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/constructable-ai/setup/main/setup-development.sh)"
```

# Start the server

Change directory to the CPM project directory

```shell
cd ~/cpm
```

Start the development server

```shell
foreman start
```

In your browser, you can now access the development server at http://localhost:5173
