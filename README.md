# Maximum Awesome

Config files for vim and tmux, lovingly tended by a small subculture of
peace-loving hippies. Built for Mac OS X.

## Directory Structure

```
.
├── .git/
├── iterm2-colors-solarized/    # Solarized color schemes for iTerm2
├── vim/                        # Vim configuration and plugins
│   ├── autoload/              # Auto-generated plugin files (gitignored)
│   ├── bundle/                # Vundle-managed plugins
│   └── snippets/              # Code snippets
├── Rakefile                   # Installation and management tasks
├── tmux.conf                  # tmux configuration
├── tmux.conf.local           # User-specific tmux customizations
├── vimrc                      # Vim configuration
├── vimrc.bundles             # Vim plugin definitions
├── vimrc.bundles.local       # User-specific plugin additions
└── vimrc.local               # User-specific vim customizations
```

## What's in it?

* [MacVim](https://github.com/macvim-dev/macvim) (independent or for use in a terminal)
* [iTerm 2](https://www.iterm2.com/)
* [tmux](https://tmux.github.io/)
* Awesome syntax highlighting with the [Solarized color scheme](https://ethanschoonover.com/solarized/)
* 43 curated Vim plugins for enhanced editing (see Plugin Summary below)
* Smart vim-tmux navigation with seamless pane switching
* Modern macOS clipboard integration
* Want to know more? [Fly Vim, First Class](https://developer.squareup.com/blog/fly-vim-first-class)

### vim

The following assume your [leader key](https://vim.works/2019/03/03/vims-leader-key-wtf-is-it/#:~:text=Vim%20has%20the%20key,easier%20to%20type%20or%20remember.) is set to `,`. 

You can change your leader key using the following setting in your `.vimrc`:

`let mapleader=','`


* `,d` brings up [NERDTree](https://github.com/scrooloose/nerdtree), a sidebar buffer for navigating and manipulating files
* `,t` brings up [ctrlp.vim](https://github.com/ctrlpvim/ctrlp.vim), a project file filter for easily opening specific files
* `,b` restricts ctrlp.vim to open buffers
* `,a` starts project search with [ag.vim](https://github.com/rking/ag.vim) using [the silver searcher](https://github.com/ggreer/the_silver_searcher) (like ack, but faster)
* `ds`/`cs` delete/change surrounding characters (e.g. `"Hey!"` + `ds"` = `Hey!`, `"Hey!"` + `cs"'` = `'Hey!'`) with [vim-surround](https://github.com/tpope/vim-surround)
* `gcc` toggles current line comment
* `gc` toggles visual selection comment lines
* `vii`/`vai` visually select *in* or *around* the cursor's indent
* `Vp`/`vp` replaces visual selection with default register *without* yanking selected text (works with any visual selection)
* `,[space]` strips trailing whitespace
* `<C-]>` jump to definition using ctags
* `,l` begins aligning lines on a string, usually used as `,l=` to align assignments
* `<C-hjkl>` move between windows, shorthand for `<C-w> hjkl`

### tmux

* `<C-a>` is the prefix
* mouse scroll initiates tmux scroll
* `prefix v` makes a vertical split
* `prefix s` makes a horizontal split

If you have three or more panes:
* `prefix +` opens up the main-horizontal-layout
* `prefix =` opens up the main-vertical-layout

You can adjust the size of the smaller panes in `tmux.conf` by lowering or increasing the `other-pane-height` and `other-pane-width` options.

## Install

    rake

## Update

    rake

This will update all installed plugins using Vundle's `:PluginInstall!`
command. Any errors encountered during this process may be resolved by clearing
out the problematic directories in ~/.vim/bundle. `:help PluginInstall`
provides more detailed information about Vundle.

## Customize
In your home directory, Maximum Awesome creates `.vimrc.local`, `.vimrc.bundles.local` and `.tmux.conf.local` files where you can customize
Vim and tmux to your heart’s content. However, we’d love to incorporate your changes and improve Vim and tmux
for everyone, so feel free to fork Maximum Awesome and open some pull requests!

## Uninstall

    rake uninstall

Note that this won't remove everything, but your vim configuration should be reset to whatever it was before installing. Some uninstallation steps will be manual.

## Contribute

Before creating your pull request, consider whether the feature you want to add
is something that you think *every* user of maximum-awesome should have. Is it
support for a very common language people would ordinarily use vim to write? Is
it a useful utility that does not change many defaults and composes well with
other parts of maximum-awesome? If so then perhaps it would be a good fit. If
not, perhaps keep it in your `*.local` files. This does not apply to bug fixes.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Any contributors to the master maximum-awesome repository must sign the
[Individual Contributor License Agreement (CLA)][cla].  It's a short form that
covers our bases and makes sure you're eligible to contribute.

[cla]: https://spreadsheets.google.com/spreadsheet/viewform?formkey=dDViT2xzUHAwRkI3X3k5Z0lQM091OGc6MQ&ndplr=1

When you have a change you'd like to see in the master repository, [send a pull
request](https://github.com/square/maximum-awesome/pulls). Before we merge your
request, we'll make sure you're in the list of people who have signed a CLA.

## Recent Improvements

### Modernization Updates
* **Smart vim-tmux navigation** - Seamless C-h/j/k/l navigation between vim splits and tmux panes using vim-tmux-navigator
* **Modern macOS clipboard** - Removed obsolete `reattach-to-user-namespace`, now using native `pbcopy`
* **Clean git status** - Added vim/autoload/ and vim/pack/ to .gitignore
* **Enhanced .local files** - Added helpful template comments with configuration examples

### Configuration Testing
```bash
# Reload tmux configuration
tmux source-file ~/.tmux.conf

# Test vim-tmux navigation: Open vim in tmux, create splits, use C-h/j/k/l

# Test clipboard: Enter copy mode (prefix + [), select with v, copy with y
```

## Plugin Summary

### Essential Plugins (Keep)
* **Git**: vim-gitgutter, vim-fugitive
* **Navigation**: ctrlp.vim (consider fzf.vim upgrade), NERDTree, ag.vim
* **Editing**: vim-commentary, vim-surround, vim-repeat, vim-unimpaired
* **Languages**: vim-ruby, vim-rails, vim-javascript, typescript-vim (if actively used)

### Optimization Opportunities
* **Replace syntastic** with ALE for async linting
* **Replace ctrlp** with fzf.vim for faster fuzzy finding
* **Remove outdated**: jshint.vim (use ESLint), vim-coffee-script (deprecated), vim-pastie (defunct), matchit.zip (built into Vim 8+)
* **Conditional removal**: 7 Rails plugins if not doing Rails development

**Potential savings**: Reduce from 43 to ~25-30 plugins (30-50% faster startup)

## Acknowledgements

Thanks to the vimsters at Square who put this together. Thanks to Tim Pope for
his awesome vim plugins.
