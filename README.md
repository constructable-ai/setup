# Setup

This is a public repo that provides a script which allows a new employee to quickly get basic development tools installed on a fresh Macbook. It installs Homebrew, Git, and sets up SSH keys so the employee can
get access to private repositories.

# Running the script

To run the setup script, execute the following command from a terminal:

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/constructable-ai/setup/main/setup-macos.sh)"
```

The script will output an SSH key that you can Slack to John to get you setup with Github.

