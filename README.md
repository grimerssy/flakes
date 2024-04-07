# What

This is a repository containing a collection of
[Nix](https://nixos.org)
[flakes](https://nixos.wiki/wiki/Flakes),
which can be used as templates for your projects.

> :information_source: **Some templates can be used without Nix.**
> 
> Only the templates located under `./nix` are Nix flakes

# How

## Nix CLI
First, you need Nix installed. You can use either one of the following installers:
- [Official](https://nixos.org/download)
- [DeterminateSystems](https://github.com/DeterminateSystems/nix-installer)

To learn how to use Nix to apply these templates, see
[nix flake new](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake-new)
and
[nix flake init](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake-init).

Templates in this repository are divided into "collections" and can be referenced with
```
--template github:grimerssy/flakes#${collection}.${template}
```
where `${collection}` is any directory in the root of this repository
and `${template}` is a subdirectory inside the collection.

For example, to use the template located at `./nix/empty`, you can run
```
nix flake init --template github:grimerssy/flakes#nix.empty
```

## Manual
Nix helps with copying the files, but some templates can still be used without it.
If you don't have Nix installed, you can use `cp` command or your file manager to copy.
```
cp -r /path/to/template/* .
```
