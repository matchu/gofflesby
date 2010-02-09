Gofflesby - a golfing test suite
================================

Quickly and easily test your code golf with a set of tests you create.

## Write tests

Tests are composed of basic input/output files.

    $ ruby add_test.rb test1 --in="123"

You can provide `--in` and `--out` for tests either inline like that, or be
prompted for them later. See `ruby add_test.rb --help` for some more options.

Tests end up saved in `tests/`, so they can be easily transferred to others.

## Run tests

Put your scripts in `scripts/`, and let Gofflesby do the rest :)

    $ ruby test.rb myscript.rb

Gofflesby automatically runs all the tests on `scripts/myscript.rb`, giving you
pass/fail feedback instantly.

### Language support

Gofflesby currently supports

* Ruby
* PHP
* C++ (requires g++)

...but this can easily be changed. `config.yml` contains basic bash instructions
on how to run a file of any filetype. `{SCRIPT}` is replaced with the script
name, and `{IO}` is replaced with the STDIN/STDOUT part of the command. Add your
own languages as needed, and feel free to send a pull request.
