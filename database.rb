def db url
  s = 'revistadelauniversidad.mx'
  s = 'localhost' if ENV['RACK_ENV'] == 'development'

  JSON.parse(Net::HTTP.get(s, url, 4056), { :symbolize_names => true })
end

release_attrs = "id,date,name,metadata"
article_attrs = "id,title,cover,file,metadata"
collab_attrs  = "id,fname,lname"

# RELEASES

$db_releases_all = lambda {
  db('/releases').
    each { |r| r[:simple_date] = simple_date r[:date] }.
    sort { |a,b| b[:date] <=> a[:date] }
}

$db_releases = lambda {
  db('/releases?online=eq.true').
    each { |r| r[:simple_date] = simple_date r[:date] }.
    sort { |a,b| a[:date] <=> b[:date] }
}

$db_release_by_id = lambda { |id|
  db("/releases?id=eq.#{id}").
    each { |r| r[:simple_date] = simple_date r[:date] }.
    sort { |a,b| b[:date] <=> a[:date] }.
    first
}

$db_current_release = lambda {
  releases = $db_releases.call

  c = releases.select { |x|
    (x[:date].match /\d{4}-(\d{2})-\d{2}/)[1].to_i == Time.now.month
  }.first

  if not c[:online]
    c = releases.select { |x|
      (x[:date].match /\d{4}-(\d{2})-\d{2}/)[1].to_i == Time.now.month - 1
    }.first
  end

  return c
}

# ARTICLES

$db_article_by_id = lambda { |id|
  a = db("/articles?select=*,collaborations{*,collabs{#{collab_attrs}}},releases{#{release_attrs}}&id=eq.#{id}&limit=1").first
  a[:seo_title]   = seo_string a[:title]
  a[:simple_date] = simple_date a[:releases][:date]

  a
}

$db_articles_by_release = lambda { |release_id|
  db("/articles?select=#{article_attrs},releases{#{release_attrs}},collaborations{*,collabs{#{collab_attrs}}}&release_id=eq.#{release_id}").
    each { |a|
    a[:seo_title]   = seo_string a[:title]
    a[:simple_date] = simple_date a[:releases][:date]
    a[:section]     = a[:releases][:metadata][:sections][a[:metadata][:section]]

    a[:collaborations].delete_if { |c| c[:relation] != 'author' }
  }.group_by { |a| a[:metadata][:section] }
}

$db_index_articles = lambda {
  ars = $db_current_release.call[:metadata][:landing][:articles_ids]

  url = "/articles?select=#{article_attrs},releases{#{release_attrs}},collaborations{*,collabs{#{collab_attrs}}}&id=in.#{ars.join(',')}"

  sort_like ars, db(url).each { |a|
    a[:seo_title]   = seo_string a[:title]
    a[:simple_date] = simple_date a[:releases][:date]
    a[:collaborations].delete_if { |c| c[:relation] != 'author' }
    a[:section]     = a[:releases][:metadata][:sections][a[:metadata][:section]]
  }
}

$db_more_articles = lambda {
  db("/articles?select=id,title,collaborations{*,collabs{#{collab_attrs}}},releases{#{release_attrs}}&starred=eq.true&online=eq.true").
    shuffle.first(3).
    each { |a|
    a[:seo_title]   = seo_string a[:title]
    a[:collaborations].delete_if { |c| c[:relation] != 'author' }
    a[:simple_date] = simple_date a[:releases][:date]
  }
}

$db_starred_articles = lambda {
  db("/articles?select=#{article_attrs},releases{#{release_attrs}},collaborations{*,collabs{#{collab_attrs}}}&starred=eq.true&online=eq.true&limit=6").
    each { |a|
    a[:seo_title]   = seo_string a[:title]
    a[:section]     = a[:releases][:metadata][:sections][a[:metadata][:section]]
  }
}

# COLLABS

$db_collabs  = lambda {
  db("/collabs?select=#{collab_attrs},starred,metadata,articles{#{article_attrs},collaborations{*,collabs{#{collab_attrs}}}}&online=eq.true").
    each { |a|
    a[:name]     = a[:fname] + " " + a[:lname]
    a[:seo_name] = seo_string a[:name]
  }
}

$db_collab_by_id  = lambda { |id|
  a = db("/collabs?select=*,articles{#{article_attrs},collaborations{*,collabs{#{collab_attrs}}}}&id=eq.#{id}&limit=1").first
  a[:name]     = a[:fname] + " " + a[:lname]
  a[:seo_name] = seo_string a[:name]

  a[:articles].
    each { |a| a[:seo_title] = seo_string a[:title] }.
    sort { |a,b| b[:date] <=> a[:date] }

  a
}

$db_starred_collabs  = lambda {
  db("/collabs?select=#{collab_attrs},metadata&starred=eq.true&online=eq.true").each { |a|
    a[:name]     = a[:fname] + " " + a[:lname]
    a[:seo_name] = seo_string a[:name]
  }
}

# OTHERS

$db_suggestions = lambda {
  db("/suggestions")
}

$db_starred_suggestions = lambda {
  db("/suggestions?starred=eq.true")
}

$db_pages_by_id = lambda { |id|
  db("/pages?id=eq.#{id}&limit=1").first
}
