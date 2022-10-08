# 📫 Himalaya

Vim plugin for email management based on the
[himalaya-cli](https://github.com/soywod/himalaya).

## Installation

First you need to install and configure the [himalaya
CLI](https://github.com/soywod/himalaya#installation). Then you can
install this plugin with your favorite plugin manager. For example
with [vim-plug](https://github.com/junegunn/vim-plug), add to your
`.vimrc`:

```vim
Plug 'https://git.sr.ht/~soywod/himalaya-vim'
```

Then:

```vim
:PlugInstall
```

## Configuration

It is highly recommanded to have those Vim options on:

```vim
syntax on
filetype plugin on
set hidden
```

### Folder picker

Defines the provider used for selecting folders (default keybind:
`gm`):

- `native` (default): a vim native input
- `fzf`: https://github.com/junegunn/fzf.vim
- `telescope`: https://github.com/nvim-telescope/telescope.nvim

If no value given, the first loaded (and available) provider will be
used (fzf > telescope > native).

```vim
let g:himalaya_folder_picker = 'native' | 'fzf' | 'telescope'
```

### Folder picker `telescope.nvim` preview

Enables folder previewing when picking a folder with the
`telescope.nvim` provider.

```vim
let g:himalaya_folder_picker_telescope_preview = 1
```

### Contact completion

```vim
let g:himalaya_complete_contact_cmd = '<your completion command>'
```

Defines the command to use for contact completion. When this is set,
`completefunc` will be set when composing emails so that contacts can
be completed with `<C-x><C-u>`.

The command must print each possible result on its own line. Each line
must contain tab-separated fields; the first must be the email
address, and the second, if present, must be the name. `%s` in the
command will be replaced with the search query.

## Usage

### Folder listing

Default behaviour (basic prompt):

![screenshot](https://user-images.githubusercontent.com/10437171/113631817-51eb3180-966a-11eb-8b13-cd1f1f2539ab.jpeg)

With [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) support:

![screenshot](https://user-images.githubusercontent.com/10437171/113631294-86122280-9669-11eb-8074-1c43c36b65a9.jpeg)

With [fzf.vim](https://github.com/junegunn/fzf.vim) support:

![screenshot](https://user-images.githubusercontent.com/10437171/113631382-acd05900-9669-11eb-817d-c28fd5d9574c.jpeg)

### Emails listing

```vim
:Himalaya
```

| Function                                         | Keybind   |
|--------------------------------------------------|-----------|
| Change the current folder                        | `gm`      |
| Show previous page                               | `gp`      |
| Show next page                                   | `gn`      |
| Read email under cursor                          | `<Enter>` |
| Write a new email                                | `gw`      |
| Reply to the email under cursor                  | `gr`      |
| Reply all to the email under cursor              | `gR`      |
| Forward the email under cursor                   | `gf`      |
| Download all attachments of email under cursor   | `ga`      |
| Copy the email under cursor                      | `gC`      |
| Move the email under cursor                      | `gM`      |
| Delete email(s) under cursor or visual selection | `gD`      |

Keybinds can be customized:

```vim
nmap gm   <plug>(himalaya-folder-select)
nmap gp   <plug>(himalaya-folder-select-previous-page)
nmap gn   <plug>(himalaya-folder-select-next-page)
nmap <cr> <plug>(himalaya-email-read)
nmap gw   <plug>(himalaya-email-write)
nmap gr   <plug>(himalaya-email-reply)
nmap gR   <plug>(himalaya-email-reply-all)
nmap gf   <plug>(himalaya-email-forward)
nmap ga   <plug>(himalaya-email-attachments)
nmap gC   <plug>(himalaya-email-copy)
nmap gM   <plug>(himalaya-email-move)
nmap gD   <plug>(himalaya-email-delete)
```

### Email reading

| Function                       | Keybind |
|--------------------------------|---------|
| Write a new email              | `gw`    |
| Reply to the email             | `gr`    |
| Reply all to the email         | `gR`    |
| Forward the email              | `gf`    |
| Download all email attachments | `ga`    |
| Copy the email                 | `gC`    |
| Move the email                 | `gM`    |
| Delete the email               | `gD`    |

Keybinds can be customized:

```vim
nmap gw <plug>(himalaya-email-write)
nmap gr <plug>(himalaya-email-reply)
nmap gR <plug>(himalaya-email-reply-all)
nmap gf <plug>(himalaya-email-forward)
nmap ga <plug>(himalaya-email-attachments)
nmap gC <plug>(himalaya-email-copy)
nmap gM <plug>(himalaya-email-move)
nmap gD <plug>(himalaya-email-delete)
```

### Email writing

| Function       | Keybind |
|----------------|---------|
| Add attachment | `ga`    |

Keybinds can be customized:

```vim
nmap ga <plug>(himalaya-email-add-attachment)
```

When you exit this special buffer, you will be prompted 4 choices:

- `send`: sends the email
- `draft`: saves the email locally
- `quit`: quits the buffer without saving
- `cancel`: goes back to the email edition
