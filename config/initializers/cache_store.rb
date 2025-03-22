# Configure o cache para desenvolvimento e produção
Rails.application.configure do
  if Rails.env.production?
    config.cache_store = :mem_cache_store, {
      expires_in: 1.hour,
      namespace: 'comunidades_prod'
    }
  else
    config.cache_store = :memory_store, {
      expires_in: 5.minutes,
      size: 64.megabytes,
      namespace: 'comunidades_dev'
    }
  end
end