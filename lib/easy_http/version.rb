# -*- encoding: utf-8 -*-

module EasyHTTP

  module Version
    MAJOR = 0
    MINOR = 1
    TINY  = 0
  end

  PROGRAM_NAME     = "EasyHTTP"
  PROGRAM_NAME_LOW = PROGRAM_NAME.downcase
  PROGRAM_DESC     = "Simple wrapper for Net:HTTP"
  VERSION = [Version::MAJOR, Version::MINOR, Version::TINY].join('.')
  AUTHOR = "Tomas J. Sahagun"
  AUTHOR_EMAIL = "113.seattle@gmail.com"
  DESCRIPTION = "#{PROGRAM_NAME} #{VERSION}\n2012, #{AUTHOR} <#{AUTHOR_EMAIL}>"

  module GemVersion
    VERSION = ::EasyHTTP::VERSION
  end

end
