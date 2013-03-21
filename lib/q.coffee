_ = require 'underscore'

q =
  dequeue: (fns, cb) ->
    fn = _.first fns
    fns = _.rest fns
    return cb() unless fn
    fn ->q.dequeue fns, cb

exports = module.exports = q