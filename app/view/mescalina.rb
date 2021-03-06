#--
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#++

class MescalinaView < Vienna::View
  element '#mescalina'

  def initialize
    %w(ongoing finished dropped planned).each { |id|
      Element["##{id}"].on :click do
        url = `window.location.href`

        if url.include?('/fansubs/') || url.include?('/users/')
          url = url.gsub /\/(ongoing|finished|dropped|planned)/, ''
          str = "#{url}/#{id}"
        elsif url.include? '/search/'
          str = false           
        else
          str = "#/#{id}"
        end
        `window.location.href = str` if str
      end
    }
  end

  def find_shows(filters)
    Episode.latest!(filters[:status]) { |episodes|
      Show.search!(filters[:keyword]) { |show|
        view = ShowView.new show, episodes.select { |ep| ep.belongs_to? show }.first
        view.render
        Element['#mescalina'] << view.element
      }
    }
  end

  def get_shows(filters)
    Episode.latest!(filters[:status]) { |episodes|
      Show.all!(filters) { |show|
        view = ShowView.new show, episodes.select { |ep| ep.belongs_to? show }.first
        view.render
        Element['#mescalina'] << view.element
      }
    }
  end

  def load(what, filters = {})
    filters[:status] ||= :ongoing

    Element.find('.show-row').remove
    SearchView.new.element

    what = :get if !filters.has_key?(:keyword) || filters[:keyword].empty?
    case what
      when :get  then get_shows  filters
      when :find then find_shows filters
    end
  end
end