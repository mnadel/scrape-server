# ScrapeServer

A [Nerves](https://www.nerves-project.org/) app that scrapes a site, determines if something interesting changed, and notifies you via Slack if so.

[Nerves](https://www.nerves-project.org/) is an embedded version of Elixir that can run on any Pi, including the $5 [Pi Zero](https://www.raspberrypi.org/products/raspberry-pi-zero/). It's a custom Linux kernel that boots directly into the BEAM.

## Getting Started

Create a `secrets.exs` file in `config/` with contents similar to this:

```
config :scrape_server,
  slack_endpoint: "https://hooks.slack.com/services/ABC/DEF/MdH4YJpKieJdTzMQ"

config :vintage_net,
  config: [
    {"wlan0",
      %{
        type: VintageNetWiFi,
        vintage_net_wifi: %{
          networks: [
            %{
              key_mgmt: :wpa_psk,
              ssid: "<< YOUR SSID HERE >>",
              psk: "<< YOUR WPA2 PSK PASSWORD HERE >>",
            }
          ]
        },
        ipv4: %{method: :dhcp},
      }
    }
  ]
```

To build your Nerves app:

  * Install dependencies with `mix deps.get`
  * Create firmware with `MIX_ENV=prod MIX_TARGET=rip0 mix firmware`
  * Burn to an SD card with `MIX_ENV=prod MIX_TARGET=rip0 mix firmware.burn`
      * This will prompt you to burn to any discovered SD cards

Drop your SD card into your Pi, then ssh to it and you'll be dropped right into an IEx session:

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