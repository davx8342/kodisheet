#!/bin/bash

#
# description: makes contact sheets for your tv shows and movies using
#              your kodi sqlite files as source material.
#
# author:      davx8342@gmail.com
# version:     0.1 ALPHA
#

#
# path to your kodi db files
#
dbpath="./db"

#
# output path to your html
#
htmlout="./html"


#
# what we process, your options are tvshow or movie or both
#
mediatypes="tvshow movie"

if [ ! -d "$dbpath" ]; then
   echo You haven\'t created your db directory, you need to create this
   echo and put your kodi database files in there for this script to work.
   exit
fi

if [ ! -d "$htmlout" ]; then
   echo Your html output directory does not exist.
   exit
fi

#
# we save our images in a particular structure, create the structure if any
# of these directories don't already exist.
#
checkdirs="$htmlout/images $htmlout/images/tvshowposters $htmlout/images/movieposters $htmlout/images/tvshowfanart $htmlout/images/moviefanart $htmlout/images/tvshowbanners $htmlout/tvshow $htmlout/movie $htmlout/actor"

for dir in $checkdirs; do
   if [ ! -d "$dir" ]; then
      echo "INFO: $dir doesn't exist, will try and create it"
      mkdir -p $dir
   fi
done

for mediatype in $mediatypes; do

#   echo $mediatype

   if [ "$mediatype" == "tvshow" ]; then
      id="idShow"
      table="$mediatype"
      indextitle="TV Shows"
   fi

   if [ "$mediatype" == "movie" ]; then
      id="idMovie"
      table="$mediatype"
      indextitle="Movies"
   fi

   idList=`sqlite3 $dbpath/MyVideos107.db "SELECT $id from $table ORDER BY c00"`

   if [ -f "$htmlout/$mediatype.html" ]; then
      rm $htmlout/$mediatype.html
   fi
   touch $htmlout/$mediatype.html

   echo "<html><head><title>$indextitle</title>" >> $htmlout/$mediatype.html
   echo "<link rel=\"stylesheet\" href=\"kodisheet.css\" type=\"text/css\">" >> $htmlout/$mediatype.html
   echo "</head><body>" >> $htmlout/$mediatype.html
   echo "<p class=\"navigaton\">" >> $htmlout/$mediatype.html
   echo "<br /><br />" >> $htmlout/$mediatype.html
   echo "<a href=\"tvshow.html\">TV Shows</a>" >> $htmlout/$mediatype.html
   echo " | " >> $htmlout/$mediatype.html
   echo "<a href=\"movie.html\">Movies</a>" >> $htmlout/$mediatype.html
   echo "<br /><br /></p>" >> $htmlout/$mediatype.html
   for idLoop in $idList; do

      name=`sqlite3 $dbpath/MyVideos107.db "SELECT c00 from $mediatype where $id=$idLoop"`
      plot=`sqlite3 $dbpath/MyVideos107.db "SELECT c01 from $mediatype where $id=$idLoop"`



      if [ "$mediatype" == "tvshow" ]; then
         status=`sqlite3 $dbpath/MyVideos107.db "SELECT c02 from $mediatype where $id=$idLoop"`
         rating=`sqlite3 $dbpath/MyVideos107.db "SELECT c04 from $mediatype where $id=$idLoop"`
         firstaired=`sqlite3 $dbpath/MyVideos107.db "SELECT c05 from $mediatype where $id=$idLoop"`
         genre=`sqlite3 $dbpath/MyVideos107.db "SELECT c08 from $mediatype where $id=$idLoop"`
         guide=`sqlite3 $dbpath/MyVideos107.db "SELECT c10 from $mediatype where $id=$idLoop"`
         contentrating=`sqlite3 $dbpath/MyVideos107.db "SELECT c13 from $mediatype where $id=$idLoop"`
         network=`sqlite3 $dbpath/MyVideos107.db "SELECT c14 from $mediatype where $id=$idLoop"`
      fi

      if [ "$mediatype" == "movie" ]; then
         trailerurl=`sqlite3 $dbpath/MyVideos107.db "SELECT c19 from $mediatype where $id=$idLoop"`
         studio=`sqlite3 $dbpath/MyVideos107.db "SELECT c18 from $mediatype where $id=$idLoop"`
         rating=`sqlite3 $dbpath/MyVideos107.db "SELECT c12 from $mediatype where $id=$idLoop"`
         runtime=`sqlite3 $dbpath/MyVideos107.db "SELECT c11 from $mediatype where $id=$idLoop"`
         genre=`sqlite3 $dbpath/MyVideos107.db "SELECT c14 from $mediatype where $id=$idLoop"`
         director=`sqlite3 $dbpath/MyVideos107.db "SELECT c15 from $mediatype where $id=$idLoop"`
      fi

      echo $name

      #
      # why, yes I am this lazy...
      #
      out="$htmlout/$mediatype/$idLoop.html"
      if [ -f "$out" ]; then
         rm $out
      fi
      touch $out

      if [ "$mediatype" == "tvshow" ]; then
         bannerurl=`sqlite3 $dbpath/MyVideos107.db "SELECT url from art where media_id=$idLoop and type='banner' and media_type=\"$mediatype\""`
         bannerfile=$(basename $bannerurl)
         if [ ! -f "$htmlout/images/${mediatype}banners/$bannerfile" ]; then
            wget -O $htmlout/images/${mediatype}banners/$bannerfile $bannerurl
         fi
      fi

