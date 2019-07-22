## Volcano Helm Chart
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fvolcano-sh%2Fcharts.svg?type=shield)](https://app.fossa.io/projects/git%2Bgithub.com%2Fvolcano-sh%2Fcharts?ref=badge_shield)


Generate Helm chart package whenever a change has been made in chart/volcano folder.

This guide will be helpful to generate helm chart package and index.yaml from that package.

### Generate Helm Package

```
## This command will generate a .tgz file in current folder
helm package chart/volcano

## Move generated file to package directory
mv volcano-{$version}.tgz package
```

### Generate index.yaml file

```
## This command will generate index.yaml file in package directory as package/index.yaml
helm repo index package --url https://volcano-sh.github.io/charts/package

## move index.yaml file from package to current directory
mv package/index.yaml .
```

## License
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fvolcano-sh%2Fcharts.svg?type=large)](https://app.fossa.io/projects/git%2Bgithub.com%2Fvolcano-sh%2Fcharts?ref=badge_large)