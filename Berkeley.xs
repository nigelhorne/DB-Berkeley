#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <db.h>

typedef struct {
    DB *dbp;
} DB_Berkeley;

MODULE = DB::Berkeley  PACKAGE = DB::Berkeley

DB_Berkeley *
_open(filename, flags, mode)
    char *filename
    int flags
    int mode
PREINIT:
    DB *dbp;
    int ret;
    DB_Berkeley *handle;
CODE:
    ret = db_create(&dbp, NULL, 0);
    if (ret != 0)
        croak("db_create failed: %s", db_strerror(ret));

    ret = dbp->open(dbp, NULL, filename, NULL, DB_HASH, flags, mode);
    if (ret != 0)
        croak("db->open failed: %s", db_strerror(ret));

    Newxz(handle, 1, DB_Berkeley);
    handle->dbp = dbp;
    RETVAL = handle;
OUTPUT:
    RETVAL

void
DESTROY(self)
    DB_Berkeley *self
CODE:
    if (self->dbp) {
        self->dbp->close(self->dbp, 0);
        self->dbp = NULL;
    }
    Safefree(self);

int
put(self, key, value)
    DB_Berkeley *self
    SV *key
    SV *value
PREINIT:
    DBT k, v;
    STRLEN klen, vlen;
    char *kptr = SvPV(key, klen);
    char *vptr = SvPV(value, vlen);
CODE:
    memset(&k, 0, sizeof(k));
    memset(&v, 0, sizeof(v));
    k.data = kptr;
    k.size = klen;
    v.data = vptr;
    v.size = vlen;

    RETVAL = self->dbp->put(self->dbp, NULL, &k, &v, 0);
OUTPUT:
    RETVAL

SV *
get(self, key)
    DB_Berkeley *self
    SV *key
PREINIT:
    DBT k, v;
    STRLEN klen;
    char *kptr = SvPV(key, klen);
    int ret;
CODE:
    memset(&k, 0, sizeof(k));
    memset(&v, 0, sizeof(v));
    k.data = kptr;
    k.size = klen;

    ret = self->dbp->get(self->dbp, NULL, &k, &v, 0);
    if (ret == DB_NOTFOUND) {
        RETVAL = &PL_sv_undef;
    } else if (ret != 0) {
        croak("get failed: %s", db_strerror(ret));
    } else {
        RETVAL = newSVpvn(v.data, v.size);
    }
OUTPUT:
    RETVAL

int
delete(self, key)
    DB_Berkeley *self
    SV *key
PREINIT:
    DBT k;
    STRLEN klen;
    char *kptr = SvPV(key, klen);
CODE:
    memset(&k, 0, sizeof(k));
    k.data = kptr;
    k.size = klen;

    RETVAL = self->dbp->del(self->dbp, NULL, &k, 0);
OUTPUT:
    RETVAL
