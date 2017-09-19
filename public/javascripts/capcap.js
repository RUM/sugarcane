function _capcap() {
  var ps = document.querySelectorAll('main > div > p');
  var p = null;
  var lh = 0;

  for (var i = 0; i < ps.length; i++)
    if (ps[i].innerText.trim() !== "") { p = ps[i]; break; }

  var first = p.innerText.slice(0,1);
  var head  = p.innerHTML.slice(0, p.innerHTML.indexOf(first));
  var tail  = p.innerHTML.slice(p.innerHTML.indexOf(first) + 1);

  var cap = document.createElement('span');
  cap.innerHTML = first;

  if (first.match(/[¿¡]/))
    lh = "1.9rem";
  else
    lh = "5.9rem";

  cap.style = `
font-size: 8.25rem;
line-height: ${lh};
margin-right: 0.3125rem;
height: 4.5rem;
float: left;
`;

  p.innerHTML = head + cap.outerHTML + tail;
};
