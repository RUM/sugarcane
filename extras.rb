# coding: utf-8

def seo_string x
  I18n.
    transliterate(x).
    gsub(/[_\*\.\,\:\/\&\\]+/,"").
    gsub(/\s+/, "-").
    downcase
end

def sort_like this, array
  return array if this.length == 0

  array.sort { |x,y|
    (this.index(x[:id]) or array.length) <=> (this.index(y[:id]) || array.length)
  }
end

def simple_date date
  months_spa = [nil, "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"]
  d = Date.parse(date)

  "#{months_spa[d.month]} de #{d.year}"
end

def collab_link c
   # return "<a>#{c[:fname]} #{c[:lname]}</a>" if not c[:online]

  seo_name = seo_string "#{c[:fname]} #{c[:lname]}"
  "<a href='/collabs/#{c[:id]}/#{seo_name}'>#{c[:fname]} #{c[:lname]}</a>"
end
