# frozen_string_literal: true
require "excon"
require "dependabot/metadata_finders/base"
require "dependabot/shared_helpers"

module Dependabot
  module MetadataFinders
    module Python
      class Pip < Dependabot::MetadataFinders::Base
        private

        def look_up_github_repo
          potential_source_urls = [
            pypi_listing.dig("info", "home_page"),
            pypi_listing.dig("info", "bugtrack_url"),
            pypi_listing.dig("info", "download_url"),
            pypi_listing.dig("info", "docs_url")
          ].compact

          source_url = potential_source_urls.find { |url| url =~ SOURCE_REGEX }

          return nil unless source_url
          return nil unless source_url.match(SOURCE_REGEX)[:host] == "github"
          source_url.match(SOURCE_REGEX)[:repo]
        end

        def pypi_listing
          return @pypi_listing unless @pypi_listing.nil?

          url = "https://pypi.python.org/pypi/#{dependency.name}/json"
          response = Excon.get(url, middlewares: SharedHelpers.excon_middleware)

          @pypi_listing = JSON.parse(response.body)
        end
      end
    end
  end
end
