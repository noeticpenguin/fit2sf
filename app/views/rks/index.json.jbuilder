json.array!(@rks) do |rk|
  json.extract! rk, :id, :authtoken
  json.url rk_url(rk, format: :json)
end
