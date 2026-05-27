/*
 * QuickJS Javascript Engine
 *
 * Copyright (c) 2017-2026 Fabrice Bellard
 * Copyright (c) 2017-2024 Charlie Gordon
 * Copyright (c) 2023-2026 Ben Noordhuis
 * Copyright (c) 2023-2026 Saúl Ibarra Corretgé
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package odin_quickjs

import "core:c"

foreign import lib "./linux/libquickjs.a"
_ :: lib

QUICKJS_NG            :: 1
QUICKJS_NG_CC_GNULIKE :: 1

JSRuntime :: struct {}
JSContext :: struct {}
JSObject  :: struct {}
JSClass   :: struct {}
JSClassID :: u32
JSAtom    :: u32

JS_TAG_BIG_INT           :: -9
JS_TAG_FIRST             :: -9
JS_TAG_STRING_ROPE       :: -6
JS_TAG_MODULE            :: -3
JS_TAG_FUNCTION_BYTECODE :: -2
JS_TAG_OBJECT            :: -1
JS_TAG_INT               :: 0
JS_TAG_BOOL              :: 1
JS_TAG_NULL              :: 2
JS_TAG_UNDEFINED         :: 3
JS_TAG_UNINITIALIZED     :: 4
JS_TAG_SYMBOL            :: -8
JS_TAG_STRING            :: -7
JS_TAG_CATCH_OFFSET      :: 5
JS_TAG_SHORT_BIG_INT     :: 7
JS_TAG_EXCEPTION         :: 6
JS_TAG_FLOAT64           :: 8
JSValueConst             :: JSValue

JSValueUnion :: struct #raw_union {
	int32:         i32,
	float64:       f64,
	ptr:           rawptr,
	short_big_int: i32,
}

JSValue :: struct {
	u:   JSValueUnion,
	tag: i64,
}

/* flags for object properties */
JS_PROP_CONFIGURABLE  :: (1<<0)
JS_PROP_WRITABLE      :: (1<<1)
JS_PROP_ENUMERABLE    :: (1<<2)
JS_PROP_C_W_E         :: (JS_PROP_CONFIGURABLE|JS_PROP_WRITABLE|JS_PROP_ENUMERABLE)
JS_PROP_LENGTH        :: (1<<3)  /* used internally in Arrays */
JS_PROP_TMASK         :: (3<<4)  /* mask for NORMAL, GETSET, VARREF, AUTOINIT */
JS_PROP_NORMAL         :: (0<<4)
JS_PROP_GETSET         :: (1<<4)
JS_PROP_VARREF         :: (2<<4) /* used internally */
JS_PROP_AUTOINIT       :: (3<<4) /* used internally */

/* flags for JS_DefineProperty */
JS_PROP_HAS_SHIFT        :: 8
JS_PROP_HAS_CONFIGURABLE :: (1<<8)
JS_PROP_HAS_WRITABLE     :: (1<<9)
JS_PROP_HAS_ENUMERABLE   :: (1<<10)
JS_PROP_HAS_GET          :: (1<<11)
JS_PROP_HAS_SET          :: (1<<12)
JS_PROP_HAS_VALUE        :: (1<<13)

/* throw an exception if false would be returned
(JS_DefineProperty/JS_SetProperty) */
JS_PROP_THROW            :: (1<<14)

/* throw an exception if false would be returned in strict mode
(JS_SetProperty) */
JS_PROP_THROW_STRICT            :: (1<<15)
JS_PROP_NO_ADD                  :: (1<<16) /* internal use */
JS_PROP_NO_EXOTIC               :: (1<<17) /* internal use */
JS_PROP_DEFINE_PROPERTY         :: (1<<18) /* internal use */
JS_PROP_REFLECT_DEFINE_PROPERTY :: (1<<19) /* internal use */
JS_DEFAULT_STACK_SIZE           :: (1024*1024)

/* JS_Eval() flags */
JS_EVAL_TYPE_GLOBAL   :: (0<<0) /* global code (default) */
JS_EVAL_TYPE_MODULE   :: (1<<0) /* module code */
JS_EVAL_TYPE_DIRECT   :: (2<<0) /* direct call (internal use) */
JS_EVAL_TYPE_INDIRECT :: (3<<0) /* indirect call (internal use) */
JS_EVAL_TYPE_MASK     :: (3<<0)
JS_EVAL_FLAG_STRICT   :: (1<<3) /* force 'strict' mode */
JS_EVAL_FLAG_UNUSED   :: (1<<4) /* unused */

/* compile but do not run. The result is an object with a
JS_TAG_FUNCTION_BYTECODE or JS_TAG_MODULE tag. It can be executed
with JS_EvalFunction(). */
JS_EVAL_FLAG_COMPILE_ONLY :: (1<<5)

/* don't include the stack frames before this eval in the Error() backtraces */
JS_EVAL_FLAG_BACKTRACE_BARRIER :: (1<<6)

/* allow top-level await in normal script. JS_Eval() returns a
promise. Only allowed with JS_EVAL_TYPE_GLOBAL */
JS_EVAL_FLAG_ASYNC :: (1<<7)

JSCFunction      :: proc "c" (ctx: ^JSContext, this_val: JSValue, argc: i32, argv: ^JSValue) -> JSValue
JSCFunctionMagic :: proc "c" (ctx: ^JSContext, this_val: JSValue, argc: i32, argv: ^JSValue, magic: i32) -> JSValue
JSCFunctionData  :: proc "c" (ctx: ^JSContext, this_val: JSValue, argc: i32, argv: ^JSValue, magic: i32, func_data: ^JSValue) -> JSValue
JSCClosure       :: proc "c" (ctx: ^JSContext, this_val: JSValue, argc: i32, argv: ^JSValue, magic: i32, opaque: rawptr) -> JSValue

JSMallocFunctions :: struct {
	js_calloc:             proc "c" (opaque: rawptr, count: c.size_t, size: c.size_t) -> rawptr,
	js_malloc:             proc "c" (opaque: rawptr, size: c.size_t) -> rawptr,
	js_free:               proc "c" (opaque: rawptr, ptr: rawptr),
	js_realloc:            proc "c" (opaque: rawptr, ptr: rawptr, size: c.size_t) -> rawptr,
	js_malloc_usable_size: proc "c" (ptr: rawptr) -> c.size_t,
}

