eval -- "$(/data/data/com.termux/files/usr/bin/starship init bash --print-full-init)"

export STARSHIP_CONFIG=~/dotfiles/starship.toml
export USER=ekorchmar
eval $(zoxide init bash --cmd cd)
eval $(direnv hook bash)
