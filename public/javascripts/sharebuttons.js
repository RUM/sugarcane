function ready(fn) {
  if (document.attachEvent ?
      document.readyState === "complete" :
      document.readyState !== "loading") fn();

  else
    document.addEventListener('DOMContentLoaded', fn);
};

ready(() => {
  var loc = window.location.href;

  var tls = document.querySelectorAll('a.twitter-share-link')
  for (var l of tls)
    l.href = `https://twitter.com/share?text=Revista de la Universidad&url=${loc}&hashtags=`;

  var fls = document.querySelectorAll('a.facebook-share-link')
  for (var l of fls)
    l.href = `https://www.facebook.com/sharer/sharer.php?u=${loc}`;

  // document.querySelector('a#link-share-link').href = `#`;
});
