use Mix.Config

config :scrape_server,
  checks: [
    Checker.Vikn,
    Checker.Pts,
    Checker.RepRings
  ]
