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
uswds.paths.dist.img = './public/img'
uswds.paths.dist.fonts = './public/fonts'
uswds.paths.dist.js = './app/javascript/uswds'

/**
* Exports
* Add as many as you need
*/
exports.init = uswds.init;
exports.compile = uswds.compile;
exports.watch = uswds.watch;
