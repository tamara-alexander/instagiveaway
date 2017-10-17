Rails.application.routes.draw do
  # Connect to Instagram first
  root 'welcome#index'

  # Instagram oauth flow
  get 'oauth/connect'
  get 'oauth/callback'

  # Giveaway form and decision
  get 'giveaway' => 'giveaway#new'
  post 'giveaway/decide' => 'giveaway#decide'
  get 'giveaway/decision' => 'giveaway#decision'
end
