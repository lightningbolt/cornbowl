class Standing < ActiveRecord::Base
  include ActiveUUID::UUID
  belongs_to :cornbowler
end
