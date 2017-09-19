function _footnotes() {
  var footnotes = document.querySelectorAll('div.footnotes ol li');

  var i = 0;

  for (i = 0; i < footnotes.length; i++) {
    var f = footnotes[i];

    var id = f.id.replace("fn:", "fnref:");
    var ref = document.getElementById(id);

    var span = document.createElement('span');
    span.className = 'footnote-hover';
    span.innerHTML = f.innerHTML;
    // span.innerText = f.innerText;

    ref.appendChild(span);
  }
};
