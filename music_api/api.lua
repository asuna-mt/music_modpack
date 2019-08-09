music = {}
local players = {}
local tracks = {}
local timer = 0

local time_interval = minetest.settings:get("music_time_interval") or 300
local synchronized_music = minetest.settings:get("music_synchronized") or false
local global_gain = minetest.settings:get("music_global_gain") or 0.35
local add_random_delay = minetest.settings:get("music_add_random_delay") or false
local maximum_random_delay = minetest.settings:get("music_maximum_random_delay") or 60
local display_playback_messages = minetest.settings:get("music_display_playback_messages") or false

local global_previous = ""
local random_delay = 0

--Initialize random delay on the first run
if add_random_delay then
    random_delay = math.random(maximum_random_delay)
end

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    players[name] = {playing=false, previous=""}
    end
)

minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    players[name] = nil
    end
)

function music.register_track(def)

    if def.name == nil or def.length == nil then
        print("Missing track definition parameters!")
        return
    end

    local track_def = {
        name = def.name,
        length = def.length,
        gain = def.gain or 1,
        day = def.day or false,
        night = def.night or false,
        ymin = def.ymin or -31000,
        ymax = def.ymax or 31000,
    }

    table.insert(tracks, track_def)
end

local function reset_player_cooldown(player)
    if players[player] ~= nil then
        players[player].playing = false
    end
end

minetest.register_globalstep(function(dtime)

    --Increment timer, return if it doesn't, reset it if it does and continue with function execution
    timer = timer + dtime
    if timer < time_interval + random_delay then return end
    timer = 0

    --Return if no tracks are defined
    if next(tracks) == nil then return end

    local time = minetest.get_timeofday()

    --Synchronized music played to all players at the same time
    if synchronized_music then

        --Create a list of music that fits the criteria
        local possible_tracks = {}
        for _,track in pairs(tracks) do
            if track.name ~= global_previous and ((track.day and time > 0.25 and time < 0.75) or (track.night and time < 0.25 and time > 0.75)) then
                table.insert(possible_tracks, track)
            end
        end    if add_random_delay then
        previous_delay = math.random(maximum_random_delay)
    end

        --Return if no music fits
        if #possible_tracks == 0 then
            global_previous = ""
            return
        end

        --Select random track from fitting ones
        local track = possible_tracks[math.random(#possible_tracks)]

        --Play it to all players, and set playing flags and cooldown timers
        for k,v in pairs(players) do
            if not v.playing then
                minetest.sound_play(track.name, {to_player = k, gain = track.gain * global_gain})
                v.playing = true
                minetest.after(track.length, reset_player_cooldown, k)
            end
        end

        --Set track as previous to avoid repeating it twice
        global_previous = track.name

    --Personalized playback depending on player surroundings (height)
    else

        --Play music for every player
        for k,v in pairs(players) do
            local player = minetest.get_player_by_name(k)
            local player_pos = player:get_pos()
            local possible_tracks = {}

            --Assemble list of fitting tracks
            for _,track in pairs(tracks) do
                if track.name ~= v.previous and ((track.day and time > 0.25 and time < 0.75) or (track.night and ((time < 0.25 and time >= 0) or (time > 0.75 and time <= 1)))) and
                player_pos.y >= track.ymin and player_pos.y < track.ymax then
                    table.insert(possible_tracks, track)
                end
            end

            --Return if no music fits
            if #possible_tracks == 0 then
                v.previous = ""
                return
            end

            --Select random track from fitting
            local track = possible_tracks[math.random(#possible_tracks)]

            --Start playback
            if not v.playing then
                if display_playback_messages then
                    print("[Music API]: Starting playblack for:", k, track.name, "Available tracks for user:", #possible_tracks, "Random delay:", random_delay)
                end
                minetest.sound_play(track.name, {to_player = k, gain = track.gain * global_gain})
                v.playing = true
                v.previous = track.name
                minetest.after(track.length, reset_player_cooldown, k)
            end
        end
    end

    --Change random delay if enabled on each play attempt
    if add_random_delay then
        random_delay = math.random(maximum_random_delay)
    end
end
)
