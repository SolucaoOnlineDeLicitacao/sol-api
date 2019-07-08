Geocoder.configure(
  # Geocoding options
  timeout: 15,                  # geocoding service timeout (secs)
  lookup: :google,              # name of geocoding service (symbol)
  # ip_lookup: :freegeoip,      # name of IP address geocoding service (symbol)
  language: :'pt-BR',           # ISO-639 language code
  use_https: true,              # use HTTPS for lookup requests? (if supported)
  # http_proxy: nil,            # HTTP proxy server (user:pass@host:port)
  # https_proxy: nil,           # HTTPS proxy server (user:pass@host:port)
  # api_key: nil,               # API key for geocoding service, server-side
  # cache: nil,                 # cache object (must respond to #[], #[]=, and #del)
  # cache_prefix: 'geocoder:',  # prefix (string) to use for all cache keys

  # Exceptions that should not be rescued by default
  # (if you want to implement custom error handling);
  # supports SocketError and Timeout::Error
  # always_raise: [],

  # Calculation options
  units: :km,                   # :km for kilometers or :mi for miles
  # distances: :linear          # :spherical or :linear

  # specific api keys
  google: {
    api_key: Rails.application.secrets.dig(:google, :geocoding)
  }
)
