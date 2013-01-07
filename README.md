About
=====

A VLC extension for tagging media as they are playing, and then filtering
playlists based on those tags.

Usage
=====

![Tagger screenshot](https://raw.github.com/jwatzman/vlc-tag/master/tagger.png)

- The first line displays the full URI of the item playing. The tag DB stores tags
by their URI.
- The next line is a space separated list of tags for this media item. In the
example, the YouTube video is tagged with "cat" and "cute".
- The third line allows you to filter the current playlist by its tags. You can
use "+TAG" to mean "filter anything that does not have tag TAG" and "-TAG" to mean
"filter anything that does have tag TAG". For example, if I wanted to filter the
current playlist down only to videos tagged "cat" but not "cute", I would enter
"+cat -cute" in the field and then press "filter".
- The final button "update" forces the dialog to update (and save the tag DB) as if
the current playlist item had changed. This is to work around the below issue with
OS X.

Mac OS X Notes
==============

VLC's extension support on OS X is rocky at best right now (but thankfully it now
exists as of VLC 2.0). As of this writing, the OS X interface does not properly
inform extensions when the playlist item has changed -- you'll need to push the
"update" button in order to cause the dialog to reflect the change (and save the
tag DB). Again, as of this writing, I have a patch in review which will fix this
problem, and will hopefully be included in VLC 2.1:

http://mailman.videolan.org/pipermail/vlc-devel/2013-January/091288.html

http://patches.videolan.org/patch/912/

There's another issue where any update to the dialog would cause it to re-center,
which is really annoying when tagging a large volume of files. My patch to fix this
was accepted and will be included in VLC 2.1 and 2.0.6.

http://git.videolan.org/?p=vlc.git;a=commit;h=ad765c21ffe71fe27b3b6a03ebaa878408ba40ee

http://git.videolan.org/?p=vlc/vlc-2.0.git;a=commit;h=67b896c381209266ed7afc978aef8b20135ed557

Depending on when you are reading this, and what has happened to my patches, you may
have a better time building VLC with them included, or using some nightly build.

Known Issues
============

WFM, YMMV, etc. Patches welcomed.

- The tag DB is just a Lua code fragment, which is eval'd in order to load it. I
would in no way be surprised to discover some security vulerability here -- it's
quite possible that a specially-crafted filename could execute arbitrary Lua code
when its tags are loaded from the DB. Be careful.
- Tag saving and loading use a ton of string concatenation and likely get
inefficient after a while.
- There is no way to totally remove a file from the DB.
- The filter query syntax isn't terribly expressive. I'd like something based on
regular expressions, but expressing negation with regexes is also tricky.
