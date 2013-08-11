#!/usr/bin/env python
import os
import subprocess
import sys

from optparse import OptionParser

from echonest.remix.audio import AudioData, AudioSegment, LocalAudioFile
from echonest.remix.action import render
from pyechonest import config as echo_config

def md5(path):
  """
  Brutally non-portable md5 computation
  """
  # mac OS:
#  p = subprocess.Popen('md5 -q %s' % path, stdout=subprocess.PIPE, shell=True)

  # linux:
  p = subprocess.Popen('md5sum %s' % path, stdout=subprocess.PIPE, shell=True)

  (md5sum, err) = p.communicate()
  if err:
    raise Exception("MD5 checksum error")
  return md5sum.split(' ')[0]

  
class Monoizer():
  def __init__(self, source_path):
    self.path = source_path
    self.checksum = md5(source_path)

  def analyze(self):
    self.laf = LocalAudioFile(self.path)
    self.analysis = self.laf.analysis
    self.key = self.analysis.key
    self.segments = self.analysis.segments

  def process(self):
    key_class = self.key['value']
    self.shifted_audio_datas = []
    for segment in self.segments:
      if 1.0 not in segment.pitches:
        continue
      dominant_pitch = segment.pitches.index(1.0)

      difference = key_class - dominant_pitch
      difference_modulo = difference % 12
      desired_shift = difference_modulo - 6

      shifted = self.shift_segment(segment, desired_shift)
      self.shifted_audio_datas.append(shifted)

  def save(self, path):
    render(self.shifted_audio_datas, path)
    

  def shift_segment(self, segment, amount):
    # filenames
    tmp_root = "/tmp/%s" % self.checksum[-3:]
    tmp_base = "%s/%s/" % (tmp_root, self.checksum)
    tmp_filename = self.checksum[:6] + str(segment.absolute_context()[0])
    tmp_path = tmp_base + tmp_filename + '.wav'
    shifted_path = tmp_base + tmp_filename + '_shifted.wav'

    # make sure the path is a thing
    if not os.path.exists(tmp_base):
      os.makedirs(tmp_base)
    
    # write the segment out
    tmp_file = segment.encode(tmp_path)

    # shift it
    subprocess.call([
      'rubberband',
      '--pitch', str(amount),
      tmp_path,
      shifted_path])

    # put it back into a segment
    new_data = AudioData(shifted_path)
    new_data.load()

    # clean up the files 
    # os.removedirs(tmp_root) # assuming no collisions, or problems if we nuke something else in there

    sys.stdout.flush()

    return new_data 


def main():
  usage = 'usage: %s <input_file> <output_file>' % sys.argv[0]
  parser = OptionParser(usage=usage)

  (options, args) = parser.parse_args()
  if len(args) < 2:
    parser.print_help()
    return -1

  print 'monoize'
  monoizer = Monoizer(args[0])
  print 'about to analyze'
  monoizer.analyze()
  print 'about to process'
  monoizer.process()
  print 'about to save'
  monoizer.save(args[1])


if __name__ == '__main__':
  try:
    main()
  except Exception, e:
    print e
