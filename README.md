# ScrapeServer

A [Nerves](https://www.nerves-project.org/) app that scrapes a site, determines if something interesting changed, and notifies you via Slack if so.

[Nerves](https://www.nerves-project.org/) is an embedded version of Elixir that can run on any Pi, including the $5 [Pi Zero](https://www.raspberrypi.org/products/raspberry-pi-zero/). It's a custom Linux kernel that boots directly into the BEAM.

## Targets

Nerves applications produce images for hardware targets based on the
`MIX_TARGET` environment variable. If `MIX_TARGET` is unset, `mix` builds an
image that runs on the host (e.g., your laptop). This is useful for executing
logic tests, running utilities, and debugging. Other targets are represented by
a short name like `rpi0` that maps to a Nerves system image for that platform.
All of this logic is in the generated `mix.exs` and may be customized. For more
information about targets see:

https://hexdocs.pm/nerves/targets.html#content

## Getting Started

To start your Nerves app:
  * `export MIX_TARGET=rip0` or prefix every command with `MIX_TARGET=rip0`
  * Install dependencies with `mix deps.get`
  * Create firmware with `mix firmware`
  * Burn to an SD card with `mix firmware.burn`
