/* File: magic.ml

   Copyright (C) 2005

     Christophe Troestler
     email: Christophe.Troestler@umh.ac.be
     WWW: http://www.umh.ac.be/math/an/software/

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public License
   version 2.1 as published by the Free Software Foundation, with the
   special exception on linking described in file LICENSE.

   This library is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the file
   LICENSE for more details.
*/
/* 	$Id: magic_stub.c,v 1.1.1.1 2005/01/24 17:28:38 chris_77 Exp $	 */

#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/custom.h>
#include <caml/fail.h>
#include <caml/callback.h>

#include <magic.h>
#include <errno.h>
#include <string.h>

#define CAML_MAGIC_VERSION "0.1"

/*
 * Failure
 */

static void raise_failure(const char * msg)
{
  static value * exn = NULL;
  if (exn == NULL) exn = caml_named_value("Magic.Failure");
  raise_with_string(*exn, (char *) msg);
}


/*
 * magic_t
 */

#define COOKIE_VAL(v) (* ((magic_t *) Data_custom_val(v)))

/* If the cookie has not been forcibly closed with [magic_close], free it. */
static void free_cookie(value c)
{
  magic_t cookie = COOKIE_VAL(c);
  if (cookie != NULL) magic_close(cookie);
}

static int compare_cookie(value c1, value c2)
{
  if (COOKIE_VAL(c1) == COOKIE_VAL(c2))      return 0;
  else if (COOKIE_VAL(c1) < COOKIE_VAL(c2))  return -1;
  else return 1;
}

static struct custom_operations cookie_ops = {
    /* identifier */ "magic/CAMLinterface/" CAML_MAGIC_VERSION,
    /* finalize */ free_cookie,
    /* compare */ compare_cookie,
    /* hash */ custom_hash_default,
    /* serialize */ custom_serialize_default,
    /* deserialize */ custom_deserialize_default
};

#define ALLOC_COOKIE alloc_custom(&cookie_ops, sizeof(magic_t),  \
                     sizeof(magic_t), 20 * sizeof(magic_t))

/*
 * Stubs
 */

CAMLprim
value magic_open_stub(value flags)
{
  CAMLparam1(flags);
  CAMLlocal1(c);
  char *errmsg; /* For thread safety of error messages */
  int len = 80; /* Initial buffer length */

  c = ALLOC_COOKIE;
  if ((COOKIE_VAL(c) = magic_open(Int_val(flags))) == NULL) {
    if (errno == EINVAL)
      raise_failure("Magic.create: Preserve_atime not supported");
    else {
      /* Allocate buffer [errmsg] until there is enough space for the
       * error message. */
      errmsg = malloc(len);
      strcpy(errmsg, "Magic.create: "); /* 14 chars */
      while (strerror_r(errno, errmsg + 14, len - 14) < 0) {
        len *= 2;
        realloc(errmsg, len);
      }
      raise_failure(errmsg);
    }
  }
  CAMLreturn(c);
}

CAMLprim
value magic_close_stub(value c)
{
  CAMLparam1(c);
  magic_t cookie = COOKIE_VAL(c);
  if (cookie != NULL) /* if first time it is called */
    magic_close(cookie);
  COOKIE_VAL(c) = NULL; /* For the finalization function & multiple calls */
  CAMLreturn(Val_unit);
}


CAMLprim
value magic_file_stub(value c, value fname)
{
  CAMLparam2(c, fname);
  const char * ans;
  magic_t cookie = COOKIE_VAL(c);

  if (cookie == NULL) caml_invalid_argument("Magic.file");
  if ((ans = magic_file(cookie, String_val(fname))) == NULL)
    raise_failure(magic_error(cookie));
  CAMLreturn(copy_string(ans));
}

CAMLprim
value magic_buffer_stub(value c, value buf)
{
  CAMLparam2(c, buf);
  const char * ans;
  magic_t cookie = COOKIE_VAL(c);

  if (cookie == NULL) caml_invalid_argument("Magic.buffer");
  if ((ans = magic_buffer(cookie, String_val(buf), string_length(buf)))
      == NULL)
    raise_failure(magic_error(cookie));
  CAMLreturn(copy_string(ans));
}


CAMLprim
value magic_setflags_stub(value c, value flags)
{
  CAMLparam2(c, flags);
  magic_t cookie = COOKIE_VAL(c);

  if (cookie == NULL) caml_invalid_argument("Magic.setflags");
  if (magic_setflags(cookie, Int_val(flags)) < 0)
    raise_failure("Magic.setflags: Preserve_atime not supported");
  CAMLreturn(Val_unit);
}



#define CHECK(fname) \
  magic_t cookie = COOKIE_VAL(c); \
  \
  if (cookie == NULL) caml_invalid_argument("Magic.check"); \
  if (magic_check(cookie, fname) < 0) \
    CAMLreturn(Val_false); \
  else \
    CAMLreturn(Val_true)

CAMLprim
value magic_check_default_stub(value c)
{
  CAMLparam1(c);
  CHECK(NULL);
}
CAMLprim
value magic_check_stub(value c, value filenames)
{
  CAMLparam2(c, filenames);
  CHECK(String_val(filenames));
}



#define COMPILE(fname) \
  magic_t cookie = COOKIE_VAL(c); \
  \
  if (cookie == NULL) caml_invalid_argument("Magic.compile"); \
  if (magic_compile(cookie, fname) < 0) \
    raise_failure(magic_error(cookie)); \
  CAMLreturn(Val_unit)

CAMLprim
value magic_compile_default_stub(value c)
{
  CAMLparam1(c);
  COMPILE(NULL);
}

CAMLprim
value magic_compile_stub(value c, value filenames)
{
  CAMLparam2(c, filenames);
  COMPILE(String_val(filenames));
}



#define LOAD(fname) \
  magic_t cookie = COOKIE_VAL(c); \
  \
  if (cookie == NULL) caml_invalid_argument("Magic.load"); \
  if (magic_load(cookie, fname) < 0) \
    raise_failure(magic_error(cookie)); \
  CAMLreturn(Val_unit)

CAMLprim
value magic_load_default_stub(value c)
{
  CAMLparam1(c);
  LOAD(NULL);
}

CAMLprim
value magic_load_stub(value c, value filenames)
{
  CAMLparam2(c, filenames);
  LOAD(String_val(filenames));
}

