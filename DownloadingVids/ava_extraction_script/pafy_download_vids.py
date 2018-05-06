# -*- coding: utf-8 -*-
"""
Created on Tue Nov 28 19:05:17 2017

Gilad Hecht
"""

import pafy
from os import listdir
# videodir = "D:/Projects/Project2_AVA/version2Vids/"
# For old laptop:
videodir = "E:/Projects/Project2_AVA/version2Vids/"
annotfile = "validVidIDs.csv"
bad_urls = []
currVids = listdir(videodir)
#%%
with open(annotfile) as f:
  while True:
    line = f.readline()
    vid  = line[:-1] + '.mp4'
    if line == '': break # EOF
    if any(vid in s for s in currVids): continue # already contains video
    try:
      url = line[:11]
      video = pafy.new(url)
      best = video.getbest(preftype="mp4")
      best.resolution, best.extension
      best.url
      filename = best.download(filepath=videodir + url +"." + best.extension)
    except:
      bad_urls.append(url)
      continue
		

#%%
#url = "1j20qq1JyX4"
#video = pafy.new(url)
#best = video.getbest(preftype="mp4")
#best.resolution, best.extension
#best.url
#filename = best.download(filepath=videodir + url +"." + best.extension)
