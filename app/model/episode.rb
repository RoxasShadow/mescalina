#--
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#++

class Episode < Vienna::Model
  adapter Vienna::LocalAdapter

  attributes :download,    :episode, :show
  attributes :translation, :editing, :checking, :timing, :typesetting, :encoding, :qchecking

  def belongs_to?(show)
    @show.name == show.name
  end

  def download=(url)
    @download = (!url || url.strip.empty?) ? ?# : url
  end

  class << self
    def of(show)
      Episode.all.select { |episode| episode.belongs_to? show }
    end

    def exists?(dat_episode)
      Episode.all.select { |episode|
        episode.show.name == dat_episode[:show].name &&
        episode.episode   == dat_episode[:episode]
      }.any?
    end

    def all!(show)
      episodes = Episode.of show

      if episodes.any?
        yield episodes
      else
        Database.get("/episodes/#{show.name}") { |episodes|
          episodes.each { |res|
            episode = { show: show }

            Episode.columns.each { |field|
              episode[field.to_sym] = res[field] if res.has_key? field
            }

            Episode.create episode
            yield Episode.of show
          }
        }
      end
    end
  end
end