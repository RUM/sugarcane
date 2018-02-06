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

    var i = e.querySelector('img')

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

      e.style["padding"]    = "1em !important";
      e.style["margin"]     = "1em !important";

      e.style["z-index"]    = "10";
      e.style["text-align"] = "center";

      e.style["position"]   = "fixed";
      e.style["top"]        = "0";
      e.style["left"]       = "0";

      e.style["width"]  = "100%";
      e.style["height"] = window.innerHeight + "px";

      e.style["background-color"] = "rgba(0, 0, 0, 0.7)";

      i.style["margin"] = "0 auto";

      o.style["display"] = "none";

      var screen_ratio = window.innerWidth / window.innerHeight;
      var image_ratio  = i.clientWidth / i.clientHeight;

      if (screen_ratio > 1) {
        if (image_ratio > screen_ratio) {
          i.style["width"]  = window.innerWidth + "px";
          i.style["height"] = "auto";
        }

        else {
          i.style["height"] = window.innerHeight + "px";
          i.style["width"]  = "auto";
        }
      }

      // else {
      //   if (image_ratio > screen_ratio) ;
      //   else ;
      // }

      e.addEventListener('click', a);
    };

    o.addEventListener('click', b);

    e.prepend(o);
  });
};
