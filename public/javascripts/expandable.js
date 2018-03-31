_expandables = function() {
  var expandables = document.querySelectorAll('p.expandable');

  expandables.forEach(function(e) {
    var o = document.createElement('a');
    o.href = '#';
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
    o.innerText = 'Expandir imagen';
    o.style = sty;

    var i = e.querySelector('img');

    var a = (event) => {
      event.preventDefault();
      event.stopPropagation();

      // the strong assumption here is that the styles attributes were
      // empty in the first place... and ugly waiting to happen.

      i.style = null;
      e.style = null;
      o.style = sty;

      i.removeEventListener('click', a);
      o.addEventListener('click', b);
    };

    var b = (event) => {
      event.preventDefault();
      event.stopPropagation();

      e.style = `
position: absolute;
padding: 1em !important;
margin: 0;
z-index: 10;
text-align: center;
top: 0;
left: 0;
background-color: rgba(0, 0, 0, 0.7);
`;

      o.style["display"] = "none";

      i.style["margin"] = "auto";
      i.style["width"]  = "auto";
      i.style["height"] = "auto";

      var oo = document.createElement('a');
      oo.innerText = "Puedes regresar dando click en la imagen";
      oo.style = `
background-color: #e3655a;
padding: 0.5em 1em;
color: #f1f1f1;
position: fixed;
top: 1em;
right: 1em;
z-index: 1000;
font-family: Cormorant, serif;
font-size: 2em;
`;

      oo.addEventListener('click', () => oo.remove());
      document.body.appendChild(oo);
      setTimeout(() => { if (oo) oo.remove() }, 5000);

      e.addEventListener('click', a);
    };

    o.addEventListener('click', b);

    e.prepend(o);
  });
};
