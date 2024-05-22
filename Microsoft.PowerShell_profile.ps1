$ENV:STARSHIP_CONFIG = "$HOME\git\dotfiles\starship.toml"
$ENV:COLORTERM = "truecolor"

Invoke-Expression (&starship init powershell)

Set-Alias lvim "$HOME\.local\bin\lvim.ps1"

Invoke-Expression (& { (zoxide init powershell --cmd cd | Out-String) })
$ENV:_ZO_ECHO = "1"

Set-PSReadLineOption -EditMode Vi
Set-PSReadLineKeyHandler -Chord Tab -Function Complete
Set-PSReadLineKeyHandler -Chord Ctrl-r -Function ReverseSearchHistory -ViMode Insert
Set-PSReadLineKeyHandler -Chord Ctrl-r -Function ReverseSearchHistory -ViMode Command

