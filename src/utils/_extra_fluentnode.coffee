crypto = require 'crypto'

String::checksum = (algorithm, encoding)->
  crypto.createHash(algorithm || 'md5')
        .update(@.toString(), 'utf8')
        .digest(encoding || 'hex')


String::size = ()->
  @.length

String::line = ()->
  @.add require('os').EOL