$ENV:STARSHIP_CONFIG = "$HOME\git\dotfiles\starship.toml"
$ENV:COLORTERM = "truecolor"

Invoke-Expression (&starship init powershell)

Set-Alias lvim "$HOME\.local\bin\lvim.ps1"

Invoke-Expression (& { (zoxide init powershell --cmd cd | Out-String) })
$ENV:_ZO_ECHO = "1"

Set-PSReadLineOption -EditMode Vi
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'

