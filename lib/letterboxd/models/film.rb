require 'active_model'

module Letterboxd
  class Film
    include ActiveModel::Model

    attr_accessor :title, :slug
  end
end
