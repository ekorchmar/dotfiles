# dotfiles

A place for me to store configs for the software I use. Configs are not recommended to be copied as is, as they are tailored to my preferences, including unusual keybindings for QWERTZ keyboard and very, _very_ purple color themes.

## Table of Contents

1. [lvim](#lvim)
2. [zshrc](#zshrc)
3. [wezterm](#wezterm)
4. [firefox](#firefox)
5. [starship](#starship)
6. [konsole](#konsole)
7. [bat](#bat)
8. [Powershell](#Powershell)
9. [Lazygit](#Lazygit)
10. [fastfetch](#fastfetch)
11. [direnv](#direnv)
12. [glow](#glow)
13. [yazi](#yazi)
14. [Neovim](#Neovim)

## lvim

> [!WARNING]
> LunarVim is de-facto deprecated by upstream and config is unmaintained. See [Neovim](#Neovim) section for replacement config.

Although I used to have a much longer and comprehensive [.vimrc](https://gist.github.com/ekorchmar/04735e1e280e37899d26b6cc552dd052), I have since switched to LunarVim, to have a managed default and not to have to worry about much. This is the content of my `~/.config/lvim/config.lua` file.

## zshrc

This is my `.zshrc` file. It is a bit of a mess, because it is mostly filled by various initialization scripts from different software. Notably, syntax highlighting are still Dracula colored, because there are few other managed color themes for ZSH.

## wezterm

Custom style, OS-specific settings and Nvim splits integration.

## firefox

Custom CSS to remove as much clutter from the UI as possible. Relies on tree style tabs extension.

## starship

Heavily modified and updated built-in Tokyo Night.
`starship_tty.toml` is a custom prompt with minimalistic style, 256 colors and no nerd font symbols. Can be used by setting `STARSHIP_CONFIG` environment variable to the path of this file.

## konsole

This is handcrafted Konsole/Yakuake color scheme, based on [Tokyo Night](https://github.com/enkia/tokyo-night-vscode-theme).

## bat

Makes it a little cleaner from the default. Also uses Dracula for lack of other themes.

## Powershell

Starship prompt & LunarVim alias.

## Lazygit

Slightly bluer color scheme, slightly less visual clutter, Nerdfonts icons.

## fastfetch

The most important part of my dotfiles, holding everything together. Expects a file `~/Pictures/Arch.png` to exist and for
Kitty graphics to be supported.

## direnv

Default to enable detecting `.env` files and enforcing strict mode.

## glow

Specifies a custom theme for `glow` markdown viewer and wider column count.

## yazi

Plugins and configs for Yazi, CLI filesystem explorer.

## Neovim

Custom config for Neovim, based on [AstroNvim](https://github.com/ekorchmar/astronvim-template).
