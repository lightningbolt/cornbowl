Cornbowl::Application.routes.draw do
  match '/' => 'cornbowlers#login'
  match '/cornbowlers/auth' => 'cornbowlers#auth'
  match '/high_scores' => 'matchups#high_scores'
  match '/highest_averages' => 'matchups#highest_averages'

  resources :cornbowlers
  resources :games do
    member do
      put 'finish'
    end
  end
  resources :tosses, :only => [:create, :update, :show, :destroy]
end
