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
playing_label = nil
tag_input = nil
filter_input = nil

tags = {}
playing_uri = nil

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
		capabilities = { "input-listener" }
	}
end

function activate()
	dlog("activate")
	dlg = vlc.dialog(appname)

	dlg:add_label("Playing:", 1, 1)
	playing_label = dlg:add_label("", 2, 1)

	dlg:add_label("Tags:", 1, 2)
	tag_input = dlg:add_text_input("", 2, 2)

	dlg:add_button("Filter", filter_button_clicked, 1, 4)
	filter_input = dlg:add_text_input("", 2, 4)

	input_changed()
end

function deactivate()
	dlog("deactivate")
	tag_input = nil
	playing_label = nil
	dlg:delete()
	dlg = nil

	tags = {}
	playing_uri = nil
end

function close()
	dlog("close")
	vlc.deactivate()
end

function input_changed()
	dlog("input changed")

	local input_text = tag_input:get_text()
	if playing_uri and input_text:len() > 0 then
		tags[playing_uri] = split(input_text, " ")
	end

	tag_input:set_text("")

	local item = vlc.input.item()
	if item then
		playing_uri = item:uri()
		playing_label:set_text(playing_uri)

		local playing_tags = tags[playing_uri]
		if playing_tags then
			tag_input:set_text(table.concat(playing_tags, " "))
		end
	else
		playing_uri = nil
		playing_label:set_text("(nothing playing)")
	end
end

function filter_button_clicked()
	dlog("filter button clicked")
	--[[
	dlog("---")
	for k,v in pairs(tags) do
		dlog(string.format("%s => %s", k, v))
	end
	dlog("---")
	for k,v in pairs(vlc.playlist.get("playlist", false).children) do
		dlog(string.format("%s => %s", k, v.path))
	end
	dlog("---")
	]]--

	--[[
	for i,v in pairs(vlc.playlist.get("playlist", false).children) do
	end
	]]--

	for i,v in pairs(split(filter_input:get_text(), " ")) do
		dlog(string.format("%s => %s", i, v))
	end
end

-- Adapted from http://lua-users.org/wiki/SplitJoin
function split(str, sep)
	local fields = {}
	local pattern = string.format("([^%s]+)", sep)
	str:gsub(pattern, function(c) fields[#fields+1] = c end)
	return fields
end

function values_to_set(vals)
	local set = {}
	for _, v in vals do
		set[v] = v
	end
	return set
end
