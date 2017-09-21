# coding: utf-8

class RUM < Sinatra::Base
  get '/' do
    mustache :index,
             :locals => {
               :index => true,
               :articles => $db_index_articles.call,
               :current_release => $db_current_release.call,
               :collaborators => $db_starred_collabs.call.shuffle.first(6),
               :suggestions => $db_starred_suggestions.call
             }
  end

  get '/releases/?' do
    mustache :releases,
             :locals => { :releases => $db_releases.call }
  end

  get '/releases/:id/?' do
    @release = $db_releases_by_id.call params[:id]

    halt 404, "No hay de esos..." if not @release

    groups = $db_release_articles.call params[:id]

    sections = (0..@release[:metadata][:sections].length-1).map { |i|
      {
        'section_name' => @release[:metadata][:sections][i],
        'articles' => (sort_like (@release[:metadata][:articles_ids] or []), groups[i])
      }
    }

    mustache :release,
             :locals => {
               :release => @release,
               :sections => sections,
               :quotes => @release[:metadata][:quotes]
             }
  end

  get '/articles/:id/?' do
    @article = $db_article_by_id.call params[:id]

    redirect "/articles/#{params[:id]}/#{@article[:seo_title]}"
  end

  get '/articles/:id/:seo_url/?' do
    @article = $db_article_by_id.call params[:id]

    halt 404, "No hay de esos..." if not @article

    @release = @article[:releases]

    begin
      authors_list  =
        @article[:collaborations].
          select { |x| x[:relation] == 'author' }.
          map    { |x| collab_link x[:collabs] }.
          join(", ")

      authors_plain_list  =
        @article[:collaborations].
          select { |x| x[:relation] == 'author' }.
          map    { |x| "#{x[:collabs][:fname]} #{x[:collabs][:lname]}" }.
          join(", ")

      collabs  = @article[:collaborations].
                   select { |x| x[:relation] != 'author' }.
                   map    { |x|
        x[:collabs][:link] = collab_link(x[:collabs])
        x[:collabs][:long_relation] = case x[:relation]
                                      when 'translator' then 'Traducción de'
                                      when 'editor'     then 'Edición de'
                                      when 'co-author'  then 'co-escrito por'
                                      else x[:relation]
                                      end
        x[:collabs]
      }
    rescue
      authors_list = nil
      collabs = nil
    end

    @title = "#{ @article[:title] } | #{ authors_plain_list }"

    if @article[:doc_only]
      mustache :article_doc_only,
               :locals => {
                 :article => @article,
                 :collabs => collabs,
                 :authors_list => authors_list
               }
    else
      mustache :article,
               :locals => {
                 :morearticles => $db_more_articles.call,
                 :article => @article,
                 :collabs => collabs,
                 :authors_list => authors_list
               }
    end
  end

  get '/collabs/?' do
    all_collabs = $db_collabs.call.sort_by { |x| x[:lname] }

    groups = all_collabs.group_by { |x| x[:lname][0].upcase }

    starred = all_collabs.select { |x| x[:starred] }.shuffle.first(12)

    mustache :collabs,
             :locals => {
               :groups => groups.keys.sort,
               :collabs => starred
             }
  end

  get '/collabs/:id/?' do
    @collab = $db_collab_by_id.call params[:id]

    redirect "/collabs/#{params[:id]}/#{@collab[:seo_name]}"
  end

  get '/collabs/:id/:seo_url?' do
    all_collabs = $db_collabs.call.sort_by { |x| x[:lname] }

    groups  = all_collabs.group_by { |x| x[:lname][0].upcase }

    @collab = $db_collab_by_id.call params[:id]

    halt 404, "No hay de esos..." if not @collab

    mustache :collab,
             :locals => {
               :groups => groups.keys.sort,
               :collab => @collab,
               :articles => @collab[:articles]
             }
  end

  get '/collabs-lastname/:letter' do
    all_collabs = $db_collabs.call

    collabs = all_collabs.select { |x| x[:lname][0].upcase == params[:letter].upcase }

    groups = all_collabs.group_by { |x| x[:lname][0].upcase }

    mustache :collabs,
             :locals => {
               :groups => groups.keys.sort,
               :collabs => collabs
             }
  end

  get '/suggestions/?' do
    mustache :suggestions,
             :locals => { :suggestions => $db_suggestions.call }
  end

  get '/search/?' do
    mustache :search
  end

  get %r{/(about|directory|related|find_us|privacy|publish|blog|archive)/?} do
    mustache :md,
             :locals => { :content => $db_pages_by_id.call(params[:captures].first)[:content] }
  end
end
