class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :convert_uuid_params

  private

  def convert_uuid_params
    params.keys.find_all {|k| k.to_s.match(/(^id$|.*_id(s)?)$/)}.each do |id_param|
      params[id_param] = if params[id_param].is_a?(String)
        UUIDTools::UUID.parse(params[id_param])
      elsif params[id_param].is_a?(Array)
        params[id_param].map {|id| UUIDTools::UUID.parse(id)}
      end
    end
  end
end
