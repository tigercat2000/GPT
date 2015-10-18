/*

	Cinematic Test Map

*/

#if !defined(LOADED_MAP)

    #include "map_files\cine\z1.dmm"
    #include "map_files\cine\cine_intro.dm"
    #include "map_files\cine\cine_mobs.dm"

    #define LOADED_MAP "Cine"

#else

    #warn A map has already been included, ignoring Cinematic

#endif