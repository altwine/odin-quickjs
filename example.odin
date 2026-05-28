package example

import "base:runtime"
import "core:fmt"

import qjs "odin-quickjs"

send_message :: proc "c" (ctx: ^qjs.JSContext, this_val: qjs.JSValue, argc: i32, argv: ^qjs.JSValue) -> qjs.JSValue {
	context = runtime.default_context()
	fmt.printfln("%s", js_value_to_string(ctx, argv^))
	return { tag=qjs.TAG_UNDEFINED }
}

main :: proc() {
	runtime := qjs.NewRuntime()
	if runtime == nil {
		fmt.printfln("err1")
		return
	}
	defer qjs.FreeRuntime(runtime)

	js_ctx := qjs.NewContext(runtime)
	if js_ctx == nil {
		fmt.printfln("err2")
		return
	}
	defer qjs.FreeContext(js_ctx)

	get_message_cfunc := qjs.NewCFunction2(js_ctx, send_message, "sendMessage", 0, qjs.JSCFunctionEnum.generic, 0)
	defer qjs.FreeValue(js_ctx, get_message_cfunc)

	global := qjs.GetGlobalObject(js_ctx)
	defer qjs.FreeValue(js_ctx, global)

	qjs.SetPropertyStr(js_ctx, global, "sendMessage", get_message_cfunc)

	TO_EVAL :: `sendMessage("Hi from JS!");`
	js_value := qjs.Eval(js_ctx, TO_EVAL, len(TO_EVAL), "test.js", qjs.EVAL_TYPE_GLOBAL)
	defer qjs.FreeValue(js_ctx, js_value)

	memory_usage := qjs.JSMemoryUsage{}
	qjs.ComputeMemoryUsage(runtime, &memory_usage)
	fmt.printfln("Memory usage report: %v", memory_usage)
}

js_value_to_string :: proc(js_ctx: ^qjs.JSContext, js_value: qjs.JSValue) -> string {
	switch js_value.tag {
	case qjs.TAG_INT:
		return fmt.tprint(js_value.u.int32)

	case qjs.TAG_FLOAT64:
		return fmt.tprint(js_value.u.float64)

	case qjs.TAG_STRING:
		str := qjs.ToCStringLen2(js_ctx, nil, js_value, false)
		defer qjs.FreeCString(js_ctx, str)
		return string(str)

	case qjs.TAG_EXCEPTION:
		exc := qjs.GetException(js_ctx)
		defer qjs.FreeValue(js_ctx, exc)
		str := qjs.ToCStringLen2(js_ctx, nil, exc, false)
		defer qjs.FreeCString(js_ctx, str)
		return string(str)
	}

	return "smth else idk"
}
