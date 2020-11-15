# esp-libopus

*Original README content further below*

This repository is a port of the original Opus code for the ESP32. It
provides a component.mk makefile with the necessary configuration to compile and
use the Opus audio codec on the ESP32. It also removes the original build system
of Opus to not clutter the filetree and confuse the ESP32 build system.

### Usage
This repository can be added as submodule to any valid ESP32 component directory.
The easiest way to do this is to create a `component/` directory in the root
of an ESP project, using `git submodule add` to clone this repo into there,
and to ensure that this new component is recognized via `make list-components`.

*Note:* Currently the component.mk file might only work for the older build system
of the ESP-IDF, however creating a config file for the newer build system should
be fairly trivial.

After adding this component to the build configuration, the "opus.h" file
can be included. All *fixed point* Opus decoder and encoder methods are available,
consult the Opus documentation for examples.

#### Important considerations
Opus is a fairly heavy codec, and it might not always work smoothly on the ESP32.
The following things have to be taken into account:

- Encoding and Decoding heavily utilize Stack via `alloca`. It is recommended
to have at least 30kB of Stack reserved for the FreeRTOS thread that is running
the Opus encoding/decoding (the stack is freed after the Opus call, so a single
thread can encode and decode).
- Decoding data on the ESP32 is fairly lightweight, and will consume about 30% of
the CPU time at 240MHz on a single core, even at 48kHz samplerate. This makes
it fairly usable.
- *Encoding* however is much more intensive. 16kHz samplerate
at encoding complexity 1 will use 70% CPU. 24kHz samplerate at anything above
complexity 4 will *not be able to run at realtime*. 48kHz can only run at
realtime with complexity 1, and even then it uses 85% CPU. It still sounds
understandable at 16kHz if you just need basic VoIP or voice recognition though,
but don't expect to encode high quality music.

Additionally, the WiFi of the ESP32 is very capable of high throughputs, so
the Samplerate is rarely an issue. What I have found to be problematic is the
unstable latency of the network. The ESP will receive in "chunks" of a few
packets, then pause for about 300ms, give or take.
If you want to use Opus to stream Audio, make sure to have a bigger buffer of
one or two seconds worth of audio on the receiving end, so that these lagspikes
can be smoothed out. Once you do that though it's quite easy to have a very
nice sounding audio stream.

**Todo:** Add a class that provides an easy to use ESP32 MQTT Audio stream.
It'll need to handle decoding the data, providing it to the XasWorks audio
core (which will need a slight rework, oh well), and keeping the buffer in synch
by varying playback speed a bit (clock drift and stuff).

If I do get around to doing this, it'll be in my [XasWorks](https://github.com/XasWorks/XasCode)
repository, so check it out.

# Opus audio codec
*Original readme:*

Opus is a codec for interactive speech and audio transmission over the Internet.

  Opus can handle a wide range of interactive audio applications, including
Voice over IP, videoconferencing, in-game  chat, and even remote live music
performances. It can scale from low bit-rate narrowband speech to very high
quality stereo music.

  Opus, when coupled with an appropriate container format, is also suitable
for non-realtime  stored-file applications such as music distribution, game
soundtracks, portable music players, jukeboxes, and other applications that
have historically used high latency formats such as MP3, AAC, or Vorbis.

                    Opus is specified by IETF RFC 6716:
                    https://tools.ietf.org/html/rfc6716

  The Opus format and this implementation of it are subject to the royalty-
free patent and copyright licenses specified in the file COPYING.

This package implements a shared library for encoding and decoding raw Opus
bitstreams. Raw Opus bitstreams should be used over RTP according to
 https://tools.ietf.org/html/rfc7587

The package also includes a number of test  tools used for testing the
correct operation of the library. The bitstreams read/written by these
tools should not be used for Opus file distribution: They include
additional debugging data and cannot support seeking.

Opus stored in files should use the Ogg encapsulation for Opus which is
described at:
 https://tools.ietf.org/html/rfc7845

An opus-tools package is available which provides encoding and decoding of
Ogg encapsulated Opus files and includes a number of useful features.

Opus-tools can be found at:
 https://git.xiph.org/?p=opus-tools.git
or on the main Opus website:
 https://opus-codec.org/

## Testing
**Todo:** Add testing according to the Opus test system. This is currently
not implemented on the ESP32 variant of libopus

## Portability notes
*Note:* Fixed point is used for the ESP32. Floating point is disabled
via a compiler define. The ESP32's FPU is way too slow for this.

This implementation uses floating-point by default but can be compiled to
use only fixed-point arithmetic by setting --enable-fixed-point (if using
autoconf) or by defining the FIXED_POINT macro (if building manually).
The fixed point implementation has somewhat lower audio quality and is
slower on platforms with fast FPUs, it is normally only used in embedded
environments.

The implementation can be compiled with either a C89 or a C99 compiler.
While it does not rely on any _undefined behavior_ as defined by C89 or
C99, it relies on common _implementation-defined behavior_ for two's
complement architectures:

o Right shifts of negative values are consistent with two's
  complement arithmetic, so that a>>b is equivalent to
  floor(a/(2^b)),

o For conversion to a signed integer of N bits, the value is reduced
  modulo 2^N to be within range of the type,

o The result of integer division of a negative value is truncated
  towards zero, and

o The compiler provides a 64-bit integer type (a C99 requirement
  which is supported by most C89 compilers).
