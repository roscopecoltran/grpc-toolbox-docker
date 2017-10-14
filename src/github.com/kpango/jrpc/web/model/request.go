package model

const (
	_                   = iota
	NONE                //Simple-RPC
	ServerSideStream    //ServerSideStreaming-RPC
	ClientSideStream    //ClientSideStreaming-RPC
	BidirectionalStream //BidirectionalStreaming-RPC
)

type JRPC struct {
	PackageName string `json:"package_name"`
	ServiceName string `json:"service_name"`
	RPCs        []RPC  `json:"rpcs"`
}

type RPC struct {
	Name       string `json:"name"`
	StreamMode int    `json:"stream_mode"`
	ReqName    string `json:"req_name"`
	ResName    string `json:"res_name"`
	ReqBody    string `json:"req_body"`
	ResBody    string `json:"res_body"`
}
