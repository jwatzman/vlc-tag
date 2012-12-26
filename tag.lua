appname = "Tagger"
dlg = nil

function dlog(msg)
	vlc.msg.dbg(string.format("[%s] %s", appname, msg))
end

function descriptor()
	return {
		title = appname;
		version = "0.0";
		author = "Josh Watzman";
		url = "https://github.com/jwatzman/vlc-tag/";
		shortdesc = "Tag arbitrary media and filter to those tags";
	}
end

function activate()
	dlog("activate")
	dlg = vlc.dialog(appname)
	dlg:add_label("Hi test")
end

function deactivate()
	dlog("deactivate")
	dlg:delete()
	dlg = nil
	vlc.deactivate()
end

function close()
	dlog("close")
	deactivate()
end
