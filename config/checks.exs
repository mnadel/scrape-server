use Mix.Config

config :scrape_server,
  checks: [
    {"https://www.repfitness.com/strength-equipment/strength-training/benches", "Checker.Rep"}
  ]