// Debug trace system: the debug output will be produced to the dump stream (currently
// stdout) if dumps are enabled and JS_SetDumpFlags is invoked with the corresponding
// bit set.
JS_DUMP_BYTECODE_FINAL   :: 0x01     /* dump pass 3 final byte code */
JS_DUMP_BYTECODE_PASS2   :: 0x02     /* dump pass 2 code */
JS_DUMP_BYTECODE_PASS1   :: 0x04     /* dump pass 1 code */
JS_DUMP_BYTECODE_HEX     :: 0x10     /* dump bytecode in hex */
JS_DUMP_BYTECODE_PC2LINE :: 0x20     /* dump line number table */
JS_DUMP_BYTECODE_STACK   :: 0x40     /* dump compute_stack_size */
JS_DUMP_BYTECODE_STEP    :: 0x80     /* dump executed bytecode */
JS_DUMP_READ_OBJECT      :: 0x100    /* dump the marshalled objects at load time */
JS_DUMP_FREE             :: 0x200    /* dump every object free */
JS_DUMP_GC               :: 0x400    /* dump the occurrence of the automatic GC */
JS_DUMP_GC_FREE          :: 0x800    /* dump objects freed by the GC */
JS_DUMP_MODULE_RESOLVE   :: 0x1000   /* dump module resolution steps */
JS_DUMP_PROMISE          :: 0x2000   /* dump promise steps */
JS_DUMP_LEAKS            :: 0x4000   /* dump leaked objects and strings in JS_FreeRuntime */
JS_DUMP_ATOM_LEAKS       :: 0x8000   /* dump leaked atoms in JS_FreeRuntime */
JS_DUMP_MEM              :: 0x10000  /* dump memory usage in JS_FreeRuntime */
JS_DUMP_OBJECTS          :: 0x20000  /* dump objects in JS_FreeRuntime */
JS_DUMP_ATOMS            :: 0x40000  /* dump atoms in JS_FreeRuntime */
JS_DUMP_SHAPES           :: 0x80000  /* dump shapes in JS_FreeRuntime */
JS_ABORT_ON_LEAKS        :: 0x10C000  /* abort on atom/object/string leaks; for testing */

// Finalizers run in LIFO order at the very end of JS_FreeRuntime.
// Intended for cleanup of associated resources; the runtime itself
// is no longer usable.
JSRuntimeFinalizer :: proc "c" (rt: ^JSRuntime, arg: rawptr)
JSGCObjectHeader   :: struct {}

@(default_calling_convention="c")
foreign lib {
	JS_NewRuntime :: proc() -> ^JSRuntime ---

	/* info lifetime must exceed that of rt */
	JS_SetRuntimeInfo :: proc(rt: ^JSRuntime, info: cstring) ---

	/* use 0 to disable memory limit */
	JS_SetMemoryLimit :: proc(rt: ^JSRuntime, limit: c.size_t) ---
	JS_SetDumpFlags   :: proc(rt: ^JSRuntime, flags: u64) ---
	JS_GetDumpFlags   :: proc(rt: ^JSRuntime) -> u64 ---
	JS_GetGCThreshold :: proc(rt: ^JSRuntime) -> c.size_t ---
	JS_SetGCThreshold :: proc(rt: ^JSRuntime, gc_threshold: c.size_t) ---

	/* use 0 to disable maximum stack size check */
	JS_SetMaxStackSize :: proc(rt: ^JSRuntime, stack_size: c.size_t) ---

	/* should be called when changing thread to update the stack top value
	used to check stack overflow. */
	JS_UpdateStackTop      :: proc(rt: ^JSRuntime) ---
	JS_NewRuntime2         :: proc(mf: ^JSMallocFunctions, opaque: rawptr) -> ^JSRuntime ---
	JS_FreeRuntime         :: proc(rt: ^JSRuntime) ---
	JS_GetRuntimeOpaque    :: proc(rt: ^JSRuntime) -> rawptr ---
	JS_SetRuntimeOpaque    :: proc(rt: ^JSRuntime, opaque: rawptr) ---
	JS_AddRuntimeFinalizer :: proc(rt: ^JSRuntime, finalizer: JSRuntimeFinalizer, arg: rawptr) -> i32 ---
}

JS_MarkFunc :: proc "c" (rt: ^JSRuntime, gp: ^JSGCObjectHeader)

@(default_calling_convention="c")
foreign lib {
	JS_MarkValue        :: proc(rt: ^JSRuntime, val: JSValue, mark_func: JS_MarkFunc) ---
	JS_RunGC            :: proc(rt: ^JSRuntime) ---
	JS_IsLiveObject     :: proc(rt: ^JSRuntime, obj: JSValue) -> bool ---
	JS_NewContext       :: proc(rt: ^JSRuntime) -> ^JSContext ---
	JS_FreeContext      :: proc(s: ^JSContext) ---
	JS_DupContext       :: proc(ctx: ^JSContext) -> ^JSContext ---
	JS_GetContextOpaque :: proc(ctx: ^JSContext) -> rawptr ---
	JS_SetContextOpaque :: proc(ctx: ^JSContext, opaque: rawptr) ---
	JS_GetRuntime       :: proc(ctx: ^JSContext) -> ^JSRuntime ---
	JS_SetClassProto    :: proc(ctx: ^JSContext, class_id: JSClassID, obj: JSValue) ---
	JS_GetClassProto    :: proc(ctx: ^JSContext, class_id: JSClassID) -> JSValue ---
	JS_GetFunctionProto :: proc(ctx: ^JSContext) -> JSValue ---

	/* the following functions are used to select the intrinsic object to
	save memory */
	JS_NewContextRaw              :: proc(rt: ^JSRuntime) -> ^JSContext ---
	JS_AddIntrinsicBaseObjects    :: proc(ctx: ^JSContext) -> i32 ---
	JS_AddIntrinsicDate           :: proc(ctx: ^JSContext) -> i32 ---
	JS_AddIntrinsicEval           :: proc(ctx: ^JSContext) -> i32 ---
	JS_AddIntrinsicRegExpCompiler :: proc(ctx: ^JSContext) ---
	JS_AddIntrinsicRegExp         :: proc(ctx: ^JSContext) -> i32 ---
	JS_AddIntrinsicJSON           :: proc(ctx: ^JSContext) -> i32 ---
	JS_AddIntrinsicProxy          :: proc(ctx: ^JSContext) -> i32 ---
	JS_AddIntrinsicMapSet         :: proc(ctx: ^JSContext) -> i32 ---
	JS_AddIntrinsicTypedArrays    :: proc(ctx: ^JSContext) -> i32 ---
	JS_AddIntrinsicPromise        :: proc(ctx: ^JSContext) -> i32 ---
	JS_AddIntrinsicBigInt         :: proc(ctx: ^JSContext) -> i32 ---
	JS_AddIntrinsicWeakRef        :: proc(ctx: ^JSContext) -> i32 ---
	JS_AddPerformance             :: proc(ctx: ^JSContext) -> i32 ---
	JS_AddIntrinsicDOMException   :: proc(ctx: ^JSContext) -> i32 ---
	JS_AddIntrinsicAToB           :: proc(ctx: ^JSContext) -> i32 ---

	/* for equality comparisons and sameness */
	JS_IsEqual       :: proc(ctx: ^JSContext, op1: JSValue, op2: JSValue) -> i32 ---
	JS_IsStrictEqual :: proc(ctx: ^JSContext, op1: JSValue, op2: JSValue) -> bool ---
	JS_IsSameValue   :: proc(ctx: ^JSContext, op1: JSValue, op2: JSValue) -> bool ---

	/* Similar to same-value equality, but +0 and -0 are considered equal. */
	JS_IsSameValueZero :: proc(ctx: ^JSContext, op1: JSValue, op2: JSValue) -> bool ---

	/* Only used for running 262 tests. TODO(saghul) add build time flag. */
	js_string_codePointRange :: proc(ctx: ^JSContext, this_val: JSValue, argc: i32, argv: ^JSValue) -> JSValue ---
	js_calloc_rt             :: proc(rt: ^JSRuntime, count: c.size_t, size: c.size_t) -> rawptr ---
	js_malloc_rt             :: proc(rt: ^JSRuntime, size: c.size_t) -> rawptr ---
	js_free_rt               :: proc(rt: ^JSRuntime, ptr: rawptr) ---
	js_realloc_rt            :: proc(rt: ^JSRuntime, ptr: rawptr, size: c.size_t) -> rawptr ---
	js_malloc_usable_size_rt :: proc(rt: ^JSRuntime, ptr: rawptr) -> c.size_t ---
	js_mallocz_rt            :: proc(rt: ^JSRuntime, size: c.size_t) -> rawptr ---
	js_calloc                :: proc(ctx: ^JSContext, count: c.size_t, size: c.size_t) -> rawptr ---
	js_malloc                :: proc(ctx: ^JSContext, size: c.size_t) -> rawptr ---
	js_free                  :: proc(ctx: ^JSContext, ptr: rawptr) ---
	js_realloc               :: proc(ctx: ^JSContext, ptr: rawptr, size: c.size_t) -> rawptr ---
	js_malloc_usable_size    :: proc(ctx: ^JSContext, ptr: rawptr) -> c.size_t ---
	js_realloc2              :: proc(ctx: ^JSContext, ptr: rawptr, size: c.size_t, pslack: ^c.size_t) -> rawptr ---
	js_mallocz               :: proc(ctx: ^JSContext, size: c.size_t) -> rawptr ---
	js_strdup                :: proc(ctx: ^JSContext, str: cstring) -> cstring ---
	js_strndup               :: proc(ctx: ^JSContext, s: cstring, n: c.size_t) -> cstring ---
}

