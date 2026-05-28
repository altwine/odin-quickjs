package odin_quickjs

import "base:runtime"
import "core:fmt"

send_message :: proc "c" (ctx: ^JSContext, this_val: JSValue, argc: i32, argv: ^JSValue) -> JSValue {
	context = runtime.default_context()
	fmt.printfln("%s", js_value_to_string(ctx, argv^))
	return { tag=TAG_UNDEFINED }
}

main :: proc() {
	runtime := NewRuntime()
	if runtime == nil {
		fmt.printfln("err1")
		return
	}
	defer FreeRuntime(runtime)

	js_ctx := NewContext(runtime)
	if js_ctx == nil {
		fmt.printfln("err2")
		return
	}
	defer FreeContext(js_ctx)

	get_message_cfunc := NewCFunction2(js_ctx, send_message, "sendMessage", 0, JSCFunctionEnum.generic, 0)
	defer FreeValue(js_ctx, get_message_cfunc)

	global := GetGlobalObject(js_ctx)
	defer FreeValue(js_ctx, global)

	SetPropertyStr(js_ctx, global, "sendMessage", get_message_cfunc)

	TO_EVAL :: `sendMessage("Hi from JS!");`
	js_value := Eval(js_ctx, TO_EVAL, len(TO_EVAL), "test.js", EVAL_TYPE_GLOBAL)
	defer FreeValue(js_ctx, js_value)
}

js_value_to_string :: proc(js_ctx: ^JSContext, js_value: JSValue) -> string {
	switch js_value.tag {
	case TAG_INT:
		return fmt.tprint(js_value.u.int32)

	case TAG_FLOAT64:
		return fmt.tprint(js_value.u.float64)

	case TAG_STRING:
		str := ToCStringLen2(js_ctx, nil, js_value, false)
		defer FreeCString(js_ctx, str)
		return string(str)

	case TAG_EXCEPTION:
		exc := GetException(js_ctx)
		defer FreeValue(js_ctx, exc)
		str := ToCStringLen2(js_ctx, nil, exc, false)
		defer FreeCString(js_ctx, str)
		return string(str)
	}

	return "smth else idk"
}
