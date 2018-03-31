_expandables = function() {
  var expandables = document.querySelectorAll('p.expandable');

  expandables.forEach(function(e) {
    var o = document.createElement('a');
    var i = e.querySelector('img');

    var sty = `
font-size: medium;
background-color: #e3655a;
padding: 0.5em 1em;
color: #f1f1f1;
position: absolute;
top: 1.7em;
right: 0;
display: block;
`;

    var b = (event) => {
      event.preventDefault();
      event.stopPropagation();

      window.open(i.src, '_blank');
    };

    o.href = i.src;
    o.target = "_blank";
    o.innerText = 'Expandir imagen';
    o.style = sty;

    i.style.cursor = 'pointer';
    i.addEventListener('click', b);

    e.prepend(o);
  });
};
