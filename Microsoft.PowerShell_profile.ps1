$ENV:STARSHIP_CONFIG = "$HOME\git\dotfiles\starship.toml"
$ENV:COLORTERM = "truecolor"

Invoke-Expression (&starship init powershell)

Set-Alias lvim "$HOME\.local\bin\lvim.ps1"
