# -*- coding: utf-8 -*-
"""
Created on Tue Nov 28 19:05:17 2017

Gilad Hecht
"""

import pafy
videodir = "D:/Projects/Project2_AVA/version2Vids/"
annotfile = "trainVidIDs.csv"
bad_urls = []
#%%
with open(annotfile) as f:
    while True:
        line = f.readline()
        if line == '': break # EOF
        url = line[:11]
        video = pafy.new(url)
        best = video.getbest(preftype="mp4")
        best.resolution, best.extension
        best.url
        try:
            filename = best.download(filepath=videodir + url +"." + best.extension)
        except:
            bad_urls.append(url)
        continue
		

#%%
url = "1j20qq1JyX4"
video = pafy.new(url)
best = video.getbest(preftype="mp4")
best.resolution, best.extension
best.url
filename = best.download(filepath=videodir + url +"." + best.extension)
