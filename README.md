# Local Apps

## How do I install these formulae?

`brew install LegandaryRa/apps/<formula>`

Or `brew tap LegandaryRa/apps` and then `brew install <formula>`.

Or, in a `brew bundle` `Brewfile`:

```ruby
tap "LegandaryRa/apps"
brew "<formula>"
```

## T3 Code on Linux

T3 Code is packaged for x86-64 Linux as an AppImage with a FUSE-free launcher.

```bash
brew install LegandaryRa/apps/t3-code-linux
t3-code-integrate install
```

The integration command installs the desktop entry and enables a daily update
check through `brew services`. Run `t3-code-integrate uninstall` before removing
the formula if you also want to remove those user integrations.

## Documentation

`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).
