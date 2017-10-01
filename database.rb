def db url
  JSON.parse(
    Net::HTTP.get('revistadelauniversidad.mx', url, 4056),
    { :symbolize_names => true }
  )
end

# RELEASES

$db_releases = lambda {
  db('/releases').
    each { |r| r[:simple_date] = simple_date r[:date] }.
    sort { |a,b| b[:date] <=> a[:date] }
}

$db_releases_by_id = lambda { |id|
  db("/releases?id=eq.#{id}").
    each { |r| r[:simple_date] = simple_date r[:date] }.
    sort { |a,b| b[:date] <=> a[:date] }.
    first
}

$db_release_articles = lambda { |id|
  db("/articles?select=*,releases{*},collaborations{*,collabs{*}}&release_id=eq.#{id}").
    each { |a|
    a[:seo_title]   = seo_string a[:title]
    a[:simple_date] = simple_date a[:releases][:date]
    a[:section]     = a[:releases][:metadata][:sections][a[:metadata][:section]]

    a[:collaborations].delete_if { |c| c[:relation] != 'author' }
  }.group_by { |a| a[:metadata][:section] }
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
  a = db("/articles?select=*,collaborations{*,collabs{*}},releases{*}&id=eq.#{id}&limit=1").first
  a[:seo_title]   = seo_string a[:title]
  a[:simple_date] = simple_date a[:releases][:date]

  a
}

$db_index_articles = lambda {
  ars = $db_current_release.call[:metadata][:landing][:articles_ids]

  url = "/articles?select=*,releases{*},collaborations{*,collabs{*}}&id=in.#{ars.join(',')}"

  sort_like ars, db(url).each { |a|
    a[:seo_title]   = seo_string a[:title]
    a[:simple_date] = simple_date a[:releases][:date]
    a[:collaborations].delete_if { |c| c[:relation] != 'author' }
    a[:section]     = a[:releases][:metadata][:sections][a[:metadata][:section]]
  }
}

$db_more_articles = lambda {
  db('/articles?select=*,collaborations{*,collabs{*}},releases{*}&starred=eq.true&online=eq.true').
    shuffle.first(3).
    each { |a|
    a[:seo_title]   = seo_string a[:title]
    a[:collaborations].delete_if { |c| c[:relation] != 'author' }
    a[:simple_date] = simple_date a[:releases][:date]
  }
}

$db_starred_articles = lambda {
  db('/articles?select=*,releases{*},collaborations{*,collabs{*}}&starred=eq.true&online=eq.true&limit=6').
    each { |a|
    a[:seo_title]   = seo_string a[:title]
    a[:section]     = a[:releases][:metadata][:sections][a[:metadata][:section]]
  }
}

# COLLABS

$db_collabs  = lambda {
  db('/collabs?select=*,articles{*,collaborations{*,collabs{*}}}&online=eq.true').
    each { |a|
    a[:name]     = a[:fname] + " " + a[:lname]
    a[:seo_name] = seo_string a[:name]
  }
}

$db_collab_by_id  = lambda { |id|
  a = db("/collabs?select=*,articles{*,collaborations{*,collabs{*}}}&id=eq.#{id}&limit=1").first
  a[:name]     = a[:fname] + " " + a[:lname]
  a[:seo_name] = seo_string a[:name]

  a[:articles].
    each { |a| a[:seo_title] = seo_string a[:title] }.
    sort { |a,b| b[:date] <=> a[:date] }

  a
}

$db_starred_collabs  = lambda {
  db('/collabs?select=*&starred=eq.true&online=eq.true').each { |a|
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
