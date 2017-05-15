# kodisheet

Description: create a contact sheet using thumbnails of your tv/movies you have in your kodi library

Basically I wanted a wall of cover art to look at to quickly see what I have in my library. Optionally clicking on one of the thumbnails will contain a list of episodes and/or plot synopsis. 

This script will create tvshow.html and movie.html as well as a directory called images which'll house all the cover artwork. You can then put these files on a web server somewhere to view them online or open them with a browser locally.

#Dependencies:

This script uses:

sqlite3 - to extract data from the kodi sqlite database files.
imagemagick - to resize the cover art
kodi database files - you'll find these in .kodi/userdata/Database of if you use profiles .kodi/userdata/profiles/USERNAME/Database

# how to use this script

Download kodisheet.sh, create a 'db' folder, in which you'll place your Kodi database files. Then create an output directory where you want to store the output files.

Then just ./kodisheet.sh and you should get some output to screen as it intergates the kodi data files and downloads cover artwork.

# issues

I couldn't work out how to extract thumbnails from Kodi's cache. It seemed really inconsistent about what was stored in the cache and to be honest, having to have a copy of your entire cache directory on hand didn't seem like a good idea. So instead this script will pull artwork is needs from tvdb/moviedb as required, and then dymanically resize it using imagemagick.

