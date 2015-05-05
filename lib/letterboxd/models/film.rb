require 'active_model'

module Letterboxd
  class Film
    include ActiveModel::Model

    attr_accessor :title, :slug, :tmdb_id, :director, :release_year, :trailer, :availability, :views
  end
end
