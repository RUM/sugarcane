_loadasset = function(t,id,media,autosize) {
	function getCORS(url, success) {
    var xhr = new XMLHttpRequest();

    if (!('withCredentials' in xhr))
      xhr = new XDomainRequest(); // fix IE8/9

    xhr.open('GET', url);
    xhr.onload = success;
    xhr.send();

    return xhr;
  }

  getCORS(`https://www.revistadelauniversidad.mx/api/articles?id=eq.${id}`, (request) => {
    try {
      var response = request.currentTarget.response || request.target.responseText;
      var tag;

      switch (media) {
      case 'video':
        var asset = JSON.parse(response)[0]['asset'];

        var w = (autosize && "640") || t.clientWidth;
        var h = (autosize && "320") || t.clientHeight;

        if (!asset) return;

        tag = `<iframe width="${w}"
                       height="${h}"
                       src="${asset}"
                       frameborder="0"
                       gesture="media"
                       allow="encrypted-media"
                       allowfullscreen=""></iframe>`;
        break;

      case 'audio':
        var file = JSON.parse(response)[0]['file'];

        if (!file) return;

        tag = `<audio controls=""
                      style="width: 100%"
                      preload="none"
                      controlsList="nodownload">
                 No se deja esta cosa tocar audio...
                 <source src="${file}">
               </audio>`;

        break;
      }

      t.innerHTML = tag;
    }

    catch (e) {
      console.error(e);
      alert('Algo se super chaló... disculpis.');

      window.location = `${window.location.origin}/articles/${id}`;
    }
  });
};
