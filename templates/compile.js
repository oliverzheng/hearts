function handlebarsName(path) {
	var filename = path.substring(path.lastIndexOf('/') + 1);
	return filename.substring(0, filename.lastIndexOf('.'));
}

paths = arguments;
for (var i = 0; i < paths.length; ++i) {
	var path = paths[i];
	var templateName = handlebarsName(path);
	var template = read(path);
	var compiled = precompileEmberHandlebars(template);

	print('Em.TEMPLATES["' + templateName + '"] = Em.Handlebars.template(' + compiled + ');');
}
