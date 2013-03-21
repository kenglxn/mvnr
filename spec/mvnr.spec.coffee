MvnR = require '../lib/mvnr'
fs = require 'fs'
cp = require 'child_process'

mvnr = new MvnR()

describe 'mvnr', ->
  ['A',
   'A/B',
   'A/B/pom.xml',
   'C',
   'C/pom.xml',
   'C/D',
   'C/D/pom.xml',
   'E',
   'E/pom.xml']

  ['B -> E',
   'B -> C'
   'E -> C'
   'C -> E -> B']

  origDir = process.cwd()
  testDir = 'spec/testDir'

  beforeEach ->
    process.chdir(testDir)
    testDir = process.cwd()

  afterEach ->
    process.chdir(origDir)

  it 'should find all pom paths', ->
    expect(mvnr.ls).toBeDefined()
    repos = mvnr.ls()
    expect(repos.length).toBe(3)
    expect(repos).toContain("#{testDir}/A/B/pom.xml")
    expect(repos).toContain("#{testDir}/C/pom.xml")
    expect(repos).toContain("#{testDir}/E/pom.xml")

  it 'should get all artifacts with dependencies filtering out non-relevant dependencies', ->
    expect(mvnr.artifacts).toBeDefined()
    artifacts = mvnr.artifacts()
    expect(artifacts.length).toBe(3)
    expect(artifacts[0].pom.artifactId.toString()).toBe('B')
    expect(artifacts[0].pom.dependencies[0].dependency.length).toBe(2)
    expect(artifacts[0].pom.dependencies[0].dependency[0].artifactId.toString()).toBe('E')
    expect(artifacts[0].pom.dependencies[0].dependency[1].artifactId.toString()).toBe('C')

    expect(artifacts[1].pom.artifactId.toString()).toBe('C')
    expect(artifacts[1].pom.dependencies).toBeUndefined()

    expect(artifacts[2].pom.artifactId.toString()).toBe('E')
    expect(artifacts[2].pom.dependencies[0].dependency.length).toBe(1)
    expect(artifacts[2].pom.dependencies[0].dependency[0].artifactId.toString()).toBe('C')

  it 'should sort dependencies in order from least dependant to most dependant', ->
    expect(mvnr.depsort).toBeDefined()
    sorted = mvnr.depsort()
    expect(sorted.length).toBe(3)
    expect(sorted[0].pom.artifactId.toString()).toBe('C')
#    expect(sorted[1].pom.artifactId.toString()).toBe('E')
#    expect(sorted[2].pom.artifactId.toString()).toBe('B')


#  it 'should execute git command recursively for all git enabled repos', ->
#    expect(mvnr.do).toBeDefined()
#    expect(cp.exec).toBeDefined();
#    spyOn(cp, 'exec').andCallFake (cmd, cb) ->
#      cb()
#    mvnr.do 'status'
#    expect(cp.exec).toHaveBeenCalled()
#    expect(cp.exec.callCount).toBe(2)
#    expect(cp.exec.calls[0].args[0]).toBe("git --git-dir=#{process.cwd()}/withGitRepoAtSecondLevel/secondLevel/.git --work-tree=#{process.cwd()}/withGitRepoAtSecondLevel/secondLevel status")
#    expect(cp.exec.calls[1].args[0]).toBe("git --git-dir=#{process.cwd()}/withGitRepo/.git --work-tree=#{process.cwd()}/withGitRepo status")
#
#  it 'should support splats', ->
#    expect(mvnr.do).toBeDefined()
#    expect(cp.exec).toBeDefined();
#    spyOn(cp, 'exec').andCallFake (cmd, cb) ->
#      cb()
#    mvnr.do 'diff', '--staged'
#    expect(cp.exec).toHaveBeenCalled()
#    expect(cp.exec.callCount).toBe(2)
#    expect(cp.exec.calls[0].args[0]).toBe("git --git-dir=#{process.cwd()}/withGitRepoAtSecondLevel/secondLevel/.git --work-tree=#{process.cwd()}/withGitRepoAtSecondLevel/secondLevel diff --staged")
#    expect(cp.exec.calls[1].args[0]).toBe("git --git-dir=#{process.cwd()}/withGitRepo/.git --work-tree=#{process.cwd()}/withGitRepo diff --staged")



