"""
Created on Tue Nov 28 23:06:31 2017

Before all, we should select a folder we want to store our data in.

This code intends to download our data from a given URL. For that we downloaded
the pytube library which includes the possibility to take a YouTube URL and 
convert it's video to a .webm/.mp4/... file.

After downloading the videos, we will change their names from the name they 
were given in YouTube, to the ones we want, which are the URLs of them.

@authors: Ronen Rahamim and Gilad Hecht
"""

from pytube import YouTube
import Tkinter
import tkFileDialog
import os


with open('IDs_not_working_to_download.txt') as f:
    IDs = f.read().splitlines()
N = len(IDs)

root = Tkinter.Tk()
root.withdraw() #use to hide tkinter window

currdir = os.getcwd()
tempdir = tkFileDialog.askdirectory(parent=root, initialdir=currdir, title='Please select a directory')
if len(tempdir) > 0:
    print "You chose %s" % tempdir
os.chdir(tempdir)


for ii in range(N):
    URL = 'https://www.youtube.com/watch?v=' + IDs[ii]
    yt = YouTube(URL)
    #yt = YouTube('https://www.youtube.com/watch?v=IGQBtbKSVhY')
    vidID = yt.video_id
    vidName = yt.fmt_streams[0].default_filename
    vidNewName = vidID + '.mp4'
    stream = yt.streams.first()
    stream.download()
    os.rename(vidName, vidNewName)
    print "finished download video %d out of %d" % (ii+1, N)


"""

junk:

root = Tkinter.Tk()
root.withdraw() #use to hide tkinter window

currdir = os.getcwd()
tempdir = tkFileDialog.askdirectory(parent=root, initialdir=currdir, title='Please select a directory')
if len(tempdir) > 0:
    print "You chose %s" % tempdir


https://www.youtube.com/embed/-ZWGpOSS6T0?start=130&end=144&version=3

For downloading a clip:
    YouTube('https://www.youtube.com/watch?v=B7bqAsxee4I').streams.first().download()
"""

