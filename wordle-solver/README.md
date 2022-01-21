# wordle-hint

A quick, dirty script to find potential words for [Wordle](https://www.powerlanguage.co.uk/wordle/)

## Usage:

`./wordle-hint <hint> <include_letters> <exclude_letters>`

Where:

* `<hint>` is e.g. `..i..` if you know the 3rd char is an "i" (so a dot for
  each position you don't yet know what letter should be there (green squares),
  and any letters you do know are in their right place)
* `<include_letters>` is a list of letters you know are in the word (yellow
  squares) but don't know the position of - so possible solutions must include
  these
* `<exclude_letters>` are letters you know from previous guesses are *not* in
  the word (grey squares)

For instance,

`./wordle-hint ..i.. r asewng` - we know the 3rd letter is an "i", we know
there is a "r" somewhere but don't yet know where, and we know the letters
a, s, e, w, n and g are *not* in the word.

It will then spew out words which could match.

So far, the word list it uses is just from `/usr/share/dict/words`.

I could rip the list of words from the Wordle JS source instead... but if I
wanted to do that, I could just rip the solutions from there too and not worry
about a solver, and where's the fun in that?

Some would consider even this approach cheating.  I suppose it sort-of is, but
I saw it as a fun challenge to write a little code to do it for me.  I like
making computers solve problems for me, it's What I Do.



