$ENV:STARSHIP_CONFIG = "$HOME\git\dotfiles\starship.toml"
$ENV:COLORTERM = "truecolor"
$ENV:FZF_DEFAULT_OPTS=@"
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
"@

Invoke-Expression (&starship init powershell)

Set-Alias lvim "$HOME\.local\bin\lvim.ps1"
Set-Alias cat "bat"
Set-Alias ls "eza"

Invoke-Expression (& { (zoxide init powershell --cmd cd | Out-String) })
$ENV:_ZO_ECHO = "1"

Set-PSReadLineOption -EditMode Vi
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'

