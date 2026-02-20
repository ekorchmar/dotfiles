import json
import pathlib
from importlib import import_module, invalidate_caches
from importlib.util import find_spec
from urllib.request import urlopen

from PyQt6.QtGui import QColor

## Documentation:
##   qute://help/configuring.html
##   qute://help/settings.html

# Redeclare global objects for type checking purposes
c = c  # pyright: ignore[reportUndefinedVariable]  # noqa: F821
config = config  # pyright: ignore[reportUndefinedVariable]  # noqa: F821


## This is here so configs done via the GUI are still loaded.
## Remove it to not load settings done via the GUI.
config.load_autoconfig(True)

# Install theme
theme_path = config.configdir / "theme.py"
if not theme_path.exists():
    theme = "https://raw.githubusercontent.com/catppuccin/qutebrowser/main/setup.py"
    with urlopen(theme) as themehtml:
        with open(config.configdir / "theme.py", "a") as file:
            file.writelines(themehtml.read().decode("utf-8"))

if find_spec("theme"):
    invalidate_caches()
    theme = import_module("theme")
    theme.setup(c, "mocha", samecolorrows=False)

## Search engines which can be used via the address bar.
c.url.searchengines = {
    "DEFAULT": "https://duckduckgo.com/?q={}",
    "!ddg": "https://duckduckgo.com/?q={}",
}

# Include DuckDuckGo's bangs
bangs: dict[str, str]
bangs_path: pathlib.Path = config.configdir / "bangs.json"
if bangs_path.exists():
    with open(bangs_path, "r") as f:
        bangs = json.load(f)
else:
    bangs_data_raw: list[dict[str, str]]
    with urlopen("https://duckduckgo.com/bang.js") as bangs_json:
        bangs_data_raw = json.load(bangs_json)

        # This is an array, but we want a map
        bangs = {
            "!" + entry["t"]: entry["u"]
            # Substitute DuckDuckGo template
            .replace("{{{s}}}", "%%QUTE_QUERY%%")
            # Escape brackets (https://www.ietf.org/rfc/rfc2396.txt)
            .replace("{", "%7B")
            .replace("}", "%7D")
            # Insert qutebrowsers template
            .replace("%%QUTE_QUERY%%", "{0}")
            for entry in bangs_data_raw
            if (
                # Only use latin
                all(char.isascii() for char in entry["t"])
                and
                # Malformed queries with unbalanced parentheses
                entry["u"].count("}") == entry["u"].count("{")
            )
        }

        # Append query template where it is missing
        for bang, url in bangs.items():
            if "{0}" not in url:
                bangs[bang] = url + "{0}"

        with open(bangs_path, "w") as f:
            json.dump(bangs, f, indent=4)

c.url.searchengines |= bangs

# Tabs to not to occupy full width
c.tabs.max_width = 300

# Transparent tab bar & status bar
c.window.transparent = True
panel_transparency = round(0xFF * 0.7)
tab_transparency = round(0xFF * 0.85)


def make_transparent(
    color_path: str, transparency: int, color_overide: QColor | None = None
) -> None:
    color = color_overide or QColor(config.get(color_path))
    color.setAlpha(transparency)
    color_str = "rgba(" + ",".join(map(str, color.getRgb())) + ")"
    config.set(color_path, color_str)


# Status bar above the tab bar
c.statusbar.position = "top"
c.statusbar.padding = {side: 5 for side in ["top", "bottom", "right", "left"]}

# Use tab bar background color as status bar background
for mode in ["caret", "command", "insert", "passthrough", "normal"]:
    make_transparent(
        f"colors.statusbar.{mode}.bg",
        panel_transparency,
        QColor(config.get("colors.tabs.bar.bg")),
    )
# Make private mode status bar more visible
config.set("colors.statusbar.private.bg", f"rgba(80, 40, 120, {panel_transparency})")

# Catpuccin sets too dark of a color for progress
config.set("colors.statusbar.progress.bg", "#dd7878")

