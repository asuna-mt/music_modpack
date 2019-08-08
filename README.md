# music_modpack

## Overview
Music modpack with API for easy in-game music playback and custom track registration.

## Features

- Time-based music
- Elevation-based music
- Synchronized playback for all players

## Adding your own music
Call music.register_track() with following definition:

```Lua
music.register_track({
    name = "my_track",
    length = 200,
    gain = 1,
    day = true,
    night = true,
    ymin = 0,
    ymax = 31000,
})
```

- name - name of the sound file in your mod sounds folder, without extension (.ogg)
- length - length of the track in seconds
- gain - volume, value from 0 to 1
- day - track will be played at day
- night - track will be played at night
- ymin - minimum elevation for track to play
- ymax - maximum elevation for track to play

## Content
Default pack features 24 tracks from composer Kevin McLeod. Tracks are split into following categories: surface at  day, surface at night, near underground, medium underground and deep underground. Underground music plays based on height, independently from daytime. Underground height limits are set according to layer levels of [dfcaverns](https://github.com/FaceDeer/dfcaverns/) by FaceDeer. Music is also selected according to layer feel.

## License

Code is licensed under GPLv3.  

All music used in this mod was produced by Kevin McLeod and released under CC BY 4.0. [link to the license](https://creativecommons.org/licenses/by/4.0/).  
Original music can be found [here](https://incompetech.com/music/royalty-free/music.html).