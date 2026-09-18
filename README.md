# ForeverQoL


[![License](https://img.shields.io/github/license/lamboley/ForeverQoL)](LICENSE)
[![CI](https://github.com/lamboley/ForeverQoL/actions/workflows/ci.yml/badge.svg)](https://github.com/lamboley/ForeverQoL/actions/workflows/ci.yml)
![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/lamboley/ForeverQoL?sort=semver)

Quality of life tweaks for World of Warcraft: Forever.

## Introduction

ForeverQoL collects the small fixes you would otherwise install a dozen addons
for: hiding frames you never look at, selling junk without clicking it one item
at a time, and keeping the interface out of the way while you play.

A handful of the safer tweaks are on out of the box, the rest wait for you to
turn them on. Every option lives in one panel behind `/fql`.

### System

- Pixel perfect UI scale, with an optional custom screen height
- Camera zoom distance maxed out on login
- A blacklist of repetitive sounds muted for the session

### Interface

- Floating combat text hidden for good, or only while you play a healer or a tank
- Tooltip hidden while in combat
- Known mounts, pets, toys, recipes and cosmetics tinted green at merchants
- Recipe icons in the profession list, with chosen categories kept collapsed

### Gameplay

- Right click reserved for mouselook instead of targeting
- Loot taken in one pass rather than one slot at a time
- Gear repaired on opening a merchant, from guild funds if you let it
- Junk sold automatically, grey weapons and armour excepted, along with a list of
  your own items, capped at the buyback limit
- A list of your own items deposited on opening the bank, and spare gold moved to
  the warband bank above an amount you keep
- A battle pet kept summoned outside instances
- A voice line on death, and breathing quotes from Thich Nhat Hanh

## Installation

Download the latest release, unzip it, and drop the `ForeverQoL` folder into the
`Interface/AddOns` folder of your WoW: Forever install. The folder must keep its
name, the client will not find the addon otherwise.

## Usage

| Command | What it does |
| --- | --- |
| `/fql` | Open the options panel |
| `/fql pet` | Print the name of the summoned battle pet |
| `/fql prof` | List the categories of the open profession with their ids |
| `/fql help` | List the commands |
| `/rel` | Reload the interface |

A module whose API is missing from the running client disables itself and says so
in the debug log, so a feature that cannot work stays quiet rather than erroring.

## Feedback

Bug reports and enhancement requests go to [GitHub Issues](https://github.com/lamboley/ForeverQoL/issues).

Please do not open a public issue for anything with security consequences. [SECURITY.md](SECURITY.md) explains how to report those privately.

## Contributing

Contributions are welcome.
[CONTRIBUTING.md](CONTRIBUTING.md) covers how to get set up, what the coding and commit conventions are, and how to open a pull request.

## License

[Apache License 2.0](LICENSE).
