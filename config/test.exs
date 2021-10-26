import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :drake, DrakeWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "T8/cQ6KiyQTOQGeSPa8437BoUYqS3G5SBohOJ8qM5AMUz4KwfPGMtw12uS7+1NFT",
  server: false

# In test we don't send emails.
config :drake, Drake.Mailer,
  adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
