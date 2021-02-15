use Mix.Config

config :scrape_server,
  freq_millis: 5*60*1000

config :vintage_net,
  config: [
    {"wlan0",
      %{
        type: VintageNetWiFi,
        vintage_net_wifi: %{
          networks: [
            %{
              key_mgmt: :wpa_psk,
              ssid: Application.get_env(:scrape_server, :wifi)[:ssid],
              psk: Application.get_env(:scrape_server, :wifi)[:psk],
            }
          ]
        },
        ipv4: %{method: :dhcp},
      }
    }
  ]