# Tab bar
# All "selected" are implicitly opaque
for color_path_tail in [
    "bar",
    "even",
    "odd",
    "pinned.even",
    "pinned.odd",
]:
    make_transparent(
        f"colors.tabs.{color_path_tail}.bg",
        panel_transparency if color_path_tail == "bar" else tab_transparency,
    )
# Catpuccin does not style pinned tab colors, set them to match normal tabs
for tail in ["even", "odd", "selected.even", "selected.odd"]:
    for component in ["fg", "bg"]:
        src = f"colors.tabs.{tail}.{component}"
        dst = f"colors.tabs.pinned.{tail}.{component}"
        config.set(dst, config.get(src))

c.aliases = {
    "o": "open",
    "go": "open",
    "w": "session-save",
    "q": "tab-close",
    "qa": "close",
    "q!": "close",
    "qa!": "quit",
    "wq": "tab-close",
    "wqa": "close",
}

## Always restore open sites when qutebrowser is reopened.
c.auto_save.session = True
c.changelog_after_upgrade = "patch"

## Render all web contents using a dark theme.
c.colors.webpage.darkmode.enabled = True

## Which images to apply dark mode to.
##   - always: Apply dark mode filter to all images.
##   - never: Never apply dark mode filter to any images.
##   - smart: Apply dark mode based on image content. Not available with Qt 5.15.0.
##   - smart-simple: On QtWebEngine 6.6, use a simpler algorithm for smart mode (based on numbers of colors and transparency), rather than an ML-based model. Same as 'smart' on older QtWebEnigne versions.
c.colors.webpage.darkmode.policy.images = "never"

c.completion.use_best_match = True
c.completion.open_categories = [
    "bookmarks",
    "history",
    "quickmarks",
    "searchengines",
]

## Automatically start playing `<video>` elements.
c.content.autoplay = False

## Closing last tabs leaves a blank page
c.tabs.last_close = "blank"

## List of URLs to ABP-style adblocking rulesets
c.content.blocking.adblock.lists = [
    # Default
    "https://easylist.to/easylist/easylist.txt",
    "https://easylist.to/easylist/easyprivacy.txt",
    # Sourced from https://github.com/bongochong/CombinedPrivacyBlockLists
    "https://raw.githubusercontent.com/bongochong/CombinedPrivacyBlockLists/master/newhosts-final.hosts",
    "https://raw.githubusercontent.com/bongochong/CombinedPrivacyBlockLists/master/cpbl-abp-list.txt",
    "https://raw.githubusercontent.com/bongochong/CombinedPrivacyBlockLists/master/pac-done.js",
    "https://raw.githubusercontent.com/bongochong/CombinedPrivacyBlockLists/master/combined-final-win.dat",
    "https://raw.githubusercontent.com/bongochong/CombinedPrivacyBlockLists/master/combined-final.cidr",
    # TODO: add https://github.com/blocklistproject/Lists?tab=readme-ov-file#available-lists
]

## A list of patterns that should always be loaded, despite being blocked
## by the ad-/host-blocker. Local domains are always exempt from
## adblocking.
## Type: List of UrlPattern
# c.content.blocking.whitelist = []

c.content.cookies.accept = "never"  # tCh to toggle per domain
c.content.cookies.store = True

## Allow JavaScript
c.content.javascript.enabled = False  # tSh to toggle per domain
c.content.javascript.clipboard = "access"

## Allow locally loaded documents to access other local URLs
# c.content.local_content_can_access_file_urls = True

## Allow locally loaded documents to access remote URLs
# c.content.local_content_can_access_remote_urls = False

## Request websites to minimize non-essentials animations and motion
c.content.prefers_reduced_motion = True

## Never open external protocols in browser
c.content.register_protocol_handler = False


EDIT_CMD_PREPEND = [
    "wezterm",
    "start",
    "--",
]


## Editor (and arguments) to use for the `edit-*` commands
c.editor.command = EDIT_CMD_PREPEND + [
    "nvim",
    "-f",
    "{file}",
    "-c",
    "normal {line}G{column0}l",
]

PICK_CMD_PREPEND = [
    "footclient",
    "--",
]

