fs = require 'fs', _ = require 'underscore', cp = require 'child_process', color = require './color', q = require './q'

class MvnR
  log = (m...) => console.log m...

  exec = (cmd, repo, cb) =>
    cp.exec "git --git-dir=#{repo}/.git --work-tree=#{repo} #{cmd.join(' ')}", (err, stdout, stderr) ->
      msg = ''
      msg += "#{stdout}\n#{color.cls}" if stdout?.length > 0
      msg += "#{color.red}#{err}#{color.cls}" if err?.length > 0
      msg += "#{color.red}#{stderr}#{color.cls}" if stderr?.length > 0
      log "#{color.yellow}::#{repo}::#{color.green}\n#{msg}" if msg?.length > 0
      cb()

  do: (cmd...) =>
    fns = []
    repos = findRepos()
    _.each repos, (repo) => fns.push (cb) => exec cmd, repo, cb
    q.dequeue fns, =>
    log "#{color.red}no git repos under #{color.yellow}#{process.cwd()}#{color.cls}" if repos.length == 0

  ls: (dir = process.cwd()) =>
    dirs = []
    if fs.statSync(dir).isDirectory()
      subDirs = fs.readdirSync(dir)
      if 'pom.xml' in subDirs
        dirs.push dir + '/pom.xml'
      else
        _.each subDirs, (subDir) =>
          dirs.push @ls dir + '/' + subDir
    _.flatten dirs

exports = module.exports = MvnR
