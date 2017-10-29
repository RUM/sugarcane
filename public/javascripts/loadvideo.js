_loadvideo = function(t,id) {
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
      var content = JSON.parse(response)[0]['content'];

      content = content.replace(/width="[0-9]+"/g, `width="${t.clientWidth}"`);
      content = content.replace(/height="[0-9]+"/g, `height="${t.clientHeight}"`);

      t.style['background'] = 'none';
      t.innerHTML = content;
    }

    catch (e) {
      console.error(e);
      alert('Algo se super chaló... disculpis.');
    }
  });
};
