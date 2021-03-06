# TidalCycles log of changes

## 0.9.10 (and earlier missing versions from this log)

* arpg, a function to arpeggiate
* within', an alternate within with a different approach to time, following discussion here https://github.com/tidalcycles/Tidal/issues/313
* sine et al are now generalised so can be used as double or rational patterns
* New Sound.Tidal.Simple module with a range of simple transformations (faster, slower, higher, lower, mute, etc)
* slice upgraded to take a pattern of slice indexes
* espgrid support
* lindenmayerI
* sew function, for binary switching between two patterns
* somecycles alias for someCycles
* ply function, for repeating each event in a pattern a given number
  of times within their original timespan
* patternify juxBy, e, e', einv, efull, eoff

## 0.9.7

### Enhancements

* The `note` pattern parameter is no longer an alias for `midinote`,
  but an independent parameter for supercollider to handle (in a manner
  similar to `up`)
  
## 0.9.6

### Enhancements

* Added `chord` for chord patterns and `scaleP` for scale patterns
* The `n` pattern parameter is now floating point

## 0.9.5

### Enhancements

* Added `hurry` which both speeds up the sound and the pattern by the given amount.
* Added `stripe` which repeats a pattern a given number of times per
  cycle, with random but contiguous durations.
* Added continuous function `cosine`
* Turned more pattern transformation parameters into patterns - spread', striateX, every', inside, outside, swing
* Added experimental datatype for Xenakis sieves
* Correctly parse negative rationals
* Added `breakUp` that finds events that share the same timespan, and spreads them out during that timespan, so for example (breakUp "[bd,sn]") gets turned into the "bd sn"
* Added `fill` which 'fills in' gaps in one pattern with events from another. 

## 0.9.4

### Fixes

* Swapped `-` for `..` in ranges as quick fix for issue with parsing negative numbers
* Removed overloaded list thingie for now, unsure whether it's worth the dependency

## 0.9.3

### Enhancements

* The sequence parser can now expand ranges, e.g. `"0-3 4-2"` is
  equivalent to `"[0 1 2 3] [4 3 2]"`
* Sequences can now be described using list syntax, for example `sound ["bd", "sn"]` is equivalent to `sound "bd sn"`. They *aren't* lists though, so you can't for example do `sound (["bd", "sn"] ++ ["arpy", "cp"])` -- but can do `sound (append ["bd", "sn"]  ["arpy", "cp"])`
* New function `linger`, e.g. `linger (1/4)` will only play the first quarter of the given pattern, four times to fill the cycle. 
* `discretise` now takes time value as its first parameter, not a pattern of time, which was causing problems and needs some careful thought.
* a `rel` alias for the `release` parameter, to match the `att` alias for `attack`
* `_fast` alias for `_density`
* The start of automatic testing for a holy bug-free future

### Fixes

* Fixed bug that was causing events to double up or get lost,
  e.g. where `rev` was combined with certain other functions.
