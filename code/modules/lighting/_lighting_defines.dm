//#define LIGHTING_INSTANT_UPDATES // Comment out to use an interval-based update scheduler.

#ifndef LIGHTING_INSTANT_UPDATES
#define LIGHTING_INTERVAL   5   // Frequency, in 1/10ths of a second, of the lighting process.
#include "lighting_process.dm"
#endif

#define LIGHTING_FALLOFF    1   // Type of falloff to use for lighting; 1 for circular, 2 for square.
#define LIGHTING_LAMBERTIAN 0   // Use lambertian shading for light sources.
#define LIGHTING_HEIGHT     1   // Height off the ground of light sources on the pseudo-z-axis, you should probably leave this alone.

#define LIGHTING_LAYER      10  // Drawing layer for lighting overlays.

#define INVISIBILITY_LIGHTING 20

// If I were you I'd leave this alone.
#define LIGHTING_BASE_MATRIX \
	list                     \
	(                        \
		0, 0, 0, 0,          \
		0, 0, 0, 0,          \
		0, 0, 0, 0,          \
		0, 0, 0, 0,          \
		0, 0, 0, 1           \
	)                        \

// Helpers so we can (more easily) control the colour matrices.
#define RR 1
#define RG 2
#define RB 3
#define RA 4
#define GR 5
#define GG 6
#define GB 7
#define GA 8
#define BR 9
#define BG 10
#define BB 11
#define BA 12
#define AR 13
#define AG 14
#define AB 15
#define AA 16
#define CR 17
#define CG 18
#define CB 19
#define CA 20
