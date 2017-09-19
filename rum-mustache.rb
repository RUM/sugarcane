class Mustache
  def md(str = nil)
    if str
      Kramdown::Document.new(str.to_s).to_html
    else
      lambda { |text| md(render(text)) }
    end
  end
end

class RUM
  register Mustache::Sinatra

  set :mustache, {
        :views     => 'views/',
        :templates => 'templates/'
      }
end
