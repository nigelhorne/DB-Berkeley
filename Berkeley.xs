#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <db.h>
#include <string.h>

/* Define internal struct to hold DB handle */
typedef struct {
    DB *dbp;
} Berk;

/* Helper C function to open a Berkeley DB */
static DB *
_bdb_open(const char *file, u_int32_t flags, int mode) {
    DB *dbp;
    int ret;

    if ((ret = db_create(&dbp, NULL, 0)) != 0) {
        croak("db_create failed: %s", db_strerror(ret));
    }

    if ((ret = dbp->open(dbp, NULL, file, NULL, DB_HASH, flags | DB_CREATE, mode)) != 0) {
        int err = ret;
        dbp->close(dbp, 0);
        croak("DB->open('%s') failed: %s", file, db_strerror(err));
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
{
    if (mode == 0)
        mode = 0666;

    dbp = _bdb_open(file, flags, mode);

    obj = (Berk *)malloc(sizeof(Berk));
    if (!obj) {
        dbp->close(dbp, 0);
        croak("Out of memory");
    }
    obj->dbp = dbp;

    ret_sv = sv_setref_pv(newSV(0), class, (void *)obj);
    RETVAL = ret_sv;
}
OUTPUT:
    RETVAL

int
put(self, key, value)
    SV *self
    SV *key
    SV *value
PREINIT:
    Berk *obj;
    DB *dbp;
    DBT k, v;
    char *kptr, *vptr;
    STRLEN klen, vlen;
    int ret;
CODE:
{
    obj = (Berk *)SvIV(SvRV(self));
    dbp = obj->dbp;

    kptr = SvPV(key, klen);
    vptr = SvPV(value, vlen);

    memset(&k, 0, sizeof(DBT));
    k.data = kptr;
    k.size = klen;

    memset(&v, 0, sizeof(DBT));
    v.data = vptr;
    v.size = vlen;

    ret = dbp->put(dbp, NULL, &k, &v, 0);
    if (ret != 0) {
        croak("DB->put error: %s", db_strerror(ret));
    }
    RETVAL = 1;
}
OUTPUT:
    RETVAL

SV *
get(self, key)
    SV *self
    SV *key
PREINIT:
    Berk *obj;
    DB *dbp;
    DBT k, v;
    char *kptr;
    STRLEN klen;
    int ret;
CODE:
{
    obj = (Berk *)SvIV(SvRV(self));
    dbp = obj->dbp;

    kptr = SvPV(key, klen);

    memset(&k, 0, sizeof(DBT));
    k.data = kptr;
    k.size = klen;

    memset(&v, 0, sizeof(DBT));
    v.flags = DB_DBT_MALLOC;

    ret = dbp->get(dbp, NULL, &k, &v, 0);
    if (ret == DB_NOTFOUND) {
        RETVAL = &PL_sv_undef;
    } else if (ret != 0) {
        croak("DB->get error: %s", db_strerror(ret));
    } else {
        RETVAL = newSVpvn((char *)v.data, v.size);
        free(v.data);
    }
}
OUTPUT:
    RETVAL

void
DESTROY(self)
    SV *self
PREINIT:
    Berk *obj;
CODE:
{
    obj = (Berk *)SvIV(SvRV(self));
    if (obj) {
        if (obj->dbp) {
            obj->dbp->close(obj->dbp, 0);
        }
        free(obj);
    }
}