JSMemoryUsage :: struct {
	malloc_size, malloc_limit, memory_used_size:    i64,
	malloc_count:                                   i64,
	memory_used_count:                              i64,
	atom_count, atom_size:                          i64,
	str_count, str_size:                            i64,
	obj_count, obj_size:                            i64,
	prop_count, prop_size:                          i64,
	shape_count, shape_size:                        i64,
	js_func_count, js_func_size, js_func_code_size: i64,
	js_func_pc2line_count, js_func_pc2line_size:    i64,
	c_func_count, array_count:                      i64,
	fast_array_count, fast_array_elements:          i64,
	binary_object_count, binary_object_size:        i64,
}

@(default_calling_convention="c")
foreign lib {
	JS_ComputeMemoryUsage :: proc(rt: ^JSRuntime, s: ^JSMemoryUsage) ---
	JS_DumpMemoryUsage    :: proc(fp: rawptr, s: ^JSMemoryUsage, rt: ^JSRuntime) ---
}

/* atom support */
JS_ATOM_NULL :: 0

@(default_calling_convention="c")
foreign lib {
	JS_NewAtomLen       :: proc(ctx: ^JSContext, str: cstring, len: c.size_t) -> JSAtom ---
	JS_NewAtom          :: proc(ctx: ^JSContext, str: cstring) -> JSAtom ---
	JS_NewAtomUInt32    :: proc(ctx: ^JSContext, n: u32) -> JSAtom ---
	JS_DupAtom          :: proc(ctx: ^JSContext, v: JSAtom) -> JSAtom ---
	JS_DupAtomRT        :: proc(rt: ^JSRuntime, v: JSAtom) -> JSAtom ---
	JS_FreeAtom         :: proc(ctx: ^JSContext, v: JSAtom) ---
	JS_FreeAtomRT       :: proc(rt: ^JSRuntime, v: JSAtom) ---
	JS_AtomToValue      :: proc(ctx: ^JSContext, atom: JSAtom) -> JSValue ---
	JS_AtomToString     :: proc(ctx: ^JSContext, atom: JSAtom) -> JSValue ---
	JS_AtomToCStringLen :: proc(ctx: ^JSContext, plen: ^c.size_t, atom: JSAtom) -> cstring ---
	JS_ValueToAtom      :: proc(ctx: ^JSContext, val: JSValue) -> JSAtom ---
}

/* object class support */
JSPropertyEnum :: struct {
	is_enumerable: bool,
	atom:          JSAtom,
}

JSPropertyDescriptor :: struct {
	flags:  i32,
	value:  JSValue,
	getter: JSValue,
	setter: JSValue,
}

JSClassExoticMethods :: struct {
	/* Return -1 if exception (can only happen in case of Proxy object),
	false if the property does not exists, true if it exists. If 1 is
	returned, the property descriptor 'desc' is filled if != NULL. */
	get_own_property: proc "c" (ctx: ^JSContext, desc: ^JSPropertyDescriptor, obj: JSValue, prop: JSAtom) -> i32,

	/* '*ptab' should hold the '*plen' property keys. Return 0 if OK,
	-1 if exception. The 'is_enumerable' field is ignored.
	*/
	get_own_property_names: proc "c" (ctx: ^JSContext, ptab: ^^JSPropertyEnum, plen: ^u32, obj: JSValue) -> i32,

	/* return < 0 if exception, or true/false */
	delete_property: proc "c" (ctx: ^JSContext, obj: JSValue, prop: JSAtom) -> i32,

	/* return < 0 if exception or true/false */
	define_own_property: proc "c" (ctx: ^JSContext, this_obj: JSValue, prop: JSAtom, val: JSValue, getter: JSValue, setter: JSValue, flags: i32) -> i32,

	/* The following methods can be emulated with the previous ones,
	so they are usually not needed */
	/* return < 0 if exception or true/false */
	has_property: proc "c" (ctx: ^JSContext, obj: JSValue, atom: JSAtom) -> i32,
	get_property: proc "c" (ctx: ^JSContext, obj: JSValue, atom: JSAtom, receiver: JSValue) -> JSValue,

	/* return < 0 if exception or true/false */
	set_property: proc "c" (ctx: ^JSContext, obj: JSValue, atom: JSAtom, value: JSValue, receiver: JSValue, flags: i32) -> i32,
}

JSClassFinalizer :: proc "c" (rt: ^JSRuntime, val: JSValue)
JSClassGCMark    :: proc "c" (rt: ^JSRuntime, val: JSValue, mark_func: JS_MarkFunc)

JS_CALL_FLAG_CONSTRUCTOR :: (1<<0)

JSClassCall :: proc "c" (ctx: ^JSContext, func_obj: JSValue, this_val: JSValue, argc: i32, argv: ^JSValue, flags: i32) -> JSValue

JSClassDef :: struct {
	class_name: cstring, /* pure ASCII only! */
	finalizer:  JSClassFinalizer,
	gc_mark:    JSClassGCMark,

	/* if call != NULL, the object is a function. If (flags &
	JS_CALL_FLAG_CONSTRUCTOR) != 0, the function is called as a
	constructor. In this case, 'this_val' is new.target. A
	constructor call only happens if the object constructor bit is
	set (see JS_SetConstructorBit()). */
	call: JSClassCall,

	/* XXX: suppress this indirection ? It is here only to save memory
	because only a few classes need these methods */
	exotic: ^JSClassExoticMethods,
}

JS_EVAL_OPTIONS_VERSION :: 1

JSEvalOptions :: struct {
	version:    i32,
	eval_flags: i32,
	filename:   cstring,
	line_num:   i32,
}

JS_INVALID_CLASS_ID :: 0

