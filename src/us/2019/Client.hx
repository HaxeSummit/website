package;

import js.html.*;
import js.Browser.*;
using StringTools;

class Client {

  static function main() {
    function overloayFromHash()
    for (kind in ['speaker', 'talk']) {
      if (window.location.hash.startsWith('#$kind-')) {
        var id = window.location.hash.substr('#$kind-'.length);
        switch document.getElementById('$kind-$id') {
          case null:
          case v: v.click();
        }
        return;
      }
    }


    overloayFromHash();

    window.onhashchange = overloayFromHash;
    document.addEventListener('change', function (e) {
      var elt:Element = cast e.target;
      if (elt.matches('input[id][name="current-speaker"]:checked'))
        window.location.hash = switch elt.id {
          case 'nospeaker': '';
          case v: v;
        }
    });
    var nav = document.getElementsByTagName('nav')[0];
    var main = document.getElementsByTagName('main')[0];
    function updateNav() {
      if (main.scrollTop > 100)
        nav.classList.remove('transparent');
      else
        nav.classList.add('transparent');
    }
    main.addEventListener('scroll', updateNav);
    updateNav();
  }

}