FS = c.fileselect
FS.handler = "external"
FS.folder.command = PICK_CMD_PREPEND + ["yazi", "--cwd-file={}"]
FS.multiple_files.command = PICK_CMD_PREPEND + ["yazi", "--chooser-file={}"]
FS.single_file.command = PICK_CMD_PREPEND + ["yazi", "--chooser-file={}"]

c.prompt.filebrowser = False
c.downloads.location.directory = "~/Downloads"
c.downloads.position = "top"
c.downloads.remove_finished = 30 * 1000  # 30 seconds

## Default font families to use in the UI
c.fonts.default_family = "FiraCode Nerd Font Mono"
c.fonts.default_size = "14pt"

## Comma-separated list of regular expressions to use for 'next' links.
# c.hints.next_regexes = ['\\bnext\\b', '\\bmore\\b', '\\bnewer\\b', '\\b[>→≫]\\b', '\\b(>>|»)\\b', '\\bcontinue\\b']

## CSS selectors used to determine which elements on a page should have hints.
# c.hints.selectors = {'all': ['a', 'area', 'textarea', 'select', 'input:not([type="hidden"])', 'button', 'frame', 'iframe', 'img', 'link', 'summary', '[contenteditable]:not([contenteditable="false"])', '[onclick]', '[onmousedown]', '[role="link"]', '[role="option"]', '[role="button"]', '[role="tab"]', '[role="checkbox"]', '[role="switch"]', '[role="menuitem"]', '[role="menuitemcheckbox"]', '[role="menuitemradio"]', '[role="treeitem"]', '[aria-haspopup]', '[ng-click]', '[ngClick]', '[data-ng-click]', '[x-ng-click]', '[tabindex]:not([tabindex="-1"])'], 'links': ['a[href]', 'area[href]', 'link[href]', '[role="link"][href]'], 'images': ['img'], 'media': ['audio', 'img', 'video'], 'url': ['[src]', '[href]'], 'inputs': ['input[type="text"]', 'input[type="date"]', 'input[type="datetime-local"]', 'input[type="email"]', 'input[type="month"]', 'input[type="number"]', 'input[type="password"]', 'input[type="search"]', 'input[type="tel"]', 'input[type="time"]', 'input[type="url"]', 'input[type="week"]', 'input:not([type])', '[contenteditable]:not([contenteditable="false"])', 'textarea']}

## Make characters in hint strings uppercase.
c.hints.uppercase = True

## Maximum time (in minutes) between two history items for them to be
## considered being from the same browsing session
c.history_gap_interval = -1

## Automatically enter insert mode if an editable element is focused
## after loading the page.
c.input.insert_mode.auto_load = True

## Switch to insert mode when clicking flash and other plugins.
c.input.insert_mode.plugins = True

## When to use Chromium's low-end device mode. Valid values:
##   - always: Always use low-end device mode.
##   - auto: Decide automatically (uses low-end mode with < 1 GB available RAM).
##   - never: Never use low-end device mode.
c.qt.chromium.low_end_device_mode = "always"  # ?

## Additional environment variables to set. Setting an environment
## variable to null/None will unset it.
## Type: Dict
# c.qt.environ = {}

## Turn on Qt HighDPI scaling
c.qt.highdpi = True

c.scrolling.bar = "when-searching"

## Enable smooth scrolling for web pages. Note smooth scrolling does not
c.scrolling.smooth = True

## Load a restored tab as soon as it takes focus.
c.session.lazy_restore = True

c.spellcheck.languages = [
    "en-US",
    "uk-UA",
    "de-DE",
]

c.statusbar.show = "always"
c.tabs.show = "always"

c.statusbar.widgets = ["search_match", "progress", "url", "scroll"]

# Tab styling and formatting
c.tabs.position = "top"
c.tabs.select_on_remove = "last-used"
c.tabs.title.alignment = "left"
c.tabs.title.elide = "middle"
c.tabs.title.format = "{audio} {current_title} {perc}"
c.tabs.title.format_pinned = "{audio}"

