# What

This is a repository containing a collection of [Nix](https://nixos.org) flakes, which can be used as templates for your projects.

> :information_source: **Some templates can be used without Nix.**
> 
> Not all the featured templates are [flakes](https://nixos.wiki/wiki/Flakes) and can be used without an installation of Nix.
> Example of that are templates for [docker compose](https://github.com/docker/compose).

# How

## Cli
In order to use the cli to apply templates, you need nix installed.
You can use either of the following installers
- [Official](https://nixos.org/download)
- [DeterminateSystems](https://github.com/DeterminateSystems/nix-installer)

### New project 
To create a new project based on a given template, run
```
nix flake new --template github:grimerssy/flakes#${template} ${project_name}
```
where `${template}` is the name of the directory in this repository which should be used as a template
and `${project_name}` is the name of the new project
(a directory with this name will be created with the contents of chosen template inside).

### Existing project
If you already have a project and want to apply a template to it, run
```
nix flake init --template github:grimerssy/flakes#${template}
```
where `${template}` is the name of the directory in this repository which should be used as a template.

## Manual
As was mentioned above, some templates can be used without Nix.
In case of using them, Nix serves only for convenience of applying templates.
If you don't have Nix installed on your current machine, you can manually copy the files to your projects.
