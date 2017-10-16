var _search_qlocked = false;
var _search_origin = 'https://www.revistadelauniversidad.mx/api'

function _search_will_search(str) {
  var r = false;

  switch(str) {
  case "collabs":
    r = true;
    break;

  case "articles":
    r = true;
    break;

  default:
    r = false;
  }

  return r;
}

function _search_render(array, container, template) {
  var container = document.querySelector(container);
  container.innerHTML = "";

  if (array === null) return;

  if (array.length === 0)
    container.innerHTML = "<div class='empty'></div>";

  // TODO: add a.name
  array.forEach((c) => {
    var div = container.appendChild(document.createElement('span'));
    div.innerHTML = template(c);
  });

  if (array.length > 2)
    _search_footer_hack(false);
};

function _search_article_template(a) {
  // TODO: add collabs?

  if (a.cover === null) a.cover = '';

  // strip down MD caracters:
  a.title = a.title.replace(/[_\*]/g, '')

  return `
<article class="article"
         onclick="window.location = '/articles/${a.id}'">
  <figure style="background-image: url(${a.cover});"
          class="no-mobile">
    <a href="/articles/${a.id}"></a>
  </figure>

  <div>
    <h3>
      <a href="/articles/${a.id}/${a.seo_title}">${a.title}</a>
    </h3>
  </div>
</article>`;
};

function _search_collab_template(c) {
  if (c.metadata.image === null) c.metadata.image = '';

  return `
<article class="collab"
         style="background-image: url(${c.metadata.image});"
         class="no-mobile">
  <div class="fuzz"></div>

  <a href="/collabs/${c.id}/${c.seo_name}">${c.name}</a>
</article>`;
};

function _search_fetch(url, callback) {
  var request = new XMLHttpRequest();
  request.open('GET', url, true);

  request.onload = function() {
    if (request.status >= 200 && request.status < 400) {
      var data = JSON.parse(request.responseText);
      callback(data);
    } else {
      // We reached our target server, but it returned an error
    }
  };

  request.onerror = function() {
    // There was a connection error of some sort
  };

  request.send();
};

function _search_footer_hack(position_absolute) {
  var f = document.querySelector('footer');
  f.style = position_absolute ? 'position: fixed !important;' : 'position: initial !important;';
};

function _search_unlock_shoot(e,f) {
  var v = e.target.value.replace(/[*\/\\{}\[\]]/g, '').trim();

  if (v === "" || v === null) {
    _search_footer_hack(true);
    _search_render(null, '#collabs', null);
    _search_render(null, '#articles', null);
    return;
  }

  if (_search_qlocked) return;

  _search_qlocked = true;

  if (_search_will_search('collabs'))
    _search_fetch(
      `${_search_origin}/collabs?select=id,name,seo_name,metadata&or=(lname.ilike.${v}*,fname.ilike.${v}*)&limit=12`,
      (data) => _search_render(data, '#collabs', _search_collab_template)
    );

  if (_search_will_search('articles'))
    _search_fetch(
      `${_search_origin}/articles?select=id,title,seo_title,cover&title=ilike.*${v}*&limit=6`,
      (data) => _search_render(data, '#articles', _search_article_template)
    );

  setTimeout(() => { _search_qlocked = false }, 200);
};

document.onreadystatechange = () => {
  if (document.readyState !== "interactive") return;

  var q = document.querySelector('input#search');
  q.onkeyup = (e) => _search_unlock_shoot(e);
};
