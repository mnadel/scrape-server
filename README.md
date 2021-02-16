# ScrapeServer

A [Nerves](https://www.nerves-project.org/) app that scrapes a site and notifies you via Slack if something interesting on it changed.

[Nerves](https://www.nerves-project.org/) is an embedded version of Elixir that can run on any Pi, including the $10 [Pi Zero W](https://www.raspberrypi.org/products/raspberry-pi-zero-w/). It's a custom Linux kernel that boots into the BEAM.

## Getting Started

Sites to monitor are currently stored in `checks.exs`. Each check is a tuple in the form of `{url, module}`:

- `url` is a string referencing the URL to monitor
- `module` is a module that `@derive`s `Checker`

Every five minutes we'll fetch the `url` and use the `module` to determine if there's changes that need to be Slacked.

## Building

First create a `secrets.exs` file in `config/` with contents similar to this:

```
use Mix.Config

config :scrape_server,
  slack_endpoint: "https://hooks.slack.com/services/ABC/DEF/MdH4YJpKieJdTzMQ",
  wifi: %{
    ssid: "<< YOUR SSID HERE >>",
    psk: "<< YOUR WPA2 PSK PASSWORD HERE >>"
  }
```

Next burn the app/firmware to your SD card:

  1. Install dependencies with `mix deps.get`
  1. Create firmware with `MIX_ENV=prod MIX_TARGET=rip0 mix firmware`
  1. Build & burn the firmware to an SD card with `MIX_ENV=prod MIX_TARGET=rip0 mix firmware.burn`
      1. This will prompt you to burn to a discovered SD card

Pop the SD card into your Pi, then ssh to it and you'll be dropped right into an IEx session:

```
[14:41:50 ~proj/scrape_server]→ ssh 10.0.0.43
Interactive Elixir (1.11.3) - press Ctrl+C to exit (type h() ENTER for help)
████▄▖    ▐███
█▌  ▀▜█▙▄▖  ▐█
█▌ ▐█▄▖▝▀█▌ ▐█   N  E  R  V  E  S
█▌   ▝▀█▙▄▖ ▐█
███▌    ▀▜████

Toolshed imported.
RingLogger is collecting log messages from Elixir and Linux. To see the
messages, either attach the current IEx session to the logger:

  RingLogger.attach

or print the next messages in the log:

  RingLogger.next

iex(1)>
```

Once you have the device up & running you can do OTA deploys via ssh:

* `MIX_ENV=prod MIX_TARGET=rpi0 mix firmware`
* `MIX_ENV=prod MIX_TARGET=rpi0 mix upload 10.0.0.43`
