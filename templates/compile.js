function handlebarsName(path) {
	var filename = path.substring(path.lastIndexOf('/') + 1);
	return filename.substring(0, filename.lastIndexOf('.'));
}

var lines = arguments[0];
var templateName = handlebarsName(arguments[1]);
var file = '';
while (lines-- > 0) {
	// We can't call read(), since Spidermonkey on Mac is stuck on 1.7. Why
	// can't we just read line by line, you ask? Spidermonkey 1.7 also doesn't
	// distringuish between EOF and empty lines. Compiling the new sources on
	// Mac is stupidly non-trivial. Mumble mumble.
	var line = readline();
	file += line;
}
var compiled = precompileEmberHandlebars(file);
print('Em.TEMPLATES["' + templateName + '"] = Em.Handlebars.template(' + compiled + ');');

/*
for (var i = 0; i < paths.length; ++i) {
	var path = paths[i];
	var templateName = handlebarsName(path);
	var template = read(path);
	var compiled = precompileEmberHandlebars(template);

	print('Em.TEMPLATES["' + templateName + '"] = Em.Handlebars.template(' + compiled + ');');
}
*/
