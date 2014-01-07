#--
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#++

class Show < Vienna::Model
  adapter Vienna::LocalAdapter

  attributes :name, :tot_episodes, :fansub, :status, :stub
  attributes :translator, :editor, :checker, :timer, :typesetter, :encoder, :qchecker

  def info?
    tot_episodes
  end
    alias_method :infos?,     :info?
    alias_method :has_infos?, :info?

  class << self
    def exclude?(field)
      [:status, :stub].include? field
    end

    def get(find_dat_show)
      shows = Show.all.select { |show| show[:name] == find_dat_show[:name] }
      shows.any? ? shows.first : nil
    end

    def exists?(show)
      !!Show.get(show)
    end

    def all!(status = :ongoing, fansub = '')
      Database.get("/shows/all/#{status}/#{fansub}") { |shows|
        shows.each { |res|
          show = {}

          Show.columns.each { |field|
            show[field.to_sym] = res[field] if res.has_key? field
          }

          if Show.exists? show
            Show.get(show).update stub: rand
          else
            Show.create show
          end

          yield Show.get show
        }
      }
    end
  end
end