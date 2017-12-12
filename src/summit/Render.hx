package summit;

import summit.data.*;
import Markdown;
import markdown.AST;
import tink.Anon.merge;

using sys.io.File;
using haxe.io.Path;
using sys.FileSystem;

class TextRenderer implements NodeVisitor {
  var buf = new StringBuf();
  function new() {}
	public function visitText(text:TextNode):Void {
    buf.add(text.text);
  }
	public function visitElementBefore(element:ElementNode):Bool
    return true;
	public function visitElementAfter(element:ElementNode):Void {}

  static public function getText(markdown:Node) {
    var r = new TextRenderer();
    markdown.accept(r);
    return r.buf.toString();
  }
}

@:less('styles.less')
@:template
class Render {

  static function dissect(md:String) {

		var document = new Document(),
        lines = ~/(\r\n|\r)/g.replace(md, '\n').split("\n");
    
    document.parseRefLinks(lines);

    var blocks = document.parseLines(lines);

    return 
      switch blocks[0] {
        case null: None;
        case v: Some({
          title: new Html(Markdown.renderHtml(switch Std.instance(v, ElementNode) {
            case null: [v];
            case e: e.children;
          })),
          body: new Html(Markdown.renderHtml(blocks.slice(1))),
        });
      }
  }

  static function main() {
    { //skip irrelevant warnings from yaml lib
      var old = haxe.Log.trace;
      haxe.Log.trace = function (msg, ?pos:haxe.PosInfos)
        if (pos != null && pos.fileName != 'YTimestamp.hx') old(msg, pos);
    }
    var talks = 
      sorted(
        read('src/summit/talks', function (v) 
          return dissect(v.markdown).map(function (doc):Talk return {
            id: v.id,
            title: doc.title,
            track: v.frontmatter.track,
            starts: v.frontmatter.starts,
            speakers: v.frontmatter.speakers,
            duration: v.frontmatter.duration,
            description: doc.body,
          })
        ),
        function (a, b) return Reflect.compare(a.starts.getTime(), b.starts.getTime())
      );
    
    var names = 'Wednesday,Thursday,Friday,Saturday'.split(',');
    
    'bin/index.html'.saveContent(renderAll({
      days: [for (day in 13...17) {
        {
          name: names.shift(),
          talks: [for (t in talks) if (t.starts.getDate() == day) t],
        }
      }],
      speakers: sorted(
        read('src/summit/speakers', function (v) return Some(({
          id: v.id,
          jobTitle: v.frontmatter.jobTitle,
          shortName: v.frontmatter.shortName,
          fullName: v.frontmatter.fullName,
          order: or(v.frontmatter.order, 0),
          image: or(v.frontmatter.image, switch '/assets/speakers/${v.id}.jpg' {
            case found if ('bin$found'.exists()): found;
            default: '/assets/speakers/${v.id}.png';
          }),
          link: or(v.frontmatter.link, 'https://github.com/${v.id}'),
          bio: new Html(Markdown.markdownToHtml(v.markdown)),
          talks: [for (t in talks) if (t.speakers != null && t.speakers.indexOf(v.id) != -1) t],
        }:Speaker))),
        function (a, b) return a.order - b.order
      )
    }));
    
  }

  static function sorted<A>(a:Array<A>, f) {
    a.sort(f);
    return a;
  }

  static function or<A>(a:A, b:A)
    return if (a == null) b else a;

  static function read<Raw, A>(directory:String, f:{ id:String, frontmatter:Raw, markdown: String }->Option<A>):Array<A> {
    return [for (file in directory.readDirectory())
      switch split('$directory/$file') {
        case None: continue;
        case Some(v):
          switch (f(merge(v, id = file.withoutExtension())):Option<A>) {
            case None: continue;
            case Some(v): v;
          }
      }
    ];
  }

  static function split<A>(path:String) {
    var content = path.getContent().replace('\r', '\n');
    return 
      if (content.startsWith('---\n'))
        switch content.indexOf('---\n', 3) {
          case -1: None;
          case v:
            var data:A = 
              try 
                yaml.Yaml.parse(
                  content.substring(4, v),
                  new yaml.Parser.ParserOptions().useObjects()
                )
              catch (e:Dynamic) {
                Sys.println('invalid frontmatter in $path:\n$e');
                Sys.exit(500);
                None;
              }
            Some({
              frontmatter: data,
              markdown: content.substr(v + 4),
            });
        }
      else None;
  }
}