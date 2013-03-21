fs = require 'fs', _ = require 'underscore', cp = require 'child_process', color = require './color', q = require './q'
xml2js = require 'xml2js'

class MvnR
  log = (m...) =>
    console.log m...

  exec = (cmd, pom, cb) =>
    cp.exec "mvn -f #{pom} #{cmd.join(' ')}", (err, stdout, stderr) ->
      msg = ''
      msg += "#{stdout}\n#{color.cls}" if stdout?.length > 0
      msg += "#{color.red}#{err}#{color.cls}" if err?.length > 0
      msg += "#{color.red}#{stderr}#{color.cls}" if stderr?.length > 0
      log "#{color.yellow}::#{pom}::#{color.green}\n#{msg}" if msg?.length > 0
      cb()

  do: (cmd...) =>
    fns = []
    projects = @depsort()
    _.each projects, (project) =>
      fns.push (cb) =>
        exec cmd, project.repo, cb
    q.dequeue fns.reverse(), =>
    log "#{color.red}no mvn projects under #{color.yellow}#{process.cwd()}#{color.cls}" if projects.length == 0

  ls: (dir = process.cwd()) =>
    dirs = []
    if fs.statSync(dir).isDirectory()
      paths = fs.readdirSync(dir)
      if 'pom.xml' in paths
        dirs.push dir + '/pom.xml'
      else
        subDirs = _.filter paths, (path) => path.indexOf('.') != 0 && fs.statSync(dir + '/' + path).isDirectory()
        _.each subDirs, (subDir) => dirs.push @ls dir + '/' + subDir
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

  depsort: (artifacts = @artifacts()) =>
    sorted = _.reject artifacts, (a) => a.pom.dependencies?[0].dependency.length > 0
    artifacts = _.reject artifacts, (a) =>
      isSorted = false
      for s in sorted
        isSorted = true if "#{a.pom.groupId}:#{a.pom.artifactId}" == "#{s.pom.groupId}:#{s.pom.artifactId}"
      isSorted

    if artifacts.length == 0
      return sorted

    for artifact in artifacts
      filtered = _.reject artifact.pom.dependencies?[0].dependency, (d) =>
        isInSorted = false
        for a in sorted
          isInSorted = true if "#{a.pom.groupId}:#{a.pom.artifactId}" == "#{d.groupId}:#{d.artifactId}"
        isInSorted
      artifact.pom.dependencies?[0].dependency = filtered

    _.union(sorted, @depsort(artifacts, sorted))

exports = module.exports = MvnR
