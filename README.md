INSERT FROM AROUND
===============================================================================
_by Ingo Karkat_

DESCRIPTION
------------------------------------------------------------------------------

With the proper indent settings, Vim will mostly supply the correct amount of
indent when creating new lines. But sometimes, one needs a special amount of
indent, and it is cumbersome to manually create that by repeatedly pressing
&lt;Tab&gt;, &lt;Space&gt;, and &lt;BS&gt;.

This plugin defines insert mode mappings that indent a new line exactly at the
current cursor position, or insert the indent used in adjacent lines, or align
the text to the right of the cursor to text fragments in surrounding lines.

To duplicate the text of adjacent lines, Vim has the i\_CTRL-E / i\_CTRL-Y
commands. But these only work character for character (which makes it slow to
copy longer fragments), and fail when empty / shorter lines surround the
current line.

This plugin supercharges these commands, making them look beyond the immediate
lines. With a separate mapping, the scope of completion can be toggled between
single characters and whole words, speeding up larger text grabs while still
allowing the fine-grained completion.

### SOURCE

- [The i\_CTRL-E / i\_CTRL-Y mappings are based on](http://www.ibm.com/developerworks/linux/library/l-vim-script-1/index.html)

### RELATED WORKS

- The prev\_indent plugin ([vimscript #4575](http://www.vim.org/scripts/script.php?script_id=4575)) provides an insert mode mapping and
  :PrevIndent to move the current line to the previous indentation level.

USAGE
------------------------------------------------------------------------------

    CTRL-Enter              Insert newline and indent the new line to the current
                            cursor column. This takes into account indent-
                            expressions and insertion of the comment leader.

    CTRL-E / CTRL-Y         Insert the character from unfolded lines below / above
                            the cursor; if the adjacent line is not that long,
                            mook beyond. The command beeps and suspends insert
                            once if the current target line has been exhausted.

    CTRL-G CTRL-E / CTRL-G CTRL-Y
                            Insert an entire word from unfolded lines below /
                            above the cursor and toggle the behavior of i_CTRL-E
                            / i_CTRL-Y to continue inserting words. The behavior
                            reverts itself when inserting in another line or by
                            using this mapping a second time.

    CTRL-G CTRL-U           Replace the text before the cursor with the indent
                            from the next nearby unfolded line that has at least
                            as much indent as the current cursor position. If the
                            indent before and after the current line differs, the
                            smaller amount is inserted; repeat the mapping to get
                            the larger amount.
                            (Mnemonic: Undo the effect of i_CTRL-U.)

    CTRL-G CTRL-B           Remove whitespace before the cursor so that the
                            current cursor position aligns with the start of
                            preceding non-whitespace text in the previous unfolded
                            line.
    <b                      Shift the current line (after any comment prefix)
                            leftwards so that its first non-blank character aligns
                            with the start of [the count'th] preceding
                            non-whitespace text in the previous unfolded line.
                            Shortcut for ^ i_CTRL-G_CTRL-B <Esc>.

    CTRL-G CTRL-A           Insert whitespace so that the text after the cursor
                            aligns with the start of following non-whitespace text
                            (and the end of the text) in the previous unfolded
                            line.
    >a                      Shift the current line (after any comment prefix)
                            rightwards so that its first non-blank character
                            aligns with the start of [the count'th] following
                            non-whitespace text in the previous unfolded line.
                            Shortcut for ^ i_CTRL-G_CTRL-A <Esc>.

    CTRL-G CTRL-V           Insert whitespace so that the text after the cursor
                            aligns with the closest match of the (non-whitespace)
                            character after the cursor found after the cursor
                            column in adjacent unfolded lines.

    CTRL-G V{char}          Insert whitespace so that the text after the cursor
                            aligns the next match of {char} in the current line
                            with the closest match of {char} found after that
                            column in adjacent unfolded lines.
                            Note: This won't work correctly when there are <Tab>
                            characters between the cursor and the next match of
                            {char}.

### EXAMPLE

Insert newline and indent to cursor column:
```
foo|ar
    v CTRL-Enter
foo
    bar
```

Insert the character, character, then word, word from above:
```
A very long example provides context.
Short one.
    I'm here|
            v CTRL-Y
    I'm heree|
            v CTRL-Y
    I'm hereex|
            v CTRL-G CTRL-Y
    I'm hereexample|
            v CTRL-Y
    I'm hereexample provides|
```

Insert the additional indent from next nearby lines:
```
    FOO            BAR        BAZ
           HI
|ere
v CTRL-G CTRL-U
    |ere
    v CTRL-G CTRL-U
           |ere
```

Align with the start of preceding text fragments:
```
    FOO            BAR        BAZ
|ere
v CTRL-G CTRL-A
    |ere
    v CTRL-G CTRL-A
                   |ere
                   v CTRL-G CTRL-A
                              |ere
                              v CTRL-G CTRL-B
                   |ere
```

Align "Nothing" with the closest match of the character "N" found nearby:
```
    NOO            BAR        NAZ
           NI
|othing
v CTRL-G CTRL-U
    |othing
    v CTRL-G CTRL-U
           |othing
           v CTRL-G CTRL-U
                              |othing
```

Align on = with the closest match found nearby:
```
    class="bar" alt="ni"
|ummary="foo"
v CTRL-G V =
  |ummary="foo"
    v CTRL-G CTRL-U
            |ummary="foo"
```

INSTALLATION
------------------------------------------------------------------------------

The code is hosted in a Git repo at
    https://github.com/inkarkat/vim-InsertFromAround
You can use your favorite plugin manager, or "git clone" into a directory used
for Vim packages. Releases are on the "stable" branch, the latest unstable
development snapshot on "master".

This script is also packaged as a vimball. If you have the "gunzip"
decompressor in your PATH, simply edit the \*.vmb.gz package in Vim; otherwise,
decompress the archive first, e.g. using WinZip. Inside Vim, install by
sourcing the vimball or via the :UseVimball command.

    vim InsertFromAround*.vmb.gz
    :so %

To uninstall, use the :RmVimball command.

### DEPENDENCIES

- Requires Vim 7.0 or higher.
- Requires the ingo-library.vim plugin ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)), version 1.041 or
  higher.

CONFIGURATION
------------------------------------------------------------------------------

For a permanent configuration, put the following commands into your vimrc:

If you want to use different mappings, map your keys to the
&lt;Plug&gt;(InsertFrom...) mapping targets _before_ sourcing the script
(e.g. in your vimrc):

    imap <C-CR> <Plug>(InsertFromEnterAndIndent)
    imap <C-e> <Plug>(InsertFromTextBelow)
    imap <C-y> <Plug>(InsertFromTextAbove)
    imap <C-g><C-e> <Plug>(InsertFromTextBelowToggle)
    imap <C-g><C-y> <Plug>(InsertFromTextAboveToggle)
    imap <C-g><C-u> <Plug>(InsertFromIndent)
    imap <C-g><C-b> <Plug>(InsertFromAlignToPrevious)
    imap <C-g><C-a> <Plug>(InsertFromAlignToNext)
    nmap <b <Plug>(InsertFromAlignToPrevious)
    nmap >a <Plug>(InsertFromAlignToNext)

CONTRIBUTING
------------------------------------------------------------------------------

Report any bugs, send patches, or suggest features via the issue tracker at
https://github.com/inkarkat/vim-InsertFromAround/issues or email (address
below).

HISTORY
------------------------------------------------------------------------------

##### 1.20    10-Nov-2024
- ENH: Add &gt;a and &lt;b normal-mode variants that work like i\_CTRL-G\_CTRL-A/B on
  the indent.

__You need to update to ingo-library ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)) version 1.041!__

