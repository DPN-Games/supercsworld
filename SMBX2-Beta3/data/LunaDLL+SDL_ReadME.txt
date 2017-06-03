This is a special LunaDLL build.

It fully replacing default SMBX audio engine with SDL2_mixer library.
All musics and sounds will be played through SDL2_mixer library.

========================================================================================
Comparison of default SMBX's MCI audio engine and SDL2_mixer library:

Default MCI:
- Floods system tray with codec icons
- Loading slow
- Between loops you will hear clicks
- Supported formats: MP3, WAV and buggy playback of MID

SDL2_Mixer:
- Supported built-in formats: MP3, WAV, MID, OGG, FLAC, MOD, IT, XX, S3M, etc...
- Will prevent flood of system tray because SDL Mixer play all sounds and musics with built-in decoders!
- Almost instant music/sound loading!
- Faster and better sound playback
- Starting of music playback is faster!
- True and clean loop: you will don't hear clicks between loops if your sound have connected waves on edges
- We have able to implement customization of sounds and musics stuff through LunaDLL without replacing of default content and without re-hexing of smbx.exe!
- SMBX summary will starts FASTER!
- Now you can CUSTOMIZE DEFAULT MUSICS AND SOUNDS by EACH EPISODE!

Restrictions:
========================================================================================
- You should convert all .MP3 sound effects into .OGG format (put your .ogg files into /sounds dir of SMBX, you can remove old .mp3 stuff, but save them just in case. LunaDLL+SDL will play .OGG sounds instead of original .MP3's).
- All your musics should have 44100 sample rate or you will hear dirty noise. You should re-sample your musics into 44100 Hz. (SDL's real-time re-sampler is buggy yet.). Why? Because SDL mixer plays all sounds and musics in the united stream and all tracks should have a uniform sample rate (SDL trying to re-sample them if they have sample rate which is not equal to sample rate of stream, but this is not giving guaranties for good playback).


sounds.ini and music.ini
========================================================================================
There are a special files which redefining music and sounds paths. You can just put them into SMBX root with sound and music fodlers
or you can insert them into your episode (you don't need to customize complete stuff, you can just replace only necessary).

Episode tree:
/--MyEpisode
-|--Folder of musics
-------musicfile1.mp3
-------musicfile2.ogg
-------musicfile3.mid
-------musicfile4.it
-------...
-------...
----music.ini
----sounds.ini

In the INI-file all path relative to EPISODE ROOT: If put musics into subfolder "My Music", you should define paths:
....
file="My Music/myfile.ogg"
....

Same rule for sounds.ini!

In the "_ini_examples" folder you can take examples of INI-files redefinign of music and sounds stuff.





Additional LUA functions (can be used with 'onLoop' event, they are not work with 'onLoad'):
========================================================================================
----------------------------------------------------------------------------------------
playSFXSDL(string soundFile);
	-- This function will play your sound effect (supports WAV, OGG, FLAC)

clearSFXBuffer();
	-- This function will clear buffer of sounds which was loaded some times ago.


Custom musics: With SDL-mixer library we got able have multiple custom musics in one section!
----------------------------------------------------------------------------------------
MusicOpen(string musicFile);
	-- This function load music file into stream (supports WAV, MP3, OGG, FLAC, MID, MOD, XM, IT, S3M, etc...)
	-- Note: current music of section should be switched to "None"

MusicPlay();
	-- Starts playback of stream (will be played file which was loaded into stream)

MusicPlayFadeIn(int ms);
	-- Starts playback of current music file in stream with fade-IN effect (argument - fade effect lenght in milliseconds)
	-- Note: this function may not work and music will starts normally

MusicStop();
	-- Stops playback of music stream;

MusicStopFadeOut(int ms);
	-- Stops playback of current music file in stream with fade-out effect (argument - fade effect lenght in milliseconds)

MusicVolume(int volume)
	-- Sets global volume of music stream. Range is 0....128

bool MusicIsPlaying()
	-- Returns true if music currently is playing

bool MusicIsPaused()
	-- Returns true if music currently paused but not halted

bool MusicIsFading()
	-- Returns true if music currently fading in or out

