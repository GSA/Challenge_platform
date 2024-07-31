# Challenge.Gov

The Challenge.Gov Platform

## Requirements

* PostgreSQL 16+
* Ruby 3.2+
* Node.js 20.x
* Yarn 1.22.x

## Install and Setup

Install PostgreSQL according to your OS of choice, for MacOS [Postgres.app](https://postgresapp.com/) is recommended.

Install of the languages needed can be done via ASDF or Nix

### ASDF Option

To install Ruby and  NodeJS it is recommended to use the [asdf version manager](https://asdf-vm.com/#/). Install instructions are copied here for MacOS, for other OSs see [asdf docs](https://asdf-vm.com/#/core-manage-asdf-vm). This also assumes you have [HomeBrew](https://brew.sh/) installed.

```bash
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.7.0
echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.bash_profile
echo -e '\n. $HOME/.asdf/completions/asdf.bash' >> ~/.bash_profile

brew install \
  coreutils automake autoconf openssl \
  libyaml readline libxslt libtool unixodbc
```

Once asdf is set up, install each language. NodeJS may require setting up keys, and should display help to guide you.

```bash
asdf plugin-add ruby
asdf install ruby 3.2.4

asdf plugin-add nodejs
bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring
asdf install nodejs 20.15.1

asdf plugin-add yarn
asdf install yarn 1.22.22
```

### Nix Shell Option

Once on your machine, you need to install [the nix package manager](https://nixos.org/download.html#nix-install-macos) by following their multi-user installer. Once nix is installed, setup [direnv](https://direnv.net/) by hooking into your shell. This only has to be done on your machine once.

```bash
nix-env -f '<nixpkgs>' -iA direnv
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
```

Once direnv is installed and your shell is restarted, clone the project and `cd` into it. You should see direnv warn about an untrusted `.envrc` file. Allow the file and finish installing dependencies and setting up the application.

1. Allow direnv to use the envrc file `direnv allow`

## Running Locally

1. Install rubygems dependencies with `bundle install`
1. Install nodejs dependencies `yarn install`
1. Set up your uswds files in the build directory `npx gulp copyAssets`
1. Setup the database `rake db:create`, note that postgres must be running for this to work
1. Boot the system, this will run the sass, esbuild, and uswds watchers along with the rails server
   1. `./bin/dev`

Now you can visit [`localhost:3000`](http://localhost:3000) from your browser.