@(default_calling_convention="c")
foreign lib {
	JS_NewClassID :: proc(rt: ^JSRuntime, pclass_id: ^JSClassID) -> JSClassID ---

	/* Returns the class ID if `v` is an object, otherwise returns JS_INVALID_CLASS_ID. */
	JS_GetClassID        :: proc(v: JSValue) -> JSClassID ---
	JS_NewClass          :: proc(rt: ^JSRuntime, class_id: JSClassID, class_def: ^JSClassDef) -> i32 ---
	JS_IsRegisteredClass :: proc(rt: ^JSRuntime, class_id: JSClassID) -> bool ---

	/* Returns the class name or JS_ATOM_NULL if `id` is not a registered class. Must be freed with JS_FreeAtom. */
	JS_GetClassName          :: proc(rt: ^JSRuntime, class_id: JSClassID) -> JSAtom ---
	JS_NewNumber             :: proc(ctx: ^JSContext, d: f64) -> JSValue ---
	JS_NewBigInt64           :: proc(ctx: ^JSContext, v: i64) -> JSValue ---
	JS_NewBigUint64          :: proc(ctx: ^JSContext, v: u64) -> JSValue ---
	JS_Throw                 :: proc(ctx: ^JSContext, obj: JSValue) -> JSValue ---
	JS_GetException          :: proc(ctx: ^JSContext) -> JSValue ---
	JS_HasException          :: proc(ctx: ^JSContext) -> bool ---
	JS_IsError               :: proc(val: JSValue) -> bool ---
	JS_IsUncatchableError    :: proc(val: JSValue) -> bool ---
	JS_SetUncatchableError   :: proc(ctx: ^JSContext, val: JSValue) ---
	JS_ClearUncatchableError :: proc(ctx: ^JSContext, val: JSValue) ---

	// Shorthand for:
	//  JSValue exc = JS_GetException(ctx);
	//  JS_ClearUncatchableError(ctx, exc);
	//  JS_Throw(ctx, exc);
	JS_ResetUncatchableError :: proc(ctx: ^JSContext) ---
	JS_NewError              :: proc(ctx: ^JSContext) -> JSValue ---
	JS_NewInternalError      :: proc(ctx: ^JSContext, fmt: cstring, #c_vararg _: ..any) -> JSValue ---
	JS_NewPlainError         :: proc(ctx: ^JSContext, fmt: cstring, #c_vararg _: ..any) -> JSValue ---
	JS_NewRangeError         :: proc(ctx: ^JSContext, fmt: cstring, #c_vararg _: ..any) -> JSValue ---
	JS_NewReferenceError     :: proc(ctx: ^JSContext, fmt: cstring, #c_vararg _: ..any) -> JSValue ---
	JS_NewSyntaxError        :: proc(ctx: ^JSContext, fmt: cstring, #c_vararg _: ..any) -> JSValue ---
	JS_NewTypeError          :: proc(ctx: ^JSContext, fmt: cstring, #c_vararg _: ..any) -> JSValue ---
	JS_ThrowInternalError    :: proc(ctx: ^JSContext, fmt: cstring, #c_vararg _: ..any) -> JSValue ---
	JS_ThrowPlainError       :: proc(ctx: ^JSContext, fmt: cstring, #c_vararg _: ..any) -> JSValue ---
	JS_ThrowRangeError       :: proc(ctx: ^JSContext, fmt: cstring, #c_vararg _: ..any) -> JSValue ---
	JS_ThrowReferenceError   :: proc(ctx: ^JSContext, fmt: cstring, #c_vararg _: ..any) -> JSValue ---
	JS_ThrowSyntaxError      :: proc(ctx: ^JSContext, fmt: cstring, #c_vararg _: ..any) -> JSValue ---
	JS_ThrowTypeError        :: proc(ctx: ^JSContext, fmt: cstring, #c_vararg _: ..any) -> JSValue ---
	JS_ThrowDOMException     :: proc(ctx: ^JSContext, name: cstring, fmt: cstring, #c_vararg _: ..any) -> JSValue ---
	JS_ThrowOutOfMemory      :: proc(ctx: ^JSContext) -> JSValue ---
	JS_FreeValue             :: proc(ctx: ^JSContext, v: JSValue) ---
	JS_FreeValueRT           :: proc(rt: ^JSRuntime, v: JSValue) ---
	JS_DupValue              :: proc(ctx: ^JSContext, v: JSValue) -> JSValue ---
	JS_DupValueRT            :: proc(rt: ^JSRuntime, v: JSValue) -> JSValue ---
	JS_ToBool                :: proc(ctx: ^JSContext, val: JSValue /* return -1 for JS_EXCEPTION */) -> i32 --- /* return -1 for JS_EXCEPTION */
	JS_ToNumber              :: proc(ctx: ^JSContext, val: JSValue) -> JSValue ---
	JS_ToInt32               :: proc(ctx: ^JSContext, pres: ^i32, val: JSValue) -> i32 ---
	JS_ToInt64               :: proc(ctx: ^JSContext, pres: ^i64, val: JSValue) -> i32 ---
	JS_ToIndex               :: proc(ctx: ^JSContext, plen: ^u64, val: JSValue) -> i32 ---
	JS_ToFloat64             :: proc(ctx: ^JSContext, pres: ^f64, val: JSValue) -> i32 ---

	/* return an exception if 'val' is a Number */
	JS_ToBigInt64  :: proc(ctx: ^JSContext, pres: ^i64, val: JSValue) -> i32 ---
	JS_ToBigUint64 :: proc(ctx: ^JSContext, pres: ^u64, val: JSValue) -> i32 ---

	/* same as JS_ToInt64() but allow BigInt */
	JS_ToInt64Ext   :: proc(ctx: ^JSContext, pres: ^i64, val: JSValue) -> i32 ---
	JS_NewStringLen :: proc(ctx: ^JSContext, str1: cstring, len1: c.size_t) -> JSValue ---

	// makes a copy of the input; does not check if the input is valid UTF-16,
	// that is the responsibility of the caller
	JS_NewStringUTF16 :: proc(ctx: ^JSContext, buf: ^u16, len: c.size_t) -> JSValue ---
	JS_NewAtomString  :: proc(ctx: ^JSContext, str: cstring) -> JSValue ---
	JS_ToString       :: proc(ctx: ^JSContext, val: JSValue) -> JSValue ---
	JS_ToPropertyKey  :: proc(ctx: ^JSContext, val: JSValue) -> JSValue ---
	JS_ToCStringLen2  :: proc(ctx: ^JSContext, plen: ^c.size_t, val1: JSValue, cesu8: bool) -> cstring ---

	// returns a utf-16 version of the string in native endianness; the
	// string is not nul terminated and can contain unmatched surrogates
	// |*plen| is in uint16s, not code points; a surrogate pair such as
	// U+D834 U+DF06 has len=2; an unmatched surrogate has len=1
	JS_ToCStringLenUTF16   :: proc(ctx: ^JSContext, plen: ^c.size_t, val1: JSValue) -> ^u16 ---
	JS_FreeCString         :: proc(ctx: ^JSContext, ptr: cstring) ---
	JS_FreeCStringRT       :: proc(rt: ^JSRuntime, ptr: cstring) ---
	JS_FreeCStringUTF16    :: proc(ctx: ^JSContext, ptr: ^u16) ---
	JS_FreeCStringRT_UTF16 :: proc(rt: ^JSRuntime, ptr: ^u16) ---
	JS_NewObjectProtoClass :: proc(ctx: ^JSContext, proto: JSValue, class_id: JSClassID) -> JSValue ---
	JS_NewObjectClass      :: proc(ctx: ^JSContext, class_id: JSClassID) -> JSValue ---
	JS_NewObjectProto      :: proc(ctx: ^JSContext, proto: JSValue) -> JSValue ---
	JS_NewObject           :: proc(ctx: ^JSContext) -> JSValue ---

	// takes ownership of the values
	JS_NewObjectFrom :: proc(ctx: ^JSContext, count: i32, props: ^JSAtom, values: ^JSValue) -> JSValue ---

	// takes ownership of the values
	JS_NewObjectFromStr  :: proc(ctx: ^JSContext, count: i32, props: ^cstring, values: ^JSValue) -> JSValue ---
	JS_ToObject          :: proc(ctx: ^JSContext, val: JSValue) -> JSValue ---
	JS_ToObjectString    :: proc(ctx: ^JSContext, val: JSValue) -> JSValue ---
	JS_IsFunction        :: proc(ctx: ^JSContext, val: JSValue) -> bool ---
	JS_IsAsyncFunction   :: proc(val: JSValue) -> bool ---
	JS_IsConstructor     :: proc(ctx: ^JSContext, val: JSValue) -> bool ---
	JS_SetConstructorBit :: proc(ctx: ^JSContext, func_obj: JSValue, val: bool) -> bool ---
	JS_IsRegExp          :: proc(val: JSValue) -> bool ---
	JS_IsMap             :: proc(val: JSValue) -> bool ---
	JS_IsSet             :: proc(val: JSValue) -> bool ---
	JS_IsWeakRef         :: proc(val: JSValue) -> bool ---
	JS_IsWeakSet         :: proc(val: JSValue) -> bool ---
	JS_IsWeakMap         :: proc(val: JSValue) -> bool ---
	JS_IsDataView        :: proc(val: JSValue) -> bool ---
	JS_NewArray          :: proc(ctx: ^JSContext) -> JSValue ---

	// takes ownership of the values
	JS_NewArrayFrom :: proc(ctx: ^JSContext, count: i32, values: ^JSValue) -> JSValue ---

	// reader beware: JS_IsArray used to "punch" through proxies and check
	// if the target object is an array but it no longer does; use JS_IsProxy
	// and JS_GetProxyTarget instead, and remember that the target itself can
	// also be a proxy, ad infinitum
	JS_IsArray           :: proc(val: JSValue) -> bool ---
	JS_IsProxy           :: proc(val: JSValue) -> bool ---
	JS_GetProxyTarget    :: proc(ctx: ^JSContext, proxy: JSValue) -> JSValue ---
	JS_GetProxyHandler   :: proc(ctx: ^JSContext, proxy: JSValue) -> JSValue ---
	JS_NewProxy          :: proc(ctx: ^JSContext, target: JSValue, handler: JSValue) -> JSValue ---
	JS_NewDate           :: proc(ctx: ^JSContext, epoch_ms: f64) -> JSValue ---
	JS_IsDate            :: proc(v: JSValue) -> bool ---
	JS_GetProperty       :: proc(ctx: ^JSContext, this_obj: JSValue, prop: JSAtom) -> JSValue ---
	JS_GetPropertyUint32 :: proc(ctx: ^JSContext, this_obj: JSValue, idx: u32) -> JSValue ---
	JS_GetPropertyInt64  :: proc(ctx: ^JSContext, this_obj: JSValue, idx: i64) -> JSValue ---
	JS_GetPropertyStr    :: proc(ctx: ^JSContext, this_obj: JSValue, prop: cstring) -> JSValue ---
	JS_SetProperty       :: proc(ctx: ^JSContext, this_obj: JSValue, prop: JSAtom, val: JSValue) -> i32 ---
	JS_SetPropertyUint32 :: proc(ctx: ^JSContext, this_obj: JSValue, idx: u32, val: JSValue) -> i32 ---
	JS_SetPropertyInt64  :: proc(ctx: ^JSContext, this_obj: JSValue, idx: i64, val: JSValue) -> i32 ---
	JS_SetPropertyStr    :: proc(ctx: ^JSContext, this_obj: JSValue, prop: cstring, val: JSValue) -> i32 ---
	JS_HasProperty       :: proc(ctx: ^JSContext, this_obj: JSValue, prop: JSAtom) -> i32 ---
	JS_IsExtensible      :: proc(ctx: ^JSContext, obj: JSValue) -> i32 ---
	JS_PreventExtensions :: proc(ctx: ^JSContext, obj: JSValue) -> i32 ---
	JS_DeleteProperty    :: proc(ctx: ^JSContext, obj: JSValue, prop: JSAtom, flags: i32) -> i32 ---
	JS_SetPrototype      :: proc(ctx: ^JSContext, obj: JSValue, proto_val: JSValue) -> i32 ---
	JS_GetPrototype      :: proc(ctx: ^JSContext, val: JSValue) -> JSValue ---
	JS_GetLength         :: proc(ctx: ^JSContext, obj: JSValue, pres: ^i64) -> i32 ---
	JS_SetLength         :: proc(ctx: ^JSContext, obj: JSValue, len: i64) -> i32 ---
	JS_SealObject        :: proc(ctx: ^JSContext, obj: JSValue) -> i32 ---
	JS_FreezeObject      :: proc(ctx: ^JSContext, obj: JSValue) -> i32 ---
}

JS_GPN_STRING_MASK  :: (1<<0)
JS_GPN_SYMBOL_MASK  :: (1<<1)
JS_GPN_PRIVATE_MASK :: (1<<2)

/* only include the enumerable properties */
JS_GPN_ENUM_ONLY    :: (1<<4)

/* set theJSPropertyEnum.is_enumerable field */
JS_GPN_SET_ENUM     :: (1<<5)

@(default_calling_convention="c")
foreign lib {
	JS_GetOwnPropertyNames :: proc(ctx: ^JSContext, ptab: ^^JSPropertyEnum, plen: ^u32, obj: JSValue, flags: i32) -> i32 ---
	JS_GetOwnProperty      :: proc(ctx: ^JSContext, desc: ^JSPropertyDescriptor, obj: JSValue, prop: JSAtom) -> i32 ---
	JS_FreePropertyEnum    :: proc(ctx: ^JSContext, tab: ^JSPropertyEnum, len: u32) ---
	JS_Call                :: proc(ctx: ^JSContext, func_obj: JSValue, this_obj: JSValue, argc: i32, argv: ^JSValue) -> JSValue ---
	JS_Invoke              :: proc(ctx: ^JSContext, this_val: JSValue, atom: JSAtom, argc: i32, argv: ^JSValue) -> JSValue ---
	JS_CallConstructor     :: proc(ctx: ^JSContext, func_obj: JSValue, argc: i32, argv: ^JSValue) -> JSValue ---
	JS_CallConstructor2    :: proc(ctx: ^JSContext, func_obj: JSValue, new_target: JSValue, argc: i32, argv: ^JSValue) -> JSValue ---

	/* Try to detect if the input is a module. Returns true if parsing the input
	* as a module produces no syntax errors. It's a naive approach that is not
	* wholly infallible: non-strict classic scripts may _parse_ okay as a module
	* but not _execute_ as one (different runtime semantics.) Use with caution.
	* |input| can be either ASCII or UTF-8 encoded source code.
	* Returns false if QuickJS was built with -DQJS_DISABLE_PARSER.
	*/
	JS_DetectModule :: proc(input: cstring, input_len: c.size_t) -> bool ---

	/* 'input' must be zero terminated i.e. input[input_len] = '\0'. */
	JS_Eval                      :: proc(ctx: ^JSContext, input: cstring, input_len: c.size_t, filename: cstring, eval_flags: i32) -> JSValue ---
	JS_Eval2                     :: proc(ctx: ^JSContext, input: cstring, input_len: c.size_t, options: ^JSEvalOptions) -> JSValue ---
	JS_EvalThis                  :: proc(ctx: ^JSContext, this_obj: JSValue, input: cstring, input_len: c.size_t, filename: cstring, eval_flags: i32) -> JSValue ---
	JS_EvalThis2                 :: proc(ctx: ^JSContext, this_obj: JSValue, input: cstring, input_len: c.size_t, options: ^JSEvalOptions) -> JSValue ---
	JS_GetGlobalObject           :: proc(ctx: ^JSContext) -> JSValue ---
	JS_IsInstanceOf              :: proc(ctx: ^JSContext, val: JSValue, obj: JSValue) -> i32 ---
	JS_DefineProperty            :: proc(ctx: ^JSContext, this_obj: JSValue, prop: JSAtom, val: JSValue, getter: JSValue, setter: JSValue, flags: i32) -> i32 ---
	JS_DefinePropertyValue       :: proc(ctx: ^JSContext, this_obj: JSValue, prop: JSAtom, val: JSValue, flags: i32) -> i32 ---
	JS_DefinePropertyValueUint32 :: proc(ctx: ^JSContext, this_obj: JSValue, idx: u32, val: JSValue, flags: i32) -> i32 ---
	JS_DefinePropertyValueStr    :: proc(ctx: ^JSContext, this_obj: JSValue, prop: cstring, val: JSValue, flags: i32) -> i32 ---
	JS_DefinePropertyGetSet      :: proc(ctx: ^JSContext, this_obj: JSValue, prop: JSAtom, getter: JSValue, setter: JSValue, flags: i32) -> i32 ---

	/* Only supported for custom classes, returns 0 on success < 0 otherwise. */
	JS_SetOpaque    :: proc(obj: JSValue, opaque: rawptr) -> i32 ---
	JS_GetOpaque    :: proc(obj: JSValue, class_id: JSClassID) -> rawptr ---
	JS_GetOpaque2   :: proc(ctx: ^JSContext, obj: JSValue, class_id: JSClassID) -> rawptr ---
	JS_GetAnyOpaque :: proc(obj: JSValue, class_id: ^JSClassID) -> rawptr ---

	/* 'buf' must be zero terminated i.e. buf[buf_len] = '\0'. */
	JS_ParseJSON     :: proc(ctx: ^JSContext, buf: cstring, buf_len: c.size_t, filename: cstring) -> JSValue ---
	JS_JSONStringify :: proc(ctx: ^JSContext, obj: JSValue, replacer: JSValue, space0: JSValue) -> JSValue ---
}

JSFreeArrayBufferDataFunc :: proc "c" (rt: ^JSRuntime, opaque: rawptr, ptr: rawptr)

@(default_calling_convention="c")
foreign lib {
	JS_NewArrayBuffer     :: proc(ctx: ^JSContext, buf: ^u8, len: c.size_t, free_func: JSFreeArrayBufferDataFunc, opaque: rawptr, is_shared: bool) -> JSValue ---
	JS_NewArrayBufferCopy :: proc(ctx: ^JSContext, buf: ^u8, len: c.size_t) -> JSValue ---
	JS_DetachArrayBuffer  :: proc(ctx: ^JSContext, obj: JSValue) ---
	JS_GetArrayBuffer     :: proc(ctx: ^JSContext, psize: ^c.size_t, obj: JSValue) -> ^u8 ---
	JS_IsArrayBuffer      :: proc(obj: JSValue) -> bool ---

	// returns true or false if obj is an ArrayBuffer, -1 otherwise
	JS_IsImmutableArrayBuffer :: proc(obj: JSValue) -> i32 ---

	// returns 0 if obj is an ArrayBuffer, -1 otherwise
	JS_SetImmutableArrayBuffer :: proc(obj: JSValue, immutable: bool) -> i32 ---
	JS_GetUint8Array           :: proc(ctx: ^JSContext, psize: ^c.size_t, obj: JSValue) -> ^u8 ---
}

JSTypedArrayEnum :: enum u32 {
	UINT8C     = 0,
	INT8       = 1,
	UINT8      = 2,
	INT16      = 3,
	UINT16     = 4,
	INT32      = 5,
	UINT32     = 6,
	BIG_INT64  = 7,
	BIG_UINT64 = 8,
	FLOAT16    = 9,
	FLOAT32    = 10,
	FLOAT64    = 11,
}

@(default_calling_convention="c")
foreign lib {
	JS_NewTypedArray       :: proc(ctx: ^JSContext, argc: i32, argv: ^JSValue, array_type: JSTypedArrayEnum) -> JSValue ---
	JS_GetTypedArrayBuffer :: proc(ctx: ^JSContext, obj: JSValue, pbyte_offset: ^c.size_t, pbyte_length: ^c.size_t, pbytes_per_element: ^c.size_t) -> JSValue ---
	JS_NewUint8Array       :: proc(ctx: ^JSContext, buf: ^u8, len: c.size_t, free_func: JSFreeArrayBufferDataFunc, opaque: rawptr, is_shared: bool) -> JSValue ---

	/* returns -1 if not a typed array otherwise return a JSTypedArrayEnum value */
	JS_GetTypedArrayType :: proc(obj: JSValue) -> i32 ---
	JS_NewUint8ArrayCopy :: proc(ctx: ^JSContext, buf: ^u8, len: c.size_t) -> JSValue ---
}

JSSharedArrayBufferFunctions :: struct {
	sab_alloc:  proc "c" (opaque: rawptr, size: c.size_t) -> rawptr,
	sab_free:   proc "c" (opaque: rawptr, ptr: rawptr),
	sab_dup:    proc "c" (opaque: rawptr, ptr: rawptr),
	sab_opaque: rawptr,
}

@(default_calling_convention="c")
foreign lib {
	JS_SetSharedArrayBufferFunctions :: proc(rt: ^JSRuntime, sf: ^JSSharedArrayBufferFunctions) ---
}

JSPromiseStateEnum :: enum i32 {
	// argument to JS_PromiseState() was not in fact a promise
	NOT_A_PROMISE = -1,
	PENDING       = 0,
	FULFILLED     = 1,
	REJECTED      = 2,
}

@(default_calling_convention="c")
foreign lib {
	JS_NewPromiseCapability :: proc(ctx: ^JSContext, resolving_funcs: ^JSValue) -> JSValue ---
	JS_PromiseState         :: proc(ctx: ^JSContext, promise: JSValue) -> JSPromiseStateEnum ---
	JS_PromiseResult        :: proc(ctx: ^JSContext, promise: JSValue) -> JSValue ---
	JS_IsPromise            :: proc(val: JSValue) -> bool ---
	JS_NewSettledPromise    :: proc(ctx: ^JSContext, is_reject: bool, value: JSValue) -> JSValue ---
	JS_NewSymbol            :: proc(ctx: ^JSContext, description: cstring, is_global: bool) -> JSValue ---
}

JSPromiseHookType :: enum u32 {
	INIT    = 0, // emitted when a new promise is created
	BEFORE  = 1, // runs right before promise.then is invoked
	AFTER   = 2, // runs right after promise.then is invoked
	RESOLVE = 3, // not emitted for rejected promises
}

// parent_promise is only passed in when type == JS_PROMISE_HOOK_INIT and
// is then either a promise object or JS_UNDEFINED if the new promise does
// not have a parent promise; only promises created with promise.then have
// a parent promise
JSPromiseHook :: proc "c" (ctx: ^JSContext, type: JSPromiseHookType, promise: JSValue, parent_promise: JSValue, opaque: rawptr)

@(default_calling_convention="c")
foreign lib {
	JS_SetPromiseHook :: proc(rt: ^JSRuntime, promise_hook: JSPromiseHook, opaque: rawptr) ---
}

/* is_handled = true means that the rejection is handled */
JSHostPromiseRejectionTracker :: proc "c" (ctx: ^JSContext, promise: JSValue, reason: JSValue, is_handled: bool, opaque: rawptr)

@(default_calling_convention="c")
foreign lib {
	JS_SetHostPromiseRejectionTracker :: proc(rt: ^JSRuntime, cb: JSHostPromiseRejectionTracker, opaque: rawptr) ---
}

/* return != 0 if the JS code needs to be interrupted */
JSInterruptHandler :: proc "c" (rt: ^JSRuntime, opaque: rawptr) -> i32

@(default_calling_convention="c")
foreign lib {
	JS_SetInterruptHandler :: proc(rt: ^JSRuntime, cb: JSInterruptHandler, opaque: rawptr) ---

	/* if can_block is true, Atomics.wait() can be used */
	JS_SetCanBlock :: proc(rt: ^JSRuntime, can_block: bool) ---

	/* set the [IsHTMLDDA] internal slot */
	JS_SetIsHTMLDDA :: proc(ctx: ^JSContext, obj: JSValue) ---
}

JSModuleDef :: struct {}

/* return the module specifier (allocated with js_malloc()) or NULL if
exception */
JSModuleNormalizeFunc  :: proc "c" (ctx: ^JSContext, module_base_name: cstring, module_name: cstring, opaque: rawptr) -> cstring
JSModuleNormalizeFunc2 :: proc "c" (ctx: ^JSContext, module_base_name: cstring, module_name: cstring, attributes: JSValue, opaque: rawptr) -> cstring
JSModuleLoaderFunc     :: proc "c" (ctx: ^JSContext, module_name: cstring, opaque: rawptr) -> ^JSModuleDef

/* module loader with import attributes support */
JSModuleLoaderFunc2 :: proc "c" (ctx: ^JSContext, module_name: cstring, opaque: rawptr, attributes: JSValue) -> ^JSModuleDef

/* return -1 if exception, 0 if OK */
JSModuleCheckSupportedImportAttributes :: proc "c" (ctx: ^JSContext, opaque: rawptr, attributes: JSValue) -> i32

@(default_calling_convention="c")
foreign lib {
	/* module_normalize = NULL is allowed and invokes the default module
	filename normalizer */
	JS_SetModuleLoaderFunc :: proc(rt: ^JSRuntime, module_normalize: JSModuleNormalizeFunc, module_loader: JSModuleLoaderFunc, opaque: rawptr) ---

	/* same as JS_SetModuleLoaderFunc but with import attributes support */
	JS_SetModuleLoaderFunc2 :: proc(rt: ^JSRuntime, module_normalize: JSModuleNormalizeFunc, module_loader: JSModuleLoaderFunc2, module_check_attrs: JSModuleCheckSupportedImportAttributes, opaque: rawptr) ---

	/* Set an attributes-aware module normalizer. Call after JS_SetModuleLoaderFunc2. */
	JS_SetModuleNormalizeFunc2 :: proc(rt: ^JSRuntime, module_normalize: JSModuleNormalizeFunc2) ---

	/* return the import.meta object of a module */
	JS_GetImportMeta      :: proc(ctx: ^JSContext, m: ^JSModuleDef) -> JSValue ---
	JS_GetModuleName      :: proc(ctx: ^JSContext, m: ^JSModuleDef) -> JSAtom ---
	JS_GetModuleNamespace :: proc(ctx: ^JSContext, m: ^JSModuleDef) -> JSValue ---

	/* associate a JSValue to a C module */
	JS_SetModulePrivateValue :: proc(ctx: ^JSContext, m: ^JSModuleDef, val: JSValue) -> i32 ---
	JS_GetModulePrivateValue :: proc(ctx: ^JSContext, m: ^JSModuleDef) -> JSValue ---
}

/* JS Job support */
JSJobFunc :: proc "c" (ctx: ^JSContext, argc: i32, argv: ^JSValue) -> JSValue

@(default_calling_convention="c")
foreign lib {
	JS_EnqueueJob           :: proc(ctx: ^JSContext, job_func: JSJobFunc, argc: i32, argv: ^JSValue) -> i32 ---
	JS_IsJobPending         :: proc(rt: ^JSRuntime) -> bool ---
	JS_GetPendingJobContext :: proc(rt: ^JSRuntime) -> ^JSContext ---
	JS_ExecutePendingJob    :: proc(rt: ^JSRuntime, pctx: ^^JSContext) -> i32 ---
}

/* Structure to retrieve (de)serialized SharedArrayBuffer objects. */
JSSABTab :: struct {
	tab: ^^u8,
	len: c.size_t,
}

/* Object Writer/Reader (currently only used to handle precompiled code) */
JS_WRITE_OBJ_BYTECODE     :: (1<<0)  /* allow function/module */
JS_WRITE_OBJ_BSWAP        :: (0)      /* byte swapped output (obsolete, handled transparently) */
JS_WRITE_OBJ_SAB          :: (1<<2)  /* allow SharedArrayBuffer */
JS_WRITE_OBJ_REFERENCE    :: (1<<3)  /* allow object references to encode arbitrary object graph */
JS_WRITE_OBJ_STRIP_SOURCE  :: (1<<4) /* do not write source code information */
JS_WRITE_OBJ_STRIP_DEBUG   :: (1<<5) /* do not write debug information */

@(default_calling_convention="c")
foreign lib {
	JS_WriteObject  :: proc(ctx: ^JSContext, psize: ^c.size_t, obj: JSValue, flags: i32) -> ^u8 ---
	JS_WriteObject2 :: proc(ctx: ^JSContext, psize: ^c.size_t, obj: JSValue, flags: i32, psab_tab: ^JSSABTab) -> ^u8 ---
}

/* WARNING: only enable JS_READ_OBJ_BYTECODE on input from a trusted
writer. The bytecode format is not designed to resist a hostile
producer; loading adversarial bytecode can lead to memory corruption. */
JS_READ_OBJ_BYTECODE  :: (1<<0) /* allow function/module */
JS_READ_OBJ_ROM_DATA  :: (0)      /* avoid duplicating 'buf' data (obsolete, broken by ICs) */

/* WARNING: serialized SharedArrayBuffers carry a literal host pointer in
the blob; only enable JS_READ_OBJ_SAB on input produced by a trusted
writer in the same process (e.g. another Worker on the same runtime). */
JS_READ_OBJ_SAB       :: (1<<2) /* allow SharedArrayBuffer */
JS_READ_OBJ_REFERENCE :: (1<<3) /* allow object references */

@(default_calling_convention="c")
foreign lib {
	JS_ReadObject  :: proc(ctx: ^JSContext, buf: ^u8, buf_len: c.size_t, flags: i32) -> JSValue ---
	JS_ReadObject2 :: proc(ctx: ^JSContext, buf: ^u8, buf_len: c.size_t, flags: i32, psab_tab: ^JSSABTab) -> JSValue ---

	/* instantiate and evaluate a bytecode function. Only used when
	reading a script or module with JS_ReadObject() */
	JS_EvalFunction :: proc(ctx: ^JSContext, fun_obj: JSValue) -> JSValue ---

	/* load the dependencies of the module 'obj'. Useful when JS_ReadObject()
	returns a module. */
	JS_ResolveModule :: proc(ctx: ^JSContext, obj: JSValue) -> i32 ---

	/* only exported for os.Worker() */
	JS_GetScriptOrModuleName :: proc(ctx: ^JSContext, n_stack_levels: i32) -> JSAtom ---

	/* only exported for os.Worker() */
	JS_LoadModule :: proc(ctx: ^JSContext, basename: cstring, filename: cstring) -> JSValue ---
}

/* C function definition */
JSCFunctionEnum :: enum u32 {
	generic                   = 0,
	generic_magic             = 1,
	constructor               = 2,
	constructor_magic         = 3,
	constructor_or_func       = 4,
	constructor_or_func_magic = 5,
	f_f                       = 6,
	f_f_f                     = 7,
	getter                    = 8,
	setter                    = 9,
	getter_magic              = 10,
	setter_magic              = 11,
	iterator_next             = 12,
} /* XXX: should rename for namespace isolation */

JSCFunctionType :: struct #raw_union {
	generic:             JSCFunction,
	generic_magic:       proc "c" (ctx: ^JSContext, this_val: JSValue, argc: i32, argv: ^JSValue, magic: i32) -> JSValue,
	constructor:         JSCFunction,
	constructor_magic:   proc "c" (ctx: ^JSContext, new_target: JSValue, argc: i32, argv: ^JSValue, magic: i32) -> JSValue,
	constructor_or_func: JSCFunction,
	f_f:                 proc "c" (f64) -> f64,
	f_f_f:               proc "c" (f64, f64) -> f64,
	getter:              proc "c" (ctx: ^JSContext, this_val: JSValue) -> JSValue,
	setter:              proc "c" (ctx: ^JSContext, this_val: JSValue, val: JSValue) -> JSValue,
	getter_magic:        proc "c" (ctx: ^JSContext, this_val: JSValue, magic: i32) -> JSValue,
	setter_magic:        proc "c" (ctx: ^JSContext, this_val: JSValue, val: JSValue, magic: i32) -> JSValue,
	iterator_next:       proc "c" (ctx: ^JSContext, this_val: JSValue, argc: i32, argv: ^JSValue, pdone: ^i32, magic: i32) -> JSValue,
}

@(default_calling_convention="c")
foreign lib {
	JS_NewCFunction2     :: proc(ctx: ^JSContext, func: JSCFunction, name: cstring, length: i32, cproto: JSCFunctionEnum, magic: i32) -> JSValue ---
	JS_NewCFunction3     :: proc(ctx: ^JSContext, func: JSCFunction, name: cstring, length: i32, cproto: JSCFunctionEnum, magic: i32, proto_val: JSValue, n_fields: i32) -> JSValue ---
	JS_NewCFunctionData  :: proc(ctx: ^JSContext, func: JSCFunctionData, length: i32, magic: i32, data_len: i32, data: ^JSValue) -> JSValue ---
	JS_NewCFunctionData2 :: proc(ctx: ^JSContext, func: JSCFunctionData, name: cstring, length: i32, magic: i32, data_len: i32, data: ^JSValue) -> JSValue ---
}

JSCClosureFinalizerFunc :: proc "c" (rawptr)

@(default_calling_convention="c")
foreign lib {
	JS_NewCClosure    :: proc(ctx: ^JSContext, func: JSCClosure, name: cstring, opaque_finalize: JSCClosureFinalizerFunc, length: i32, magic: i32, opaque: rawptr) -> JSValue ---
	JS_SetConstructor :: proc(ctx: ^JSContext, func_obj: JSValue, proto: JSValue) -> i32 ---
}

/* C property definition */
JSCFunctionListEntry :: struct {
	name:       cstring, /* pure ASCII or UTF-8 encoded */
	prop_flags: u8,
	def_type:   u8,
	magic:      i16,

	u: struct #raw_union {
		func: struct {
			length: u8, /* XXX: should move outside union */
			cproto: u8, /* XXX: should move outside union */
			cfunc:  JSCFunctionType,
		},

		getset: struct {
			get: JSCFunctionType,
			set: JSCFunctionType,
		},

		alias: struct {
			name: cstring,
			base: i32,
		},

		prop_list: struct {
			tab: ^JSCFunctionListEntry,
			len: i32,
		},

		str:  cstring, /* pure ASCII or UTF-8 encoded */
		_i32: i32,
		_i64: i64,
		_u64: u64,
		_f64: f64,
	},
}

JS_DEF_CFUNC          :: 0
JS_DEF_CGETSET        :: 1
JS_DEF_CGETSET_MAGIC  :: 2
JS_DEF_PROP_STRING    :: 3
JS_DEF_PROP_INT32     :: 4
JS_DEF_PROP_INT64     :: 5
JS_DEF_PROP_DOUBLE    :: 6
JS_DEF_PROP_UNDEFINED :: 7
JS_DEF_OBJECT         :: 8
JS_DEF_ALIAS          :: 9
JS_DEF_PROP_SYMBOL    :: 10
JS_DEF_PROP_BOOL      :: 11

@(default_calling_convention="c")
foreign lib {
	JS_SetPropertyFunctionList :: proc(ctx: ^JSContext, obj: JSValue, tab: ^JSCFunctionListEntry, len: i32) -> i32 ---
}

/* C module definition */
JSModuleInitFunc :: proc "c" (ctx: ^JSContext, m: ^JSModuleDef) -> i32

@(default_calling_convention="c")
foreign lib {
	JS_NewCModule :: proc(ctx: ^JSContext, name_str: cstring, func: JSModuleInitFunc) -> ^JSModuleDef ---

	/* can only be called before the module is instantiated */
	JS_AddModuleExport     :: proc(ctx: ^JSContext, m: ^JSModuleDef, name_str: cstring) -> i32 ---
	JS_AddModuleExportList :: proc(ctx: ^JSContext, m: ^JSModuleDef, tab: ^JSCFunctionListEntry, len: i32) -> i32 ---

	/* can only be called after the module is instantiated */
	JS_SetModuleExport     :: proc(ctx: ^JSContext, m: ^JSModuleDef, export_name: cstring, val: JSValue) -> i32 ---
	JS_SetModuleExportList :: proc(ctx: ^JSContext, m: ^JSModuleDef, tab: ^JSCFunctionListEntry, len: i32) -> i32 ---
}

/* Version */
QJS_VERSION_MAJOR  :: 0
QJS_VERSION_MINOR  :: 15
QJS_VERSION_PATCH  :: 0
QJS_VERSION_SUFFIX :: ""

@(default_calling_convention="c")
foreign lib {
	JS_GetVersion :: proc() -> cstring ---

	/* Integration point for quickjs-libc.c, not for public use. */
	js_std_cmd :: proc(cmd: i32, #c_vararg _: ..any) -> c.uintptr_t ---
}