c.tabs.indicator.width = 2
c.tabs.indicator.padding = {
    "top": 3,
    "bottom": 3,
    "right": 6,
    "left": 0,
}
c.tabs.padding = {
    "top": 2,
    "bottom": 2,
    "right": 5,
    "left": 5,
}

# TODO: create a custom new tab page
c.url.default_page = "about:blank"
c.url.start_pages = ["about:blank"]

## URL segments where `:navigate increment/decrement` will search for a
## number.
## Type: FlagList
## Valid values:
##   - host
##   - port
##   - path
##   - query
##   - anchor
# c.url.incdec_segments = ['path', 'query']

## Default zoom level.
## Type: Perc
c.zoom.default = "110%"

config.bind("<Ctrl-T>", "cmd-set-text -s :open -t")
config.bind("D", "tab-close")
config.bind("cD", "download-delete")
config.bind("<Ctrl-L>", "cmd-set-text :open {url:pretty}")
config.bind(
    "tCH",
    "config-cycle -p -u *://*.{url:host}/* content.cookies.accept all never ;; reload",
)
config.bind(
    "tCh",
    "config-cycle -p -u *://{url:host}/* content.cookies.accept all never ;; reload",
)
config.bind(
    "tCu", "config-cycle -p -u {url} content.cookies.accept all never ;; reload"
)
config.bind(
    "tcH",
    "config-cycle -p -t -u *://*.{url:host}/* content.cookies.accept all never ;; reload",
)
config.bind(
    "tch",
    "config-cycle -p -t -u *://{url:host}/* content.cookies.accept all never ;; reload",
)
config.bind(
    "tcu", "config-cycle -p -t -u {url} content.cookies.accept all never ;; reload"
)
config.bind("<Ctrl-X>", "cmd-edit", mode="command")

# Toggle dark mode with Alt-Shift-A
# config.bind("<Alt-Shift-A>", "config-cycle colors.webpage.darkmode.enabled")
config.bind(
    "<Alt-Shift-A>",
    "config-cycle -p -u *://*.{url:host}/* colors.webpage.darkmode.enabled false true;; "
    "reload",
)
# Toggle spatial navigation with Alt-Shift-S
config.bind("<Alt-Shift-S>", "config-cycle -t input.spatial_navigation")

# Tab management shortcuts
config.bind("<Shift-Right>", "tab-next", mode="normal")
config.bind("<Shift-Left>", "tab-prev", mode="normal")
config.bind("<Ctrl-Shift-Right>", "tab-move +", mode="normal")
config.bind("<Ctrl-Shift-Left>", "tab-move -", mode="normal")
config.bind("<Ctrl-Shift-Space>", "tab-give", mode="normal")

# Shorthand to "trust" and "distrust" the current domain
config_cmd_prefix = "set -u *://{url:host}/*"
for chord, js_setting, cookie_setting in [
    (",t", "true", "all"),
    (",T", "false", "never"),
]:
    config.bind(
        chord,
        f"{config_cmd_prefix} content.javascript.enabled {js_setting} ;; "
        f"{config_cmd_prefix} content.cookies.accept {cookie_setting} ;; "
        "reload",
    )


# External apps
config.bind(",i", "spawn -d gwenview {url}", mode="normal")
config.bind(",f", "spawn -d firefox {url}", mode="normal")
config.bind(",c", "spawn -d chromium {url}", mode="normal")
config.bind(",p", "spawn -d okular {url}", mode="normal")
config.bind(",v", "spawn -d vlc {url}", mode="normal")

# Reduce logging level to prevent leaks
c.logging.level.console = "warning"
c.logging.level.ram = "warning"

# pass support
config.bind("zl", "spawn --userscript qute-pass")
config.bind("zul", "spawn --userscript qute-pass --username-only")
config.bind("zpl", "spawn --userscript qute-pass --password-only")
config.bind("zol", "spawn --userscript qute-pass --otp-only")

## Use KGet/KTorrent for downloading urls
config.bind(";U", "hint links spawn kget {url}", mode="normal")
config.bind(";T", "hint links spawn ktorrent {url}", mode="normal")
