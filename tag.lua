--[[

Tagging extension for VLC
Copyright (c) 2012 Joshua Watzman (jwatzman@jwatzman.org)

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.

--]]

appname = "Tagger"
dlg = nil
test_label = nil

function dlog(msg)
	vlc.msg.warn(string.format("[%s] %s", appname, msg))
end

function descriptor()
	return {
		title = appname;
		version = "0.0";
		author = "Josh Watzman";
		url = "https://github.com/jwatzman/vlc-tag/";
		shortdesc = "Tag arbitrary media and filter to those tags";
		capabilities = { "input-listener", "playing-listener", "meta-listener" }
	}
end

function activate()
	dlog("activate")
	dlg = vlc.dialog(appname)
	test_label = dlg:add_label("Hi test", 1, 1)
end

function deactivate()
	dlog("deactivate")
	test_label = nil
	dlg:delete()
	dlg = nil
end

function close()
	dlog("close")
	vlc.deactivate()
end

function input_changed()
	dlog("input changed")
	test_label:set_text(vlc.input.item():uri())
end

function status_changed()
	dlog("status changed")
end

function meta_changed()
	dlog("meta changed")
end