#      fanarturl=`sqlite3 $dbpath/MyVideos107.db "SELECT url from art where media_id=$idLoop and type='fanart' and media_type=\"$mediatype\""`
#      fanartfile=$(basename $fanarturl)
#      if [ ! -f "$htmlout/images/${mediatype}fanart/$fanartfile" ]; then
#         wget -O $htmlout/images/${mediatype}fanart/$fanartfile $fanarturl
#      fi

      posterurl=`sqlite3 $dbpath/MyVideos107.db "SELECT url from art where media_id=$idLoop and type='poster' and media_type=\"$mediatype\""`
      posterfile=$(basename $posterurl)
      if [ ! -f "$htmlout/images/${mediatype}posters/$posterfile" ]; then
         wget -O $htmlout/images/${mediatype}posters/TEMP${posterfile} $posterurl
         convert $htmlout/images/${mediatype}posters/TEMP${posterfile} -resize 150 $htmlout/images/${mediatype}posters/${posterfile}
         if [ -f $htmlout/images/${mediatype}posters/TEMP${posterfile} ]; then
            rm $htmlout/images/${mediatype}posters/TEMP${posterfile}
         fi
      fi

      echo "<a href=\"$mediatype/$idLoop.html\">" >> $htmlout/$mediatype.html
      echo "<img width=150 src=\"images/${mediatype}posters/$posterfile\"></a>" >> $htmlout/$mediatype.html

      echo "<html><head><title>$name</title>" >> $out
      echo "<link rel=\"stylesheet\" href=\"../kodisheet.css\" type=\"text/css\">" >> $out
      echo "</head>" >> $out
      echo "<body>" >> $out
      echo "<center><table width=400><tr><td>" >> $out

      if [ "$mediatype" == "tvshow" ]; then
         echo "<img src=\"../images/${mediatype}banners/$bannerfile\" width=450>" >> $out
         echo "</p>" >> $out
         echo "<p class=\"details\">" >> $out
         echo "Rating: $rating<br />" >> $out
         echo "First aired: $firstaired<br />" >> $out
         echo "Genre: $genre<br />" >> $out
         echo "Network: $network<br />" >> $out
         echo "Content Rating: $contentrating<br />" >> $out
         echo "</p>" >> $out
      fi
      if [ "$mediatype" == "movie" ]; then
         echo "<p class=\"showtitle\">$name</p>" >> $out
         echo "<p class=\"artwork\">" >> $out
         echo "<img src=\"../images/${mediatype}posters/$posterfile\"" >> $out
         echo "</p>" >> $out
         echo "<p class=\"details\">" >> $out
         echo "trailer: $trailerurl<br />" >> $out
         echo "studio: $studio<br />" >> $out
         echo "rating: $rating<br />" >> $out
         echo "runtime: $runtime<br />" >> $out
         echo "genre: $genre<br />" >> $out
         echo "director: $director<br />" >> $out
         echo "</p>" >> $out
      fi

      echo "<p class=\"synopsis\">" >> $out
      echo "<font class=\"heading\">Plot synopsis</font><br /><br />" >> $out
      echo "$plot" >> $out
      echo "</p>" >> $out

#      echo "<p class=\"cast\">" >> $out
#      echo "<font class=\"heading\">Cast</font><br /><br />" >> $out
#      idActors=`sqlite3 $dbpath/MyVideos107.db "SELECT actor_id from actor_link where media_id=$idLoop ORDER BY cast_order"`
#      for idActor in $idActors; do
#         actor=`sqlite3 $dbpath/MyVideos107.db "SELECT name from actor where actor_id=$idActor"`
#         echo "<a href=\"../actor/$idActor.html\">" >> $out
#         echo "$actor</a>, " >> $out
#      done
#
#      echo "</p>" >> $out

      if [ "$mediatype" == "tvshow" ]; then

         seasons=`sqlite3 $dbpath/MyVideos107.db "SELECT idSeason from seasons where idShow=$idLoop"`
         for season in $seasons; do
            count=`sqlite3 $dbpath/MyVideos107.db "SELECT count() from episode where idShow=$idLoop and idSeason=$season"`

            if [ "$count" != "0" ]; then
               echo "<p class=\"seasonlist\">" >> $out
               seasonNo=`sqlite3 $dbpath/MyVideos107.db "SELECT season from seasons where idShow=$idLoop and idSeason=$season"`
               realseason=`sqlite3 $dbpath/MyVideos107.db "SELECT c12 from episode where idShow=$idLoop and idSeason=$season limit 1"`
               file=`sqlite3 $dbpath/MyVideos107.db "SELECT c18 from episode where idShow=$idLoop and idSeason=$season"`
               echo "<Font class=\"heading\">Season $realseason</font>" >> $out
               echo "<br /><br />" >> $out

               episodes=`sqlite3 $dbpath/MyVideos107.db "select idEpisode from episode where idShow=$idLoop and idSeason=$season"`

               for episode in $episodes; do
                  episodeNo=`sqlite3 $dbpath/MyVideos107.db "SELECT c13 from episode where idShow=$idLoop and idSeason=$season and idEpisode=$episode"`
                  episodeTitle=`sqlite3 $dbpath/MyVideos107.db "SELECT c00 from episode where idShow=$idLoop and idSeason=$season and idEpisode=$episode"`
                  echo "$episodeNo. $episodeTitle<br />" >> $out
               done
               echo "</p>" >> $out
            fi
         done

         echo "</td></tr></table></center>" >> $out

      fi

   done
done

