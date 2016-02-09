Songkick::OAuth2::Model::Client.create!({
  id: 1,
  name: "Speak",
  redirect_uri: ENV.fetch('APP_URL')
})