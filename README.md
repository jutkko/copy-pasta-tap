# copy-pasta

This repository is based on the [apihub-homebrew-cli](https://github.com/apihub/homebrew-apihub).

## Usage

First, add this tap:

```
brew tap jutkko/copy-pasta-tap
```

Then install the desired formula:

```
brew install copy-pasta
```

If you want to uninstall the copy-pasta command line from your computer:

```
brew uninstall copy-pasta
```

## Publish a new version

> You need to export one environment variable called GITHUB_TOKEN.
> (You should be able to create one token at https://github.com/settings/applications)

> This script assumes that you have github-release installed (https://github.com/aktau/github-release).

```
chmod +x scripts/create_release.sh
./create_release.sh
```

The output looks like the following:

```
Creating "/tmp/dist-src" directory... ok
Downloading copy-pasta source... ok
Restoring dependencies... ok
Creating package...ok
Uploading file to Github...ok

Updating and tagging formula...ok
Removing temporary folder...ok
Generating tag and commiting...ok
```
