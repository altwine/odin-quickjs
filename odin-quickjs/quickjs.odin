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

TAG_BIG_INT           :: -9
TAG_FIRST             :: -9
TAG_STRING_ROPE       :: -6
TAG_MODULE            :: -3
TAG_FUNCTION_BYTECODE :: -2
TAG_OBJECT            :: -1
TAG_INT               :: 0
TAG_BOOL              :: 1
TAG_NULL              :: 2
TAG_UNDEFINED         :: 3
TAG_UNINITIALIZED     :: 4
TAG_SYMBOL            :: -8
TAG_STRING            :: -7
TAG_CATCH_OFFSET      :: 5
TAG_SHORT_BIG_INT     :: 7
TAG_EXCEPTION         :: 6
TAG_FLOAT64           :: 8
JSValueConst          :: JSValue

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
PROP_CONFIGURABLE  :: (1<<0)
PROP_WRITABLE      :: (1<<1)
PROP_ENUMERABLE    :: (1<<2)
PROP_C_W_E         :: (PROP_CONFIGURABLE|PROP_WRITABLE|PROP_ENUMERABLE)
PROP_LENGTH        :: (1<<3)  /* used internally in Arrays */
PROP_TMASK         :: (3<<4)  /* mask for NORMAL, GETSET, VARREF, AUTOINIT */
PROP_NORMAL         :: (0<<4)
PROP_GETSET         :: (1<<4)
PROP_VARREF         :: (2<<4) /* used internally */
PROP_AUTOINIT       :: (3<<4) /* used internally */

/* flags for JS_DefineProperty */
PROP_HAS_SHIFT        :: 8
PROP_HAS_CONFIGURABLE :: (1<<8)
PROP_HAS_WRITABLE     :: (1<<9)
PROP_HAS_ENUMERABLE   :: (1<<10)
PROP_HAS_GET          :: (1<<11)
PROP_HAS_SET          :: (1<<12)
PROP_HAS_VALUE        :: (1<<13)

/* throw an exception if false would be returned
(JS_DefineProperty/JS_SetProperty) */
PROP_THROW            :: (1<<14)

/* throw an exception if false would be returned in strict mode
(JS_SetProperty) */
PROP_THROW_STRICT            :: (1<<15)
PROP_NO_ADD                  :: (1<<16) /* internal use */
PROP_NO_EXOTIC               :: (1<<17) /* internal use */
PROP_DEFINE_PROPERTY         :: (1<<18) /* internal use */
PROP_REFLECT_DEFINE_PROPERTY :: (1<<19) /* internal use */
DEFAULT_STACK_SIZE           :: (1024*1024)

/* JS_Eval() flags */
EVAL_TYPE_GLOBAL   :: (0<<0) /* global code (default) */
EVAL_TYPE_MODULE   :: (1<<0) /* module code */
EVAL_TYPE_DIRECT   :: (2<<0) /* direct call (internal use) */
EVAL_TYPE_INDIRECT :: (3<<0) /* indirect call (internal use) */
EVAL_TYPE_MASK     :: (3<<0)
EVAL_FLAG_STRICT   :: (1<<3) /* force 'strict' mode */
EVAL_FLAG_UNUSED   :: (1<<4) /* unused */

/* compile but do not run. The result is an object with a
JS_TAG_FUNCTION_BYTECODE or JS_TAG_MODULE tag. It can be executed
with JS_EvalFunction(). */
EVAL_FLAG_COMPILE_ONLY :: (1<<5)

/* don't include the stack frames before this eval in the Error() backtraces */
EVAL_FLAG_BACKTRACE_BARRIER :: (1<<6)

/* allow top-level await in normal script. JS_Eval() returns a
promise. Only allowed with JS_EVAL_TYPE_GLOBAL */
EVAL_FLAG_ASYNC :: (1<<7)

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
DUMP_BYTECODE_FINAL   :: 0x01     /* dump pass 3 final byte code */
DUMP_BYTECODE_PASS2   :: 0x02     /* dump pass 2 code */
DUMP_BYTECODE_PASS1   :: 0x04     /* dump pass 1 code */
DUMP_BYTECODE_HEX     :: 0x10     /* dump bytecode in hex */
DUMP_BYTECODE_PC2LINE :: 0x20     /* dump line number table */
DUMP_BYTECODE_STACK   :: 0x40     /* dump compute_stack_size */
DUMP_BYTECODE_STEP    :: 0x80     /* dump executed bytecode */
DUMP_READ_OBJECT      :: 0x100    /* dump the marshalled objects at load time */
DUMP_FREE             :: 0x200    /* dump every object free */
DUMP_GC               :: 0x400    /* dump the occurrence of the automatic GC */
DUMP_GC_FREE          :: 0x800    /* dump objects freed by the GC */
DUMP_MODULE_RESOLVE   :: 0x1000   /* dump module resolution steps */
DUMP_PROMISE          :: 0x2000   /* dump promise steps */
DUMP_LEAKS            :: 0x4000   /* dump leaked objects and strings in JS_FreeRuntime */
DUMP_ATOM_LEAKS       :: 0x8000   /* dump leaked atoms in JS_FreeRuntime */
DUMP_MEM              :: 0x10000  /* dump memory usage in JS_FreeRuntime */
DUMP_OBJECTS          :: 0x20000  /* dump objects in JS_FreeRuntime */
DUMP_ATOMS            :: 0x40000  /* dump atoms in JS_FreeRuntime */
DUMP_SHAPES           :: 0x80000  /* dump shapes in JS_FreeRuntime */
ABORT_ON_LEAKS        :: 0x10C000  /* abort on atom/object/string leaks; for testing */

