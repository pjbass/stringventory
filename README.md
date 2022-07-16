# Stringventory

A command line app to help track string changes

## Installation

To install from source, clone the source code and run `shards build`. Once the
binary has built, move the resulting binary to somewhere in your path.

## Usage

`stringventory` is a command line tool that performs actions on resources.
Commands take the form of `stringventory <resource> <action> [options]`, where
resource can be one of `guitars`, `strings`, `changes`, or `database`. Each
resource has a different set of actions that can be performed on it (i.e.
adding a new instrument to your collection or updating the database). The
`stringventory` binary itself and all of the resources and actions support the
`-h, --help` option, which can be used to learn more about the resources and
actions, as well as the options that they support.

### Guitars

Guitars are the main focus of `stringventory`. Available actions are `add`
(which adds a new guitar to the database), `remove` (which removes a guitar
from the database), and `list` (which lists guitars from the database).

### Strings

Strings are inventoried in `stringventory` as well, in part to help the user
see when it may be time to order more strings. Available actions are `add`
(which adds a type of string pack to the database), `remove` (which removes
a type of string pack from the database), `bought` (which increases the number
of packs available for an already added type of string pack), and `used` (which
decreases the number of packs of a certain type).

### Changes

String changes are tracked under `changes` in `stringventory`. Available actions
are `restring` (which adds an instance of a guitar restring to the database,
deducting one pack of strings of the given type) and `list` (which shows a list
of string changes that have occured).

### Database

Database management functions are also included in the `stringventory` binary.
In order to keep `stringventory` to a single binary without a need for attendant
files, any time the models are updated, the database must be dropped and recreated.
Because of this, the `dump` action is provided to dump the database data to a
single yaml file that can then be reloaded either using options to the `update`
action or by using the `load` action. It is always recommended to perform a
`dump` before updating to a new version of `stringventory`, even if there are
no changes to the models. Additional actions include `create` (which will create
the database from scratch) and `drop` (which will erase all data).

## Development

`stringventory` is written in Crystal, and as such will require the Crystal
compiler and `shards` for managing dependencies. No other tools are required.

## Contributing

1. Fork it (<https://github.com/pjbass/stringventory/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [PJ](https://github.com/pjbass) - creator and maintainer
