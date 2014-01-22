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

[Vundle][vundle] is recommended for plugin management.

When using [Vundle][vundle], simply add the following line to your .vimrc:

		Plugin 'ToadJamb/vim_alternate_file'


Usage
-----

Add the following to your .vimrc to add a keybinding using your leader key:

		map <silent> <leader>s :call OpenAlternateFile()<CR>

Add the following to your .vimrc to add a keybinding using a custom vim command:

		command AF :execute OpenAlternateFile()


Notes
-----

The canonical repo for this plugin lives [here][alternate-file], NOT on github.
It is on github only to ease use of installation via [Vundle][vundle].


[vundle](https://github.com/gmarik/vundle)
[alternate-file](https://www.bitbucket.org/ToadJamb/vim-alternate-file)
