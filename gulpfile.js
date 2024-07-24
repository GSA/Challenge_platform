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
uswds.paths.dist.css = './app/assets/stylesheets';
uswds.paths.dist.theme = './app/assets/uswds';
uswds.paths.src.sass = './node_modules/@uswds/uswds/packages'
uswds.paths.dist.js = './app/javascript/uswds'
uswds.paths.dist.img = './app/assets/uswds/images'
uswds.paths.dist.fonts = './app/assets/uswds/fonts'

/**
* Exports
* Add as many as you need
*/
exports.init = uswds.init;
exports.compile = uswds.compile;
exports.watch = uswds.watch;
exports.default = uswds.watch;
exports.copyFonts = uswds.copyFonts;
exports.copyImages = uswds.copyImages;