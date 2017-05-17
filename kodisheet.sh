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
htmlout="/var/www/html/kodisheet"


#
# what we process, your options are tvshow or movie or both
#
mediatypes="movie tvshow"

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
checkdirs="$htmlout/images $htmlout/images/tvshowposters $htmlout/images/movieposters $htmlout/images/tvshowfanart $htmlout/images/moviefanart $htmlout/images/tvshowbanners $htmlout/tvshow $htmlout/movie $htmlout/genre"

#
# some basic metrics
#
movieCount=`sqlite3 db/MyVideos107.db "SELECT count() from movie"`
tvCount=`sqlite3 db/MyVideos107.db "SELECT count() from tvshow"`

#
# remove the genre index
#
if [ -f "$htmlout/genre/index.html" ]; then
   rm "$htmlout/genre/index.html"
fi

for dir in $checkdirs; do
   if [ ! -d "$dir" ]; then
      echo "INFO: $dir doesn't exist, will try and create it"
      mkdir -p $dir
   fi
done

#
# if we have files without poster art we need to substitute something or we get broken images
#
convert -size 150x221 xc:black $htmlout/images/tvshowbanners/unknown.jpg
convert -size 150x221 xc:black $htmlout/images/tvshowposters/unknown.jpg
convert -size 150x221 xc:black $htmlout/images/movieposters/unknown.jpg



genres=`sqlite3 db/MyVideos107.db "SELECT genre_id from genre"`
genrenav=""

for genre in $genres; do
   name=`sqlite3 db/MyVideos107.db "SELECT name from genre where genre_id=$genre"`
   out="$htmlout/genre/$genre.html"

   #
   # count to see if we have media in this genre, if we don't we exclude it
   #
   count=`sqlite3 db/MyVideos107.db "SELECT count() from genre_link where genre_id=$genre"`
   if [ "$count" != "0" ]; then
      genrenav="<a href=\"$genre.html\">$name</a> | $genrenav"

      if [ -f "$out" ]; then
         rm $out
      fi
      touch $out

      echo "<html><head><title>$name</title>" >> $out
      echo "<link rel=\"stylesheet\" href=\"../kodisheet.css\" type=\"text/css\">" >> $out
      echo "</head><body>" >> $out
      echo "<p class=\"navigaton\">" >> $out
      echo "<font class=\"giantheading\">Genre: $name</font>" >> $out
      echo "<br /><br />" >> $out
   fi
done

#
# remove the last 3 digits, basically ' | '
#
genrenav=${genrenav::-3}

for genre in $genres; do
   if [ -f "$htmlout/genre/$genre.html" ]; then
      echo "<font class=\"heading\">" >> $htmlout/genre/$genre.html
      echo "$genrenav" >> $htmlout/genre/$genre.html
      echo "</font>" >> $htmlout/genre/$genre.html
   fi
done

echo "<html><head><title>genres</title>" >> $htmlout/genre/index.html
echo "<link rel=\"stylesheet\" href=\"../kodisheet.css\" type=\"text/css\">" >> $htmlout/genre/index.html
echo "</head><body>" >> $htmlout/genre/index.html
echo "<p class=\"navigaton\">" >> $htmlout/genre/index.html
echo "<font class=\"giantheading\">Genres</font>" >> $htmlout/genre/index.html
echo "<br /><br />" >> $htmlout/genre/index.html
echo "<font class=\"heading\">$genrenav" >> $htmlout/genre/index.html
echo "</font></p></body></html>" >> $htmlout/genre/index.html

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
   echo "<font class=\"giantheading\">" >> $htmlout/$mediatype.html
   echo "<a href=\"tvshow.html\">TV Shows</a> [$tvCount]" >> $htmlout/$mediatype.html
   echo " | " >> $htmlout/$mediatype.html
   echo "<a href=\"movie.html\">Movies</a> [$movieCount]" >> $htmlout/$mediatype.html
   echo " | " >> $htmlout/$mediatype.html
   echo "<a href=\"genre/index.html\">Genres</a>" >> $htmlout/$mediatype.html
   echo "<br /><br /></font></p>" >> $htmlout/$mediatype.html
   for idLoop in $idList; do

      name=`sqlite3 $dbpath/MyVideos107.db "SELECT c00 from $mediatype where $id=$idLoop"`

      if [ "$name" != "** 403: Series Not Permitted **" ]; then
