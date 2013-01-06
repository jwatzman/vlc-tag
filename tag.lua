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
tags_filename = nil
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

	tags_filename = vlc.config.configdir() .. "/taggerdb"
	dlog(tags_filename)

	read_tags()

	dlg = vlc.dialog(appname)

	dlg:add_label("Playing:", 1, 1)
	playing_label = dlg:add_label("", 2, 1)

	dlg:add_label("Tags:", 1, 2)
	tag_input = dlg:add_text_input("", 2, 2)

	dlg:add_button("Filter", filter_button_clicked, 1, 3)
	filter_input = dlg:add_text_input("", 2, 3)

	dlg:add_button("Update", input_changed, 1, 4)
	dlg:add_label("(for OS X)", 2, 4)

	input_changed()
end

function deactivate()
	dlog("deactivate")

	input_changed() -- force writeback to tags table and file

	tag_input = nil
	playing_label = nil
	dlg:delete()
	dlg = nil

	tags = {}
	tags_filename = nil
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
		write_tags()
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

	local include, exclude = {}, {}
	for _, v in pairs(split(filter_input:get_text(), " ")) do
		local sigil = v:sub(1,1)
		local tag = v:sub(2)
		if sigil == "+" then
			include[tag] = tag
		elseif sigil == "-" then
			exclude[tag] = tag
		else
			include[v] = v
		end
	end

	for _, v in pairs(vlc.playlist.get("playlist", false).children) do
		if not passes_filters(v.path, include, exclude) then
			dlog(string.format("filtering %s", v.path))
			vlc.playlist.delete(tonumber(v.id))
		end
	end
end

function passes_filters(uri, include, exclude)
	local uri_tags = tags[uri]
	if not uri_tags then
		uri_tags = {"NOTAGS"}
	end

	local tags_set = array_to_set(uri_tags)

	for _, v in pairs(exclude) do
		if tags_set[v] then
			return false
		end
	end

	for _, v in pairs(include) do
		if not tags_set[v] then
			return false
		end
	end

	return true
end

function read_tags()
	dlog("reading tags")
	local f = io.open(tags_filename, "rb")
	if f then
		local file_contents = f:read("*all")
		f:close()
		tags = loadstring(file_contents)()
	end
end

function write_tags()
	dlog("writing tags")
	local f = io.open(tags_filename, "wb")
	if f then
		f:write(table_to_string(tags))
		f:close()
	else
		dlog("failed to write tags!!")
	end
end

-- Adapted from http://lua-users.org/wiki/SplitJoin
function split(str, sep)
	local fields = {}
	local pattern = string.format("([^%s]+)", sep)
	str:gsub(pattern, function(c) fields[#fields+1] = c end)
	return fields
end

function array_to_set(vals)
	local set = {}
	for _, v in pairs(vals) do
		set[v] = v
	end
	return set
end

function table_to_string(t)
	return "return {\n" .. table_to_string_rec(t, 1) .. "}\n"
end

function table_to_string_rec(t, depth)
	local tab = "\t"
	local indent = tab:rep(depth)

	local result = ""
	for k,v in pairs(t) do
		-- I don't know lua very well, but I can't imagine these string
		-- concatenations are efficient.
		result = result .. indent ..
			"[" .. val_to_string(k, depth) .. "]" ..
			" = " ..
			val_to_string(v, depth) ..
			",\n"
	end

	return result
end

function val_to_string(v, depth)
	local tab = "\t"
	local indent = tab:rep(depth)

	local ty = type(v)
	if ty == "table" then
		return "{\n" .. table_to_string_rec(v, depth + 1) .. indent .. "}"
	elseif ty == "number" then
		return string.format("%d", v)
	else
		return string.format("%q", v)
	end
end
