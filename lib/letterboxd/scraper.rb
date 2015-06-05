require 'letterboxd/scraper/version'
require 'letterboxd/scraper/base'

module Letterboxd
  module Scraper
    extend Letterboxd::Scraper::Base

    def self.fetch_seen(username)
      fetch_films("/#{username}/films")
    end

    def self.fetch_watchlist(username)
      fetch_films("/#{username}/watchlist")
    end

    def self.fetch_liked(username)
      fetch_films("/#{username}/likes/films")
    end

    def self.fetch_rated(username, rating = nil)
      if rating.nil?
        fetch_films("/#{username}/films/ratings")
      else
        fetch_films("/#{username}/films/ratings/rated/#{rating}")
      end
    end

    def self.fetch_popular(pages = 400)
      # popular is an AJAX call and has 18 items per page instead of 72
      fetch_films("/films/ajax/popular", pages)
    end

    def self.fetch_film(slug)
      doc = fetch("/film/#{slug}")
      tmdb_id = doc.at_css('body').attribute('data-tmdb-id').value.to_i
      title = doc.at_css('#featured-film-header .film-title').text
      release_year = doc.at_css('#poster-col .film-poster').attribute('data-film-release-year').value.to_i
      director = doc.at_css('#featured-film-header p > a').text
      trailer = doc.at_css('#trailer-zoom').attribute('href').value

      average_rating_node = doc.at_css('meta[itemprop="average"]').attribute('content')
      average_rating = average_rating_node.value unless average_rating_node.nil?
      vote_count_node = doc.at_css('meta[itemprop="votes"]').attribute('content').value
      vote_count = vote_count_node.value unless vote_count_node.nil?

      # Availability
      doc = fetch("/esi/film/#{slug}/availability/?esiAllowUser=true")
      itunes = true unless doc.at_css('#source-itunes').nil?
      amazon = true unless doc.at_css('#source-amazon').nil?
      netflix = true unless doc.at_css('#source-netflix').nil?

      node_disc = doc.css('#source-amazon a')
      disc = true unless node_disc.nil? || node_disc.last.nil? || node_disc.last.text != 'Buy on Disc'

      # View count
      doc = fetch("/esi/film/#{slug}/sidebar-viewings/?esiAllowUser=true")
      views_string = doc.at_css('.small-watched a').text
      views = views_string.split('&nbsp;').first.gsub!(',','').to_i

      # Put everything in a hash
      {
        title: title,
        slug: slug,
        tmdb_id: tmdb_id,
        release_year: release_year,
        director: director,
        trailer: trailer,
        availability: { itunes: itunes, amazon: amazon, disc: disc, netflix: netflix },
        views: views,
        average_rating: average_rating,
        vote_count: vote_count
      }
    end

    def self.fetch_following(username)
      fetch_users("/#{username}/following")
    end

    def self.fetch_followers(username)
      fetch_users("/#{username}/followers")
    end
  end
end