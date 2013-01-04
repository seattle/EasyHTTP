## Basic Usage

### Simple request:

```ruby
session = EasyHTTP::Session.new "https://www.google.com/", { :ssl => true }
session.get "/"
```

### Additional config:

```ruby
session = EasyHTTP::Session.new "https://www.google.com/", {
  :ssl => true,
  :port => 443,
  :username => 'http_auth_user',
  :password => 'http_auth_pass',
  :read_timeout => 1000,
  :debug => $sdtout,
  :insecure => false
  }
```

### Store session cookies

```ruby
session = EasyHTTP::Session.new "https://www.google.com/", { :ssl => true }
session.session_cookies
```

### Enable body encode (only ruby >= 1.9.2):

```ruby
Encoding.default_internal = 'UTF-8'
```

## Installation

```
~$ sudo gem install easy_http
```

## Author

* Tomas J. Sahagun (<113.seattle@gmail.com> | [github](https://github.com/seattle) | [twitter](https://twitter.com/seattle113))


## License

EasyHTTP uses the MIT license, check LICENSE file.