// Finalizers run in LIFO order at the very end of JS_FreeRuntime.
// Intended for cleanup of associated resources; the runtime itself
// is no longer usable.
JSRuntimeFinalizer :: proc "c" (rt: ^JSRuntime, arg: rawptr)
JSGCObjectHeader   :: struct {}

@(default_calling_convention="c", link_prefix="JS_")
foreign lib {
	NewRuntime :: proc() -> ^JSRuntime ---

	/* info lifetime must exceed that of rt */
	SetRuntimeInfo :: proc(rt: ^JSRuntime, info: cstring) ---

	/* use 0 to disable memory limit */
	SetMemoryLimit :: proc(rt: ^JSRuntime, limit: c.size_t) ---
	SetDumpFlags   :: proc(rt: ^JSRuntime, flags: u64) ---
	GetDumpFlags   :: proc(rt: ^JSRuntime) -> u64 ---
	GetGCThreshold :: proc(rt: ^JSRuntime) -> c.size_t ---
	SetGCThreshold :: proc(rt: ^JSRuntime, gc_threshold: c.size_t) ---

	/* use 0 to disable maximum stack size check */
	SetMaxStackSize :: proc(rt: ^JSRuntime, stack_size: c.size_t) ---

	/* should be called when changing thread to update the stack top value
	used to check stack overflow. */
	UpdateStackTop      :: proc(rt: ^JSRuntime) ---
	NewRuntime2         :: proc(mf: ^JSMallocFunctions, opaque: rawptr) -> ^JSRuntime ---
	FreeRuntime         :: proc(rt: ^JSRuntime) ---
	GetRuntimeOpaque    :: proc(rt: ^JSRuntime) -> rawptr ---
	SetRuntimeOpaque    :: proc(rt: ^JSRuntime, opaque: rawptr) ---
	AddRuntimeFinalizer :: proc(rt: ^JSRuntime, finalizer: JSRuntimeFinalizer, arg: rawptr) -> i32 ---
}

MarkFunc :: proc "c" (rt: ^JSRuntime, gp: ^JSGCObjectHeader)

