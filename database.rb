def db url
  s = 'revistadelauniversidad.mx'
  s = 'localhost' if ENV['RACK_ENV'] == 'development'

  JSON.parse(Net::HTTP.get(s, url, 4056), { :symbolize_names => true })
end

release_attrs = "id,date,cover,month_year,name,metadata,online"
article_attrs = "id,title,cover,file,metadata,release_name,section_name,seo_title"
collab_attrs  = "id,fname,lname,seo_name,name"

# RELEASES

$db_releases_all = lambda {
  db("/releases?select=#{release_attrs},number&order=date.desc")
}

$db_releases = lambda {
  db("/releases?select=#{release_attrs}&online=eq.true&order=date.asc")
}

$db_release_by_id = lambda { |id|
  db("/releases?id=eq.#{id}").first
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
  a = db("/articles?select=*,seo_title,plain_title,month_year,collaborations(*,collabs(#{collab_attrs})),releases(#{release_attrs})&id=eq.#{id}&limit=1").first
  s = a[:section_name]
  a[:section_name] = (s == 'editorial' ? nil : s)

  a
}

$db_articles_by_release = lambda { |release_id|
  db("/articles?select=#{article_attrs},releases(#{release_attrs}),collaborations(*,collabs(#{collab_attrs}))&release_id=eq.#{release_id}").
    each { |a| a[:collaborations].delete_if { |c| c[:relation] != 'author' } }.
    group_by { |a| a[:metadata][:section] }
}

}

$db_index_articles = lambda {
  ars = $db_current_release.call[:metadata][:landing][:articles_ids]

  url = "/articles?select=#{article_attrs},releases(#{release_attrs}),collaborations(*,collabs(#{collab_attrs}))&id=in.#{ars.join(',')}"

  sort_like ars, db(url).each { |a|
    a[:collaborations].delete_if { |c| c[:relation] != 'author' }
  }
}

$db_more_articles = lambda { |not_id|
  db("/articles?select=#{article_attrs},collaborations(*,collabs(#{collab_attrs})),releases(#{release_attrs})&id=not.eq.#{not_id}&starred=eq.true&online=eq.true").
    shuffle.first(3).
    each { |a|
    a[:collaborations].delete_if { |c| c[:relation] != 'author' }
  }
}

$db_starred_articles = lambda {
  db("/articles?select=#{article_attrs},releases(#{release_attrs}),collaborations(*,collabs(#{collab_attrs}))&starred=eq.true&online=eq.true&limit=6")
}

# COLLABS

$db_collabs  = lambda {
  db("/collabs?select=#{collab_attrs},starred,metadata,articles(#{article_attrs},collaborations(*,collabs(#{collab_attrs})))&online=eq.true")
}

$db_collab_by_id  = lambda { |id|
  db("/collabs?select=#{collab_attrs},sinopsis,metadata,articles(#{article_attrs},collaborations(*,collabs(#{collab_attrs})))&articles.order=date.desc&id=eq.#{id}&limit=1").first
}

$db_starred_collabs  = lambda {
  db("/collabs?select=#{collab_attrs},metadata&starred=eq.true&online=eq.true")
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
