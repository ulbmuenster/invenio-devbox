# Invenio-devbox

This repository provides a starting point for a development environment for InvenioRDM with [Devbox](https://www.jetpack.io/devbox/docs/).

## Prerequisits

### Docker

Docker and `docker compose` must be installed on the host, here are the steps for Debian-based systems (always refer
to [the official documentation](https://docs.docker.com/engine/install/)!)

#### Installation via the package manager:

Attention: The package sources must also be adapted for
this: https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository

`sudo apt install docker docker-compose-plugin`

For the latest Docker version (not necessary for Invenio) please proceed as follows (see also for current information
always the official documentation: https://docs.docker.com/engine/install/ubuntu/)

Attention: _If an Ubuntu derivative such as Linux Mint is used, `UBUNTU_CODENAME` may have to be used instead
of `VERSION_CODENAME`._

```bash
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg lsb-release
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
# DOCKER-COMPOSE
sudo curl -L https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
# Add current user to the Docker group:
sudo groupadd docker
sudo usermod -aG docker ${USER}
# After that, log out and log back in to apply the changes and test Docker:
docker run hello-world
docker compose version
```

### Devbox

```
curl -fsSL https://get.jetpack.io/devbox | bash
```

or use `wget` if `cURL` is not installed:

```
wget -qO- https://get.jetpack.io/devbox | bash
```

# Activate Devbox

After cloning this repository, execute in the folder with the `devbox.json`:

```
devbox shell
```

`nix` will be installed.

# Install InvenioRDM

In activated devbox shell:

```
devbox run install-empty
```

- You will be prompted to enter a name for your new instance or accept the default _my-site_
- Choosing a custom name that contains a dash (e.g. `my-instance`) leads to an error and should therefore be avoided
- After installation navigate to your instance directory, e.g.:
  - `cd my-site`
- Start your new InvenioRDM instance:
  - `invenio-cli run`
- Open your browser and navigate to `https://127.0.0.1:5000`
  - Click the button for “Advanced…” options and click “Accept the risk and continue”
- You can log in with the already activated admin account:
  - user: `admin@inveniosoftware.org`, password: `123456`
- Enjoy your fresh InvenioRDM installation!

## Useful provided commands

The aliases work directly after installation. (If not you might need to exit the devbox environment and re-enter it.)

- `iab`: assets build
- `ir`: run
- `iaw`: assets watch
- `feierabend`: shuts down containers and exits the devbox

## Information

- Devbox needs its own VirtualEnv, in which the `invenio-cli` is then also installed. Pipenv uses the Virtualenv after.
- Docker must already be running on the host, otherwise `nix` cannot start the daemon.
- The warning `Skipping venv creation, '/home/myusername/InvenioRDM/invenio-devbox/.devbox/virtenv/python39Packages.pip/.venv' already exists You can activate the virtual environment by running 'source $VENV_DIR/bin/activate'`
  is due to Nix and must be ignored.

## Remarks: macOS

If you get an error like 

```bash
OSError: cannot load library 'libgobject-2.0-0': dlopen(libgobject-2.0-0, 0x0002): tried: 'libgobject-2.0-0' (no such file), '/System/Volumes/Preboot/Cryptexes/OSlibgobject-2.0-0' (no such file), '/usr/lib/libgobject-2.0-0' (no such file, not in dyld cache), 'libgobject-2.0-0' (no such file).  Additionally, ctypes.util.find_library() did not manage to locate a library called 'libgobject-2.0-0'
```

you might try `brew install glib pango harfbuzz fontconfig cairo` (see https://brew.sh/) and then:

```bash
sudo ln -s /opt/homebrew/opt/glib/lib/libgobject-2.0.0.dylib /usr/local/lib/gobject-2.0
sudo ln -s /opt/homebrew/opt/pango/lib/libpango-1.0.dylib /usr/local/lib/pango-1.0
sudo ln -s /opt/homebrew/opt/harfbuzz/lib/libharfbuzz.dylib /usr/local/lib/harfbuzz
sudo ln -s /opt/homebrew/opt/fontconfig/lib/libfontconfig.1.dylib /usr/local/lib/fontconfig-1
sudo ln -s /opt/homebrew/opt/pango/lib/libpangoft2-1.0.dylib /usr/local/lib/pangoft2-1.0
sudo ln -s /opt/homebrew/opt/cairo/lib/libcairo.2.dylib /usr/local/lib/cairo
```

# License

Copyright (C) 2023 University of Münster.

Invenio-devbox is free software; you can redistribute it and/or
modify it under the terms of the MIT License; see LICENSE file for more
details.
