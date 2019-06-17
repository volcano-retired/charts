## Volcano Helm Chart

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