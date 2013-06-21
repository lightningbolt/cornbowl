class BroadcastController < WebsocketRails::BaseController
  def initialize_session
    # perform application setup here
    puts "initialized!"
  end
  def testing
    puts "testing!"
  end
end
