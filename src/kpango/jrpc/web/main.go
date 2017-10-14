package main

import (
	"context"
	"net/http"
	_ "net/http/pprof"
	"os"
	"os/signal"
	"runtime"
	"syscall"
	"time"

	glog "github.com/kpango/glog"
	"github.com/kpango/gouter"
	"github.com/kpango/jrpc/web/config"
	"github.com/kpango/jrpc/web/handler"
	"github.com/pkg/profile"
)

func main() {
	defer profile.Start().Stop()

	runtime.GOMAXPROCS(runtime.NumCPU())

	defer func() {
		if err := recover(); err != nil {
			if _, ok := err.(runtime.Error); ok {
				panic(err)
			}
			glog.Println(err.(error))
		}
	}()

	srv := &http.Server{
		Addr: config.ServerPort,
		Handler: gouter.New().
			AddRoute("index", "/index", http.MethodGet, handler.Index).
			AddRoute("proto", "/proto", http.MethodPost, handler.Proto).
			AddRoute("static", "/", http.MethodGet, handler.JRPC).
			GetRouter(),
	}

	go func() {
		glog.Info("start http server")
		if err := srv.ListenAndServe(); err != nil {
			glog.Error(err)
		}
	}()

	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, syscall.SIGTERM)

	// wait terminate signal
	<-sigCh

	ctx, _ := context.WithTimeout(context.Background(), 5*time.Second)
	glog.Info("server shutdown")

	if err := srv.Shutdown(ctx); err != nil {
		glog.Error(err)
	}
}
