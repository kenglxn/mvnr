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



