# Recursive Descent Parsers

Presentation originally given at [B'more on Rails](http://bmoreonrails.org) on
[2014-07-08](http://www.meetup.com/bmore-on-rails/events/188368652/)

* [Slides](https://drive.google.com/file/d/0B98lOc5S3ThPM2FWMFRocnd4eDg/edit?usp=sharing) (and [also on github](../master/talk.pdf))
* [rspec for parser](../master/spec/parser_spec.rb)
* [parser](../master/lib/demo_expressions/parser.rb)
  * [lexer](../master/lib/demo_expressions/parser.rb#L25-67)
  * [grammar rules](../master/lib/demo_expressions/parser.rb#L69-127)
* [helper modules mixed in to parser](../master/lib/parsing_tools)
