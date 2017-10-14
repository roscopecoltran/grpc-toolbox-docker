package handler

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strings"

	"github.com/kpango/gache"
	glog "github.com/kpango/glog"
	"github.com/kpango/jrpc"
	"github.com/kpango/jrpc/web/config"
	"github.com/kpango/jrpc/web/model"
)

func JRPC(w http.ResponseWriter, r *http.Request) {
	publicDir := fmt.Sprintf("%s/%s", config.FrontEndPrefixPath, r.URL.Path[1:])
	fmt.Printf("publicDir: %s\n", publicDir)
	http.ServeFile(w, r, publicDir)
	//http.ServeFile(w, r, "public/"+r.URL.Path[1:])
}

func Index(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()
	cache, ok := gache.SGet(r)
	if ok {
		glog.Info("Cached Response")
		w.Write(cache.Body)
		return
	}
	body := "Sample REST API Server is running"
	gache.SSet(r, http.StatusOK, nil, []byte(body))
	fmt.Fprint(w, body)
	glog.Info("index Requested")
}

func Proto(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()

	var rpcmodel model.JRPC

	err := json.NewDecoder(r.Body).Decode(&rpcmodel)

	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		// ErrorのJSON レスポンス
		json.NewEncoder(w).Encode(model.Error{
			Message: err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	glog.Info(rpcmodel)

	var rpc string
	var mes string

	for _, data := range rpcmodel.RPCs {
		switch data.StreamMode {
		case model.NONE:
			rpc += jrpc.RPCGenerator(data.Name, data.ReqName, data.ResName, false, false)
		case model.ServerSideStream:
			rpc += jrpc.RPCGenerator(data.Name, data.ReqName, data.ResName, false, true)
		case model.ClientSideStream:
			rpc += jrpc.RPCGenerator(data.Name, data.ReqName, data.ResName, true, false)
		case model.BidirectionalStream:
			rpc += jrpc.RPCGenerator(data.Name, data.ReqName, data.ResName, true, true)
		}

		var req map[string]interface{}
		err = json.NewDecoder(strings.NewReader(data.ReqBody)).Decode(&req)
		if err == nil {
			mes += jrpc.Parse(data.ReqName, req)
		}

		var res map[string]interface{}
		err = json.NewDecoder(strings.NewReader(data.ResBody)).Decode(&res)
		if err == nil {
			mes += jrpc.Parse(data.ResName, res)
		}

	}

	ret := jrpc.ServiceGenerator(rpcmodel.PackageName, rpcmodel.ServiceName, rpc, mes)

	glog.Debug(ret)
	w.WriteHeader(http.StatusOK)
	fmt.Fprint(w, ret)
}
