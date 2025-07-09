#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <db.h>
#include <string.h>

/* 
 * Internal C struct to wrap a Berkeley DB handle.
 * We'll store a pointer to this inside a Perl scalar reference.
 */
typedef struct {
    DB *dbp;  // Pointer to Berkeley DB handle
} Berk;

/*
 * Helper function to open a Berkeley DB file as a HASH.
 * Takes filename, flags, and mode.
 * Dies (croaks) on failure.
 */
static DB *
_bdb_open(const char *file, u_int32_t flags, int mode) {
    DB *dbp;
    int ret;

    // Create the database handle
    ret = db_create(&dbp, NULL, 0);
    if (ret != 0) {
        croak("db_create failed: %s", db_strerror(ret));
    }

    // Open the database file as a HASH type
    ret = dbp->open(dbp, NULL, file, NULL, DB_HASH, flags | DB_CREATE, mode);
    if (ret != 0) {
        dbp->close(dbp, 0);
        croak("db->open failed: %s", db_strerror(ret));
    }

    return dbp;
}

MODULE = DB::Berkeley    PACKAGE = DB::Berkeley
PROTOTYPES: ENABLE

SV *
new(class, file, flags, mode)
    char *class
    char *file
    int flags
    int mode
PREINIT:
    Berk *obj;
    DB *dbp;
    SV *ret_sv;
CODE:

    // Use default file mode if not specified
    if (mode == 0)
        mode = 0666;

    dbp = _bdb_open(file, flags, mode);  // Open Berkeley DB file

    obj = (Berk *)malloc(sizeof(Berk));
    if (!obj) {
        dbp->close(dbp, 0);
        croak("Out of memory");
    }
    obj->dbp = dbp;

    // Bless the object reference
    ret_sv = sv_setref_pv(newSV(0), class, (void *)obj);
    RETVAL = ret_sv;
OUTPUT:
    RETVAL

int
put(self, key, value)
    SV *self
    SV *key
    SV *value
PREINIT:
    Berk *obj;
    DBT k, v;
    char *kptr, *vptr;
    STRLEN klen, vlen;
    int ret;
CODE:
    obj = (Berk *)SvIV(SvRV(self));  // Extract the Berk* from the Perl object

    kptr = SvPV(key, klen);   // Get raw key bytes
    vptr = SvPV(value, vlen); // Get raw value bytes

    memset(&k, 0, sizeof(DBT));
    k.data = kptr;
    k.size = klen;

    memset(&v, 0, sizeof(DBT));
    v.data = vptr;
    v.size = vlen;

    ret = obj->dbp->put(obj->dbp, NULL, &k, &v, 0);  // Perform DB->put
    if (ret != 0) {
        croak("db->put failed: %s", db_strerror(ret));
    }

    RETVAL = 1;
OUTPUT:
    RETVAL

SV *
get(self, key)
    SV *self
    SV *key
PREINIT:
    Berk *obj;
    DBT k, v;
    char *kptr;
    STRLEN klen;
    int ret;
CODE:
    obj = (Berk *)SvIV(SvRV(self));

    kptr = SvPV(key, klen);  // Extract raw key string

    memset(&k, 0, sizeof(DBT));
    k.data = kptr;
    k.size = klen;

    memset(&v, 0, sizeof(DBT));
    v.flags = DB_DBT_MALLOC;  // Let DB allocate value buffer

    ret = obj->dbp->get(obj->dbp, NULL, &k, &v, 0);  // Perform DB->get
    if (ret == DB_NOTFOUND) {
        RETVAL = &PL_sv_undef;
    } else if (ret != 0) {
        croak("db->get failed: %s", db_strerror(ret));
    } else {
        RETVAL = newSVpvn((char *)v.data, v.size);  // Return as Perl scalar
        free(v.data);
    }
OUTPUT:
    RETVAL

void
DESTROY(self)
    SV *self
PREINIT:
    Berk *obj;
CODE:
    obj = (Berk *)SvIV(SvRV(self));
    if (obj) {
        if (obj->dbp) {
            obj->dbp->close(obj->dbp, 0);  // Close DB handle
        }
        free(obj);  // Free the struct
    }
