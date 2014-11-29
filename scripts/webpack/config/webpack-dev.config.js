var Builder = require('../webpack-config-builder');

module.exports = new Builder({
  debug: true,
  hashing: false,
  optimization: false,
  sourceMaps: true,
  publicPath: '/'
});