@(default_calling_convention="c", link_prefix="JS_")
foreign lib {
	MarkValue        :: proc(rt: ^JSRuntime, val: JSValue, mark_func: MarkFunc) ---
	RunGC            :: proc(rt: ^JSRuntime) ---
	IsLiveObject     :: proc(rt: ^JSRuntime, obj: JSValue) -> bool ---
	NewContext       :: proc(rt: ^JSRuntime) -> ^JSContext ---
	FreeContext      :: proc(s: ^JSContext) ---
	DupContext       :: proc(ctx: ^JSContext) -> ^JSContext ---
	GetContextOpaque :: proc(ctx: ^JSContext) -> rawptr ---
	SetContextOpaque :: proc(ctx: ^JSContext, opaque: rawptr) ---
	GetRuntime       :: proc(ctx: ^JSContext) -> ^JSRuntime ---
	SetClassProto    :: proc(ctx: ^JSContext, class_id: JSClassID, obj: JSValue) ---
	GetClassProto    :: proc(ctx: ^JSContext, class_id: JSClassID) -> JSValue ---
	GetFunctionProto :: proc(ctx: ^JSContext) -> JSValue ---

	/* the following functions are used to select the intrinsic object to
	save memory */
	NewContextRaw              :: proc(rt: ^JSRuntime) -> ^JSContext ---
	AddIntrinsicBaseObjects    :: proc(ctx: ^JSContext) -> i32 ---
	AddIntrinsicDate           :: proc(ctx: ^JSContext) -> i32 ---
	AddIntrinsicEval           :: proc(ctx: ^JSContext) -> i32 ---
	AddIntrinsicRegExpCompiler :: proc(ctx: ^JSContext) ---
	AddIntrinsicRegExp         :: proc(ctx: ^JSContext) -> i32 ---
	AddIntrinsicJSON           :: proc(ctx: ^JSContext) -> i32 ---
	AddIntrinsicProxy          :: proc(ctx: ^JSContext) -> i32 ---
	AddIntrinsicMapSet         :: proc(ctx: ^JSContext) -> i32 ---
	AddIntrinsicTypedArrays    :: proc(ctx: ^JSContext) -> i32 ---
	AddIntrinsicPromise        :: proc(ctx: ^JSContext) -> i32 ---
	AddIntrinsicBigInt         :: proc(ctx: ^JSContext) -> i32 ---
	AddIntrinsicWeakRef        :: proc(ctx: ^JSContext) -> i32 ---
	AddPerformance             :: proc(ctx: ^JSContext) -> i32 ---
	AddIntrinsicDOMException   :: proc(ctx: ^JSContext) -> i32 ---
	AddIntrinsicAToB           :: proc(ctx: ^JSContext) -> i32 ---

	/* for equality comparisons and sameness */
	IsEqual       :: proc(ctx: ^JSContext, op1: JSValue, op2: JSValue) -> i32 ---
	IsStrictEqual :: proc(ctx: ^JSContext, op1: JSValue, op2: JSValue) -> bool ---
	IsSameValue   :: proc(ctx: ^JSContext, op1: JSValue, op2: JSValue) -> bool ---

	/* Similar to same-value equality, but +0 and -0 are considered equal. */
	IsSameValueZero :: proc(ctx: ^JSContext, op1: JSValue, op2: JSValue) -> bool ---

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

@(default_calling_convention="c", link_prefix="JS_")
foreign lib {
	ComputeMemoryUsage :: proc(rt: ^JSRuntime, s: ^JSMemoryUsage) ---
	DumpMemoryUsage    :: proc(fp: rawptr, s: ^JSMemoryUsage, rt: ^JSRuntime) ---
}

/* atom support */
ATOM_NULL :: 0

@(default_calling_convention="c", link_prefix="JS_")
foreign lib {
	NewAtomLen       :: proc(ctx: ^JSContext, str: cstring, len: c.size_t) -> JSAtom ---
	NewAtom          :: proc(ctx: ^JSContext, str: cstring) -> JSAtom ---
	NewAtomUInt32    :: proc(ctx: ^JSContext, n: u32) -> JSAtom ---
	DupAtom          :: proc(ctx: ^JSContext, v: JSAtom) -> JSAtom ---
	DupAtomRT        :: proc(rt: ^JSRuntime, v: JSAtom) -> JSAtom ---
	FreeAtom         :: proc(ctx: ^JSContext, v: JSAtom) ---
	FreeAtomRT       :: proc(rt: ^JSRuntime, v: JSAtom) ---
	AtomToValue      :: proc(ctx: ^JSContext, atom: JSAtom) -> JSValue ---
	AtomToString     :: proc(ctx: ^JSContext, atom: JSAtom) -> JSValue ---
	AtomToCStringLen :: proc(ctx: ^JSContext, plen: ^c.size_t, atom: JSAtom) -> cstring ---
	ValueToAtom      :: proc(ctx: ^JSContext, val: JSValue) -> JSAtom ---
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
JSClassGCMark    :: proc "c" (rt: ^JSRuntime, val: JSValue, mark_func: MarkFunc)

CALL_FLAG_CONSTRUCTOR :: (1<<0)

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

EVAL_OPTIONS_VERSION :: 1

JSEvalOptions :: struct {
	version:    i32,
	eval_flags: i32,
	filename:   cstring,
	line_num:   i32,
}

INVALID_CLASS_ID :: 0

@(default_calling_convention="c", link_prefix="JS_")
foreign lib {
	NewClassID :: proc(rt: ^JSRuntime, pclass_id: ^JSClassID) -> JSClassID ---

	/* Returns the class ID if `v` is an object, otherwise returns JS_INVALID_CLASS_ID. */
	GetClassID        :: proc(v: JSValue) -> JSClassID ---
	NewClass          :: proc(rt: ^JSRuntime, class_id: JSClassID, class_def: ^JSClassDef) -> i32 ---
	IsRegisteredClass :: proc(rt: ^JSRuntime, class_id: JSClassID) -> bool ---

	/* Returns the class name or JS_ATOM_NULL if `id` is not a registered class. Must be freed with JS_FreeAtom. */
	GetClassName          :: proc(rt: ^JSRuntime, class_id: JSClassID) -> JSAtom ---
	NewNumber             :: proc(ctx: ^JSContext, d: f64) -> JSValue ---
	NewBigInt64           :: proc(ctx: ^JSContext, v: i64) -> JSValue ---
	NewBigUint64          :: proc(ctx: ^JSContext, v: u64) -> JSValue ---
	Throw                 :: proc(ctx: ^JSContext, obj: JSValue) -> JSValue ---
	GetException          :: proc(ctx: ^JSContext) -> JSValue ---
	HasException          :: proc(ctx: ^JSContext) -> bool ---
	IsError               :: proc(val: JSValue) -> bool ---
	IsUncatchableError    :: proc(val: JSValue) -> bool ---
	SetUncatchableError   :: proc(ctx: ^JSContext, val: JSValue) ---
	ClearUncatchableError :: proc(ctx: ^JSContext, val: JSValue) ---

	// Shorthand for:
	//  JSValue exc = JS_GetException(ctx);
	//  JS_ClearUncatchableError(ctx, exc);
	//  JS_Throw(ctx, exc);
	ResetUncatchableError :: proc(ctx: ^JSContext) ---
	NewError              :: proc(ctx: ^JSContext) -> JSValue ---
	NewInternalError      :: proc(ctx: ^JSContext, fmt: cstring, #c_vararg _: ..any) -> JSValue ---
	NewPlainError         :: proc(ctx: ^JSContext, fmt: cstring, #c_vararg _: ..any) -> JSValue ---
	NewRangeError         :: proc(ctx: ^JSContext, fmt: cstring, #c_vararg _: ..any) -> JSValue ---
	NewReferenceError     :: proc(ctx: ^JSContext, fmt: cstring, #c_vararg _: ..any) -> JSValue ---
	NewSyntaxError        :: proc(ctx: ^JSContext, fmt: cstring, #c_vararg _: ..any) -> JSValue ---
	NewTypeError          :: proc(ctx: ^JSContext, fmt: cstring, #c_vararg _: ..any) -> JSValue ---
	ThrowInternalError    :: proc(ctx: ^JSContext, fmt: cstring, #c_vararg _: ..any) -> JSValue ---
	ThrowPlainError       :: proc(ctx: ^JSContext, fmt: cstring, #c_vararg _: ..any) -> JSValue ---
	ThrowRangeError       :: proc(ctx: ^JSContext, fmt: cstring, #c_vararg _: ..any) -> JSValue ---
	ThrowReferenceError   :: proc(ctx: ^JSContext, fmt: cstring, #c_vararg _: ..any) -> JSValue ---
	ThrowSyntaxError      :: proc(ctx: ^JSContext, fmt: cstring, #c_vararg _: ..any) -> JSValue ---
	ThrowTypeError        :: proc(ctx: ^JSContext, fmt: cstring, #c_vararg _: ..any) -> JSValue ---
	ThrowDOMException     :: proc(ctx: ^JSContext, name: cstring, fmt: cstring, #c_vararg _: ..any) -> JSValue ---
	ThrowOutOfMemory      :: proc(ctx: ^JSContext) -> JSValue ---
	FreeValue             :: proc(ctx: ^JSContext, v: JSValue) ---
	FreeValueRT           :: proc(rt: ^JSRuntime, v: JSValue) ---
	DupValue              :: proc(ctx: ^JSContext, v: JSValue) -> JSValue ---
	DupValueRT            :: proc(rt: ^JSRuntime, v: JSValue) -> JSValue ---
	ToBool                :: proc(ctx: ^JSContext, val: JSValue /* return -1 for JS_EXCEPTION */) -> i32 --- /* return -1 for JS_EXCEPTION */
	ToNumber              :: proc(ctx: ^JSContext, val: JSValue) -> JSValue ---
	ToInt32               :: proc(ctx: ^JSContext, pres: ^i32, val: JSValue) -> i32 ---
	ToInt64               :: proc(ctx: ^JSContext, pres: ^i64, val: JSValue) -> i32 ---
	ToIndex               :: proc(ctx: ^JSContext, plen: ^u64, val: JSValue) -> i32 ---
	ToFloat64             :: proc(ctx: ^JSContext, pres: ^f64, val: JSValue) -> i32 ---

	/* return an exception if 'val' is a Number */
	ToBigInt64  :: proc(ctx: ^JSContext, pres: ^i64, val: JSValue) -> i32 ---
	ToBigUint64 :: proc(ctx: ^JSContext, pres: ^u64, val: JSValue) -> i32 ---

	/* same as JS_ToInt64() but allow BigInt */
	ToInt64Ext   :: proc(ctx: ^JSContext, pres: ^i64, val: JSValue) -> i32 ---
	NewStringLen :: proc(ctx: ^JSContext, str1: cstring, len1: c.size_t) -> JSValue ---

	// makes a copy of the input; does not check if the input is valid UTF-16,
	// that is the responsibility of the caller
	NewStringUTF16 :: proc(ctx: ^JSContext, buf: ^u16, len: c.size_t) -> JSValue ---
	NewAtomString  :: proc(ctx: ^JSContext, str: cstring) -> JSValue ---
	ToString       :: proc(ctx: ^JSContext, val: JSValue) -> JSValue ---
	ToPropertyKey  :: proc(ctx: ^JSContext, val: JSValue) -> JSValue ---
	ToCStringLen2  :: proc(ctx: ^JSContext, plen: ^c.size_t, val1: JSValue, cesu8: bool) -> cstring ---

	// returns a utf-16 version of the string in native endianness; the
	// string is not nul terminated and can contain unmatched surrogates
	// |*plen| is in uint16s, not code points; a surrogate pair such as
	// U+D834 U+DF06 has len=2; an unmatched surrogate has len=1
	ToCStringLenUTF16   :: proc(ctx: ^JSContext, plen: ^c.size_t, val1: JSValue) -> ^u16 ---
	FreeCString         :: proc(ctx: ^JSContext, ptr: cstring) ---
	FreeCStringRT       :: proc(rt: ^JSRuntime, ptr: cstring) ---
	FreeCStringUTF16    :: proc(ctx: ^JSContext, ptr: ^u16) ---
	FreeCStringRT_UTF16 :: proc(rt: ^JSRuntime, ptr: ^u16) ---
	NewObjectProtoClass :: proc(ctx: ^JSContext, proto: JSValue, class_id: JSClassID) -> JSValue ---
	NewObjectClass      :: proc(ctx: ^JSContext, class_id: JSClassID) -> JSValue ---
	NewObjectProto      :: proc(ctx: ^JSContext, proto: JSValue) -> JSValue ---
	NewObject           :: proc(ctx: ^JSContext) -> JSValue ---

	// takes ownership of the values
	NewObjectFrom :: proc(ctx: ^JSContext, count: i32, props: ^JSAtom, values: ^JSValue) -> JSValue ---

	// takes ownership of the values
	NewObjectFromStr  :: proc(ctx: ^JSContext, count: i32, props: ^cstring, values: ^JSValue) -> JSValue ---
	ToObject          :: proc(ctx: ^JSContext, val: JSValue) -> JSValue ---
	ToObjectString    :: proc(ctx: ^JSContext, val: JSValue) -> JSValue ---
	IsFunction        :: proc(ctx: ^JSContext, val: JSValue) -> bool ---
	IsAsyncFunction   :: proc(val: JSValue) -> bool ---
	IsConstructor     :: proc(ctx: ^JSContext, val: JSValue) -> bool ---
	SetConstructorBit :: proc(ctx: ^JSContext, func_obj: JSValue, val: bool) -> bool ---
	IsRegExp          :: proc(val: JSValue) -> bool ---
	IsMap             :: proc(val: JSValue) -> bool ---
	IsSet             :: proc(val: JSValue) -> bool ---
	IsWeakRef         :: proc(val: JSValue) -> bool ---
	IsWeakSet         :: proc(val: JSValue) -> bool ---
	IsWeakMap         :: proc(val: JSValue) -> bool ---
	IsDataView        :: proc(val: JSValue) -> bool ---
	NewArray          :: proc(ctx: ^JSContext) -> JSValue ---

	// takes ownership of the values
	NewArrayFrom :: proc(ctx: ^JSContext, count: i32, values: ^JSValue) -> JSValue ---

	// reader beware: JS_IsArray used to "punch" through proxies and check
	// if the target object is an array but it no longer does; use JS_IsProxy
	// and JS_GetProxyTarget instead, and remember that the target itself can
	// also be a proxy, ad infinitum
	IsArray           :: proc(val: JSValue) -> bool ---
	IsProxy           :: proc(val: JSValue) -> bool ---
	GetProxyTarget    :: proc(ctx: ^JSContext, proxy: JSValue) -> JSValue ---
	GetProxyHandler   :: proc(ctx: ^JSContext, proxy: JSValue) -> JSValue ---
	NewProxy          :: proc(ctx: ^JSContext, target: JSValue, handler: JSValue) -> JSValue ---
	NewDate           :: proc(ctx: ^JSContext, epoch_ms: f64) -> JSValue ---
	IsDate            :: proc(v: JSValue) -> bool ---
	GetProperty       :: proc(ctx: ^JSContext, this_obj: JSValue, prop: JSAtom) -> JSValue ---
	GetPropertyUint32 :: proc(ctx: ^JSContext, this_obj: JSValue, idx: u32) -> JSValue ---
	GetPropertyInt64  :: proc(ctx: ^JSContext, this_obj: JSValue, idx: i64) -> JSValue ---
	GetPropertyStr    :: proc(ctx: ^JSContext, this_obj: JSValue, prop: cstring) -> JSValue ---
	SetProperty       :: proc(ctx: ^JSContext, this_obj: JSValue, prop: JSAtom, val: JSValue) -> i32 ---
	SetPropertyUint32 :: proc(ctx: ^JSContext, this_obj: JSValue, idx: u32, val: JSValue) -> i32 ---
	SetPropertyInt64  :: proc(ctx: ^JSContext, this_obj: JSValue, idx: i64, val: JSValue) -> i32 ---
	SetPropertyStr    :: proc(ctx: ^JSContext, this_obj: JSValue, prop: cstring, val: JSValue) -> i32 ---
	HasProperty       :: proc(ctx: ^JSContext, this_obj: JSValue, prop: JSAtom) -> i32 ---
	IsExtensible      :: proc(ctx: ^JSContext, obj: JSValue) -> i32 ---
	PreventExtensions :: proc(ctx: ^JSContext, obj: JSValue) -> i32 ---
	DeleteProperty    :: proc(ctx: ^JSContext, obj: JSValue, prop: JSAtom, flags: i32) -> i32 ---
	SetPrototype      :: proc(ctx: ^JSContext, obj: JSValue, proto_val: JSValue) -> i32 ---
	GetPrototype      :: proc(ctx: ^JSContext, val: JSValue) -> JSValue ---
	GetLength         :: proc(ctx: ^JSContext, obj: JSValue, pres: ^i64) -> i32 ---
	SetLength         :: proc(ctx: ^JSContext, obj: JSValue, len: i64) -> i32 ---
	SealObject        :: proc(ctx: ^JSContext, obj: JSValue) -> i32 ---
	FreezeObject      :: proc(ctx: ^JSContext, obj: JSValue) -> i32 ---
}

GPN_STRING_MASK  :: (1<<0)
GPN_SYMBOL_MASK  :: (1<<1)
GPN_PRIVATE_MASK :: (1<<2)

/* only include the enumerable properties */
GPN_ENUM_ONLY    :: (1<<4)

/* set theJSPropertyEnum.is_enumerable field */
GPN_SET_ENUM     :: (1<<5)

@(default_calling_convention="c", link_prefix="JS_")
foreign lib {
	GetOwnPropertyNames :: proc(ctx: ^JSContext, ptab: ^^JSPropertyEnum, plen: ^u32, obj: JSValue, flags: i32) -> i32 ---
	GetOwnProperty      :: proc(ctx: ^JSContext, desc: ^JSPropertyDescriptor, obj: JSValue, prop: JSAtom) -> i32 ---
	FreePropertyEnum    :: proc(ctx: ^JSContext, tab: ^JSPropertyEnum, len: u32) ---
	Call                :: proc(ctx: ^JSContext, func_obj: JSValue, this_obj: JSValue, argc: i32, argv: ^JSValue) -> JSValue ---
	Invoke              :: proc(ctx: ^JSContext, this_val: JSValue, atom: JSAtom, argc: i32, argv: ^JSValue) -> JSValue ---
	CallConstructor     :: proc(ctx: ^JSContext, func_obj: JSValue, argc: i32, argv: ^JSValue) -> JSValue ---
	CallConstructor2    :: proc(ctx: ^JSContext, func_obj: JSValue, new_target: JSValue, argc: i32, argv: ^JSValue) -> JSValue ---

	/* Try to detect if the input is a module. Returns true if parsing the input
	* as a module produces no syntax errors. It's a naive approach that is not
	* wholly infallible: non-strict classic scripts may _parse_ okay as a module
	* but not _execute_ as one (different runtime semantics.) Use with caution.
	* |input| can be either ASCII or UTF-8 encoded source code.
	* Returns false if QuickJS was built with -DQJS_DISABLE_PARSER.
	*/
	DetectModule :: proc(input: cstring, input_len: c.size_t) -> bool ---

	/* 'input' must be zero terminated i.e. input[input_len] = '\0'. */
	Eval                      :: proc(ctx: ^JSContext, input: cstring, input_len: c.size_t, filename: cstring, eval_flags: i32) -> JSValue ---
	Eval2                     :: proc(ctx: ^JSContext, input: cstring, input_len: c.size_t, options: ^JSEvalOptions) -> JSValue ---
	EvalThis                  :: proc(ctx: ^JSContext, this_obj: JSValue, input: cstring, input_len: c.size_t, filename: cstring, eval_flags: i32) -> JSValue ---
	EvalThis2                 :: proc(ctx: ^JSContext, this_obj: JSValue, input: cstring, input_len: c.size_t, options: ^JSEvalOptions) -> JSValue ---
	GetGlobalObject           :: proc(ctx: ^JSContext) -> JSValue ---
	IsInstanceOf              :: proc(ctx: ^JSContext, val: JSValue, obj: JSValue) -> i32 ---
	DefineProperty            :: proc(ctx: ^JSContext, this_obj: JSValue, prop: JSAtom, val: JSValue, getter: JSValue, setter: JSValue, flags: i32) -> i32 ---
	DefinePropertyValue       :: proc(ctx: ^JSContext, this_obj: JSValue, prop: JSAtom, val: JSValue, flags: i32) -> i32 ---
	DefinePropertyValueUint32 :: proc(ctx: ^JSContext, this_obj: JSValue, idx: u32, val: JSValue, flags: i32) -> i32 ---
	DefinePropertyValueStr    :: proc(ctx: ^JSContext, this_obj: JSValue, prop: cstring, val: JSValue, flags: i32) -> i32 ---
	DefinePropertyGetSet      :: proc(ctx: ^JSContext, this_obj: JSValue, prop: JSAtom, getter: JSValue, setter: JSValue, flags: i32) -> i32 ---

	/* Only supported for custom classes, returns 0 on success < 0 otherwise. */
	SetOpaque    :: proc(obj: JSValue, opaque: rawptr) -> i32 ---
	GetOpaque    :: proc(obj: JSValue, class_id: JSClassID) -> rawptr ---
	GetOpaque2   :: proc(ctx: ^JSContext, obj: JSValue, class_id: JSClassID) -> rawptr ---
	GetAnyOpaque :: proc(obj: JSValue, class_id: ^JSClassID) -> rawptr ---

	/* 'buf' must be zero terminated i.e. buf[buf_len] = '\0'. */
	ParseJSON     :: proc(ctx: ^JSContext, buf: cstring, buf_len: c.size_t, filename: cstring) -> JSValue ---
	JSONStringify :: proc(ctx: ^JSContext, obj: JSValue, replacer: JSValue, space0: JSValue) -> JSValue ---
}

JSFreeArrayBufferDataFunc :: proc "c" (rt: ^JSRuntime, opaque: rawptr, ptr: rawptr)

@(default_calling_convention="c", link_prefix="JS_")
foreign lib {
	NewArrayBuffer     :: proc(ctx: ^JSContext, buf: ^u8, len: c.size_t, free_func: JSFreeArrayBufferDataFunc, opaque: rawptr, is_shared: bool) -> JSValue ---
	NewArrayBufferCopy :: proc(ctx: ^JSContext, buf: ^u8, len: c.size_t) -> JSValue ---
	DetachArrayBuffer  :: proc(ctx: ^JSContext, obj: JSValue) ---
	GetArrayBuffer     :: proc(ctx: ^JSContext, psize: ^c.size_t, obj: JSValue) -> ^u8 ---
	IsArrayBuffer      :: proc(obj: JSValue) -> bool ---

	// returns true or false if obj is an ArrayBuffer, -1 otherwise
	IsImmutableArrayBuffer :: proc(obj: JSValue) -> i32 ---

	// returns 0 if obj is an ArrayBuffer, -1 otherwise
	SetImmutableArrayBuffer :: proc(obj: JSValue, immutable: bool) -> i32 ---
	GetUint8Array           :: proc(ctx: ^JSContext, psize: ^c.size_t, obj: JSValue) -> ^u8 ---
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

@(default_calling_convention="c", link_prefix="JS_")
foreign lib {
	NewTypedArray       :: proc(ctx: ^JSContext, argc: i32, argv: ^JSValue, array_type: JSTypedArrayEnum) -> JSValue ---
	GetTypedArrayBuffer :: proc(ctx: ^JSContext, obj: JSValue, pbyte_offset: ^c.size_t, pbyte_length: ^c.size_t, pbytes_per_element: ^c.size_t) -> JSValue ---
	NewUint8Array       :: proc(ctx: ^JSContext, buf: ^u8, len: c.size_t, free_func: JSFreeArrayBufferDataFunc, opaque: rawptr, is_shared: bool) -> JSValue ---

	/* returns -1 if not a typed array otherwise return a JSTypedArrayEnum value */
	GetTypedArrayType :: proc(obj: JSValue) -> i32 ---
	NewUint8ArrayCopy :: proc(ctx: ^JSContext, buf: ^u8, len: c.size_t) -> JSValue ---
}

JSSharedArrayBufferFunctions :: struct {
	sab_alloc:  proc "c" (opaque: rawptr, size: c.size_t) -> rawptr,
	sab_free:   proc "c" (opaque: rawptr, ptr: rawptr),
	sab_dup:    proc "c" (opaque: rawptr, ptr: rawptr),
	sab_opaque: rawptr,
}

@(default_calling_convention="c", link_prefix="JS_")
foreign lib {
	SetSharedArrayBufferFunctions :: proc(rt: ^JSRuntime, sf: ^JSSharedArrayBufferFunctions) ---
}

JSPromiseStateEnum :: enum i32 {
	// argument to JS_PromiseState() was not in fact a promise
	NOT_A_PROMISE = -1,
	PENDING       = 0,
	FULFILLED     = 1,
	REJECTED      = 2,
}

@(default_calling_convention="c", link_prefix="JS_")
foreign lib {
	NewPromiseCapability :: proc(ctx: ^JSContext, resolving_funcs: ^JSValue) -> JSValue ---
	PromiseState         :: proc(ctx: ^JSContext, promise: JSValue) -> JSPromiseStateEnum ---
	PromiseResult        :: proc(ctx: ^JSContext, promise: JSValue) -> JSValue ---
	IsPromise            :: proc(val: JSValue) -> bool ---
	NewSettledPromise    :: proc(ctx: ^JSContext, is_reject: bool, value: JSValue) -> JSValue ---
	NewSymbol            :: proc(ctx: ^JSContext, description: cstring, is_global: bool) -> JSValue ---
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

@(default_calling_convention="c", link_prefix="JS_")
foreign lib {
	SetPromiseHook :: proc(rt: ^JSRuntime, promise_hook: JSPromiseHook, opaque: rawptr) ---
}

/* is_handled = true means that the rejection is handled */
JSHostPromiseRejectionTracker :: proc "c" (ctx: ^JSContext, promise: JSValue, reason: JSValue, is_handled: bool, opaque: rawptr)

@(default_calling_convention="c", link_prefix="JS_")
foreign lib {
	SetHostPromiseRejectionTracker :: proc(rt: ^JSRuntime, cb: JSHostPromiseRejectionTracker, opaque: rawptr) ---
}

/* return != 0 if the JS code needs to be interrupted */
JSInterruptHandler :: proc "c" (rt: ^JSRuntime, opaque: rawptr) -> i32

@(default_calling_convention="c", link_prefix="JS_")
foreign lib {
	SetInterruptHandler :: proc(rt: ^JSRuntime, cb: JSInterruptHandler, opaque: rawptr) ---

	/* if can_block is true, Atomics.wait() can be used */
	SetCanBlock :: proc(rt: ^JSRuntime, can_block: bool) ---

	/* set the [IsHTMLDDA] internal slot */
	SetIsHTMLDDA :: proc(ctx: ^JSContext, obj: JSValue) ---
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

@(default_calling_convention="c", link_prefix="JS_")
foreign lib {
	/* module_normalize = NULL is allowed and invokes the default module
	filename normalizer */
	SetModuleLoaderFunc :: proc(rt: ^JSRuntime, module_normalize: JSModuleNormalizeFunc, module_loader: JSModuleLoaderFunc, opaque: rawptr) ---

	/* same as JS_SetModuleLoaderFunc but with import attributes support */
	SetModuleLoaderFunc2 :: proc(rt: ^JSRuntime, module_normalize: JSModuleNormalizeFunc, module_loader: JSModuleLoaderFunc2, module_check_attrs: JSModuleCheckSupportedImportAttributes, opaque: rawptr) ---

	/* Set an attributes-aware module normalizer. Call after JS_SetModuleLoaderFunc2. */
	SetModuleNormalizeFunc2 :: proc(rt: ^JSRuntime, module_normalize: JSModuleNormalizeFunc2) ---

	/* return the import.meta object of a module */
	GetImportMeta      :: proc(ctx: ^JSContext, m: ^JSModuleDef) -> JSValue ---
	GetModuleName      :: proc(ctx: ^JSContext, m: ^JSModuleDef) -> JSAtom ---
	GetModuleNamespace :: proc(ctx: ^JSContext, m: ^JSModuleDef) -> JSValue ---

	/* associate a JSValue to a C module */
	SetModulePrivateValue :: proc(ctx: ^JSContext, m: ^JSModuleDef, val: JSValue) -> i32 ---
	GetModulePrivateValue :: proc(ctx: ^JSContext, m: ^JSModuleDef) -> JSValue ---
}

/* JS Job support */
JSJobFunc :: proc "c" (ctx: ^JSContext, argc: i32, argv: ^JSValue) -> JSValue

@(default_calling_convention="c", link_prefix="JS_")
foreign lib {
	EnqueueJob           :: proc(ctx: ^JSContext, job_func: JSJobFunc, argc: i32, argv: ^JSValue) -> i32 ---
	IsJobPending         :: proc(rt: ^JSRuntime) -> bool ---
	GetPendingJobContext :: proc(rt: ^JSRuntime) -> ^JSContext ---
	ExecutePendingJob    :: proc(rt: ^JSRuntime, pctx: ^^JSContext) -> i32 ---
}

/* Structure to retrieve (de)serialized SharedArrayBuffer objects. */
JSSABTab :: struct {
	tab: ^^u8,
	len: c.size_t,
}

/* Object Writer/Reader (currently only used to handle precompiled code) */
WRITE_OBJ_BYTECODE     :: (1<<0)  /* allow function/module */
WRITE_OBJ_BSWAP        :: (0)      /* byte swapped output (obsolete, handled transparently) */
WRITE_OBJ_SAB          :: (1<<2)  /* allow SharedArrayBuffer */
WRITE_OBJ_REFERENCE    :: (1<<3)  /* allow object references to encode arbitrary object graph */
WRITE_OBJ_STRIP_SOURCE  :: (1<<4) /* do not write source code information */
WRITE_OBJ_STRIP_DEBUG   :: (1<<5) /* do not write debug information */

@(default_calling_convention="c", link_prefix="JS_")
foreign lib {
	WriteObject  :: proc(ctx: ^JSContext, psize: ^c.size_t, obj: JSValue, flags: i32) -> ^u8 ---
	WriteObject2 :: proc(ctx: ^JSContext, psize: ^c.size_t, obj: JSValue, flags: i32, psab_tab: ^JSSABTab) -> ^u8 ---
}

/* WARNING: only enable JS_READ_OBJ_BYTECODE on input from a trusted
writer. The bytecode format is not designed to resist a hostile
producer; loading adversarial bytecode can lead to memory corruption. */
READ_OBJ_BYTECODE  :: (1<<0) /* allow function/module */
READ_OBJ_ROM_DATA  :: (0)      /* avoid duplicating 'buf' data (obsolete, broken by ICs) */

/* WARNING: serialized SharedArrayBuffers carry a literal host pointer in
the blob; only enable JS_READ_OBJ_SAB on input produced by a trusted
writer in the same process (e.g. another Worker on the same runtime). */
READ_OBJ_SAB       :: (1<<2) /* allow SharedArrayBuffer */
READ_OBJ_REFERENCE :: (1<<3) /* allow object references */

@(default_calling_convention="c", link_prefix="JS_")
foreign lib {
	ReadObject  :: proc(ctx: ^JSContext, buf: ^u8, buf_len: c.size_t, flags: i32) -> JSValue ---
	ReadObject2 :: proc(ctx: ^JSContext, buf: ^u8, buf_len: c.size_t, flags: i32, psab_tab: ^JSSABTab) -> JSValue ---

	/* instantiate and evaluate a bytecode function. Only used when
	reading a script or module with JS_ReadObject() */
	EvalFunction :: proc(ctx: ^JSContext, fun_obj: JSValue) -> JSValue ---

	/* load the dependencies of the module 'obj'. Useful when JS_ReadObject()
	returns a module. */
	ResolveModule :: proc(ctx: ^JSContext, obj: JSValue) -> i32 ---

	/* only exported for os.Worker() */
	GetScriptOrModuleName :: proc(ctx: ^JSContext, n_stack_levels: i32) -> JSAtom ---

	/* only exported for os.Worker() */
	LoadModule :: proc(ctx: ^JSContext, basename: cstring, filename: cstring) -> JSValue ---
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

@(default_calling_convention="c", link_prefix="JS_")
foreign lib {
	NewCFunction2     :: proc(ctx: ^JSContext, func: JSCFunction, name: cstring, length: i32, cproto: JSCFunctionEnum, magic: i32) -> JSValue ---
	NewCFunction3     :: proc(ctx: ^JSContext, func: JSCFunction, name: cstring, length: i32, cproto: JSCFunctionEnum, magic: i32, proto_val: JSValue, n_fields: i32) -> JSValue ---
	NewCFunctionData  :: proc(ctx: ^JSContext, func: JSCFunctionData, length: i32, magic: i32, data_len: i32, data: ^JSValue) -> JSValue ---
	NewCFunctionData2 :: proc(ctx: ^JSContext, func: JSCFunctionData, name: cstring, length: i32, magic: i32, data_len: i32, data: ^JSValue) -> JSValue ---
}

JSCClosureFinalizerFunc :: proc "c" (rawptr)

@(default_calling_convention="c", link_prefix="JS_")
foreign lib {
	NewCClosure    :: proc(ctx: ^JSContext, func: JSCClosure, name: cstring, opaque_finalize: JSCClosureFinalizerFunc, length: i32, magic: i32, opaque: rawptr) -> JSValue ---
	SetConstructor :: proc(ctx: ^JSContext, func_obj: JSValue, proto: JSValue) -> i32 ---
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

DEF_CFUNC          :: 0
DEF_CGETSET        :: 1
DEF_CGETSET_MAGIC  :: 2
DEF_PROP_STRING    :: 3
DEF_PROP_INT32     :: 4
DEF_PROP_INT64     :: 5
DEF_PROP_DOUBLE    :: 6
DEF_PROP_UNDEFINED :: 7
DEF_OBJECT         :: 8
DEF_ALIAS          :: 9
DEF_PROP_SYMBOL    :: 10
DEF_PROP_BOOL      :: 11

@(default_calling_convention="c", link_prefix="JS_")
foreign lib {
	SetPropertyFunctionList :: proc(ctx: ^JSContext, obj: JSValue, tab: ^JSCFunctionListEntry, len: i32) -> i32 ---
}

/* C module definition */
JSModuleInitFunc :: proc "c" (ctx: ^JSContext, m: ^JSModuleDef) -> i32

@(default_calling_convention="c", link_prefix="JS_")
foreign lib {
	NewCModule :: proc(ctx: ^JSContext, name_str: cstring, func: JSModuleInitFunc) -> ^JSModuleDef ---

	/* can only be called before the module is instantiated */
	AddModuleExport     :: proc(ctx: ^JSContext, m: ^JSModuleDef, name_str: cstring) -> i32 ---
	AddModuleExportList :: proc(ctx: ^JSContext, m: ^JSModuleDef, tab: ^JSCFunctionListEntry, len: i32) -> i32 ---

	/* can only be called after the module is instantiated */
	SetModuleExport     :: proc(ctx: ^JSContext, m: ^JSModuleDef, export_name: cstring, val: JSValue) -> i32 ---
	SetModuleExportList :: proc(ctx: ^JSContext, m: ^JSModuleDef, tab: ^JSCFunctionListEntry, len: i32) -> i32 ---
}

/* Version */
QJS_VERSION_MAJOR  :: 0
QJS_VERSION_MINOR  :: 15
QJS_VERSION_PATCH  :: 0
QJS_VERSION_SUFFIX :: ""

@(default_calling_convention="c", link_prefix="JS_")
foreign lib {
	GetVersion :: proc() -> cstring ---

	/* Integration point for quickjs-libc.c, not for public use. */
	js_std_cmd :: proc(cmd: i32, #c_vararg _: ..any) -> c.uintptr_t ---
}

