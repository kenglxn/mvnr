fs = require 'fs', _ = require 'underscore', cp = require 'child_process', color = require './color', q = require './q'
xml2js = require 'xml2js'

class MvnR
  log = (m...) =>
    console.log m...

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
    _.each repos, (repo) =>
      fns.push (cb) =>
        exec cmd, repo, cb
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

  artifacts: =>
    qualifiers = []
    projects = []
    repos = @ls()
    parser = new xml2js.Parser()
    _.each repos, (repo) =>
      parser.parseString fs.readFileSync(repo), (err, result) =>
        projects.push
          pom: result.project
          repo: repo
        qualifiers.push "#{result.project.groupId}:#{result.project.artifactId}"
    for artifact in projects
      dependencies = artifact.pom.dependencies?[0].dependency
      filtered = _.filter dependencies, (dependency) =>
        _.contains qualifiers, "#{dependency.groupId}:#{dependency.artifactId}"
      artifact.pom.dependencies?[0].dependency = filtered
    projects

  depsort: (artifacts = @artifacts(), sorted = []) =>
    sorted.push _.reject artifacts, (a) => a.pom.dependencies?[0].dependency.length > 0
    sorted = _.flatten sorted

    for s in sorted
      console.log 'sorted', s.pom.artifactId
    console.log '------'

    artifacts = _.reject artifacts, (a) =>
      isSorted = false
      for s in sorted
        isSorted = true if "#{a.pom.groupId}:#{a.pom.artifactId}" == "#{s.pom.groupId}:#{s.pom.artifactId}"
      isSorted

    for a in artifacts
      console.log 'unsorted', a.pom.artifactId
    console.log '------'

    if artifacts.length == 0
      console.log 'all sorted out'
      return sorted

    for artifact in artifacts
      filtered = _.reject artifact.pom.dependencies?[0].dependency, (d) =>
        isInSorted = false
        for a in sorted
          isInSorted = true if "#{a.pom.groupId}:#{a.pom.artifactId}" == "#{d.groupId}:#{d.artifactId}"
        isInSorted
      artifact.pom.dependencies?[0].dependency = filtered

    @depsort(artifacts, sorted)

exports = module.exports = MvnR
