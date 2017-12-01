#define ismovableatom(A) istype(A, /atom/movable)
#define isclient(A) istype(A, /client)
#define islist(A) istype(A, /list)
#define isopenspace(A) istype(A, /turf/simulated/open)
#define isliving(A) istype(A, /mob/living)

#define isadmin(A) (A in GLOB.admins)