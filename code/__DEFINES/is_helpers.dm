#define in_range(source, user) (get_dist(source, user) <= 1 && (get_step(source, 0)?:z) == (get_step(user, 0)?:z))
#define isatom(A) istype(A, /atom)
#define ismovableatom(A) istype(A, /atom/movable)
#define isclient(A) istype(A, /client)
#define islist(A) istype(A, /list)
#define isopenspace(A) istype(A, /turf/simulated/open)
#define isliving(A) istype(A, /mob/living)
#define isitem(A) istype(A, /obj/item)

#define isadmin(A) (A in GLOB.admins)
