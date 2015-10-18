/**
 * Startup hook.
 * Called in world.dm when the server starts.
 */
/hook/startup

/**
 * First-time client login hook.
 * Called in /mob/login.dm when loc is null; Mobs do not qdel, so their loc should only be null if they are being spawned by normal BYOND systems. In theory.
 */
/hook/clientNewLogin