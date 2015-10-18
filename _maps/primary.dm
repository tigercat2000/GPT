/*

	Primary Map

*/

#if !defined(LOADED_MAP)

    #include "map_files\primary\z1.dmm"
    #include "map_files\primary\primary_intro.dm"

    #define LOADED_MAP "Primary"

#else

    #warn A map has already been included, ignoring Primary

#endif