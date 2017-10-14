package config

import (
	"errors"
	"time"
)

const (
	//Serverのポート
	ServerPort = ":8080"

	//ログ関連の設定
	LogFilePath = "/tmp/api.log"
	LogPerm     = 0755

	// HTTPリクエストのタイムアウト
	HTTPRequestTimeout = time.Second * 3
	TimeFormatRFC2822  = "Mon, 02 Jan 2006 15:04:05 -0700"

	//リダイレクト時の最大トライ回数
	RedirectCount = 10

	//cacheの有効期限
	CacheExpire = time.Minute * 5
)

var (
	ErrInvalidHost             = errors.New("無効なHostのためリクエストに失敗しました")
	ErrInvalidURL              = errors.New("無効なURLのためリクエストに失敗しました")
	ErrInvalidRedirectLocation = errors.New("無効なリダイレクト先が指定されました")
	ErrTooManyRedirection      = errors.New("リダイレクト回数が多すぎます")

	ErrSystem       = "sysmte_error"
	ErrMsgSystem    = "一時的にアプリケーションがご利用できません。しばらく時間をおいてから再度お試しください"
	ErrInvalidParam = "invalid_parameter"
	ErrMsgParam     = "リクエストパラメータ'%s'に誤りがあります"
)