#      	echo halt
#      fi
         plot=`sqlite3 $dbpath/MyVideos107.db "SELECT c01 from $mediatype where $id=$idLoop"`

         if [ "$mediatype" == "tvshow" ]; then
            status=`sqlite3 $dbpath/MyVideos107.db "SELECT c02 from $mediatype where $id=$idLoop"`
            rating=`sqlite3 $dbpath/MyVideos107.db "SELECT c04 from $mediatype where $id=$idLoop"`
            firstaired=`sqlite3 $dbpath/MyVideos107.db "SELECT c05 from $mediatype where $id=$idLoop"`
            guide=`sqlite3 $dbpath/MyVideos107.db "SELECT c10 from $mediatype where $id=$idLoop"`
            contentrating=`sqlite3 $dbpath/MyVideos107.db "SELECT c13 from $mediatype where $id=$idLoop"`
            network=`sqlite3 $dbpath/MyVideos107.db "SELECT c14 from $mediatype where $id=$idLoop"`
            echo $name
         fi

         if [ "$mediatype" == "movie" ]; then
            idFile=`sqlite3 $dbpath/MyVideos107.db "SELECT idFile from $mediatype where $id=$idLoop"`
            width=`sqlite3 $dbpath/MyVideos107.db "SELECT iVideoWidth from streamdetails where idFile=\"$idFile\" and iStreamType=0"`
            height=`sqlite3 $dbpath/MyVideos107.db "SELECT iVideoHeight from streamdetails where idFile=\"$idFile\" and iStreamType=0"`
            if [ "$width" == "1920" ]; then
               width="1080p"
            elif [ "$width" == "1280" ]; then
               width="720p"
            elif [ "$width" == "640" ]; then
               width="480p"
            elif [ "$width" == "" ]; then
               width=""
            else
               width="${width}x${height}"
            fi
            filetype=`sqlite3 $dbpath/MyVideos107.db "SELECT strFilename from files where idFile=\"$idFile\""`
            filetype="${filetype: -3}"
            trailerurl=`sqlite3 $dbpath/MyVideos107.db "SELECT c19 from $mediatype where $id=$idLoop"`
            if [ "$trailerurl" != "" ]; then
               videoarg=`echo $trailerurl|awk -F"videoid=" '{print $2}'|cut -c1-11`
               trailerurl="https://www.youtube.com/watch?v=${videoarg}"
            fi
         
            studio=`sqlite3 $dbpath/MyVideos107.db "SELECT c18 from $mediatype where $id=$idLoop"`
            rating=`sqlite3 $dbpath/MyVideos107.db "SELECT c12 from $mediatype where $id=$idLoop"`
            runtime=`sqlite3 $dbpath/MyVideos107.db "SELECT c11 from $mediatype where $id=$idLoop"`
            director=`sqlite3 $dbpath/MyVideos107.db "SELECT c15 from $mediatype where $id=$idLoop"`
            echo $name posterfile: $posterfile prevposterfile: $prevposterfile
         fi


         out="$htmlout/$mediatype/$idLoop.html"
         if [ -f "$out" ]; then
            rm $out
         fi
         touch $out

         if [ "$mediatype" == "tvshow" ]; then
            bannerurl=`sqlite3 $dbpath/MyVideos107.db "SELECT url from art where media_id=$idLoop and type='banner' and media_type=\"$mediatype\""`
            if [ "$bannerurl" != "" ]; then
               bannerfile=$(basename $bannerurl)
               if [ ! -f "$htmlout/images/${mediatype}banners/$bannerfile" ]; then
                  wget -O $htmlout/images/${mediatype}banners/$bannerfile $bannerurl
               fi
            else
               bannerfile="unknown.jpg"
            fi
         fi

         posterurl=`sqlite3 $dbpath/MyVideos107.db "SELECT url from art where media_id=$idLoop and type='poster' and media_type=\"$mediatype\""`
         if [ "$posterurl" != "" ]; then
            posterfile=$(basename $posterurl)

            if [ "$posterfile" == "$prevposterfile" ]; then
               posterfile=${idLoop}.jpg
