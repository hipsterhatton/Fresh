# Fresh

Fresh is a small menubar utility app for OS X) that periodically changes the desktop background (based on a user-defined schedule)

It uses the Unsplash API (https://unsplash.com/) to download and apply, a new background wallpaper for each screen (e.g.: laptop + external monitor)

Features:
- Mesasures screen dimensions so each wallpaper is perfect sized
- Downloads either: random image -or- user can define keywords (e.g.: black and white, landscape) [WIP]
- Flexible scheule: per screen schedule - supports variety of intervals, e.g.: every 3 days at 10am / every 20 minutes / 12th of every month at 4.30pm
- Very small memory footprint
- History of wallpapers fetched
- Simple to use UI [WIP]


#NOTE# not worked on this for a while, unfortunately OS X doesn't have an API for updating wallpaper whilst an app is fullscreen (it works if an app is NOT fullscreen)
Right now, I update a SQLite database which holds the desktop wallpaper info, then 'kill' the Dock app, which is auto restarted and applies the new wallpaper
