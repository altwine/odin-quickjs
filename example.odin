package odin_quickjs

import "core:fmt"

main :: proc() {
	runtime := JS_NewRuntime()
	if runtime == nil {
		fmt.printfln("err1")
		return
	}
	defer JS_FreeRuntime(runtime);

	js_ctx := JS_NewContext(runtime)
	if js_ctx == nil {
		fmt.printfln("err2")
		return
	}
	defer JS_FreeContext(js_ctx)

	TO_EVAL :: `const hi = "test"+123; hi; /* Should return "test123" */`
	js_value := JS_Eval(js_ctx, TO_EVAL, len(TO_EVAL), "test.js", JS_EVAL_TYPE_GLOBAL)
	defer JS_FreeValue(js_ctx, js_value)

	fmt.printfln("got '%s'!", js_value_to_string(js_ctx, js_value))
}

js_value_to_string :: proc(js_ctx: ^JSContext, js_value: JSValue) -> string {
    switch js_value.tag {
    case JS_TAG_INT:
        return fmt.tprint(js_value.u.int32)

    case JS_TAG_FLOAT64:
        return fmt.tprint(js_value.u.float64)

    case JS_TAG_STRING:
        str := JS_ToCStringLen2(js_ctx, nil, js_value, false)
        defer JS_FreeCString(js_ctx, str)
        return string(str)

    case JS_TAG_EXCEPTION:
        fmt.println("JS Exception occurred")
        exc := JS_GetException(js_ctx)
        defer JS_FreeValue(js_ctx, exc)
        str := JS_ToCStringLen2(js_ctx, nil, exc, false)
        defer JS_FreeCString(js_ctx, str)
        return string(str)
    }

    return "smth else idk"
}