#               wget -O $htmlout/images/${mediatype}posters/${posterfile} $posterurl
            fi

            if [ ! -f "$htmlout/images/${mediatype}posters/$posterfile" ]; then
               wget -O $htmlout/images/${mediatype}posters/TEMP${posterfile} $posterurl

              
               if [ "$mediatype" == "movie" ]; then
                  if [ "$width" == "" ]; then
                     imagetext="$filetype"
                  else
                     imagetext="${width} / ${filetype}"
                  fi
                  convert $htmlout/images/${mediatype}posters/TEMP${posterfile} -resize 150 $htmlout/images/${mediatype}posters/TEMP1${posterfile}
               posterwidth=`identify -format %w $htmlout/images/${mediatype}posters/TEMP1${posterfile}`
#               posterheight=`identify -format %h $htmlout/images/${mediatype}posters/TEMP1${posterfile}`



#                 marker=$((posterheight-25))
#                 convert -background '#0008' -fill white -gravity center -size ${posterwidth}x30 caption:"$imagetext" $htmlout/images/${mediatype}posters/TEMP1${posterfile} +swap -gravity south -composite $htmlout/images/${mediatype}posters/${posterfile}
convert -background '#0008' -fill white -gravity southeast -size ${posterwidth}x15 caption:"${imagetext}" $htmlout/images/${mediatype}posters/TEMP1${posterfile} +swap -gravity south -composite $htmlout/images/${mediatype}posters/${posterfile}

               else
                  convert $htmlout/images/${mediatype}posters/TEMP${posterfile} -resize 150 $htmlout/images/${mediatype}posters/${posterfile}
               fi
                  if [ -f "$htmlout/images/${mediatype}posters/TEMP1${posterfile}" ]; then
                     rm $htmlout/images/${mediatype}posters/TEMP1${posterfile}
                  fi
                  if [ -f $htmlout/images/${mediatype}posters/TEMP${posterfile} ]; then
                     rm $htmlout/images/${mediatype}posters/TEMP${posterfile}
                  fi
               prevposterfile=${posterfile}
            fi
         else
            cp $htmlout/images/${mediatype}posters/unknown.jpg $htmlout/images/${mediatype}posters/TEMP1${idLoop}.jpg
            convert -background '#0008' -fill white -gravity southeast -size 150x15 caption:"${imagetext}" $htmlout/images/${mediatype}posters/TEMP1${idLoop}.jpg +swap -gravity south -composite $htmlout/images/${mediatype}posters/TEMP2${idLoop}.jpg
            convert -background '#0008' -fill white -gravity northwest -size 150x200 caption:"${name}" $htmlout/images/${mediatype}posters/TEMP2${idLoop}.jpg +swap -gravity north -composite $htmlout/images/${mediatype}posters/${idLoop}.jpg
            if [ -f "$htmlout/images/${mediatype}posters/TEMP2${posterfile}" ]; then
               rm $htmlout/images/${mediatype}posters/TEMP2${posterfile}
            fi
            if [ -f $htmlout/images/${mediatype}posters/TEMP1${posterfile} ]; then
               rm $htmlout/images/${mediatype}posters/TEMP1${posterfile}
            fi 
            if [ -f $htmlout/images/${mediatype}posters/TEMP1${idLoop}.jpg ]; then
               rm $htmlout/images/${mediatype}posters/TEMP1${idLoop}.jpg
            fi 
            if [ -f $htmlout/images/${mediatype}posters/TEMP2${idLoop}.jpg ]; then
               rm $htmlout/images/${mediatype}posters/TEMP2${idLoop}.jpg
            fi 


            posterfile="${idLoop}.jpg"
