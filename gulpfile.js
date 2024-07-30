/* gulpfile.js */

/**
* Import uswds-compile
*/
const uswds = require("@uswds/compile");

/**
* USWDS version
* Set the major version of USWDS you're using
* (Current options are the numbers 2 or 3)
*/
uswds.settings.version = 3;

/**
* Path settings
* Set as many as you need
*/
uswds.paths.src.projectSass = './app/assets/uswds'
uswds.paths.dist.theme = './app/assets/uswds';
uswds.paths.dist.css = './app/assets/builds';
uswds.paths.dist.js = './app/assets/builds'
uswds.paths.dist.img = './app/assets/builds/images'
uswds.paths.dist.fonts = './app/assets/builds/fonts'

/**
* Exports
* Add as many as you need
*/
exports.init = uswds.init;
exports.compile = uswds.compile;
exports.watch = uswds.watch;
exports.default = uswds.watch;
