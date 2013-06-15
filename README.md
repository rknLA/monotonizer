Monotonizer
===========

Turn any recording into ~~pure~~ ~~un~~adultered monotony.

Usage
-----

This repo contains the Monotonizer server as well as the Monotonizer script.

To run the script locally, run `./lib/monotonize.py` on the command line.

Pass it an input audio file, and an output destination.

Listen to the output when it's done.

Script Dependencies
------------

* The [Echonest Remix API](http://echonest.github.io/remix/) (`pip install remix`)
* `ECHO_NEST_API_KEY` must be in your env, or added to `monotonize.py`
* The [RubberBand](http://www.breakfastquay.com/rubberband/) CLI utility somewhere in your path. (`which rubberband` should give you something)
* The [Numpy](http://www.numpy.org/) Python package (`pip install numpy`)
* [FFmpeg](http://www.ffmpeg.org/) With homebrew installed run `brew install ffmpeg` and then `sudo ln -s 'which ffmpeg' /usr/local/bin/en-ffmpeg`.

About
-----

Built by R. Kevin Nelson for Music Hack Day, Barcelona 2013.
