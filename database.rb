$api = '127.0.0.1'
$api_port = '4056'
$api_prefix = ''

# if ENV['RACK_ENV'] == 'production'
#   $api = 'api.revistadelauniversidad.mx'
#   $api_port = '80'
#   $api_prefix = ''
# end

def db(url)
  JSON.parse(Net::HTTP.get($api, $api_prefix + url, $api_port), { :symbolize_names => true })
end

release_attrs = "id,date,cover,month_year,name,metadata,online"
article_attrs = "id,title,cover,file,metadata,release_name,section_name,seo_title"
collab_attrs  = "id,fname,lname,seo_name,name"

# RELEASES

$db_releases_all = -> {
  db("/releases?select=#{release_attrs},number&order=date.desc")
}

$db_releases_latest = -> (i) {
  db("/releases?select=#{release_attrs}&online=eq.true&order=date.desc&limit=#{i}")
}

$db_releases = -> {
  db("/releases?select=#{release_attrs}&online=eq.true&order=date.asc")
}

$db_release_by_id = -> (id) {
  db("/releases?select=*,month_year&id=eq.#{id}").first
}

$db_current_release = -> {
  db("/releases?select=#{release_attrs},file&online=eq.true&order=date.desc&limit=1").first
}

# ARTICLES

$db_article_by_id = -> (id) {
  a = db("/articles?select=*,seo_title,plain_title,month_year,collaborations(*,collabs(#{collab_attrs})),release:releases(#{release_attrs})&id=eq.#{id}&limit=1").first
  s = a[:section_name]
  a[:section_name] = (s == 'editorial' ? nil : s)

  a
}

$db_articles_by_release = -> (release_id) {
  db("/articles?select=#{article_attrs},quote,release:releases(#{release_attrs}),collaborations(*,collabs(#{collab_attrs}))&collaborations.relation=eq.author&release_id=eq.#{release_id}").
    group_by { |a| a[:metadata][:section] }
}

$db_articles_by_tags = -> (array) {
  post = Net::HTTP.post URI("http://#{$api}:#{$api_port}/rpc/articles_with_tags"),
                        "{ \"tags_array\": #{array.to_json} }",
                        "Content-Type" => "application/json"

  ids = JSON.parse(post.body).map { |x| x['id'] }.join(',')

  JSON.parse(
    Net::HTTP.get($api, "/articles?select=#{article_attrs},collabs(#{collab_attrs}),collaborations(*,collabs(#{collab_attrs}))&order=date.desc&id=in.#{ids}", $api_port),
    { :symbolize_names => true }
  )
}

$db_articles_suggestion = -> (not_id, i) {
  post = Net::HTTP.post URI("http://#{$api}:#{$api_port}/rpc/articles_suggestion"),
                        "{ \"i\": #{i + 1} }",
                        "Content-Type" => "application/json"

  ids = JSON.parse(post.body).map { |x| x['id'] }.join(',')

  url = "/articles?select=#{article_attrs},collaborations(*,collabs(#{collab_attrs})),release:releases(#{release_attrs})&collaborations.relation=eq.author&id=in.#{ids}"
  url += (not_id ? "&id=not.eq.#{not_id}" : '')

  db(url).first(i)
}

$db_starred_articles = -> {
  db("/articles?select=#{article_attrs},release:releases(#{release_attrs}),collaborations(*,collabs(#{collab_attrs}))&starred=eq.true&online=eq.true&limit=6")
}

# COLLABS

$db_collabs = -> {
  db("/collabs?select=#{collab_attrs},starred,metadata,articles(#{article_attrs},collaborations(*,collabs(#{collab_attrs})))&online=eq.true")
}

$db_collab_by_id = -> (id) {
  db("/collabs?select=#{collab_attrs},sinopsis,metadata,articles(#{article_attrs},collaborations(*,collabs(#{collab_attrs})))&articles.collaborations.relation=eq.author&articles.order=date.desc&id=eq.#{id}&limit=1").first
}

$db_collabs_suggestion = -> (i) {
  post = Net::HTTP.post URI("http://#{$api}:#{$api_port}/rpc/collabs_suggestion"),
                        "{ \"i\": #{i} }",
                        "Content-Type" => "application/json"

  ids = JSON.parse(post.body).map { |x| x['id'] }.join(',')

  db("/collabs?select=#{collab_attrs},metadata&id=in.#{ids}")
}

$db_collabs_by_letter = -> (x) {
  db("/collabs?select=#{collab_attrs},metadata&online=eq.true&lname=ilike.#{x}*")
}

$db_collabs_index_letters = -> {
  db("/collabs_index_letters").first[:array]
}

# OTHERS

$db_suggestions = -> {
  db("/suggestions")
}

$db_starred_suggestions = -> {
  db("/suggestions?starred=eq.true")
}

$db_pages_by_id = -> (id) {
  db("/pages?id=eq.#{id}&limit=1").first
}

$static_pages = %r{/(about|announcements|contact|directory|find_us|legal|privacy|related|publish|transparency)/?}
