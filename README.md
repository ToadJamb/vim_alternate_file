VIM Alternate File Plugin
=========================

This plugin is intended to open the unit test corresponding to the class in the
current buffer or the class that the unit test corresponds to if the current
buffer is a unit test.

It is currently very opinionated. Unit tests are expected to be in a spec folder
with a name that ends in \_spec.

Alternate files are currently opened in a vertical split.


Installation
------------

[Vundle](https://github.com/gmarik/vundle) is recommended for plugin management.

When using [Vundle](https://github.com/gmarik/vundle), simply add
the following line to your .vimrc:

		Bundle 'ToadJamb/vim-alternate-file'


Usage
-----

Add the following to your .vimrc to add a keybinding using your leader key:

		map <silent> <leader>s :call af:OpenAlternate()<CR>

Add the following to your .vimrc to add a keybinding using a custom vim command:

		command AF :execute af:OpenAlternate()


Notes
-----

The canonical repo for this plugin lives
[here](https://www.bitbucket.org/ToadJamb/vim-alternate-file), NOT on github.
It is on github only to ease use of installation via
[Vundle](https://github.com/gmarik/vundle).
