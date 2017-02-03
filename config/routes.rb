Cornbowl::Application.routes.draw do
  match '/' => 'cornbowlers#login'
  match '/cornbowlers/auth' => 'cornbowlers#auth'
  match '/high_scores' => 'matchups#high_scores'

  resources :cornbowlers
  resources :games do
    member do
      put 'finish'
    end
  end
  resources :tosses, :only => [:create, :update, :show, :destroy]
end
