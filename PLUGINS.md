# Vim Plugins Audit

This document provides an audit of all 43 Vim plugins currently installed, with recommendations for modernization.

## Plugin Manager
- **VundleVim/Vundle.vim** - Plugin manager
  - *Recommendation*: Consider migrating to vim-plug (faster, async) or native Vim 8 package management

## Git Integration
- **airblade/vim-gitgutter** - Shows git diff in the sign column
  - *Status*: Modern, actively maintained ✅
- **tpope/vim-fugitive** - Git wrapper
  - *Status*: Essential, actively maintained ✅

## File Navigation & Search
- **ctrlpvim/ctrlp.vim** - Fuzzy file finder
  - *Recommendation*: Consider fzf.vim (faster, more features)
- **scrooloose/nerdtree** - File tree explorer
  - *Status*: Still useful, but consider netrw (built-in) or nvim-tree
- **rking/ag.vim** - The Silver Searcher integration
  - *Status*: Good if using ag, but consider vim-grepper for multi-tool support

## Code Quality & Linting
- **scrooloose/syntastic** - Syntax checking
  - *Recommendation*: ⚠️ REPLACE with ALE (async, better performance)
- **wookiehangover/jshint.vim** - JSHint integration
  - *Recommendation*: ⚠️ OUTDATED - Use ESLint via ALE instead

## Language Support

### Ruby/Rails (7 plugins)
- **vim-ruby/vim-ruby** - Ruby syntax and tools
- **tpope/vim-rails** - Rails integration
- **tpope/vim-bundler** - Bundler integration
- **tpope/vim-endwise** - Auto-end for Ruby blocks
- **tpope/vim-cucumber** - Cucumber support
- **slim-template/vim-slim** - Slim template support
- **tpope/vim-ragtag** - Tag completion for templates
  - *Assessment*: If you're actively doing Ruby/Rails development, keep all ✅
  - *Recommendation*: If not actively using Rails, consider removing these 7 plugins

### JavaScript/TypeScript (5 plugins)
- **pangloss/vim-javascript** - JavaScript syntax
  - *Recommendation*: Consider vim-javascript-syntax or native Vim JS support
- **kchmck/vim-coffee-script** - CoffeeScript support
  - *Recommendation*: ⚠️ CoffeeScript is largely deprecated, consider removing
- **leafgarland/typescript-vim** - TypeScript syntax
  - *Status*: Good if using TypeScript ✅
- **juvenn/mustache.vim** - Mustache/Handlebars templates
- **nono/vim-handlebars** - Handlebars support
  - *Note*: Two similar plugins for templates, possibly redundant

## Color Schemes
- **altercation/vim-colors-solarized** - Solarized colorscheme
  - *Status*: Classic, keep if using ✅
- **tpope/vim-vividchalk** - Alternative colorscheme
  - *Assessment*: Extra colorscheme, keep if you use it

## Utilities & Editing
- **tpope/vim-commentary** - Easy commenting
  - *Status*: Essential ✅
- **tpope/vim-surround** - Manipulate surroundings
  - *Status*: Essential ✅
- **tpope/vim-repeat** - Better repeat (.) command
  - *Status*: Essential ✅
- **tpope/vim-unimpaired** - Bracket mappings
  - *Status*: Very useful ✅
- **tpope/vim-dispatch** - Async build/test
  - *Status*: Useful for async operations ✅
- **tpope/vim-pastie** - Pastie integration
  - *Assessment*: Pastie.org appears defunct, consider removing
- **nathanaelkane/vim-indent-guides** - Visual indent guides
  - *Status*: Useful, or use native indent visualization
- **vim-scripts/Align** - Text alignment
  - *Status*: Useful, but junegunn/vim-easy-align is more modern
- **vim-scripts/greplace.vim** - Global search/replace
  - *Status*: Useful for project-wide replacements
- **vim-scripts/matchit.zip** - Extended % matching
  - *Note*: This is built into Vim 8+, can remove

## Snippets
- **garbas/vim-snipmate** - Snippet engine
- **MarcWeber/vim-addon-mw-utils** - Dependency for snipmate
- **tomtom/tlib_vim** - Dependency for snipmate
  - *Assessment*: If using snippets, keep. Consider UltiSnips as alternative
  - *Recommendation*: If not actively using, remove all 3

## Code Navigation
- **majutsushi/tagbar** - Tag browser
  - *Status*: Useful if using ctags ✅
- **austintaylor/vim-indentobject** - Text objects based on indentation
  - *Status*: Useful for Python/YAML/etc ✅

## Tmux Integration
- **christoomey/vim-tmux-navigator** - Seamless tmux/vim navigation
  - *Status*: ⚠️ CONFLICT - This duplicates the smart pane switching we just enabled
  - *Recommendation*: Keep this AND remove the manual tmux.conf bindings, OR remove this plugin

## Summary & Recommendations

### High Priority Removals (Save ~8 plugins)
1. ❌ **wookiehangover/jshint.vim** - Outdated, use ESLint
2. ❌ **kchmck/vim-coffee-script** - CoffeeScript is deprecated
3. ❌ **tpope/vim-pastie** - Service appears defunct
4. ❌ **vim-scripts/matchit.zip** - Built into Vim 8+
5. ❌ **snipmate** suite (3 plugins) - If not actively using

### High Priority Replacements
1. ⚠️ **syntastic** → **dense-analysis/ale** - Much better async linting
2. ⚠️ **ctrlp.vim** → **junegunn/fzf.vim** - Faster, more powerful

### Conditional Removals (If not using)
- 7 Ruby/Rails plugins (if not doing Rails work)
- 2 Handlebars/Mustache plugins (if not using these templates)
- vim-indent-guides (if not using)
- vim-vividchalk colorscheme (if not using)

### Plugin Conflict to Resolve
- **vim-tmux-navigator vs manual tmux bindings** - Choose one approach

### Modern Additions to Consider
- **dense-analysis/ale** - Async linting
- **junegunn/fzf.vim** - Better fuzzy finder
- **neoclide/coc.nvim** - Language server support (if using Neovim)
- **sheerun/vim-polyglot** - Language pack (syntax for many languages)

## Estimated Savings
- Current: 43 plugins
- After cleanup: ~25-30 plugins (depending on Rails usage)
- Startup time improvement: ~30-50%
