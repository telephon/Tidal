module Sound.Tidal.Params where

import Sound.Tidal.Stream
import Sound.Tidal.Pattern
import qualified Data.Map as Map
import Sound.Tidal.Utils
import Control.Applicative

-- | group multiple params into one
grp :: [Param] -> Pattern String -> ParamPattern
grp [] _ = silence
grp params p = (fmap lookupPattern p)
  where lookupPattern :: String -> ParamMap
        lookupPattern s = Map.fromList $ map (\(param,s') -> toPV param s') $ zip params $ (split s)
        split s = wordsBy (==':') s
        toPV :: Param -> String -> (Param, Value)
        toPV param@(S _ _) s = (param, (VS s))
        toPV param@(F _ _) s = (param, (VF $ read s))
        toPV param@(I _ _) s = (param, (VI $ read s))
{- |

A pattern of strings representing sounds or synth notes.

Internally, `sound` or its shorter alias `s` is a combination of the samplebank name and number when used with samples, or synth name and note number when used with a synthesiser. For example `bd:2` specifies the third sample (not the second as you might expect, because we start counting at zero) in the `bd` sample folder.

*Internally, `sound`/`s` is a combination of two parameters, the
hidden parameter `s'` which specifies the samplebank or synth, and the
`n` parameter which specifies the sample or note number. For example:

@
d1 $ sound "bd:2 sn:0"
@

is essentially the same as:

@
d1 $ s' "bd sn" # n "2 0"
@

`n` is therefore useful when you want to pattern the sample or note
number separately from the samplebank or synth. For example:

@
d1 $ n "0 5 ~ 2" # sound "drum"
@

is equivalent to:

@
d1 $ sound "drum:0 drum:5 ~ drum:2"
@
-}
sound :: Pattern String -> ParamPattern
sound = grp [s_p, n_p]
s = sound

pF name defaultV = (make' VF param, param)
  where param = F name defaultV
pI name defaultV = (make' VI param, param)
  where param = I name defaultV
pS name defaultV = (make' VS param, param)
  where param = S name defaultV
-- | a pattern of numbers that speed up (or slow down) samples while they play.
(accelerate, accelerate_p)       = pF "accelerate" (Just 0)
-- | a pattern of numbers to specify the attack time (in seconds) of an envelope applied to each sample. Only takes effect if `release` is also specified.
(attack, attack_p)               = pF "attack" (Just (-1))
-- | a pattern of numbers from 0 to 1. Sets the center frequency of the band-pass filter.
(bandf, bandf_p)                 = pF "bandf" (Just 0)
-- | a pattern of numbers from 0 to 1. Sets the q-factor of the band-pass filter.
(bandq, bandq_p)                 = pF "bandq" (Just 0)
{- | a pattern of numbers from 0 to 1. Skips the beginning of each sample, e.g. `0.25` to cut off the first quarter from each sample.

Using `begin "-1"` combined with `cut "-1"` means that when the sample cuts itself it will begin playback from where the previous one left off, so it will sound like one seamless sample. This allows you to apply a synth param across a long sample in a way similar to `chop`:

@
cps 0.5

d1 $ sound "breaks125*8" # unit "c" # begin "-1" # cut "-1" # coarse "1 2 4 8 16 32 64 128"
@

This will play the `breaks125` sample and apply the changing `coarse` parameter over the sample. Compare to:

@
d1 $ (chop 8 $ sounds "breaks125") # unit "c" # coarse "1 2 4 8 16 32 64 128"
@

which performs a similar effect, but due to differences in implementation sounds different.
-}
begin_p, channel_p, legato_p, clhatdecay_p, coarse_p, crush_p :: Param
begin, legato, clhatdecay, crush :: Pattern Double -> ParamPattern
channel, coarse :: Pattern Int -> ParamPattern
(begin, begin_p)                 = pF "begin" (Just 0)
-- | choose the physical channel the pattern is sent to, this is super dirt specific
(channel, channel_p)             = pI "channel" Nothing

--legato controls the amount of overlap between two adjacent synth sounds
(legato, legato_p)             = pF "legato" (Just 1)

(clhatdecay, clhatdecay_p)       = pF "clhatdecay" (Just 0)
-- | fake-resampling, a pattern of numbers for lowering the sample rate, i.e. 1 for original 2 for half, 3 for a third and so on.
(coarse, coarse_p)               = pI "coarse" (Just 0)
-- | bit crushing, a pattern of numbers from 1 (for drastic reduction in bit-depth) to 16 (for barely no reduction).
(crush, crush_p)                 = pF "crush" (Just 0)
{- |
In the style of classic drum-machines, `cut` will stop a playing sample as soon as another samples with in same cutgroup is to be played.

An example would be an open hi-hat followed by a closed one, essentially muting the open.

@
d1 $ stack [
  sound "bd",
  sound "~ [~ [ho:2 hc/2]]" # cut "1"
  ]
@

This will mute the open hi-hat every second cycle when the closed one is played.

Using `cut` with negative values will only cut the same sample. This is useful to cut very long samples

@
d1 $ sound "[bev, [ho:3](3,8)]" # cut "-1"
@

Using `cut "0"` is effectively _no_ cutgroup.
-}
(cut, cut_p)                     = pI "cut" (Just 0)
-- | a pattern of numbers from 0 to 1. Applies the cutoff frequency of the low-pass filter.
(cutoff, cutoff_p)               = pF "cutoff" (Just 0)
(cutoffegint, cutoffegint_p)     = pF "cutoffegint" (Just 0)
(decay, decay_p)                 = pF "decay" (Just 0)
-- | a pattern of numbers from 0 to 1. Sets the level of the delay signal.
(delay, delay_p)                 = pF "delay" (Just 0)
-- | a pattern of numbers from 0 to 1. Sets the amount of delay feedback.
(delayfeedback, delayfeedback_p) = pF "delayfeedback" (Just (-1))
-- | a pattern of numbers from 0 to 1. Sets the length of the delay.
(delaytime, delaytime_p)         = pF "delaytime" (Just (-1))
(detune, detune_p)               = pF "detune" (Just 0)
-- | when set to `1` will disable all reverb for this pattern. See `room` and `size` for more information about reverb.
(dry, dry_p)                     = pF "dry" (Just 0)
{- the same as `begin`, but cuts the end off samples, shortening them;
  e.g. `0.75` to cut off the last quarter of each sample.
-}
(end, end_p)                     = pF "end" (Just 1)
-- | a pattern of numbers that specify volume. Values less than 1 make the sound quieter. Values greater than 1 make the sound louder.
(gain, gain_p)                   = pF "gain" (Just 1)
(gate, gate_p)                   = pF "gate" (Just 0)
(hatgrain, hatgrain_p)           = pF "hatgrain" (Just 0)
-- | a pattern of numbers from 0 to 1. Applies the cutoff frequency of the high-pass filter.
(hcutoff, hcutoff_p)             = pF "hcutoff" (Just 0)
-- | a pattern of numbers to specify the hold time (in seconds) of an envelope applied to each sample. Only takes effect if `attack` and `release` are also specified.
(hold, hold_p)                   = pF "hold" (Just 0)
-- | a pattern of numbers from 0 to 1. Applies the resonance of the high-pass filter.
(hresonance, hresonance_p)       = pF "hresonance" (Just 0)
(kriole, kriole_p)               = pI "kriole" (Just 0)
(lagogo, lagogo_p)               = pF "lagogo" (Just 0)
(lclap, lclap_p)                 = pF "lclap" (Just 0)
(lclaves, lclaves_p)             = pF "lclaves" (Just 0)
(lclhat, lclhat_p)               = pF "lclhat" (Just 0)
(lcrash, lcrash_p)               = pF "lcrash" (Just 0)
(lfo, lfo_p)                     = pF "lfo" (Just 0)
(lfocutoffint, lfocutoffint_p)   = pF "lfocutoffint" (Just 0)
(lfodelay, lfodelay_p)           = pF "lfodelay" (Just 0)
(lfoint, lfoint_p)               = pF "lfoint" (Just 0)
(lfopitchint, lfopitchint_p)     = pF "lfopitchint" (Just 0)
(lfoshape, lfoshape_p)           = pF "lfoshape" (Just 0)
(lfosync, lfosync_p)             = pF "lfosync" (Just 0)
(lhitom, lhitom_p)               = pF "lhitom" (Just 0)
(lkick, lkick_p)                 = pF "lkick" (Just 0)
(llotom, llotom_p)               = pF "llotom" (Just 0)
{- |  A pattern of numbers. Specifies whether delaytime is calculated relative to cps. When set to 1, delaytime is a direct multiple of a cycle.
-}
(lock, lock_p)                 = pF "lock" (Just 0)
-- | loops the sample (from `begin` to `end`) the specified number of times.
(loop, loop_p)                   = pF "loop" (Just 1)
(lophat, lophat_p)               = pF "lophat" (Just 0)
(lsnare, lsnare_p)               = pF "lsnare" (Just 0)
-- | specifies the sample or note number to be used
(n, n_p)                         = pF "n" (Just 0)
(note, note_p)                   = pF "note" (Just 0)
{- |
Pushes things forward (or backwards within built-in latency) in time. Allows for nice things like _swing_ feeling:

@
d1 $ stack [
  sound "bd bd/4",
  sound "hh(5,8)"
  ] # nudge "[0 0.04]*4"
@

--pitch model -}

degree, mtranspose, ctranspose, harmonic, stepsPerOctave, octaveRatio :: Pattern Double -> ParamPattern
degree_p, mtranspose_p, ctranspose_p, harmonic_p, stepsPerOctave_p, octaveRatio_p :: Param
(degree, degree_p)               = pF "degree" Nothing
(mtranspose, mtranspose_p)       = pF "mtranspose" Nothing
(ctranspose, ctranspose_p)       = pF "ctranspose" Nothing
(harmonic, harmonic_p)           = pF "ctranspose" Nothing
(stepsPerOctave, stepsPerOctave_p)           = pF "stepsPerOctave" Nothing
(octaveRatio, octaveRatio_p)           = pF "octaveRatio" Nothing


--Low values will give a more _human_ feeling, high values might result in quite the contrary.

(nudge, nudge_p)                 = pF "nudge" (Just 0)
(octave, octave_p)               = pI "octave" (Just 3)
(offset, offset_p)               = pF "offset" (Just 0)
(ophatdecay, ophatdecay_p)       = pF "ophatdecay" (Just 0)
{- |  a pattern of numbers. An `orbit` is a global parameter context for patterns. Patterns with the same orbit will share hardware output bus offset and global effects, e.g. reverb and delay. The maximum number of orbits is specified in the superdirt startup, numbers higher than maximum will wrap around.
-}
(orbit, orbit_p)                 = pI "orbit" (Just 0)
-- | a pattern of numbers between 0 and 1, from left to right (assuming stereo), once round a circle (assuming multichannel)
(pan, pan_p)                     = pF "pan" (Just 0.5)
-- | a pattern of numbers between -inf and inf, which controls how much multichannel output is fanned out (negative is backwards ordering)
(panspan, panspan_p)                     = pF "span" (Just 1.0)
-- | a pattern of numbers between 0.0 and 1.0, which controls the multichannel spread range (multichannel only)
(pansplay, pansplay_p)                     = pF "splay" (Just 1.0)
-- | a pattern of numbers between 0.0 and inf, which controls how much each channel is distributed over neighbours (multichannel only)
(panwidth, panwidth_p)                     = pF "panwidth" (Just 2.0)
-- | a pattern of numbers between -1.0 and 1.0, which controls the relative position of the centre pan in a pair of adjacent speakers (multichannel only)
(panorient, panorient_p)                     = pF "orientation" (Just 0.5)

(pitch1, pitch1_p)               = pF "pitch1" (Just 0)
(pitch2, pitch2_p)               = pF "pitch2" (Just 0)
(pitch3, pitch3_p)               = pF "pitch3" (Just 0)
(portamento, portamento_p)       = pF "portamento" (Just 0)
-- | a pattern of numbers to specify the release time (in seconds) of an envelope applied to each sample. Only takes effect if `attack` is also specified.
(release, release_p)             = pF "release" (Just (-1))
-- | a pattern of numbers from 0 to 1. Specifies the resonance of the low-pass filter.
(resonance, resonance_p)         = pF "resonance" (Just 0)
-- | a pattern of numbers from 0 to 1. Sets the level of reverb.
(room, room_p)                   = pF "room" Nothing
(sagogo, sagogo_p)               = pF "sagogo" (Just 0)
(sclap, sclap_p)                 = pF "sclap" (Just 0)
(sclaves, sclaves_p)             = pF "sclaves" (Just 0)
(scrash, scrash_p)               = pF "scrash" (Just 0)
(semitone, semitone_p)           = pF "semitone" (Just 0)
-- | wave shaping distortion, a pattern of numbers from 0 for no distortion up to 1 for loads of distortion.
(shape, shape_p)                 = pF "shape" (Just 0)
-- | a pattern of numbers from 0 to 1. Sets the perceptual size (reverb time) of the `room` to be used in reverb.
(size, size_p)                   = pF "size" Nothing
(slide, slide_p)                 = pF "slide" (Just 0)
-- | a pattern of numbers which changes the speed of sample playback, i.e. a cheap way of changing pitch. Negative values will play the sample backwards!
(speed, speed_p)                 = pF "speed" (Just 1)
-- | a pattern of strings. Selects the sample to be played.
(s', s_p)                         = pS "s" Nothing
(stutterdepth, stutterdepth_p)   = pF "stutterdepth" (Just 0)
(stuttertime, stuttertime_p)     = pF "stuttertime" (Just 0)
(sustain, sustain_p)             = pF "sustain" (Just 0)
(tomdecay, tomdecay_p)           = pF "tomdecay" (Just 0)
{- | used in conjunction with `speed`, accepts values of "r" (rate, default behavior), "c" (cycles), or "s" (seconds).
Using `unit "c"` means `speed` will be interpreted in units of cycles, e.g. `speed "1"` means samples will be stretched to fill a cycle.
Using `unit "s"` means the playback speed will be adjusted so that the duration is the number of seconds specified by `speed`.
-}
(unit, unit_p)                   = pS "unit" (Just "rate")
(velocity, velocity_p)           = pF "velocity" (Just 0.5)
(vcfegint, vcfegint_p)           = pF "vcfegint" (Just 0)
(vcoegint, vcoegint_p)           = pF "vcoegint" (Just 0)
(voice, voice_p)                 = pF "voice" (Just 0)
-- | formant filter to make things sound like vowels, a pattern of either `a`, `e`, `i`, `o` or `u`. Use a rest (`~`) for no effect.
(vowel, vowel_p)                 = pS "vowel" (Just "")
(psrate, psrate_p)      = pF "psrate" (Just 1)

-- MIDI-specific params

(dur,dur_p)                      = pF "dur" (Just 0.05)
(modwheel,modwheel_p)            = pF "modwheel" (Just 0)
(expression,expression_p)        = pF "expression" (Just 1)
(sustainpedal,sustainpedal_p)    = pF "sustainpedal" (Just 0)

-- Tremolo Audio DSP effect | params are "tremolorate" and "tremolodepth"
tremolorate, tremolodepth :: Pattern Double -> ParamPattern
tremolorate_p, tremolodepth_p :: Param
(tremolorate,tremolorate_p)      = pF "tremolorate" (Just 1)
(tremolodepth,tremolodepth_p)    = pF "tremolodepth" (Just 0.5)

-- Phaser Audio DSP effect | params are "phaserrate" and "phaserdepth"
phaserrate, phaserdepth :: Pattern Double -> ParamPattern
phaserrate_p, phaserdepth_p :: Param
(phaserrate,phaserrate_p)      = pF "phaserrate" (Just 1)
(phaserdepth,phaserdepth_p)    = pF "phaserdepth" (Just 0.5)

-- aliases
att, chdecay, ctf, ctfg, delayfb, delayt, lbd, lch, lcl, lcp, lcr, lfoc, lfoi
   , lfop, lht, llt, loh, lsn, ohdecay, phasdp, phasr, pit1, pit2, pit3, por, sag, scl, scp
   , scr, sld, std, stt, sus, tdecay, tremdp, tremr, vcf, vco, voi
      :: Pattern Double -> ParamPattern
att = attack
bpf = bandf
bpf_p = bandf_p
bpq = bandq
bpq_p = bandq_p
chdecay = clhatdecay
ctf  = cutoff
ctfg = cutoffegint
delayfb = delayfeedback
delayt  = delaytime
det  = detune
gat = gate
hg = hatgrain
hpf = hcutoff
hpf_p = hcutoff_p
hpq = hresonance
hpq_p = hresonance_p
lag = lagogo
lbd = lkick
lch = lclhat
lcl = lclaves
lcp = lclap
lcr = lcrash
lfoc = lfocutoffint
lfoi = lfoint
lfop = lfopitchint
lht = lhitom
llt = llotom
loh = lophat
lpf = cutoff
lpf_p = cutoff_p
lpq = resonance
lpq_p = resonance_p
lsn = lsnare
ohdecay = ophatdecay
phasdp = phaserdepth
phasr = phaserrate
pit1 = pitch1
pit2 = pitch2
pit3 = pitch3
por = portamento
rel = release
sag = sagogo
scl = sclaves
scp = sclap
scr = scrash
sz  = size
sld = slide
std = stutterdepth
stt = stuttertime
sus  = sustain
tdecay = tomdecay
tremdp = tremolodepth
tremr = tremolorate
vcf  = vcfegint
vco  = vcoegint
voi  = voice

midinote :: Pattern Double -> ParamPattern
midinote = note . ((subtract 60) <$>)

drum :: Pattern String -> ParamPattern
drum = n . ((subtract 60) . drumN <$>)

drumN :: Num a => String -> a
drumN "bd"  = 36
drumN "sn"  = 38
drumN "lt"  = 43
drumN "ht"  = 50
drumN "ch"  = 42
drumN "oh"  = 46
drumN "cp"  = 39
drumN "cl"  = 75
drumN "ag"  = 67
drumN "cr"  = 49
drumN _ = 0


-- SuperDirt MIDI Params

(array, array_p) = pF "array" Nothing
(midichan, midichan_p) = pF "midichan" Nothing
(control, control_p) = pF "control" Nothing
ctl = control
(ctlNum, ctlNum_p) = pF "ctlNum" Nothing
(frameRate, frameRate_p) = pF "frameRate" Nothing
(frames, frames_p) = pF "frames" Nothing
(hours, hours_p) = pF "hours" Nothing
(midicmd, midicmd_p) = pS "midicmd" Nothing
(minutes, minutes_p) = pF "minutes" Nothing
(progNum, progNum_p) = pF "progNum" Nothing
(seconds, seconds_p) = pF "seconds" Nothing
(songPtr, songPtr_p) = pF "songPtr" Nothing
(uid, uid_p) = pF "uid" Nothing
(val, val_p) = pF "val" Nothing