##### 1.11    04-Nov-2018
- Make &lt;C-CR&gt; handle comment prefixes, not just indent.
- CHG: Rename i\_CTRL-G\_CTRL-D / i\_CTRL-G\_CTRL-T default mappings to
  i\_CTRL-G\_CTRL-B ("before") / i\_CTRL-G\_CTRL-A ("after"). I need the original
  mappings to toggle i\_CTRL-D / i\_CTRL-T in my IndentCommentPrefix.vim plugin
  for toggling similar to i\_CTRL-G\_CTRL-E here. To restore the original
  mappings, put this into your .vimrc:
 <!-- -->

    imap <C-g><C-d> <Plug>(InsertFromAlignToPrevious)
    imap <C-g><C-t> <Plug>(InsertFromAlignToNext)

__You need to update to ingo-library ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)) version 1.030!__

##### 1.10    03-Apr-2014
- ENH: The i\_CTRL-G\_CTRL-D / i\_CTRL-G\_CTRL-T mappings also align to
  non-whitespace text in preceding lines when the line immediately above is
  shorter than the cursor column.
- Add CTRL-G CTRL-V mapping that aligns to the current character found in
  adjacent lines.
- Add CTRL-G V{char} mapping that aligns to the queried character.

##### 1.00    23-Jan-2014
- First published version.

##### 0.90    14-Apr-2013
- Separated into independent plugin.

##### 0.01    07-May-2009
- Started development.

------------------------------------------------------------------------------
Copyright: (C) 2009-2024 Ingo Karkat -
The [VIM LICENSE](http://vimdoc.sourceforge.net/htmldoc/uganda.html#license) applies to this plugin.

Maintainer:     Ingo Karkat &lt;ingo@karkat.de&gt;
