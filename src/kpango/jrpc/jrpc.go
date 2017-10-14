package jrpc

import (
	"fmt"
	"reflect"
	"sort"
	"strings"
)

func ServiceGenerator(pkg, name, rpcs, messages string) string {
	if isEmpty(pkg) || isEmpty(name) || isEmpty(rpcs) || isEmpty(messages) {
		return "syntax - \"proto3\";\n"
	}
	if strings.Contains(rpcs, "Empty") {
		return strings.Replace(fmt.Sprintf("syntax = \"proto3\";\n\npackage %s;\n\n\noption optimize_for = SPEED;\n\nservice %s {\n%s\n}\n\nmessage Empty {}\n\n%s", pkg, toUpperCamel(name), rpcs, messages), "\n\n", "\n", -1)
	}
	return strings.Replace(fmt.Sprintf("syntax = \"proto3\";\n\npackage %s;\n\n\noption optimize_for = SPEED;\n\nservice %s {\n%s\n}\n\n%s", pkg, toUpperCamel(name), rpcs, messages), "\n\n", "\n", -1)
}

func RPCGenerator(name, arg, res string, streamFlg1, streamFlg2 bool) string {

	if isEmpty(name) {
		return ""
	}

	if isEmpty(arg) {
		arg = "Empty"
	} else if streamFlg1 {
		arg = "stream " + toUpperCamel(arg)
	} else {
		arg = toUpperCamel(arg)
	}

	if isEmpty(res) {
		res = "Empty"
	} else if streamFlg2 {
		res = "stream " + toUpperCamel(res)
	} else {
		res = toUpperCamel(res)
	}

	return fmt.Sprintf("\t rpc %s (%s) returns (%s);\n", toUpperCamel(name), arg, res)
}

func MessageGenerator(reqName, resName string, reqBody, resBody map[string]interface{}) string {

	var req, res string

	if isEmpty(reqName) {
		req = Parse(reqName, reqBody)
	}

	if isEmpty(resName) {
		res = Parse(resName, resBody)
	}

	return fmt.Sprintf("%s\n%s", req, res)
}

func Parse(name string, data map[string]interface{}) string {
	if isEmpty(name) {
		return ""
	}

	n := toUpperCamel(name)

	return fmt.Sprintf("%s}\n", parse(fmt.Sprintf("message %s {\n", n), "\t", n, data))
}

func parse(str, ident, name string, data map[string]interface{}) string {
	val := reflect.ValueOf(data)

	if val.IsNil() || !val.IsValid() {
		return str
	}

	if val.Kind() == reflect.Map {
		var fields []string
		var repFields []string
		for k, v := range data {
			vr := reflect.ValueOf(v)
			switch vr.Kind() {
			case reflect.Map:
				n := name + toUpperCamel(k)
				fields = append(fields, fmt.Sprintf("%s%s %s = ", ident, n, k))
				str = Parse(n, v.(map[string]interface{})) + "\n\n" + str
			case reflect.String:
				if !isEmpty(k) {
					fields = append(fields, fmt.Sprintf("%sstring %s = ", ident, k))
				}
			case reflect.Int, reflect.Int8, reflect.Int16, reflect.Int32:
				fields = append(fields, fmt.Sprintf("%sint32 %s = ", ident, k))
			case reflect.Int64:
				fields = append(fields, fmt.Sprintf("%sint64 %s = ", ident, k))
			case reflect.Uint, reflect.Uint8, reflect.Uint16, reflect.Uint32:
				fields = append(fields, fmt.Sprintf("%suint32 %s = ", ident, k))
			case reflect.Uint64:
				fields = append(fields, fmt.Sprintf("%suint64 %s = ", ident, k))
			case reflect.Float32:
				fields = append(fields, fmt.Sprintf("%sfloat %s = ", ident, k))
			case reflect.Float64:
				fields = append(fields, fmt.Sprintf("%sdouble %s = ", ident, k))
			case reflect.Bool:
				fields = append(fields, fmt.Sprintf("%sbool %s = ", ident, k))
			case reflect.Array, reflect.Slice:
				switch reflect.ValueOf(vr.Index(0).Interface()).Kind() {
				case reflect.Map:
					n := name + toUpperCamel(k)
					repFields = append(repFields, fmt.Sprintf("%srepeated %s %s = ", ident, n, k))
					str = Parse(n, vr.Index(0).Interface().(map[string]interface{})) + "\n\n" + str
				case reflect.String:
					repFields = append(repFields, fmt.Sprintf("%srepeated string %s = ", ident, k))
				case reflect.Int, reflect.Int8, reflect.Int16, reflect.Int32, reflect.Int64:
					repFields = append(repFields, fmt.Sprintf("%srepeated int32 %s = ", ident, k))
				case reflect.Uint, reflect.Uint8, reflect.Uint16, reflect.Uint32, reflect.Uint64:
					repFields = append(repFields, fmt.Sprintf("%srepeated uint32 %s = ", ident, k))
				case reflect.Float64, reflect.Float32:
					repFields = append(repFields, fmt.Sprintf("%srepeated double %s = ", ident, k))
				}
			}
		}

		sort.Strings(fields)
		sort.Strings(repFields)

		fields = append(fields, repFields...)
		for i, v := range fields {
			str += fmt.Sprintf("%s%d;\n", v, i+1)
		}
	}

	return str
}

func toUpperCamel(name string) string {
	if len(name) < 2 {
		return strings.ToUpper(name)
	}

	strs := strings.Split(strings.Replace(name, "-", "_", -1), "_")
	var str string

	for _, v := range strs {
		if len(v) < 2 {
			str += strings.ToUpper(v[:1])
		} else {
			str += strings.ToUpper(v[:1]) + v[1:]
		}
	}

	return strings.ToUpper(str[:1]) + str[1:]
}

func isEmpty(str string) bool {
	return len(str) != 0 || str != ""
}