#            posterdimensions=`identify $htmlout/images/${mediatype}posters/TEMP${posterfile}| awk '{print $3}'`
#            posterwidth=`echo $posterdimensions|awk -F"x" '{print $1}'`
#            posterheight=`echo $posterdimensions|awk -F"x" '{print $2}'`
#            convert $htmlout/images/${mediatype}posters/unknown.jpg -resize 150 $htmlout/images/${mediatype}posters/TEMP1${posterfile}
#            marker=$((posterheight-25))
#            convert $htmlout/images/${mediatype}posters/TEMP1${posterfile} -gravity southeast -draw "fill black rectangle 0,$marker $posterwidth,$posterheight" -fill white -annotate +5+5 "$imagetext" $htmlout/images/${mediatype}posters/${posterfile}

         fi

         #
         # genres
         #
         genres=`sqlite3 $dbpath/MyVideos107.db "SELECT genre_id from genre_link where media_id=$idLoop and media_type=\"$mediatype\""`

         filegenre=""
         for genre in $genres; do
            genrename=`sqlite3 $dbpath/MyVideos107.db "SELECT name from genre where genre_id=$genre"`
#         echo $genrename
            filegenre="<a href=\"../genre/$genre.html\">$genrename</a> / $filegenre"
            echo "<a href=\"../$mediatype/$idLoop.html\">" >> $htmlout/genre/$genre.$mediatype
            echo "<img width=150 src=\"../images/${mediatype}posters/$posterfile\"></a>" >> $htmlout/genre/$genre.$mediatype
         done

         if [ "$filegenre" != "" ]; then 
            filegenre=${filegenre::-3}
         fi

         echo $posterfile $prevposterfile
         if [ "$posterfile" == "$prevposterfile" ]; then
            posterfile=${idLoop}.jpg
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
            echo "Genre: $filegenre<br />" >> $out
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
            echo "trailer: <a href=\"$trailerurl\">youtube</a><br />" >> $out
            echo "studio: $studio<br />" >> $out
            echo "rating: $rating<br />" >> $out
            echo "runtime: $runtime<br />" >> $out
            echo "genre: $filegenre<br />" >> $out
            echo "director: $director<br />" >> $out
            echo "</p>" >> $out
         fi

         echo "<p class=\"synopsis\">" >> $out
         echo "<font class=\"heading\">Plot synopsis</font><br /><br />" >> $out
         echo "$plot" >> $out
         echo "</p>" >> $out

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
   fi
      done

   genres=`sqlite3 $dbpath/MyVideos107.db "SELECT genre_id from genre"`
   for genre in $genres; do
      if [ -f "$htmlout/genre/$genre.html" ]; then
         genrename=`sqlite3 $dbpath/MyVideos107.db "SELECT name from genre where genre_id=$genre"`
         if [ -f "$htmlout/genre/$genre.$mediatype" ]; then
            echo "<p class="artwork"><font class=\"giantheading\">$indextitle</font><br /><br />" >> $htmlout/genre/$genre.html
            cat $htmlout/genre/$genre.$mediatype >> $htmlout/genre/$genre.html
            echo "<br /><br /></p>" >> $htmlout/genre/$genre.html
            rm $htmlout/genre/$genre.$mediatype
         fi
      fi
   done
done

genres=`sqlite3 $dbpath/MyVideos107.db "SELECT genre_id from genre"`
for genre in $genres; do
   if [ -f "$htmlout/genre/$genre.html" ]; then
      echo "</body></html>" >> $htmlout/genre/$genre.html
   fi
done
