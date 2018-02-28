# coding: utf-8

def sort_like this, array
  return array if this.length == 0

  array.sort { |x,y|
    (this.index(x[:id]) or array.length) <=> (this.index(y[:id]) or array.length)
  }
end

def collab_link c
  if c[:online]
    "<a href='/collabs/#{c[:id]}/#{c[:seo_name]}'>#{c[:name]}</a>"
  else
    c[:name]
  end
end
