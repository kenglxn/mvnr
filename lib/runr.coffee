argv = process.argv.slice(2)

MvnR = require './mvnr'
new MvnR().do argv...
